//
//  FindLocalizeStringController.swift
//  LocalizedCSV
//
//  Created by 张行 on 2017/8/19.
//  Copyright © 2017年 张行. All rights reserved.
//

import Cocoa

class FindLocalizeStringController: NSViewController, NSTableViewDataSource {
    @IBOutlet weak var stateLabel: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var filePathLabel: NSTextField!
    
    @IBOutlet weak var countLabel: NSTextField!
    let findKit:FindLocalizeStringKit = FindLocalizeStringKit.shareManager()
    var findPath:String?
    var keys:[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let path  = findPath else {
            return
        }
        self.stateLabel.stringValue = "正在查找"
        findKit.completionLog = {log in
            self.filePathLabel.stringValue = log
        }
        findKit.updateCompletion = { key in
            self.keys.append(key)
            self.tableView.reloadData()
            self.countLabel.stringValue = "\(self.keys.count)"
        }
        DispatchQueue.global().async {
            FindLocalizeStringKit.shareManager().findAllLocalizeString(path: path)
            DispatchQueue.main.async {
                self.stateLabel.stringValue = "✅查询完毕"
            }
        }
    }
    
    @IBAction func export(_ sender: Any) {
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
        for c in FindLocalizeStringKit.shareManager().list.enumerated() {
            guard c.element.value.characters.count > 0 else {
                continue
            }
            content += "\"\(c.element.key)\" = \"\(c.element.value)\";\n"
        }
//        content = content.replacingOccurrences(of: "\\", with: "\\\\")
        try? content.write(toFile: "\(path)/Localizable.strings", atomically: true, encoding: String.Encoding.utf8)
        self.dismiss(nil)
    }
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return keys.count
    }
    
    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let co = tableColumn else {
            return nil
        }
        let key = keys[row]
        if co.title == "Key" {
            return key
        } else if co.title == "Value" {
            return FindLocalizeStringKit.shareManager().list[key]
        }
        return nil
    }
}
