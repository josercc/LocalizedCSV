//
//  CSVParseKit.swift
//  LocalizedCSV
//
//  Created by 张行 on 2017/8/18.
//  Copyright © 2017年 张行. All rights reserved.
//

import Foundation

enum CSVParseKitError: Error {
    case fileError
}

struct CSVParseKitManager {
    static let manager = CSVParseKit()
}

/// 解析CSV文件的库 ⚠️：解析之前必须让CSV文件所有‘,’分隔符用‘{R}’替换不然无法和系统自动生成的区分
class CSVParseKit {
    
    static func shareManager() -> CSVParseKit {
        return CSVParseKitManager.manager
    }
    
    var items:[CSVItem] {
        var _items:[CSVItem] = []
        for item in _tempItems {
            guard item.name.characters.count > 0 && item.name != "\r" else {
                continue
            }
            _items.append(item)
        }
        return _items
    }
    private var _tempItems:[CSVItem] = []
    func parse(file:String) throws -> Void {
        _tempItems.removeAll()
        let pathList = file.components(separatedBy: ".")
        guard pathList.count > 1 else {
            throw CSVParseKitError.fileError
        }
        guard let lastPath = pathList.last else {
            throw CSVParseKitError.fileError
        }
        guard lastPath == "csv" else {
            throw CSVParseKitError.fileError
        }
        let csvContent = try String(contentsOfFile: file)
        let csvLines = csvContent.components(separatedBy: "\r\n")
        guard csvLines.count > 0 else {
            throw CSVParseKitError.fileError
        }
        /// 解析支持的语言
        let supportlanguages = csvLines[0].components(separatedBy: ",")
        for language in supportlanguages {
            let l = formatterValue(value: language)
            let item = CSVItem()
            item.name = l
            _tempItems.append(item)
        }
        
        guard csvLines.count > 1 else {
            return
        }
        
        for c in csvLines.enumerated() {
            guard c.offset > 0 else {
                continue
            }
            let values = c.element.components(separatedBy: ",")
            if values.count != supportlanguages.count {
                print("❌\(c.element)错误,line->\(c.offset)")
                throw CSVParseKitError.fileError
            }
            guard var value0 = values.first else {
                continue
            }
            value0 = formatterValue(value: value0)
            for itemC in _tempItems.enumerated() {
                guard values.count > itemC.offset else {
                    continue
                }
                itemC.element.list[value0] = formatterValue(value: values[itemC.offset])
            }
        }
        
    }
    
    func formatterValue(value:String) -> String {
        var v = value
        let formatters = [
            "{R}":",",
            "\r":"",
            "\n":"",
        ]
        formatters.forEach { (key,value) in
            v = v.replacingOccurrences(of: key, with: value)
        }
        return v
    }
    
}

class CSVItem {
    var name:String = ""
    var list:[String:String] = [:]
}
