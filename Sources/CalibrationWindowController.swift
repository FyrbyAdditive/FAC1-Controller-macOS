import Cocoa

class CalibrationViewController: NSViewController {
    private var servoController: ServoController
    private var instructionLabel: NSTextField!
    private var calibrateButton: NSButton!
    private var cancelButton: NSButton!
    private var statusLabel: NSTextField!
    
    init(servoController: ServoController) {
        self.servoController = servoController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 250))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        disableTorque()
    }
    
    private func setupUI() {
        // Instruction label
        instructionLabel = NSTextField(labelWithString: """
        Motor torque has been released.
        
        Please manually move the camera to the desired
        default position (center position).
        
        Hold it steady and press "Calibrate" to save
        this position as the center point.
        """)
        instructionLabel.frame = NSRect(x: 20, y: 120, width: 360, height: 100)
        instructionLabel.alignment = .center
        instructionLabel.font = NSFont.systemFont(ofSize: 13)
        view.addSubview(instructionLabel)
        
        // Status label
        statusLabel = NSTextField(labelWithString: "")
        statusLabel.frame = NSRect(x: 20, y: 90, width: 360, height: 20)
        statusLabel.alignment = .center
        statusLabel.font = NSFont.systemFont(ofSize: 11)
        statusLabel.textColor = .systemGray
        view.addSubview(statusLabel)
        
        // Calibrate button
        calibrateButton = NSButton(title: "Calibrate", target: self, action: #selector(calibratePressed))
        calibrateButton.frame = NSRect(x: 150, y: 40, width: 100, height: 32)
        calibrateButton.bezelStyle = .rounded
        calibrateButton.keyEquivalent = "\r"
        view.addSubview(calibrateButton)
        
        // Cancel button
        cancelButton = NSButton(title: "Cancel", target: self, action: #selector(cancelPressed))
        cancelButton.frame = NSRect(x: 150, y: 10, width: 100, height: 28)
        cancelButton.bezelStyle = .rounded
        cancelButton.keyEquivalent = "\u{1b}"
        view.addSubview(cancelButton)
    }
    
    private func disableTorque() {
        statusLabel.stringValue = "Releasing motor torque..."
        servoController.disableTorque()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.statusLabel.stringValue = "Motors are now free to move"
        }
    }
    
    @objc private func calibratePressed() {
        calibrateButton.isEnabled = false
        cancelButton.isEnabled = false
        statusLabel.stringValue = "Calibrating..."
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let success = self.servoController.calibrateCenter()
            
            DispatchQueue.main.async {
                if success {
                    self.statusLabel.stringValue = "✓ Calibration successful!"
                    self.statusLabel.textColor = .systemGreen
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        self?.closeSheet()
                    }
                } else {
                    self.statusLabel.stringValue = "✗ Calibration failed"
                    self.statusLabel.textColor = .systemRed
                    self.calibrateButton.isEnabled = true
                    self.cancelButton.isEnabled = true
                }
            }
        }
    }
    
    @objc private func cancelPressed() {
        servoController.enableTorque()
        closeSheet()
    }
    
    private func closeSheet() {
        servoController.enableTorque()
        
        if let window = view.window, let sheetParent = window.sheetParent {
            sheetParent.endSheet(window)
        }
    }
}
