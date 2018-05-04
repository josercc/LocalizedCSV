//
//  FileKit.swift
//  LocalizedCSV
//
//  Created by 张行 on 2017/8/21.
//  Copyright © 2017年 张行. All rights reserved.
//

import AppKit

class FileKit {
    
    /// 获取文件夹下面所有的文件
    ///
    /// - Parameters:
    ///   - path: 文件夹路径
    ///   - allowFileTypes: 允许查询的文件后缀 默认为全部支持
    /// - Returns: 查询出的文件
    static func findAllFiles(path:String, allowFileTypes:[String] = []) -> [String] {
        /// 存放查询出的文件数组
        var files:[String] = []
        /// 是否是文件夹 默认是不是
        var isDirectory = ObjCBool(false)
        /// 查询路径是否存在 不存在直接返回空数组
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
            return files
        }
        /// 如果过滤的数组存在对文件进行过滤
        if allowFileTypes.count > 0 {
            /// 如果不存在最后一个错误直接返回
            guard let lastPath = path.components(separatedBy: "/").last else {
                return files
            }
            /// 获取文件后缀 如果不存在就返回
            guard let lastExtern = lastPath.components(separatedBy: ".").last else {
                return files
            }
            guard !allowFileTypes.contains(lastExtern) else {
                return files
            }
        }
        
        /// 如果是文件就直接的添加 否则就获取文件夹的子元素
        if !isDirectory.boolValue {
            files.append(path)
        } else {
            /// 如果不存在子元素就返回
            guard let contents = try? FileManager.default.contentsOfDirectory(atPath: path) else {
                return files
            }
            for content in contents {
                /// 获取子元素的路径 替换//成/
                let subPath = "\(path)/\(content)".replacingOccurrences(of: "//", with: "/")
                files.append(contentsOf: findAllFiles(path: subPath))
            }
        }
        
        return files
    }
    
    
    /// 获取目录
    ///
    /// - Returns: 目录的地址
    static func getDirectory() -> String? {
        let openPannel = NSOpenPanel()
        openPannel.canChooseFiles = false
        openPannel.canChooseDirectories = true
        guard openPannel.runModal() == NSFileHandlingPanelOKButton else {
            return nil;
        }
        guard let path = openPannel.urls.first?.absoluteString.replacingOccurrences(of: "file://", with: "") else {
            return nil;
        }
        return path;
    }
}
