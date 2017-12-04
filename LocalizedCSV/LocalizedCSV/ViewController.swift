//
//  ViewController.swift
//  LocalizedCSV
//
//  Created by 张行 on 2017/8/17.
//  Copyright © 2017年 张行. All rights reserved.
//

import Cocoa


class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var tableView: NSTableView! {
        didSet {
            self.tableView.target = self
            self.tableView.doubleAction = #selector(self.pushDetail)
        }
    }
    var canReadloadData = false
    @IBOutlet weak var SVGTextFiled: NSTextField!
    @IBOutlet weak var localizeStringTextFiled: NSTextField!
    let csvParse:CSVParseKit = CSVParseKit.shareManager()
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func readSVGFile(_ sender: NSButton) {
        self.SVGTextFiled.stringValue = getFile(fileType: "csv")
        parse(parse: { 
            do {
                try self.csvParse.parse(file: self.SVGTextFiled.stringValue)
                self.canReadloadData = true
            } catch {
                self.canReadloadData = false
                DispatchQueue.main.sync {
                    let alert = NSAlert()
                    alert.messageText = "CSV 文件错误"
                    alert.runModal()
                }
            }
        }) {
            if self.canReadloadData {
                self.tableView.reloadData()
            }
        }
    }
    
    func parse(parse:@escaping (() -> Void), completion:@escaping (() -> Void)) {
        DispatchQueue.global().async {
            parse()
            DispatchQueue.main.sync {
                completion()
            }
        }
    }
    
    @IBAction func readLocalizeStringFile(_ sender: NSButton) {
        self.localizeStringTextFiled.stringValue = getFile(fileType: "strings")
//        parse(parse: {
            try? LocalizeStringKit.shareManager().parse(filePath: self.localizeStringTextFiled.stringValue)
//        }) {
			var stringList = self.localizeStringTextFiled.stringValue.components(separatedBy: "/")
			stringList.removeLast()
			stringList.removeLast()
			SettingModel.shareSettingModel().projectRootPath = stringList.joined(separator: "/")
			print(SettingModel.shareSettingModel().projectRootPath!)
//        }
    }
    
    func getFile(fileType:String) -> String {
        let openPannel = NSOpenPanel()
        openPannel.allowedFileTypes = [fileType]
        openPannel.canChooseFiles = true
        openPannel.canChooseDirectories = false
        guard openPannel.runModal() == NSFileHandlingPanelOKButton else {
            return ""
        }
        return openPannel.urls.first?.absoluteString.replacingOccurrences(of: "file://", with: "") ?? ""
    }
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return csvParse.items.count
    }
    
    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let item  = csvParse.items[row]
        if let column = tableColumn, let cell = column.dataCell as? NSTextFieldCell {
            let color = NSColor.lightGray
            cell.backgroundColor = color
            cell.drawsBackground = true
        }
        return item.name
    }
    
    func pushDetail() {
        guard self.localizeStringTextFiled.stringValue.characters.count > 0 else {
            let alert = NSAlert()
            alert.messageText = "必须选择Strings文件"
            alert.alertStyle = .warning
            alert.runModal()
            return
        }
        guard tableView.selectedRow >= 0 else {
            return
        }
        guard let controller = self.storyboard?.instantiateController(withIdentifier: "LanguageValueController") as? LanguageValueController else {
            return
        }
        controller.item = csvParse.items[tableView.selectedRow]
        self.presentViewControllerAsModalWindow(controller)
    }
    
}

