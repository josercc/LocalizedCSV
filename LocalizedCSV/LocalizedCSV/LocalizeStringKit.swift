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
        guard let key = findString(string: &list[0]), let value = findString(string: &list[1]) else {
            return
        }
        localizeDictionary[key] = value
    }
    
}

func findString(string:inout String) -> String? {
    guard let range = string.range(of: "\"") else {
        return nil
    }
    string = string.substring(from: string.index(range.upperBound, offsetBy: 0))
    guard let range1 = string.range(of: "\"") else {
        return nil
    }
    let findText = string.substring(to: string.index(range1.lowerBound, offsetBy: 0))
    string = string.substring(from: string.index(range1.upperBound, offsetBy: 0))
    return findText
}

