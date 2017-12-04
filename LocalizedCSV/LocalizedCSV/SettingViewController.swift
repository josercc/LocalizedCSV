//
//  SettingViewController.swift
//  LocalizedCSV
//
//  Created by 张行 on 2017/10/26.
//  Copyright © 2017年 张行. All rights reserved.
//

import Cocoa

class SettingViewController: NSViewController {

	@IBOutlet weak var languageCodeTextView:NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
		self.languageCodeTextView.string = SettingModel.shareSettingModel().languageCodeString()
    }

	@IBAction func save(_ sender:NSButton) {
		guard let text = self.languageCodeTextView.string else {
			return
		}
		let textList = text.components(separatedBy: "\n")
		var textDic:[String:String] = [:]
		for text in textList.enumerated() {
			let subList = text.element.components(separatedBy: ":")
			guard subList.count == 2 else {
				continue
			}
			textDic[subList[0]] = subList[1]
		}
		SettingModel.shareSettingModel().saveNewLanguageCode(dic: textDic)
	}
    
}

let settingModel = SettingModel()

class SettingModel {

	var projectRootPath:String?

	var projectLanguageCode:[String:String] = [:]

	init() {
		if let oldLanguageCode = UserDefaults.standard.object(forKey: "projectLanguageCode") as? [String:String] {
			self.projectLanguageCode = oldLanguageCode
		}
	}

	class func shareSettingModel() -> SettingModel {
		return settingModel
	}

	func saveNewLanguageCode(dic:[String:String]) {
		for (key,value) in dic {
			self.projectLanguageCode[key] = value
		}
		UserDefaults.standard.set(self.projectLanguageCode, forKey: "projectLanguageCode")
		UserDefaults.standard.synchronize()
	}

	func languageCodeString() -> String {
		var codeList:[String] = []
		for (key,value) in self.projectLanguageCode {
			let subString = "\(key):\(value)"
			codeList.append(subString)
		}
		return codeList.joined(separator: "\n")
	}
}
