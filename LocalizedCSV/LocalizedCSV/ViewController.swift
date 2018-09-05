//
//  ViewController.swift
//  LocalizedCSV
//
//  Created by 张行 on 2017/8/17.
//  Copyright © 2017年 张行. All rights reserved.
//

import Cocoa


class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var tableView: NSTableView! {
        didSet {
            /* 如果 TableView 已经初始化则 添加 Cell 双击事件 */
            self.tableView.target = self
            self.tableView.doubleAction = #selector(self.pushDetail)
        }
    }
    /* 是否可以刷新数据 */
    var canReadloadData = false
    /* 显示 CSV 的路径 */
    @IBOutlet weak var csvTextFiled: NSTextField!
    /* 显示基础语言文件路径 */
    @IBOutlet weak var localizeStringTextFiled: NSTextField!
    /* CSV 解析单利库 */
    let csvParse:CSVParseKit = CSVParseKit.shareManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func readCSVFile(_ sender: NSButton) {
        guard CheckConfigManager.checkConfigReadySuccess() else {
            return
        }
        /* 读取 CSV 文件并赋值到文本框里面 */
        self.csvTextFiled.stringValue = FileKit.getFile(fileType: "csv")
        /* 执行异步解析 */
        parse(parse: { 
            do {
                /* 尝试解析读取到的 CSV 文件 */
                try self.csvParse.parse(file: self.csvTextFiled.stringValue)
                /* 如果不报异常 则代表可以刷新表格 */
                self.canReadloadData = true
            } catch {
                /* 如果报异常则不能刷新表格 并提示用户 CSV 文件错误 */
                self.canReadloadData = false
                DispatchQueue.main.sync {
                    let alert = NSAlert()
                    alert.messageText = "CSV 文件错误"
                    alert.runModal()
                }
            }
        }) {
            /* 如果解析完毕 并且可以刷新表格就刷新表格 */
            if self.canReadloadData {
                self.tableView.reloadData()
            }
        }
    }
    
    func parse(parse:@escaping (() -> Void), completion:@escaping (() -> Void)) {
        DispatchQueue.global().async {
            parse()
            DispatchQueue.main.sync {
                completion()
            }
        }
    }
    
    @IBAction func readLocalizeStringFile(_ sender: NSButton) {
        guard CheckConfigManager.checkConfigReadySuccess() else {
            return
        }
        self.localizeStringTextFiled.stringValue = FileKit.getFile(fileType: "strings")
        try? LocalizeStringKit.shareManager().parse(filePath: self.localizeStringTextFiled.stringValue)
        var stringList = self.localizeStringTextFiled.stringValue.components(separatedBy: "/")
        stringList.removeLast()
        stringList.removeLast()
        SettingModel.shareSettingModel().projectRootPath = stringList.joined(separator: "/")
        print(SettingModel.shareSettingModel().projectRootPath!)
    }
    
    
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return csvParse.items.count
    }
    
    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let item  = csvParse.items[row]
        if let column = tableColumn, let cell = column.dataCell as? NSTextFieldCell {
            let color = NSColor.lightGray
            cell.backgroundColor = color
            cell.drawsBackground = true
        }
        return item.name
    }
    
    /// 跳转到语言详情
    func pushDetail() {
        guard self.localizeStringTextFiled.stringValue.count > 0 else {
            let alert = NSAlert()
            alert.messageText = "必须选择Strings文件"
            alert.alertStyle = .warning
            alert.runModal()
            return
        }
        guard tableView.selectedRow >= 0 else {
            return
        }
        guard let controller = self.storyboard?.instantiateController(withIdentifier: "LanguageValueController") as? LanguageValueController else {
            return
        }
        controller.item = csvParse.items[tableView.selectedRow]
        self.presentViewControllerAsModalWindow(controller)
    }
    
    /* 导出未添加的 Key
     拿着本地工程的所有 Key 对比多语言表格的 Key 如果不在多语言表格里面 则代表需要添加的
     */
    @IBAction func exportUnAdd(_ sender: Any) {
        guard CheckConfigManager.checkConfigReadySuccess() else {
            return
        }
        /* 获取全部的多语言配置列表 */
        let list = FindLocalizeStringKit.shareManager().list
        guard list.count > 0 else {
            /* 如果不存在就需要提取国际化 */
            let alert = NSAlert()
            alert.messageText = "导出失败 请先提取一次工程的国际化 cmd+optional+R";
            alert.runModal()
            return
        }
        /* 需要写入的文件字符串 */
        var exportString = "";
        /* 需要的 Key 字段 */
        var keyString = ""
        /* 需要的翻译的 Value 的字段 */
        var valueString = ""
        
        /* 遍历工程多语言的所有键 */
        for key in LocalizeStringKit.shareManager().localizeDictionary.keys {
            /* 去掉 Key 自动生成的字符 */
            let formatterKey = LCFormatterKey(key: key)
            /* 查找母文本的语言数据对象 */
            guard let item = self.csvParse.getLanguageItem(name: "母文本English") else {
                return
            }
            /* 如果当前的 Key 不在多语言表格的 Key 列表里面 */
            if !item.list.keys.contains(formatterKey) {
                let enValue = LocalizeStringKit.shareManager().localizeDictionary[key]
                /* 查找相似的 Key数组信息 */
                let similarKeys = matchSimilarKeys(key: key, item:item)
                /* 如果查找出来相似的 Key 信息 */
                if similarKeys.count > 0 {
                    keyString += "\(key)"
                    for similarKeyKid in similarKeys {
                        keyString += "[相似的Key:[\(similarKeyKid.similarKey)](相似度:\(similarKeyKid.proportion * 100)%)],"
                    }
                    keyString += "\n"
                } else {
                    keyString += "\(key)\n"
                }
                valueString += "\(enValue ?? "")\n"
                
            }
        }
        exportString = "\(keyString)\n\n\n\n\(valueString)"
        guard let path = FileKit.getDirectory() else {
            return
        }
        let exportPath = "\(path)/未添加翻译Key.txt"
        try? exportString.write(toFile: exportPath, atomically: true, encoding: String.Encoding.utf8)
    }
    
    /// 查找相似的 Key 如果存在可能之前的翻译可能有用
    ///
    /// - Parameter key: 需要查找的 Key
    /// - Returns:  相似 Key 的元祖数组 similarKey: 相似的 Key 字段 proportion: 相似度占比
    func matchSimilarKeys(key:String, item:CSVItem) -> [(similarKey:String, proportion:Float)] {
        /* 储存查找相似Key的信息 */
        var similarKeys:[(similarKey:String, proportion:Float)] = []
        /* 遍历已经翻译的 Key */
        for localizetionKey in item.list.keys {
            /* 查找的 Key和遍历的全部变成小写 */
            let lowercaseKey = key.lowercased()
            /* 多语言表格Key 转换为小写 */
            let lowercaseLocalizetionKey = localizetionKey.lowercased()
            /* 包含关系的权重 */
            var rangeProportion:Float = 0
            /* 如果一方的字符串被包含在另外一方里面 */
            if lowercaseLocalizetionKey.range(of: lowercaseKey) != nil || lowercaseKey.range(of: lowercaseLocalizetionKey) != nil {
                if lowercaseLocalizetionKey.range(of: lowercaseKey) != nil {
                    rangeProportion = Float(lowercaseKey.count) / Float(lowercaseLocalizetionKey.count)
                } else {
                    rangeProportion = Float(lowercaseLocalizetionKey.count) / Float(lowercaseKey.count)
                }
            }
            /* 权重 */
            var weight = 0
            for keyKid in lowercaseKey.enumerated() {
                for localizetionKeyKid in lowercaseLocalizetionKey.enumerated() {
                    /* 如果索引一样 并且字符一样 那样权重+1 */
                    if keyKid.offset == localizetionKeyKid.offset && keyKid.element == localizetionKeyKid.element {
                        weight += 1
                    }
                }
            }
            /* 查找出来的占比 */
            var proportion = Float(weight) / Float(localizetionKey.count)
            if proportion < 0.6 {
                proportion = rangeProportion
            }
            /* 如果相似度大于60% 就可以提醒 */
            if proportion >= 0.6  && proportion <= 1.0 {
                similarKeys.append((localizetionKey,proportion))
            }
        }
        similarKeys.sort { (left, right) -> Bool in
            return left.proportion > right.proportion
        }
        return similarKeys
    }
    

    /* 一键快速保存所有的多语言 */
    @IBAction func quickAllLocalizetion(_ sender: Any) {
        guard CheckConfigManager.checkConfigReadySuccess() else {
            return
        }
        var errorMessage = ""
        guard let rootPath = SettingModel.shareSettingModel().projectRootPath else {
            let alert = NSAlert()
            alert.messageText = "找不到工程路径，一键保存错误!"
            alert.runModal()
            return
        }
        self.csvParse.items.forEach { (item) in
            guard let enCode = SettingModel.shareSettingModel().projectLanguageCode[item.name] else {
                if !SettingModel.shareSettingModel().filterLocalizedNames.contains(item.name) {
                    errorMessage += "[\(item.name)]在配置里面找不到配置简码无法一键保存\n"
                }
                return
            }
            let savePath = "\(rootPath)/\(enCode).lproj"
            saveInPath(path: savePath, item: item, errorMessage: &errorMessage)
        }
        if errorMessage.count > 0 {
            let alert = NSAlert()
            alert.messageText = errorMessage
            alert.runModal()
            return
        }
    }
    
    func saveInPath(path:String, item:CSVItem, errorMessage:inout String) {
        var content = ""
        let keys = LocalizeStringKit.shareManager().localizeDictionary.keys
        for c in keys.enumerated() {
            let key = c.element
            guard let value = item.list[key] else {
                continue
            }
            guard value.count > 0 else {
                continue
            }
            guard let enValue = LocalizeStringKit.shareManager().localizeDictionary[key] else {
                return
            }
            var fixSource = value
            SettingModel.shareSettingModel().fixValues.forEach { (key,value) in
                fixSource = fixSource.replacingOccurrences(of: key, with: value)
            }
            
            guard enValue.specialEqual(source: fixSource) else {
                errorMessage += "[\(fixSource)]占位符和[\(enValue)]占位符个数不一样\n\n"
                continue
            }
            guard !value.containChineseChar() else {
                errorMessage += "[\(fixSource)]不能包含中文\n\n"
                continue
            }
            fixSource = fixSource.replacingOccurrences(of: "\"", with: "'")
            var append = "\"\(key)\" = \"\(fixSource)\";\n"
            append = append.replacingOccurrences(of: "\r", with: "")
            content += append
        }
//        content = content.replacingOccurrences(of: "\\", with: "\\\\")
        do {
            try content.write(toFile: "\(path)/Localizable.strings", atomically: true, encoding: String.Encoding.utf8)
        } catch let error {
            let alert = NSAlert()
            alert.messageText = "找不到\(error.localizedDescription)，一键保存错误!"
            alert.runModal()
        }
    }
    
    
}

