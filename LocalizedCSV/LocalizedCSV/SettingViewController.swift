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
    @IBOutlet weak var searchLocalizetionPrefix:NSTextField!
    @IBOutlet weak var filterLocalizeNameTextView:NSTextView!
    @IBOutlet weak var checkPlaceholderTextView:NSTextView!
    @IBOutlet weak var fixValueTextView:NSTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let setting = SettingModel.shareSettingModel()
		self.languageCodeTextView.string = setting.languageCodeString()
        self.filterLocalizeNameTextView.string = setting.filterLocalizedNames.joined(separator: "\n")
        self.checkPlaceholderTextView.string = setting.checkPlaceholders.joined(separator: "\n")
        self.searchLocalizetionPrefix.stringValue = setting.searchLocalizetionPrefix
        self.fixValueTextView.string = setting.transferMapToString(map: setting.fixValues)
    }

    @IBAction func save(_ sender:NSButton) {
        if let text = self.languageCodeTextView.string {
            let textList = text.components(separatedBy: "\n")
            var textDic:[String:String] = [:]
            for text in textList.enumerated() {
                let subList = text.element.components(separatedBy: ":")
                guard subList.count == 2 else {
                    continue
                }
                textDic[subList[0]] = subList[1]
            }
            SettingModel.shareSettingModel().projectLanguageCode = textDic
        }
        if self.searchLocalizetionPrefix.stringValue.count > 0 {
            SettingModel.shareSettingModel().searchLocalizetionPrefix = self.searchLocalizetionPrefix.stringValue
        }
        
        if let text = self.filterLocalizeNameTextView.string {
            let textList = text.components(separatedBy: "\n")
            SettingModel.shareSettingModel().filterLocalizedNames = textList
        }
        
        if let text = self.checkPlaceholderTextView.string {
            let textList = text.components(separatedBy: "\n")
            SettingModel.shareSettingModel().checkPlaceholders = textList
        }
        
        if let text = self.fixValueTextView.string {
            let textList = text.components(separatedBy: "\n")
            var textDic:[String:String] = [:]
            for text in textList.enumerated() {
                let subList = text.element.components(separatedBy: ":")
                guard subList.count == 2 else {
                    continue
                }
                textDic[subList[0]] = subList[1]
            }
            SettingModel.shareSettingModel().fixValues = textDic
        }
        
        SettingModel.shareSettingModel().save()
        
    }
    
    
    
    
}

let settingModel = SettingModel()

class SettingModel {

	var projectRootPath:String?

	var projectLanguageCode:[String:String] = [:]
    
    var searchLocalizetionPrefix:String = "GBLocalizedString"
    
    var filterLocalizedNames:[String] = []
    
    var checkPlaceholders:[String] = []
    
    var fixValues:[String:String] = [:]

	init() {
		if let oldLanguageCode = UserDefaults.standard.object(forKey: "projectLanguageCode") as? [String:String] {
			self.projectLanguageCode = oldLanguageCode
		}
        if let fixValues = UserDefaults.standard.object(forKey: "fixValues") as? [String:String] {
            self.fixValues = fixValues
        }
        if let filterLocalizedNames = UserDefaults.standard.object(forKey: "filterLocalizedNames") as? [String]  {
            self.filterLocalizedNames = filterLocalizedNames
        }
        if let checkPlaceholders = UserDefaults.standard.object(forKey: "checkPlaceholders") as? [String]  {
            self.checkPlaceholders = checkPlaceholders
        }
        
        if let searchLocalizetionPrefix = UserDefaults.standard.object(forKey: "searchLocalizetionPrefix") as? String {
            if searchLocalizetionPrefix.count > 0 {
                self.searchLocalizetionPrefix = searchLocalizetionPrefix
            }
        }
	}

	class func shareSettingModel() -> SettingModel {
		return settingModel
	}

    func save() {
        let userDefault = UserDefaults.standard
        userDefault.set(self.projectLanguageCode, forKey: "projectLanguageCode")
        userDefault.set(self.filterLocalizedNames, forKey: "filterLocalizedNames")
        userDefault.set(self.checkPlaceholders, forKey: "checkPlaceholders")
        userDefault.set(self.searchLocalizetionPrefix, forKey: "searchLocalizetionPrefix")
        userDefault.set(self.fixValues, forKey: "fixValues")
        userDefault.synchronize()
    }

	func languageCodeString() -> String {
		return transferMapToString(map: self.projectLanguageCode)
	}
    
    func transferMapToString(map:[String:String]) -> String {
        var codeList:[String] = []
        for (key,value) in map {
            let subString = "\(key):\(value)"
            codeList.append(subString)
        }
        return codeList.joined(separator: "\n")
    }
}
