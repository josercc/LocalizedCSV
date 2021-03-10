//
//  SettingViewController.swift
//  LocalizedCSV
//
//  Created by 张行 on 2017/10/26.
//  Copyright © 2017年 张行. All rights reserved.
//

import Cocoa

class SettingViewController: NSViewController {

    @IBOutlet var languageCodeTextView:NSTextView!
    @IBOutlet weak var searchLocalizetionPrefix:NSTextField!
    @IBOutlet var filterLocalizeNameTextView:NSTextView!
    @IBOutlet var checkPlaceholderTextView:NSTextView!
    @IBOutlet var fixValueTextView:NSTextView!
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
        let text = self.languageCodeTextView.string
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
        
        if self.searchLocalizetionPrefix.stringValue.count > 0 {
            SettingModel.shareSettingModel().searchLocalizetionPrefix = self.searchLocalizetionPrefix.stringValue
        }
        
        SettingModel.shareSettingModel().filterLocalizedNames = self.filterLocalizeNameTextView.string.components(separatedBy: "\n")
        
        SettingModel.shareSettingModel().checkPlaceholders = self.checkPlaceholderTextView.string.components(separatedBy: "\n")
        
        
        let text1 = self.fixValueTextView.string
        let textList1 = text1.components(separatedBy: "\n")
        var textDic1:[String:String] = [:]
        for text in textList1.enumerated() {
            let subList = text.element.components(separatedBy: ":")
            guard subList.count == 2 else {
                continue
            }
            textDic1[subList[0]] = subList[1]
        }
        SettingModel.shareSettingModel().fixValues = textDic1
        
        
        SettingModel.shareSettingModel().save()
        
    }
    
    
    
    
}

let settingModel = SettingModel()

class SettingModel {

	var projectRootPath:String?

	var projectLanguageCode:[String:String] = [:]
    
    var searchLocalizetionPrefix:String = "NSLocalizedString"
    
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
