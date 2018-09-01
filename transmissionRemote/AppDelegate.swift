//
//  AppDelegate.swift
//  transmitRemote
//
//  Created by Derek Oakley on 18/08/2018.
//  Copyright © 2018 Derek Oakley. All rights reserved.
//

import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBAction func torrentsWindowMenuItem(_ sender: NSMenuItem) {
        for window in NSApplication.shared.windows {
            if (window.delegate?.isKind(of: NSWindowController.self)) == true {
                window.makeKeyAndOrderFront(self)
            }
        }
    }

    func applicationWillFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(AppDelegate.handleGetURLEvent(event:replyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if (flag == false) {
             for window in sender.windows {
                if (window.delegate?.isKind(of: NSWindowController.self)) == true {
                    window.makeKeyAndOrderFront(self)
                }
            }
        }
        return false;
    }
    
    @objc private func handleGetURLEvent(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue!
        getTransmissionSessionId() { result in
            torrentAdd(filename: urlString!) { result in
                if (result == true) {
                    NotificationCenter.default.post(name: Notification.Name("torrentGetAndUpdateTableView"), object: nil)
                }
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
