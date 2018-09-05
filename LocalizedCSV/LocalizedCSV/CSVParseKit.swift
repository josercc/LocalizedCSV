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
    
    /* 获取解析 CSV 文件库的单利 */
    static func shareManager() -> CSVParseKit {
        return CSVParseKitManager.manager
    }
    
    /* 获取解析 CSV 出来的数据 */
    var items:[CSVItem] {
        /* 存放数据的临时数组 */
        var _items:[CSVItem] = []
        /* 遍历所有的临时数据 */
        for item in _tempItems {
            /* 如果翻译表的名称不存在 或者 名字是换行就继续遍历 */
            guard item.name.count > 0 && item.name != "\r" else {
                continue
            }
            _items.append(item)
        }
        return _items
    }
    /* 存在解析出来的临时数据 */
    private var _tempItems:[CSVItem] = []
    
    /// 解析指定的 CSV 文件
    ///
    /// - Parameter file:  CSV 文件路径
    /// - Throws: 解析出错抛出的异常
    func parse(file:String) throws -> Void {
        /* 移除之前的临时旧数据 */
        _tempItems.removeAll()
        /* 指定的文件后缀是否是 csv 如果不是抛出异常 */
        guard FileKit.isSuffixType(typeName: "csv", filePath: file) else {
            throw CSVParseKitError.fileError
        }
        /* 获取 CSV 中的内容 */
        var csvContent = try String(contentsOfFile: file)
        /* 按照\r\n 切割内容为一个数组 */
        var csvLines = csvContent.components(separatedBy: "\r\n")
        /* 如果切割不出来则抛出异常 */
        guard csvLines.count > 0 else {
            throw CSVParseKitError.fileError
        }
        /* 翻译的多语言的名称列表 */
        let supportlanguages = csvLines[0].components(separatedBy: ",")
        /* 遍历所有的多语言名称 */
        for language in supportlanguages {
            /* 获取格式化之后的多语言名称 */
            let l = formatterValue(value: language)
            let item = CSVItem()
            item.name = l
            _tempItems.append(item)
        }
        
        /* 如果只能解析出一行 返回报错 */
        guard csvLines.count > 1 else {
            throw CSVParseKitError.fileError
        }
        
        /* 遍历全部的数据 */
        for c in csvLines.enumerated() {
            /* 如果是第一行 跳过 */
            guard c.offset > 0 else {
                continue
            }
            /* 获取值切割的数组 */
            let values = c.element.components(separatedBy: ",")
            /* 如果值的数组不等于支持的语言的数组个数 则报错 */
            if values.count != supportlanguages.count {
                throw CSVParseKitError.fileError
            }
            /* 如果第一个值获取不到则继续 */
            guard var value0 = values.first else {
                continue
            }
            /* 格式化获取到的值 */
            value0 = formatterValue(value: value0)
            
            /* 遍历已经存在的数据列表 */
            for itemC in _tempItems.enumerated() {
                /* 如果存在的值数组已经大于或者等于 切割的值的数组个数 则跳过 */
                guard values.count > itemC.offset else {
                    continue
                }
                itemC.element.list[value0] = formatterValue(value: values[itemC.offset])
            }
        }
    }
    
    /// 格式化多语言标题
    ///
    /// - Parameter value: 多语言标题
    /// - Returns: 格式化之后多语言标题
    func formatterValue(value:String) -> String {
        var v = value
        /* 需要格式化的占位符 */
        let formatters = [
            "{R}":",",
            "\r":"",
            "\u{08}":"",
        ]
        formatters.forEach { (key,value) in
            v = v.replacingOccurrences(of: key, with: value)
        }
        return v
    }
    
    /// 获取指定语言名称的数据对象
    ///
    /// - Parameter name: 指定的语言名称
    /// - Returns: 查找出来的数据对象
    func getLanguageItem(name:String) -> CSVItem? {
        var findItem:CSVItem?
        self.items.forEach { (item) in
            if item.name == name {
                findItem = item
            }
        }
        return findItem
    }
    
}

class CSVItem {
    var name:String = ""
    var list:[String:String] = [:]
}
