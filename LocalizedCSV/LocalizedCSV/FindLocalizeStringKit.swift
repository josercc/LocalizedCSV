//
//  FindLocalizeStringKit.swift
//  LocalizedCSV
//
//  Created by 张行 on 2017/8/19.
//  Copyright © 2017年 张行. All rights reserved.
//

import Foundation

/* 结构体获取单利对象 */
struct FindLocalizeStringKitManager {
    /* FindLocalizeStringKit对象 */
    static let manager = FindLocalizeStringKit()
}

/* 查找本地多语言的管理器 */
class FindLocalizeStringKit {
    /* 查找出来的多语言的字典 */
    var list:[String:String] = [:]
    /* 存在相同key 值不相同的数组列表 */
    var exitSameKeyList:[String:[String]] = [:]
    /* 准备查询文件多语言的回调
     @param name 文件的地址
     */
    var completionLog:((_ name:String) -> Void)?
    /* 更新的回调
     @param key 多语言的 Key
     @param value 多语言的值
     */
    var updateCompletion:((_ key:String, _ value:String) -> Void)?
    
    static func shareManager() -> FindLocalizeStringKit {
        return FindLocalizeStringKitManager.manager
    }
    
    /* 查找本地所有的多语言 */
    func findAllLocalizeString(path:String) {
        /* 移除之前的旧数据 */
        list.removeAll()
        /* 获取查询路径下面所有的文件路径 */
        let files = FileKit.findAllFiles(path: path)
        /* 遍历所有的文件 */
        for file in files {
            /* 开始查找之前 回调正在查找的文件路径 */
            if let completionLog = self.completionLog {
                completionLog(file)
            }
            /* 如果文件的内容无法获取到就继续 */
            guard let content = try? String(contentsOfFile: file) else {
                continue
            }
            /* 遍历查找出来内容的所有的多语言 */
            for d in findAllLocalizeString(string: content) {
                /* 如果相同的 key 已经存在 并且值不一样则代表多语言存在问题 存在同一个数组提示用户*/
                if (list.keys.contains(d.key) && list[d.key] != d.value) {
                    var exitList:[String] = []
                    /* 查找已经存在数据 */
                    if let tempExitList = exitSameKeyList[d.key] {
                        exitList.append(contentsOf: tempExitList)
                    }
                    exitList.append(file)
                    exitSameKeyList[d.key] = exitList
                }
                guard !list.keys.contains(d.key) else {
                    continue
                }
                let key = CSVParseKitManager.manager.formatterValue(value: d.key)
                let value = CSVParseKitManager.manager.formatterValue(value: d.value)
                list[key] = value
                if let updateCompletion = self.updateCompletion {
                    updateCompletion(d.key, d.value)
                }
            }
        }
    }
    
    
    
    /// * 查找指定文本中所有的多语言
    ///
    /// - Parameter string: 执行的多语言
    /// - Returns: 查找出来的多语言字典
    private func findAllLocalizeString(string:String) -> [String:String] {
        /* 存放查找出来的多语言字典 */
        var localizeString:[String:String] = [:]
        /* 查找出现第一个所在的位置GBLocalizedString( */
        let searchLocallizetionPrefix = SettingModel.shareSettingModel().searchLocalizetionPrefix
        guard let range1 = string.range(of: "\(searchLocallizetionPrefix)(") else {
            /* 查找不到就返回 */
            return localizeString
        }
        /* 从查找到的数据之后开始截取 */
        let subString = string.substring(from: string.index(range1.upperBound, offsetBy: 0))
        /* 查找多语言的中间的文本 */
        let filter = filterBrackets(string: subString)
        var parseString = filter.result
        /* 如果查找的字符串不存在@"则直接返回 */
        guard let _ = parseString.range(of: "@\"") else {
            return localizeString
        }
        /* 多语言的 Key */
        var key:String?
        /* 多语言的值 */
        var value:String?
        /* 查找左侧的 Key */
        let result = findString(string: parseString)
        /* 查找出来的多语言的Key */
        key = result.0
        /* 剩余的查找字符串 */
        parseString = result.1
        /* 查找多语言值的结果集 */
        let result1 = findString(string: parseString)
        /* 查找出来多语言的值 */
        value = result1.0
        /* 查找多语言剩余的字符串 */
        parseString = result1.1
        /* 如果 Key 存在 就添加到结果集 */
        if let k = key {
            /* 如果值存在就用值 否则就用 Key */
            localizeString[k] = value ?? key
        }
        /* 查找剩余字符串中的多语言 */
        for d in findAllLocalizeString(string: filter.findString) {
            localizeString[d.key] = d.value
        }
        return localizeString
    }
}

/// 查找‘GBLocalizedString(‘和’)‘中间的文本
///
/// - Parameter string: 需要查找的文本
/// - Returns: 查找出来的结果文本和剩余的文本
func filterBrackets(string:String) -> (result:String, findString:String) {
    /* 拼接结果文本 */
    var result = ""
    /* 是否需要停止 */
    var isStop = false
    /* 需要查找的文本 */
    var findString = string
    /* 当前查找的索引 */
    var index = 0
    while !isStop {
        /* 获取第一个字符 */
        let startChar = findString.substring(to: findString.index(findString.startIndex, offsetBy: 1))
        /* 如果第一个为(则代表多语言的字符串存在() */
        if startChar == "(" {
            index += 1
            result += startChar
        } else if startChar == ")" {
            /* 如果是) 代表可能是多语言(结束符号或者多语言截取结束 */
            if index != 0   {
                /* 如果 Index 此时不为0 代表不是多语言结束的标志 */
                index -= 1
                result += startChar
            } else {
                /* 代表查找已经结束 */
                isStop = true
            }
        } else {
            /* 其他的就是我们要查找的多语言文本 */
            result += startChar
        }
        findString = findString.substring(from: findString.index(findString.startIndex, offsetBy: 1))
    }
    return (result,findString)
}


