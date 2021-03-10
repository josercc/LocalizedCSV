//
//  PannelKit.swift
//  LocalizedCSV
//
//  Created by 张行 on 2017/8/19.
//  Copyright © 2017年 张行. All rights reserved.
//

import AppKit

class PannelKit {
    static func openFilePannel(fileType:String = "") -> String? {
        return self.openPannel(pannnel: { (pannel) in
            pannel.allowedFileTypes = fileType.count > 0 ? [fileType] : []
            pannel.canChooseFiles = true
            pannel.canChooseDirectories = false
        })
    }
    
    static func openDirectory() -> String? {
        return self.openPannel(pannnel: { (pannel) in
            pannel.canChooseDirectories = true
            pannel.canChooseFiles = false
        })
    }
    
    static func openPannel(pannnel:((_ make:NSOpenPanel) -> Void)) -> String? {
        let openPannel = NSOpenPanel()
        pannnel(openPannel)
        guard openPannel.runModal().rawValue == NSFileHandlingPanelOKButton else {
            return nil
        }
        return openPannel.urls.first?.absoluteString.replacingOccurrences(of: "file://", with: "")
    }
}
