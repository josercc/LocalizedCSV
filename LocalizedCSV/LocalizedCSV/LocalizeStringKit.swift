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

/* 读取工程 en 多语言文件的键值对 */
class LocalizeStringKit {
    /* 工程多语言的 Key 和值对应的字典 */
    var localizeDictionary:[String:String] = [:]
    static func shareManager() -> LocalizeStringKit {
        return LocalizeStringKitManager.manager
    }
    
    /// 开始解析多语言文件
    ///
    /// - Parameter filePath: 解析的文件路径
    /// - Throws: 解析出现异常抛出的异常
    func parse(filePath:String) throws -> Void {
        /* 解析之前移除之前的数据 */
        localizeDictionary.removeAll()
        /* 根据.切割为一个数组 */
        let pathList = filePath.components(separatedBy: ".")
        /* 如果数组为空 抛出文件异常 */
        guard pathList.count > 1 else {
            throw CSVParseKitError.fileError
        }
        /* 如果获取不到文件后缀 抛出文件异常 */
        guard let lastPath = pathList.last else {
            throw CSVParseKitError.fileError
        }
        /* 如果文件的后缀不是 strings 则抛出异常 */
        guard lastPath == "strings" else {
            throw CSVParseKitError.fileError
        }
        /* 获取文件的内容 */
        let contentString = try String(contentsOfFile: filePath)
        /* 根据换行切割文本为字符串数组 */
        let contentList = contentString.components(separatedBy: "\n")
        /* 遍历文件里面的每行字符串 */
        for content in  contentList {
            findKeyValue(content: content)
        }
    }
    
    /// 查找每行里面的 Key 和值
    ///
    /// - Parameter content: 查找的每一行字符串
    func findKeyValue(content:String) {
        /* 通过=符号切割字符串 */
        var list = content.components(separatedBy: "=")
        /* 如果数组的总数不等于2 则代表有问题 直接退出查找 */
        guard list.count == 2 else {
            return
        }
        /* 如果查找的 Key 和值一个不存在的话  就返回 */
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
    var remainContent = string.replacingOccurrences(of: "\\\"", with: "{R}")
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
    let findText = remainContent.substring(to: remainContent.index(range1.lowerBound, offsetBy: 0)).replacingOccurrences(of: "{R}", with: "\\\"")
    /// 获取剩余的字符串
    remainContent = remainContent.substring(from: remainContent.index(range1.upperBound, offsetBy: 0))
    /// 再把{R}替换成\"
    return (findText,remainContent)
}

