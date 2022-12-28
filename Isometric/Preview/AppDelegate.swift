//
//  AppDelegate.swift
//  Preview
//
//  Created by Nicolas Seriot on 17.10.21.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: NSWindow!
    var vc: ViewController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let vc = ViewController()
        self.vc = vc

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = vc.view
        window.makeKeyAndOrderFront(nil)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}
