//
//  FindLocalizeStringController.swift
//  LocalizedCSV
//
//  Created by 张行 on 2017/8/19.
//  Copyright © 2017年 张行. All rights reserved.
//

import Cocoa

/* 查找工程存在的多语言 */
class FindLocalizeStringController: NSViewController, NSTableViewDataSource {
    /* 显示查找的状态 */
    @IBOutlet weak var stateLabel: NSTextField!
    /* 超找出来结果的表格 */
    @IBOutlet weak var tableView: NSTableView!
    /* 显示正在查找的路径地址 */
    @IBOutlet weak var filePathLabel: NSTextField!
    
    /* 显示超找的总数量 */
    @IBOutlet weak var countLabel: NSTextField!
    /* 查找管理器的单利对象 */
    let findKit:FindLocalizeStringKit = FindLocalizeStringKit.shareManager()
    /* 需要查找的路径 */
    var findPath:String?
    /* 查找出来的数据数组 */
    var keys:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* 如果路径不存在 结束查询 */
        guard let path  = findPath else {
            return
        }
        /* 开始查询 */
        self.stateLabel.stringValue = "正在查找..."
        /* 查找管理器查找完成的回调 */
        findKit.completionLog = {log in
            DispatchQueue.main.async {
                self.filePathLabel.stringValue = log
            }
        }
        /* 查找管理器查找一组最新的数据回调 */
        findKit.updateCompletion = { key, value in
            self.keys.append(key)
            self.tableView.reloadData()
            self.countLabel.stringValue = "\(self.keys.count)"
        }
        DispatchQueue.global().async {
            FindLocalizeStringKit.shareManager().findAllLocalizeString(path: path)
            DispatchQueue.main.async {
                self.stateLabel.stringValue = "✅查询完毕"
                if FindLocalizeStringKit.shareManager().exitSameKeyList.keys.count > 0 {
                    let alert = NSAlert()
                    var message = "以下Key 存在多个值可能造成程序运行问题\n"
                    for key in FindLocalizeStringKit.shareManager().exitSameKeyList {
                        message += "\n\n\n\(key.key) \n"
                        for text in key.value {
                            message += ":\(text)"
                        }
                    }
                    alert.messageText = message
                    alert.runModal()
                }
            }
        }
    }
    
    @IBAction func export(_ sender: Any) {
        let openPannel = NSOpenPanel()
        openPannel.canChooseFiles = false
        openPannel.canChooseDirectories = true
        guard openPannel.runModal().rawValue == NSFileHandlingPanelOKButton else {
            return
        }
        guard let path = openPannel.urls.first?.absoluteString.replacingOccurrences(of: "file://", with: "") else {
            return
        }
        var content = ""
        for c in FindLocalizeStringKit.shareManager().list.enumerated() {
            guard c.element.value.count > 0 else {
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
