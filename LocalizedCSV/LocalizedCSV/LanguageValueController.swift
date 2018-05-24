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
//        for c in item.list.enumerated() {
//            print("->>:\(c.element.key)\n->>:\(c.element.value)\n\n")
//        }
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
            var value = findValue(key: key, list: nil)
            if !key.specialEqual(source: value) {
                exportString += "\(key)\n"
            } else {
                if let v = value, v.characters.count > 0 {
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
        let list = FindLocalizeStringKit.shareManager().list
        guard list.count > 0 else {
            let alert = NSAlert()
            alert.messageText = "导出失败 请先提取一次工程的国际化 cmd+optional+R";
            alert.runModal()
            return
        }
        var exportString = "";
        var keyString = ""
        var valueString = ""
        for key in keys {
            var value = findValue(key: formatterKey(key: key), list: nil)
            if !key.specialEqual(source: value) {
                let enValue = list[key]
                keyString += "\(key)\n"
                valueString += "\(enValue ?? "")\n"
            }
        }
        exportString = "\(keyString) \n\n\n\n \(valueString)"
        guard let path = openADirectory() else {
            return
        }
        let exportPath = "\(path)/unadd.file"
        try? exportString.write(toFile: exportPath, atomically: true, encoding: String.Encoding.utf8)
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
        var key = formatterKey(key: keys[row])
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
                if let v = value, v.characters.count > 0 {
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
    
    func formatterKey(key:String) -> String {
        return key.replacingOccurrences(of: "\u{08}", with: "")
    }

}
