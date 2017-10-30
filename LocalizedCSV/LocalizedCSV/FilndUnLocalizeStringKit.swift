//
//  FilndUnLocalizeStringKit.swift
//  LocalizedCSV
//
//  Created by 张行 on 2017/8/19.
//  Copyright © 2017年 张行. All rights reserved.
//

//  查询本地需要国际化的字符串
//  第一步: 获取查询的文件列表

import Foundation

class FilndUnLocalizeStringKit {
    
    func findAll() {
        guard let directoryPath = PannelKit.openDirectory() else {
            return
        }
        let files = FileKit.findAllFiles(path: directoryPath, allowFileTypes: ["h","m"])
        for file in files {
//            print("->\(file)")
            guard let content = try? String(contentsOfFile: file) else {
                continue
            }
            let list = findUIAlertController(content: content)
            guard list.count > 0 else {
                continue
            }
            print("✅\(list)")
        }
        print("结束")
    }
    
}

/// [UIAlertController alertControllerWithTitle:@""  message:@"" preferredStyle:alertControllerStyle]
func findUIAlertController(content:String) -> [String] {
    let result = findPlaceholder(source: ["[","UIAlertController","alertControllerWithTitle",":","{R}","message",":","{R}","preferredStyle"], content:content)
    return result.0
}

/*
 栗子 [UIAlertController alertControllerWithTitle:@"title"  message:@"message" preferredStyle:alertControllerStyle]
 source: ["[","UIAlertController","alertControllerWithTitle",":","{R}","message",":","{R}","preferredStyle"]
 */

func findPlaceholder(source:[String], content:String) -> ([String], String) {
    var remainContent = content
    /// 如果查找的模板数组为空 则查询失败 返回空数组 并且原字符串一并返回
    guard source.count > 0 else {
        return ([],remainContent)
    }
    /// 获取首个全部查找的字符串
    let first = source[0]
    /// 查询首个字符串在查询字符串位置 如果查询不存在就查询失败 返回空数组 并且源字符串一并返回
    guard let range1 = content.range(of: first) else {
        return ([],remainContent)
    }
    /// 获取需要向后截取的位置
    let fromIndex = remainContent.index(range1.upperBound, offsetBy: 0)
    /// 获取剩下需要查询的字符串
    remainContent = remainContent.substring(from: fromIndex)
    /// 已经查询出来的占位符
    var list:[String] = []
    /// 遍历模板数组的字符
    for item in source.enumerated() {
        /// 移除字符串前面的空格
        remainContent = removeSpance(content: remainContent)
        /// 如果是第一个就跳过
        guard item.offset != 0 else {
            continue
        }
        ///如果是占位符 就开始查找字符串
        if item.element == "{R}" {
            /// 查询是否还存在下一个占位符 如果不存在 代表参数错误返回
            guard source.count > item.offset + 1 else {
                break
            }
            /// 获取下一个占位符
            let nextPlaceholder = source[item.offset + 1]
            /// 获取查询出来的元组
            let result = findPlaceholderContent(content: remainContent, nextPlaceholder: nextPlaceholder)
            remainContent = result.1
            /// 如果没有查询出来 代表错误
            guard let findText = result.0 else {
                break
            }
            list.append(findText)
        } else {
            /// 如果查找不到查找的内容跳出
            guard let range = remainContent.range(of: item.element) else {
                break
            }
            /// 获取截取开始的位置
            let rangeIndex = remainContent.index(range.upperBound, offsetBy: 0)
            /// 截取剩余字符的位置
            remainContent = remainContent.substring(from: rangeIndex)
        }
    }
    return (list,remainContent)
}


/// 移除最前面空格的字符串
func removeSpance(content:String) -> String {
    /// 如果数据源字符串为空 则直接返回
    guard content.characters.count > 0 else {
        return content
    }
    /// 获取首个字符串
    let firstIndex = content.index(content.startIndex, offsetBy: 1)
    /// 如果第一个字符不为空则直接返回
    guard content.substring(to: firstIndex) == " " else {
        return content
    }
    return removeSpance(content: content.substring(from: firstIndex))
}


/// 查找占位符
///
/// - Parameter content: 需要查找的字符串
/// - Parameter nextPlaceholder: 下一步占位符
/// - Returns: $0代表查找出来的字符串可为空 $1查找之后剩余的字符串
func findPlaceholderContent(content: String, nextPlaceholder:String) -> (String?,String) {
    var remainContent = content
    /// 移除之前的空格
    remainContent = removeSpance(content: remainContent)
    /// 占位符
    var p:String = ""
    /// 首个字符串位置
    let startIndex = remainContent.index(remainContent.startIndex, offsetBy: 1)
    /// 获取首个字符串
    let subContent = remainContent.substring(to: startIndex)
    /// 如果首页字符串为@代表是原字符串
    if subContent == "@" {
        print("原来是字符串类型")
        let findResult = findString(string: remainContent)
        return findResult
    } else {
        print("是变量类型的")
        /// 获取用户设置了下一个占位符 否则就直接返回错误
        guard let _ = remainContent.range(of: nextPlaceholder) else {
            return (nil,remainContent)
        }
        /// 为了防止宏包含空格的影响 直接使用下一个占位符进行查找
        while true {
            /// 获取首个字符串的位置
            let index0 = remainContent.index(remainContent.startIndex, offsetBy: 1)
            /// 获取首个字符串
            let s0 = remainContent.substring(to: index0)
            /// 获取剩余的字符串
            let subRemainContent = remainContent.substring(from: index0)
            /// 如果首个是空格 那么继续 因为不管是变量还是方法还是宏是不能空格开头的
            if s0 == " "{
                remainContent = subRemainContent
                continue
            }
            /// 获取剩下的不足以我们查找下一个占位符 代表字符串错误
            guard remainContent.characters.count >= nextPlaceholder.characters.count else {
                return (nil, remainContent)
            }
            /// 获取占位符的位置
            let indexPlaceholder = remainContent.index(remainContent.startIndex, offsetBy: nextPlaceholder.characters.count)
            /// 获取查找出来的占位符
            let placeholder = remainContent.substring(to: indexPlaceholder)
            /// 如果查找出来的占位符就是我们设置的占位符 代表我们查找结束了 否则就还没有结束
            guard placeholder == nextPlaceholder else {
                remainContent = subRemainContent
                p += s0
                continue
            }
            remainContent = remainContent.substring(from: indexPlaceholder)
            break;
        }
        return (p,remainContent)
    }
}


