//
//  LanguageValueController.swift
//  LocalizedCSV
//
//  Created by 张行 on 2017/8/18.
//  Copyright © 2017年 张行. All rights reserved.
//

import Cocoa

class LanguageValueController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var item:CSVItem?
    var keys:[String] = []
    var verifyCount = 0

    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.item?.name
        guard let item = self.item else {
            return
        }
        for c in item.list.enumerated() {
            print("->>:\(c.element.key)\n->>:\(c.element.value)\n\n")
        }
        keys.append(contentsOf: LocalizeStringKit.shareManager().localizeDictionary.keys)
        self.tableView.reloadData()
    }
    
    @IBAction func save(_ sender: Any) {
        let openPannel = NSOpenPanel()
        openPannel.canChooseFiles = false
        openPannel.canChooseDirectories = true
        guard openPannel.runModal() == NSFileHandlingPanelOKButton else {
            return
        }
        guard let path = openPannel.urls.first?.absoluteString.replacingOccurrences(of: "file://", with: "") else {
            return
        }
        var content = ""
        guard let item = self.item else {
            return
        }
        for c in keys.enumerated() {
            let key = keys[c.offset]
            guard var value = item.list[key] else {
                continue
            }
            guard value.characters.count > 0 else {
                continue
            }
            guard key.specialEqual(source: value) else {
                continue
            }
            guard !value.containChineseChar() else {
                continue
            }
            value = value.replacingOccurrences(of: "\"", with: "'")
            var append = "\"\(key)\" = \"\(value)\";\n"
            append = append.replacingOccurrences(of: "\r", with: "")
            content += append
        }
        content = content.replacingOccurrences(of: "\\", with: "\\\\")
        try? content.write(toFile: "\(path)/Localizable.strings", atomically: true, encoding: String.Encoding.utf8)
    }
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        verifyCount = 0
        return keys.count
    }
    
    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let key = keys[row]
        guard let column = tableColumn, let cell = column.dataCell as? NSTextFieldCell else {
            return nil
        }
        cell.drawsBackground = true
        if column.title == "Key" {
            cell.backgroundColor = NSColor.darkGray
            return key
        } else if (column.title == "Value") {
            var value = findValue(key: key)
            if value == nil {
//                print("🆘查找不到的 key:->\(key)\n")
                verifyCount += 1
            }
//            if value!.containChineseChar() {
//                value = nil
//            }
            if !key.specialEqual(source: value) {
                cell.backgroundColor = NSColor.red
            } else {
                if let v = value, v.characters.count > 0 {
                    cell.backgroundColor = NSColor.green
                } else {
                    cell.backgroundColor = NSColor.yellow
                }
            }
            return value
        }
        return nil
    }
    
    public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard let value = object as? String else {
            return
        }
        let key = keys[row]
        item?.list[key] = value
        tableView.reloadData()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let controller = segue.destinationController as? LocalLanguagesViewController else {
            return
        }
        controller.normalLanguage = item?.name.replacingOccurrences(of: "\r", with: "")
        controller.didClickLanguageCompletionHandle = { language in
            guard let item = self.item else {
                return
            }
            LanguageSourceKit.saveLanguage(item: [item], language: language)
        }
    }
    
    func findValue(key:String) -> String? {
        if let value = self.item?.list[key] {
            return value
        }
        var fixKey = key.trimmingCharacters(in: CharacterSet.whitespaces)
        if let value = self.item?.list[fixKey] {
            return value
        }
        fixKey = fixKey.replacingOccurrences(of: "\\\"", with: "\\\"\"")
        if let value = self.item?.list[fixKey] {
            return value
        }
        return nil
    }

}
