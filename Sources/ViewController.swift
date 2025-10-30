import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {
    var servoController: ServoController!
    
    // UI Elements
    private var statusIndicator: NSView!
    private var statusLabel: NSTextField!
    private var portLabel: NSTextField!
    private var reconnectButton: NSButton!
    private var alwaysOnTopCheckbox: NSButton!
    
    // Arrow buttons
    private var upButton: NSButton!
    private var downButton: NSButton!
    private var leftButton: NSButton!
    private var rightButton: NSButton!
    
    // Connection status update timer
    private var statusUpdateTimer: Timer?
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 280))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        servoController = ServoController()
        setupUI()
        
        // Auto-connect on startup (must be on main thread - SDK is single-threaded)
        servoController.autoConnect()
        updateStatus()
        
        // Setup periodic status updates
        statusUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateStatus()
        }
    }
    
    deinit {
        statusUpdateTimer?.invalidate()
    }
    
    private func setupUI() {
        let contentView = view
        
        // Always on top checkbox - positioned above the arrows, centered
        alwaysOnTopCheckbox = NSButton(checkboxWithTitle: "Always on Top", target: self, action: #selector(alwaysOnTopToggled))
        alwaysOnTopCheckbox.frame = NSRect(x: 90, y: 250, width: 120, height: 24)
        contentView.addSubview(alwaysOnTopCheckbox)
        
        // Arrow buttons in cross pattern
        let centerX: CGFloat = 150
        let centerY: CGFloat = 130
        let spacing: CGFloat = 60
        let buttonSize = NSSize(width: 50, height: 50)
        
        // Up button
        upButton = createArrowButton(symbol: "↑", color: .systemBlue)
        upButton.frame = NSRect(
            origin: NSPoint(x: centerX - buttonSize.width / 2, y: centerY + spacing),
            size: buttonSize
        )
        upButton.target = self
        upButton.action = #selector(upPressed)
        contentView.addSubview(upButton)
        
        // Down button
        downButton = createArrowButton(symbol: "↓", color: .systemBlue)
        downButton.frame = NSRect(
            origin: NSPoint(x: centerX - buttonSize.width / 2, y: centerY - spacing),
            size: buttonSize
        )
        downButton.target = self
        downButton.action = #selector(downPressed)
        contentView.addSubview(downButton)
        
        // Left button
        leftButton = createArrowButton(symbol: "←", color: .systemGreen)
        leftButton.frame = NSRect(
            origin: NSPoint(x: centerX - spacing - buttonSize.width / 2, y: centerY),
            size: buttonSize
        )
        leftButton.target = self
        leftButton.action = #selector(leftPressed)
        contentView.addSubview(leftButton)
        
        // Right button
        rightButton = createArrowButton(symbol: "→", color: .systemGreen)
        rightButton.frame = NSRect(
            origin: NSPoint(x: centerX + spacing - buttonSize.width / 2, y: centerY),
            size: buttonSize
        )
        rightButton.target = self
        rightButton.action = #selector(rightPressed)
        contentView.addSubview(rightButton)
        
        // Status bar at bottom
        setupStatusBar()
    }
    
    private func setupStatusBar() {
        let barWidth: CGFloat = 300
        
        // Status bar background
        let statusBar = NSView()
        statusBar.frame = NSRect(x: 0, y: 0, width: 300, height: 40)
        statusBar.wantsLayer = true
        statusBar.layer?.backgroundColor = NSColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0).cgColor
        view.addSubview(statusBar)
        
        // Status indicator dot
        statusIndicator = NSView()
        statusIndicator.frame = NSRect(x: 8, y: 18, width: 16, height: 16)
        statusIndicator.wantsLayer = true
        statusIndicator.layer?.backgroundColor = NSColor.red.cgColor
        statusIndicator.layer?.cornerRadius = 8
        statusBar.addSubview(statusIndicator)
        
        // Status label - expanded width
        statusLabel = NSTextField(frame: NSRect(x: 36, y: 18, width: 190, height: 16))
        statusLabel.stringValue = "Initializing..."
        statusLabel.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        statusLabel.textColor = .labelColor
        statusLabel.isEditable = false
        statusLabel.isBezeled = false
        statusLabel.drawsBackground = false
        statusBar.addSubview(statusLabel)
        
        // Port label (smaller secondary text)
        portLabel = NSTextField(labelWithString: "")
        portLabel.frame = NSRect(x: 36, y: 4, width: 160, height: 12)
        portLabel.font = NSFont.systemFont(ofSize: 9, weight: .regular)
        portLabel.textColor = .systemGray
        portLabel.isEditable = false
        portLabel.isBezeled = false
        portLabel.drawsBackground = false
        statusBar.addSubview(portLabel)
        
        // Reconnect button - positioned on the right side
        reconnectButton = NSButton(title: "Reconnect", target: self, action: #selector(reconnectPressed))
        reconnectButton.frame = NSRect(x: barWidth - 90, y: 8, width: 82, height: 24)
        reconnectButton.bezelStyle = .rounded
        reconnectButton.font = NSFont.systemFont(ofSize: 10, weight: .semibold)
        reconnectButton.contentTintColor = .systemBlue
        reconnectButton.wantsLayer = true
        reconnectButton.layer?.backgroundColor = NSColor.systemBlue.cgColor
        reconnectButton.layer?.cornerRadius = 4
        
        // Make button text visible
        let attrTitle = NSAttributedString(string: "Reconnect", attributes: [
            .font: NSFont.systemFont(ofSize: 10, weight: .semibold),
            .foregroundColor: NSColor.white
        ])
        reconnectButton.attributedTitle = attrTitle
        
        statusBar.addSubview(reconnectButton)
    }
    
    private func createArrowButton(symbol: String, color: NSColor) -> NSButton {
        let button = NSButton()
        button.title = ""
        button.bezelStyle = .circular
        button.isBordered = true
        button.wantsLayer = true
        button.layer?.cornerRadius = 25
        button.layer?.backgroundColor = NSColor(white: 0.15, alpha: 1.0).cgColor
        button.layer?.borderColor = color.cgColor
        button.layer?.borderWidth = 2.5
        
        // Create attributed string for arrow with proper sizing and centering
        let arrowAttr = NSAttributedString(string: symbol, attributes: [
            .font: NSFont.systemFont(ofSize: 28, weight: .semibold),
            .foregroundColor: color
        ])
        button.attributedTitle = arrowAttr
        
        // Add hover effect
        button.wantsLayer = true
        return button
    }
    
    @objc private func upPressed() {
        servoController.moveTilt(direction: .up)
    }
    
    @objc private func downPressed() {
        servoController.moveTilt(direction: .down)
    }
    
    @objc private func leftPressed() {
        servoController.movePan(direction: .left)
    }
    
    @objc private func rightPressed() {
        servoController.movePan(direction: .right)
    }
    
    // MARK: - NSTextFieldDelegate
    
    func controlTextDidEndEditing(_ obj: Notification) {
        // No longer needed
    }
    
    @objc private func alwaysOnTopToggled() {
        if let window = view.window {
            if alwaysOnTopCheckbox.state == .on {
                window.level = .floating
            } else {
                window.level = .normal
            }
        }
    }
    
    @objc private func reconnectPressed() {
        if servoController.isConnected {
            // Disconnect
            reconnectButton.isEnabled = false
            reconnectButton.attributedTitle = NSAttributedString(string: "Disconnecting...", attributes: [
                .font: NSFont.systemFont(ofSize: 11, weight: .semibold),
                .foregroundColor: NSColor.white
            ])
            servoController.disconnect()
            updateStatus()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.reconnectButton.isEnabled = true
                self?.updateButtonTitle()
            }
        } else {
            // Reconnect
            reconnectButton.isEnabled = false
            reconnectButton.attributedTitle = NSAttributedString(string: "Connecting...", attributes: [
                .font: NSFont.systemFont(ofSize: 11, weight: .semibold),
                .foregroundColor: NSColor.white
            ])
            servoController.autoConnect()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.updateStatus()
                self?.reconnectButton.isEnabled = true
                self?.updateButtonTitle()
            }
        }
    }
    
    private func updateButtonTitle() {
        let title = servoController.isConnected ? "Disconnect" : "Reconnect"
        reconnectButton.attributedTitle = NSAttributedString(string: title, attributes: [
            .font: NSFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: NSColor.white
        ])
    }
    
    private func updateStatus() {
        let statusText = servoController.connectionStatus
        
        // Color coding based on actual connection status text
        let textColor: NSColor
        let bgColor: CGColor
        
        if statusText == "Connected" {
            textColor = .systemGreen
            bgColor = NSColor.systemGreen.cgColor
        } else if statusText == "No USB connection" {
            textColor = .systemRed
            bgColor = NSColor.systemRed.cgColor
        } else {
            // Partial connection (one servo missing)
            textColor = .systemOrange
            bgColor = NSColor.systemOrange.cgColor
        }
        
        statusLabel.stringValue = statusText
        statusLabel.textColor = textColor
        portLabel.stringValue = servoController.connectedPort ?? ""
        statusIndicator.layer?.backgroundColor = bgColor
        
        updateButtonTitle()
    }
}
