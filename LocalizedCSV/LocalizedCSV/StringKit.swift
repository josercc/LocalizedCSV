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
    ///   - left: 左侧原来母语
    ///   - right: 右侧翻译的
    /// - Returns: 如果 YES 代表相等 如果 NO 代表不相等
    static func compareSpecial(special:String, left:String, right:String) -> Bool {
        return findSpecialCount(special: special, source: left) == findSpecialCount(special: special, source: right)
    }
    
    /// 查找字符串中占位符的总数
    ///
    /// - Parameters:
    ///   - special: 占位符
    ///   - source: 查找的字符串
    /// - Returns: 所占的总数
    static func findSpecialCount(special:String, source:String) -> Int {
        var count = 0
        /* 如果已经不存在占位符就返回 */
        guard let range = source.range(of: special) else {
            return count
        }
        /* 如果查找出来则计数+1 */
        count += 1
        /* 切除占位符之后的字符串 */
        let cutSource = source.substring(from: source.index(range.upperBound, offsetBy: 0))
        /* 计数加上剩余占位符的总数 */
        count += findSpecialCount(special: special, source: cutSource)
        return count
    }
}

extension String {
    /* 判断值和翻译的占位符是否一样 */
    func specialEqual(source:String?) -> Bool {
        /* 如果参数不存在 直接返回不相等 */
        guard let source = source else {
            return false
        }
        /* 针对于 iOS 开发特殊的字符 */
        let specials = SettingModel.shareSettingModel().checkPlaceholders
        for special in specials {
            guard StringKit.compareSpecial(special: special, left: self, right: source) else {
                return false
            }
        }
        return true
    }
    
    /// 判断是否包含中文字符
    ///
    /// - Returns:  true 代表包含 false 代表不包含
    func containChineseChar() -> Bool {
        /* 中文的正则表达式 */
        let regularParameter = "[\\u4e00-\\u9fa5]"
        guard let regular = try? NSRegularExpression(pattern: regularParameter, options: NSRegularExpression.Options.caseInsensitive) else {
            return false
        }
        let res = regular.matches(in: self, options: NSRegularExpression.MatchingOptions.anchored, range: NSRange.init(location: 0, length: self.count))
        return res.count > 0
    }
}



