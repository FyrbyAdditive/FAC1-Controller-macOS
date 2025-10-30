import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var viewController: ViewController!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create and set view controller first
        viewController = ViewController()
        
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
        
        window.contentViewController = viewController
        
        window.makeKeyAndOrderFront(nil)
    }
    
    private func setupMenuBar() {
        let mainMenu = NSMenu()
        
        // App menu
        let appMenuItems = NSMenu()
        let appMenuItem = NSMenuItem(title: "App", action: nil, keyEquivalent: "")
        appMenuItem.submenu = appMenuItems
        
        let aboutItem = NSMenuItem(title: "About FAC1", action: #selector(openAbout), keyEquivalent: "")
        appMenuItems.addItem(aboutItem)
        
        appMenuItems.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit FAC1", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenuItems.addItem(quitItem)
        
        mainMenu.addItem(appMenuItem)
        
        // Calibration menu
        let calibrationMenuItems = NSMenu(title: "Calibration")
        let calibrationMenuItem = NSMenuItem(title: "Calibration", action: nil, keyEquivalent: "")
        calibrationMenuItem.submenu = calibrationMenuItems
        
        let calibrateItem = NSMenuItem(title: "Calibrate Center Position", action: #selector(openCalibration), keyEquivalent: "k")
        calibrationMenuItems.addItem(calibrateItem)
        
        calibrationMenuItems.addItem(NSMenuItem.separator())
        
        // Invert controls menu items
        let invertPanItem = NSMenuItem(title: "Invert Pan", action: #selector(toggleInvertPan), keyEquivalent: "")
        invertPanItem.state = UserDefaults.standard.bool(forKey: "invertPan") ? .on : .off
        calibrationMenuItems.addItem(invertPanItem)
        
        let invertTiltItem = NSMenuItem(title: "Invert Tilt", action: #selector(toggleInvertTilt), keyEquivalent: "")
        invertTiltItem.state = UserDefaults.standard.bool(forKey: "invertTilt") ? .on : .off
        calibrationMenuItems.addItem(invertTiltItem)
        
        mainMenu.addItem(calibrationMenuItem)
        
        NSApplication.shared.mainMenu = mainMenu
    }
    
    @objc private func openAbout() {
        let aboutVC = AboutViewController()
        viewController.presentAsSheet(aboutVC)
    }
    
    @objc private func toggleInvertPan(_ sender: NSMenuItem) {
        viewController.servoController.invertPan.toggle()
        sender.state = viewController.servoController.invertPan ? .on : .off
    }
    
    @objc private func toggleInvertTilt(_ sender: NSMenuItem) {
        viewController.servoController.invertTilt.toggle()
        sender.state = viewController.servoController.invertTilt ? .on : .off
    }
    
    @objc private func openCalibration() {
        guard let servoController = viewController?.servoController else { return }
        
        let calibrationVC = CalibrationViewController(servoController: servoController)
        
        // Present as sheet
        viewController.presentAsSheet(calibrationVC)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldTerminateAutomatically(_ sender: NSApplication) -> Bool {
        return true
    }
}
