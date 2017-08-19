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
    
    var completionLog:((_ name:String) -> Void)?
    var updateCompletion:((_ key:String) -> Void)?
    
    static func shareManager() -> FindLocalizeStringKit {
        return FindLocalizeStringKitManager.manager
    }
    
    func findAllLocalizeString(path:String) {
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
                guard !list.keys.contains(d.key) else {
                    continue
                }
                list[d.key] = d.value
                print("✅\(d.key) = \(d.value)")
                if let updateCompletion = self.updateCompletion {
                    updateCompletion(d.key)
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
        guard let range1 = string.range(of: "NSLocalizedString(") else {
            return localizeString
        }
        let subString = string.substring(from: string.index(range1.upperBound, offsetBy: 0))
        guard let range2 = subString.range(of: ")") else {
            return localizeString
        }
        let parseString = subString.substring(to: string.index(range2.lowerBound, offsetBy: 0))
        let listContent = parseString.components(separatedBy: ",")
        var key:String?
        var value:String?
        for c in listContent.enumerated() {
            if c.offset == 0 {
                key = findString(string: c.element).0
            } else if c.offset == 1 {
                value = findString(string: c.element).0
            }
        }
        if let k = key {
            localizeString[k] = value ?? key
        }
        for d in findAllLocalizeString(string: subString.substring(from: subString.index(range2.upperBound, offsetBy: 0))) {
            localizeString[d.key] = d.value
        }
        return localizeString
    }
    
}



