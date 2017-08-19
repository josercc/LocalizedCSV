//
//  FilndUnLocalizeStringKit.swift
//  LocalizedCSV
//
//  Created by 张行 on 2017/8/19.
//  Copyright © 2017年 张行. All rights reserved.
//

import Foundation

/*
 扫描程序代码 可能存在本地化地方
 * 1
 
 */


class FilndUnLocalizeStringKit {
    
    func findAll() {
        
    }
    
}

/// [UIAlertController alertControllerWithTitle:@""  message:@"" preferredStyle:alertControllerStyle]
func findUIAlertController(content:String) -> [String] {
    /// [UIAlertController alertControllerWithTitle:X  message:X preferredStyle:alertControllerStyle]
    var c = content
    return findPlaceholder(source: ["[","UIAlertController","alertControllerWithTitle",":","{p}","message",":","{p}","preferredStyle"], content: &c)
}

/*
 栗子 [UIAlertController alertControllerWithTitle:@"title"  message:@"message" preferredStyle:alertControllerStyle]
 findPath: ["[","UIAlertController","alertControllerWithTitle",":","{p}","message",":","{P}","preferredStyle"]
 */

func findPlaceholder(source:[String], content:inout String) -> [String] {
    guard source.count > 0 else {
        return []
    }
    let first = source[0]
    guard let range1 = content.range(of: first) else {
        return []
    }
    let fromIndex = content.index(range1.upperBound, offsetBy: 0)
    content = content.substring(from: fromIndex)
    var list:[String] = []
    for item in source.enumerated() {
        content = removeSpance(content: content)
        guard item.offset != 0 else {
            continue
        }
        if item.element == "{p}" {
            guard let subContent = findPlaceholderContent(content: &content) else {
                break
            }
            list.append(subContent)
        } else {
            guard content.characters.count >= item.element.characters.count else {
                break
            }
            let subContent = content.substring(to: content.index(content.startIndex, offsetBy: item.element.characters.count))
            guard subContent == item.element else {
                break
            }
            content = content.substring(from: content.index(content.startIndex, offsetBy: item.element.characters.count))
        }
        
    }
    return list
}

func removeSpance(content:String) -> String {
    guard content.characters.count > 0 else {
        return content
    }
    let firstIndex = content.index(content.startIndex, offsetBy: 1)
    guard content.substring(to: firstIndex) == " " else {
        return content
    }
    return removeSpance(content: content.substring(from: firstIndex))
}

func findPlaceholderContent(content: inout String) -> String? {
    content = removeSpance(content: content)
    var p:String = ""
    let startIndex = content.index(content.startIndex, offsetBy: 1)
    let subContent = content.substring(to: startIndex)
    if subContent == "@" {
        print(content)
        let findText = findString(string: &content)
        return findText
    } else {
        print("是变量类型的")
        while content.characters.count > 0 {
            let index0 = content.index(content.startIndex, offsetBy: 1)
            let s0 = content.substring(to: index0)
            content = content.substring(from: index0)
            if s0 == " " {
                break
            }
            p += s0
        }
        return p
    }
}


