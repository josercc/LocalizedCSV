//
//  StringKit.swift
//  LocalizedCSV
//
//  Created by 张行 on 2017/8/19.
//  Copyright © 2017年 张行. All rights reserved.
//

import Foundation


/// 字符串工具
class StringKit {
    /// * 比较特殊字符翻译和原来的是否相等
    ///
    /// - Parameters:
    ///   - left: 左侧原来
    ///   - right: 右侧翻译的
    /// - Returns: 如果 YES 代表相等 如果 NO 代表不相等
    static func compareSpecial(special:String, left:String, right:String) -> Bool {
        return findSpecialCount(special: special, source: left) == findSpecialCount(special: special, source: right)
    }
    
    static func findSpecialCount(special:String, source:String) -> Int {
        var count = 0
        guard let range = source.range(of: special) else {
            return count
        }
        let cutSource = source.substring(from: source.index(range.upperBound, offsetBy: 0))
        count += findSpecialCount(special: special, source: cutSource)
        return count
    }
}

extension String {
    func specialEqual(source:String?) -> Bool {
        guard let source = source else {
            return false
        }
        let specials = ["%@","%%","\\n",":","*","...","&",">","?"]
        for special in specials {
            guard StringKit.compareSpecial(special: special, left: self, right: source) else {
                return false
            }
        }
        return true
    }
    
    func containChineseChar() -> Bool {
        let regularParameter = "[\\u4e00-\\u9fa5]"
        guard let regular = try? NSRegularExpression(pattern: regularParameter, options: NSRegularExpression.Options.caseInsensitive) else {
            return false
        }
        let res = regular.matches(in: self, options: NSRegularExpression.MatchingOptions.anchored, range: NSRange.init(location: 0, length: self.characters.count))
        return res.count > 0
    }
}



