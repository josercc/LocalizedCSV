//
//  AppDelegate.swift
//  LocalizedCSV
//
//  Created by 张行 on 2017/8/17.
//  Copyright © 2017年 张行. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
    
    /// 查找工程里面的国际化字符串 默认为 NSLocalizedString
    ///
    /// - Parameter sender: 执行的按钮
    @IBAction func findProjLocalizeString(_ sender: Any) {
        guard let path = FileKit.getDirectory() else {
            return
        }
        guard let rootController = NSApp.mainWindow?.contentViewController else {
            return
        }
        guard let controller = "FindLocalizeStringController".findController() as? FindLocalizeStringController else {
            return
        }
        controller.findPath = path
        rootController.presentViewControllerAsSheet(controller)
        
    }
    
    @IBAction func checkProjectAllString(_ sender: Any) {
        FilndUnLocalizeStringKit().findAll()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        for window in sender.windows {
            window.makeKeyAndOrderFront(nil)
        }
        return true
    }
    
}

extension String {
    func findController() -> NSViewController? {
        guard let rootController = NSApp.mainWindow?.contentViewController else {
            return nil
        }
        guard let controller = rootController.storyboard?.instantiateController(withIdentifier: self) as? FindLocalizeStringController else {
            return nil
        }
        return controller;
    }
}

