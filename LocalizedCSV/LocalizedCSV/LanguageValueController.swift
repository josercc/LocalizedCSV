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
        guard let _ = self.item else {
            return
        }
        keys.append(contentsOf: LocalizeStringKit.shareManager().localizeDictionary.keys)
        self.tableView.reloadData()
    }
    
    @IBAction func save(_ sender: Any) {
        guard verifyCount == 0 else {
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = "保存之前必须翻译完所有字段"
            alert.runModal()
            return
        }
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
        for c in item.list.enumerated() {
            guard c.element.value.characters.count > 0 else {
                continue
            }
            content += "\"\(c.element.key)\" = \"\(c.element.value)\";\n"
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
            let value = self.item?.list[key]
            if value == nil {
                verifyCount += 1
            }
            cell.backgroundColor = value != nil ? NSColor.green : NSColor.red
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

}
