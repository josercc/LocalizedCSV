//
//  TranslateStringViewController.swift
//  LocalizedCSV
//
//  Created by 张行 on 2017/10/27.
//  Copyright © 2017年 张行. All rights reserved.
//

import Cocoa

class TranslateStringViewController: NSViewController, NSTextViewDelegate {
    @IBOutlet weak var  replaceTextView:NSTextView!
    @IBOutlet weak var  removeTextView:NSTextView!
    @IBOutlet weak var  stringTextFiled:NSTextField!
    @IBOutlet weak var  resultTextFiled:NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let replaceStr = UserDefaults.standard.object(forKey: "replaceTextView") as? String {
            replaceTextView.string = replaceStr
        }
        if let removeStr = UserDefaults.standard.object(forKey: "removeTextView") as? String {
            removeTextView.string = removeStr
        }
    }
    
    func textDidChange(_ notification: Notification) {
        viewTextDidChnaged(obj: notification)
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        viewTextDidChnaged(obj: obj)
    }
    
    func viewTextDidChnaged(obj:Notification) {
        if let filed = obj.object as? NSTextView ,filed == replaceTextView {
            UserDefaults.standard.set(replaceTextView.string, forKey: "replaceTextView")
            UserDefaults.standard.synchronize()
        } else if let filed = obj.object as? NSTextView , filed == removeTextView {
            UserDefaults.standard.set(removeTextView.string, forKey: "removeTextView")
            UserDefaults.standard.synchronize()
        } else if let filed = obj.object as? NSTextField , filed == stringTextFiled {
            guard let removeString = removeTextView.string else {
                return
            }
            guard let repleaceString = replaceTextView.string else {
                return
            }
            var text = stringTextFiled.stringValue
            let removes = removeString.components(separatedBy: "\n")
            let replaces = repleaceString.components(separatedBy: "\n")
            for t in replaces.enumerated() {
                text = text.replacingOccurrences(of: t.element, with: " ")
            }
            for t in removes.enumerated() {
                text = text.replacingOccurrences(of: t.element, with: "")
            }
            let textList = text.components(separatedBy: " ")
            var result = ""
            for li in textList.enumerated() {
                let content = li.element
                if content.characters.count > 0 {
                    if result.characters.count != 0 {
                        result += "_"
                    }
                    result += content.uppercased()
                }
            }
            resultTextFiled.stringValue = result
        }
    }
    
}
