import Cocoa

class AboutViewController: NSViewController {
    
    override func loadView() {
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 350))
        self.view = containerView
        
        // Logo
        let logoView = NSImageView(frame: NSRect(x: 125, y: 220, width: 150, height: 150))
        logoView.imageScaling = .scaleProportionallyUpOrDown
        
        // Load logo from project root
        let logoPath = FileManager.default.currentDirectoryPath + "/FAME-150-150.png"
        if let logo = NSImage(contentsOfFile: logoPath) {
            logoView.image = logo
        } else {
            print("Warning: Could not load logo from: \(logoPath)")
        }
        
        containerView.addSubview(logoView)
        
        // App name
        let appNameLabel = NSTextField(labelWithString: "FAC1 Controller")
        appNameLabel.font = NSFont.systemFont(ofSize: 20, weight: .semibold)
        appNameLabel.alignment = .center
        appNameLabel.frame = NSRect(x: 50, y: 160, width: 300, height: 30)
        containerView.addSubview(appNameLabel)
        
        // Version
        let versionLabel = NSTextField(labelWithString: "Version 1.0")
        versionLabel.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        versionLabel.textColor = NSColor.secondaryLabelColor
        versionLabel.alignment = .center
        versionLabel.frame = NSRect(x: 50, y: 140, width: 300, height: 20)
        containerView.addSubview(versionLabel)
        
        // Copyright
        let copyrightLabel = NSTextField(labelWithString: "Copyright © 2025")
        copyrightLabel.font = NSFont.systemFont(ofSize: 11, weight: .regular)
        copyrightLabel.textColor = NSColor.secondaryLabelColor
        copyrightLabel.alignment = .center
        copyrightLabel.frame = NSRect(x: 50, y: 100, width: 300, height: 20)
        containerView.addSubview(copyrightLabel)
        
        // Author
        let authorLabel = NSTextField(labelWithString: "Timothy Ellis")
        authorLabel.font = NSFont.systemFont(ofSize: 11, weight: .regular)
        authorLabel.textColor = NSColor.secondaryLabelColor
        authorLabel.alignment = .center
        authorLabel.frame = NSRect(x: 50, y: 80, width: 300, height: 20)
        containerView.addSubview(authorLabel)
        
        // Company
        let companyLabel = NSTextField(labelWithString: "Fyrby Additive Manufacturing & Engineering")
        companyLabel.font = NSFont.systemFont(ofSize: 11, weight: .regular)
        companyLabel.textColor = NSColor.secondaryLabelColor
        companyLabel.alignment = .center
        companyLabel.frame = NSRect(x: 50, y: 60, width: 300, height: 20)
        containerView.addSubview(companyLabel)
        
        // Close button
        let closeButton = NSButton(frame: NSRect(x: 150, y: 20, width: 100, height: 30))
        closeButton.title = "OK"
        closeButton.bezelStyle = .rounded
        closeButton.target = self
        closeButton.action = #selector(closeWindow)
        closeButton.keyEquivalent = "\r" // Enter key
        containerView.addSubview(closeButton)
    }
    
    @objc private func closeWindow() {
        dismiss(self)
    }
}
