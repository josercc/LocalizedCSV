//
//  LocalizeStringKit.swift
//  LocalizedCSV
//
//  Created by 张行 on 2017/8/18.
//  Copyright © 2017年 张行. All rights reserved.
//

import Foundation

struct LocalizeStringKitManager {
    static let manager = LocalizeStringKit()
}

class LocalizeStringKit {
    var localizeDictionary:[String:String] = [:]
    static func shareManager() -> LocalizeStringKit {
        return LocalizeStringKitManager.manager
    }
    
    func parse(filePath:String) throws -> Void {
        localizeDictionary.removeAll()
        let pathList = filePath.components(separatedBy: ".")
        guard pathList.count > 1 else {
            throw CSVParseKitError.fileError
        }
        guard let lastPath = pathList.last else {
            throw CSVParseKitError.fileError
        }
        guard lastPath == "strings" else {
            throw CSVParseKitError.fileError
        }
        let contentString = try String(contentsOfFile: filePath)
        let contentList = contentString.components(separatedBy: "\n")
        for content in  contentList {
            findKeyValue(content: content)
        }
    }
    
    func findKeyValue(content:String) {
        var list = content.components(separatedBy: "=")
        guard list.count == 2 else {
            return
        }
        guard let key = findString(string: list[0]).0, let value = findString(string: list[1]).0 else {
            return
        }
        localizeDictionary[key] = value
    }
    
}

/// 查找""中间的字符串
///
/// - Parameter string: 需要查找的字符串
/// - Returns: $0查找出来的字符串 $1代表查询剩余的字符串
func findString(string: String) -> (String?,String) {
    /// 替换字符串中的\"防止字符串"的干扰
    var remainContent = string.replacingOccurrences(of: "\\\"", with: "{p}")
    /// 如果查找的字符串中不存在"字符则不存在
    guard let range = remainContent.range(of: "\"") else {
        return (nil,remainContent)
    }
    /// 获取首个"之后的字符串
    remainContent = remainContent.substring(from: remainContent.index(range.upperBound, offsetBy: 0))
    /// 获取最后一个"之后的字符串
    guard let range1 = remainContent.range(of: "\"") else {
        return (nil,remainContent)
    }
    /// 获取最后一个"字符串之前的内容
    let findText = remainContent.substring(to: remainContent.index(range1.lowerBound, offsetBy: 0))
    /// 获取剩余的字符串
    remainContent = remainContent.substring(from: remainContent.index(range1.upperBound, offsetBy: 0))
    /// 再把{p}替换成\"
    remainContent = remainContent.replacingOccurrences(of: "{p}", with: "\\\"")
    return (findText,remainContent)
}

