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
        let openPannel = NSOpenPanel()
        openPannel.canChooseFiles = false
        openPannel.canChooseDirectories = true
        guard openPannel.runModal() == NSFileHandlingPanelOKButton else {
            return
        }
        guard let path = openPannel.urls.first?.absoluteString.replacingOccurrences(of: "file://", with: "") else {
            return
        }
		saveInPath(path: path)
    }

	func saveInPath(path:String) {
		var content = ""
		guard let item = self.item else {
			return
		}
		for c in keys.enumerated() {
			let key = keys[c.offset]
			guard var value = item.list[key] else {
				continue
			}
			guard value.count > 0 else {
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
		do {
			try content.write(toFile: "\(path)/Localizable.strings", atomically: true, encoding: String.Encoding.utf8)
		} catch let error {
			let alert = NSAlert()
			alert.messageText = "找不到\(error.localizedDescription)，一键保存错误!"
			alert.runModal()
		}
	}
    
    @IBAction func exportUnUsed(_ sender: Any) {
        var unused:String = ""
        for name in self.item!.list.keys {
            if !keys.contains(name) {
               unused += "\(name)\n"
            }
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
        let exportPath = "\(path)/unused.txt"
        try? unused.write(toFile: exportPath, atomically: true, encoding: String.Encoding.utf8)
    }
    
    
    @IBAction func exportUnTranslateToFile(_ sender:Any) {
        
        var exportString = "";
        for key in keys {
            let value = findValue(key: key, list: nil)
            if !key.specialEqual(source: value) {
                exportString += "\(key)\n"
            } else {
                if let v = value, v.count > 0 {
                } else {
                    
                    exportString += "\(key)\n"
                }
            }
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
        let exportPath = "\(path)/\(self.item!.name).txt"
        try? exportString.write(toFile: exportPath, atomically: true, encoding: String.Encoding.utf8)
    }
    
    @IBAction func exportUnAddToFile(_ sender:Any) {
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
        
        for key in keys {
            let value = findValue(key: LCFormatterKey(key: key), list: nil)
            if !key.specialEqual(source: value) {
                let similarKeys = matchSimilarKeys(key: key)
                let enValue = list[key]
                if similarKeys.count > 0 {
                    keyString += "\(key)"
                    for similarKeyKid in similarKeys {
                        keyString += " 相似的Key: \(similarKeyKid.similarKey)(相似度:\(similarKeyKid.proportion * 100)%)"
                    }
                    keyString += "\n"
                } else {
                    keyString += "\(key)\n"
                }
                valueString += "\(enValue ?? "")\n"
                
            }
            
        }
        exportString = "\(keyString) \n\n\n\n\(valueString)"
        guard let path = openADirectory() else {
            return
        }
        let exportPath = "\(path)/unadd.file"
        try? exportString.write(toFile: exportPath, atomically: true, encoding: String.Encoding.utf8)
    }
    
    
    /// 查找相似的 Key 如果存在可能之前的翻译可能有用
    ///
    /// - Parameter key: 需要查找的 Key
    /// - Returns:  相似 Key 的元祖数组 similarKey: 相似的 Key 字段 proportion: 相似度占比
    func matchSimilarKeys(key:String) -> [(similarKey:String, proportion:Float)] {
        var similarKeys:[(similarKey:String, proportion:Float)] = []
        /* 遍历已经翻译的 Key */
        for localizetionKey in self.item!.list.keys {
            
            /* 查找的 Key和遍历的全部变成小写 */
            let lowercaseKey = key.lowercased()
            let lowercaseLocalizetionKey = localizetionKey.lowercased()
            var rangeProportion:Float = 0
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
    
    func openADirectory() -> String? {
        let openPannel = NSOpenPanel()
        openPannel.canChooseFiles = false
        openPannel.canChooseDirectories = true
        guard openPannel.runModal() == NSFileHandlingPanelOKButton else {
            return nil
        }
        guard let path = openPannel.urls.first?.absoluteString.replacingOccurrences(of: "file://", with: "") else {
            return nil
        }
        return path
    }
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        verifyCount = 0
        return keys.count
    }
    
    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        var key = LCFormatterKey(key: keys[row])
        guard let column = tableColumn, let cell = column.dataCell as? NSTextFieldCell else {
            return nil
        }
        cell.drawsBackground = true
        let isEn = self.item!.name == "母文本English"
        var value = findValue(key: key, list: isEn ? FindLocalizeStringKit.shareManager().list : nil)
        if column.title == "Key" {
            cell.backgroundColor = NSColor.darkGray
            if isEn && key != value! {
                cell.backgroundColor = NSColor.blue
            }
            return key
        } else if (column.title == "Value") {
            if value == nil {
                verifyCount += 1
            }
            if !key.specialEqual(source: value) {
                cell.backgroundColor = NSColor.red
            } else {
                if let v = value, v.count > 0 {
                    cell.backgroundColor = NSColor.green
                } else {
                    cell.backgroundColor = NSColor.yellow
                }
            }
            if isEn && key != value! {
                cell.backgroundColor = NSColor.blue
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
    
    func findValue(key:String, list:[String:String]?) -> String? {
        var _list = list ?? self.item?.list
        var _value:String?
        findKeyValue(key: key, list: _list!) { (value, index, fixKey) -> String? in
            if let _ = value {
                _value = value!
                return nil
            }
            if index == 0 {
                return fixKey.trimmingCharacters(in: CharacterSet.whitespaces)
            } else if index == 1 {
                return fixKey.replacingOccurrences(of: "\\\"", with: "\\\"\"")
            } else if index == 2 {
                return fixKey.replacingOccurrences(of: "\u{08}", with: "")
            }
            return nil
        }
        return _value;
    }
    
    func findKeyValue(key:String, list:[String:String], completion:((_ value:String?, _ index:Int, _ key:String) -> String?)) {
        var isExitKey:String? = key
        var index = 0
        while true {
            guard let fixKey = isExitKey else {
                break
            }
            let value = list[fixKey]
            isExitKey = completion(value, index, fixKey)
            index += 1;
        }
    }

	@IBAction func quickSave(_ sender:NSButton) {
		guard let rootPath = SettingModel.shareSettingModel().projectRootPath else {
			let alert = NSAlert()
			alert.messageText = "找不到工程路径，一键保存错误!"
			alert.runModal()
			return
		}
		guard let enCode = SettingModel.shareSettingModel().projectLanguageCode[self.item!.name] else {
			let alert = NSAlert()
			alert.messageText = "找不到对应简码，一键保存错误!"
			alert.runModal()
			return
		}
		let savePath = "\(rootPath)/\(enCode).lproj"
		saveInPath(path: savePath)

	}

}
