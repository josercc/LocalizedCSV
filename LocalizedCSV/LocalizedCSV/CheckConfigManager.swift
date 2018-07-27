//
//  CheckConfigManager.swift
//  LocalizedCSV
//
//  Created by 张行 on 2018/7/27.
//  Copyright © 2018年 张行. All rights reserved.
//

import AppKit

/*
俄语-Русский язык:ru
匈牙利语-Hungarian:hu
阿拉伯语-اللغة العربية:ar
葡萄牙葡萄牙语-Português-:pt-PT
印尼-indonesian:id
波兰—Polski:pl
土耳其-Türkçe:tr
西语-español:es
法语-french:fr
以色列（希伯来语）-Hebrew:he-IL
意大利-Italiano:it
希腊-greece:el
巴葡-português brasileiro:pt-BR
德语-Deutsch:de
荷兰语-dutch:nl
 */
/* 检查配置 */
class CheckConfigManager {
    /* 检查的工程是否配置好 */
    static func checkConfigReadySuccess() -> Bool {
        /* 先检车配置 */
        guard SettingModel.shareSettingModel().projectLanguageCode.count > 0 else {
            let alert = NSAlert()
            alert.messageText = "检测你还没有配置多语言简码，无法继续操作，请进行配置。"
            let response = alert.runModal()
            if response == NSFileHandlingPanelCancelButton {
                if let settingController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "SettingViewController") as? SettingViewController {
                    let window = NSWindow(contentViewController: settingController)
                    let windowController = NSWindowController(window: window)
                    windowController.showWindow(nil)
                }
                
            }
            return false
        }
        guard FindLocalizeStringKit.shareManager().list.count > 0 else {
            let alert = NSAlert()
            alert.messageText = "检测你还没有读取工程多语言，无法继续操作，请进行读取。"
            let response = alert.runModal()
            if response == NSFileHandlingPanelCancelButton {
                if let appDelegate = NSApp.delegate as? AppDelegate {
                    appDelegate.findProjLocalizeString()
                }
            }
            return false
        }
        return true
    }
}
