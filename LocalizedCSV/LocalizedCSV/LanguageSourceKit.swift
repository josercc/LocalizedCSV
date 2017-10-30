//
//  LanguageSourceKit.swift
//  LocalizedCSV
//
//  Created by 张行 on 2017/9/5.
//  Copyright © 2017年 张行. All rights reserved.
//

import Foundation

/// 本地国际化源的管理
class LanguageSourceKit {
    static func languages() -> [LanguageModel] {
        var list:[LanguageModel] = []
        if let localDic = UserDefaults.standard.object(forKey: LanguageSourceKit.LanguageSourceKitName) as? [String:Any] {
            localDic.forEach({ (key,value) in
                let model = LanguageModel(name: key, dic: value as? [String:Any])
                list.append(model)
            })
        }
        return list
    }
    static let LanguageSourceKitName = "LanguageSourceKitName"
    static func saveLanguage(item:[CSVItem], language:String? = nil) {
        var dic:[String:Any] = [:]
        if let localDic = UserDefaults.standard.object(forKey: LanguageSourceKit.LanguageSourceKitName) as? [String:Any] {
            localDic.forEach({ (key,value) in
                dic[key] = value
            })
        }
        
        item.forEach { (item) in
            let keyName = language ?? item.name
            if dic.keys.contains(keyName) {
                var values:[String:Any] = [:]
                if let localValues = dic[item.name] as? [String:Any] {
                    localValues.forEach({ (key,value) in
                        values[key] = value
                    })
                }
                item.list.forEach({ (key,value) in
                    values[key] = value
                })
            } else {
                dic[keyName] = item.list
            }
        }
        UserDefaults.standard.set(dic, forKey: LanguageSourceKit.LanguageSourceKitName)
        UserDefaults.standard.synchronize()
    }
    
}

/// 国际化语言的模型
class LanguageModel {
    /// 名称
    let name:String?
    /// 已经本地化的值的列表
    var values:[String:Any] = [:]
    required init(name:String, dic:[String:Any]? = nil) {
        self.name = name
        dic?.forEach({ (key:String, value:Any) in
            self.values[key] = value
        })
    }
}



