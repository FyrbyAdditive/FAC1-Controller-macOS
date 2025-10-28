import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var viewController: ViewController!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create menu bar
        setupMenuBar()
        
        // Create window
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 280),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "FAC1 - Pan & Tilt Controller"
        window.center()
        
        // Create and set view controller
        viewController = ViewController()
        window.contentViewController = viewController
        
        window.makeKeyAndOrderFront(nil)
    }
    
    private func setupMenuBar() {
        let mainMenu = NSMenu()
        let appMenuItems = NSMenu()
        
        // Create app menu with Quit option
        let appMenuItem = NSMenuItem(title: "App", action: nil, keyEquivalent: "")
        appMenuItem.submenu = appMenuItems
        
        let quitItem = NSMenuItem(title: "Quit FAC1", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenuItems.addItem(quitItem)
        
        mainMenu.addItem(appMenuItem)
        NSApplication.shared.mainMenu = mainMenu
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldTerminateAutomatically(_ sender: NSApplication) -> Bool {
        return true
    }
}
