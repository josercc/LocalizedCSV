//
//  LocalLanguagesViewController.swift
//  LocalizedCSV
//
//  Created by 张行 on 2017/9/5.
//  Copyright © 2017年 张行. All rights reserved.
//

import Cocoa

/// 本地数据源列表
class LocalLanguagesViewController: NSViewController, NSTableViewDataSource {
    @IBOutlet weak var tableView:NSTableView!
    @IBOutlet weak var textFiled:NSTextField!
    var normalLanguage:String?
    var languages:[String] = []
    var didClickLanguageCompletionHandle:((_ language:String) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        LanguageSourceKit.languages().forEach { (model) in
            guard let name = model.name else {
                return
            }
            languages.append(name)
        }
        self.tableView.reloadData()
        if let language = normalLanguage {
            self.textFiled.stringValue = language
        }
        self.tableView.doubleAction = #selector(self.doubleClick)
    }
    
    @objc func doubleClick() {
        let index = self.tableView.selectedRow
        self.didClickLanguageCompletionHandle?(languages[index])
    }
    
    @IBAction func add(_ sender:Any?) {
        guard self.textFiled.stringValue.count > 0 && !languages.contains(self.textFiled.stringValue) else {
            return
        }
        languages.append(self.textFiled.stringValue)
        self.tableView.reloadData()
    }
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return languages.count
    }
    
    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return languages[row]
    }
}
