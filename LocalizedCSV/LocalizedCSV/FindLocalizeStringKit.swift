//
//  FindLocalizeStringKit.swift
//  LocalizedCSV
//
//  Created by 张行 on 2017/8/19.
//  Copyright © 2017年 张行. All rights reserved.
//

import Foundation

struct FindLocalizeStringKitManager {
    static let manager = FindLocalizeStringKit()
}

class FindLocalizeStringKit {
    var list:[String:String] = [:]
    
    /* 存在相同key 值不相同的数组列表 */
    var exitSameKeyList:[String:[String]] = [:]
    
    var completionLog:((_ name:String) -> Void)?
    var updateCompletion:((_ key:String, _ value:String) -> Void)?
    
    static func shareManager() -> FindLocalizeStringKit {
        return FindLocalizeStringKitManager.manager
    }
    
    func findAllLocalizeString(path:String) {
        list.removeAll()
        let files = findAllFiles(path: path)
        for file in files {
            print("➡️\(file)\n")
            if let completionLog = self.completionLog {
                completionLog(file)
            }
            guard let content = try? String(contentsOfFile: file) else {
                continue
            }
            for d in findAllLocalizeString(string: content) {
                /* 如果相同的 key 已经存在 并且值不一样则存起来 */
                if (list.keys.contains(d.key) && list[d.key] != d.value) {
                    var exitList:[String] = []
                    if let tempExitList = exitSameKeyList[d.key] as? [String] {
                        exitList.append(contentsOf: tempExitList)
                    }
                    exitList.append(file)
                    exitSameKeyList[d.key] = exitList
                }
                guard !list.keys.contains(d.key) else {
                    continue
                }
                let key = d.key.replacingOccurrences(of: "\u{08}", with: "")
                let value = d.value.replacingOccurrences(of: "\u{08}", with: "")
                list[key] = value
                print("✅\(d.key) = \(d.value)")
                if let updateCompletion = self.updateCompletion {
                    updateCompletion(d.key, d.value)
                }
            }
        }
    }
    
    private func findAllFiles(path:String) -> [String] {
        var files:[String] = []
        var isDirectory = ObjCBool(false)
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
            return files
        }
        if !isDirectory.boolValue {
            files.append(path)
        } else {
            guard let contents = try? FileManager.default.contentsOfDirectory(atPath: path) else {
                return files
            }
            for content in contents {
                let subPath = "\(path)/\(content)".replacingOccurrences(of: "//", with: "/")
                files.append(contentsOf: findAllFiles(path: subPath))
            }
        }
        
        return files
    }
    
    // NSLocalizedString(@"", @"")
    
    private func findAllLocalizeString(string:String) -> [String:String] {
        var localizeString:[String:String] = [:]
        guard let range1 = string.range(of: "GBLocalizedString(") else {
            return localizeString
        }
        let subString = string.substring(from: string.index(range1.upperBound, offsetBy: 0))
        let filter = filterBrackets(string: subString)
        var parseString = filter.result
        guard let _ = parseString.range(of: "@\"") else {
            return localizeString
        }
        var key:String?
        var value:String?
        let result = findString(string: parseString)
        key = result.0
        parseString = result.1
        let result1 = findString(string: parseString)
        value = result1.0
        parseString = result1.1
        if let k = key {
            localizeString[k] = value ?? key
        }
        for d in findAllLocalizeString(string: filter.findString) {
            localizeString[d.key] = d.value
        }
        return localizeString
    }
}

func filterBrackets(string:String) -> (result:String, findString:String) {
    var result = ""
    var isStop = false
    var findString = string
    var index = 0
    while !isStop {
        let startChar = findString.substring(to: findString.index(findString.startIndex, offsetBy: 1))
        if startChar == "(" {
            index += 1
            result += startChar
        } else if startChar == ")" {
            if index != 0   {
                index -= 1
                result += startChar
            } else {
                isStop = true
            }
        } else {
            result += startChar
        }
        findString = findString.substring(from: findString.index(findString.startIndex, offsetBy: 1))
    }
    return (result,findString)
}


