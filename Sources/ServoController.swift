import Foundation
import SCServoSDK

enum PanDirection {
    case left, right
}

enum TiltDirection {
    case up, down
}

class ServoController {
    private var portHandler: PortHandler?
    private var packetHandler: PacketHandlerProtocol?
    
    private var panServoId: UInt8 = 6
    private var tiltServoId: UInt8 = 4
    
    private let baudRate: UInt32 = 1000000
    private let protocolEnd = 0  // STS series (STS3250)
    
    // Position tracking
    private var currentPanPosition: UInt16 = 2048  // Middle position
    private var currentTiltPosition: UInt16 = 2048
    
    // Movement parameters
    private let positionStep: UInt16 = 100  // How much to move per button press
    private let minPosition: UInt16 = 0     // Full 360-degree range
    private let maxPosition: UInt16 = 4095  // Full 360-degree range
    private let movingSpeed: UInt16 = 200  // Moderate speed
    private let movingAcc: UInt8 = 50
    
    var isConnected: Bool {
        guard let port = portHandler, port.isOpen else { return false }
        // Just check if USB is open - report servo status separately via connectionStatus
        return true
    }
    
    var connectionStatus: String {
        guard let port = portHandler, port.isOpen else { 
            return "No USB connection"
        }
        
        let (_, panResult, _) = packetHandler?.ping(port, servoId: panServoId) ?? (0, .notAvailable, ProtocolError(rawValue: 0))
        let (_, tiltResult, _) = packetHandler?.ping(port, servoId: tiltServoId) ?? (0, .notAvailable, ProtocolError(rawValue: 0))
        
        let panOk = panResult == .success
        let tiltOk = tiltResult == .success
        
        if panOk && tiltOk {
            return "Connected"
        } else if panOk {
            return "Pan OK, Tilt missing"
        } else if tiltOk {
            return "Tilt OK, Pan missing"
        } else {
            return "No servos found"
        }
    }
    
    private func verifyConnection() -> Bool {
        guard let port = portHandler, let handler = packetHandler else { return false }
        let (_, panResult, _) = handler.ping(port, servoId: panServoId)
        let (_, tiltResult, _) = handler.ping(port, servoId: tiltServoId)
        return panResult == .success && tiltResult == .success
    }
    
    var connectedPort: String? {
        return portHandler?.portName
    }
    
    init() {
        // Initialize packet handler
        packetHandler = createPacketHandler(protocolEnd: protocolEnd)
    }
    
    // MARK: - Connection Management
    
    func autoConnect() {
        print("Searching for USB-serial devices...")
        
        let availablePorts = PortHandler.availablePorts()
        
        // Filter for common USB serial port patterns on macOS
        let usbPorts = availablePorts.filter { port in
            port.contains("usbserial") || port.contains("usbmodem")
        }.filter { port in
            // Prefer cu. over tty. for better compatibility
            port.contains("/dev/cu.")
        }
        
        print("Found USB ports: \(usbPorts)")
        
        // Try each port
        for portName in usbPorts {
            print("Trying to connect to: \(portName)")
            if testPingExactlyCopyingExample(portName: portName) {
                print("Successfully connected to: \(portName)")
                return
            }
        }
        
        print("Could not auto-connect to any USB-serial port")
    }
    
    // Test using EXACT code from ping example
    private func testPingExactlyCopyingExample(portName: String) -> Bool {
        print("\n=== Testing connection ===")
        
        // Initialize PortHandler
        let portHandler = PortHandler(portName: portName)
        
        // Initialize PacketHandler
        let packetHandler = createPacketHandler(protocolEnd: 0)
        
        do {
            // Open port
            try portHandler.openPort()
            print("✓ Succeeded to open the port: \(portName)")
        } catch {
            print("✗ Failed to open the port: \(error)")
            return false
        }
        
        do {
            // Set port baudrate
            try portHandler.setBaudRate(1000000)
            print("✓ Succeeded to change the baudrate to 1000000")
        } catch {
            print("✗ Failed to change the baudrate: \(error)")
            portHandler.closePort()
            return false
        }
        
        // Store the connection regardless of servo status
        self.portHandler = portHandler
        self.packetHandler = packetHandler
        print("USB connection established on \(portName)")
        
        // Try ping both servos
        print("\nPinging servo with ID 4...")
        let (modelNumber, commResult, protocolError) = packetHandler.ping(portHandler, servoId: 4)
        let panFound = commResult == .success && protocolError.isEmpty
        if panFound {
            print("✓ [ID:004] ping Succeeded! Model: \(modelNumber)")
        } else {
            print("✗ [ID:004] not responding")
        }
        
        print("\nPinging servo with ID 6...")
        let (model2, comm2, proto2) = packetHandler.ping(portHandler, servoId: 6)
        let tiltFound = comm2 == .success && proto2.isEmpty
        if tiltFound {
            print("✓ [ID:006] ping Succeeded! Model: \(model2)")
        } else {
            print("✗ [ID:006] not responding")
        }
        
        // Initialize any servos that responded
        if panFound || tiltFound {
            initializeServos()
        }
        
        // Return true since USB connected successfully
        return true
    }
    
    func connect(to portName: String) -> Bool {
        disconnect()
        
        let port = PortHandler(portName: portName)
        let handler = createPacketHandler(protocolEnd: protocolEnd)
        
        do {
            try port.openPort()
            print("Port opened successfully")
            try port.setBaudRate(baudRate)
            print("Baud rate set to \(baudRate)")
            
            // Clear any existing data in the port buffer
            port.clearPort()
            
            // Small delay to let the port stabilize
            usleep(50_000) // 50ms
            
            // Store the connection even if servos aren't found yet
            // This way we can report USB connection success separately from servo presence
            portHandler = port
            packetHandler = handler
            print("USB connection established on \(portName)")
            
            // Ping both servos to detect which ones are available
            print("Attempting to ping pan servo (ID \(panServoId))...")
            let (panModel, panPingResult, panPingError) = handler.ping(port, servoId: panServoId)
            let panFound = panPingResult == .success && panPingError.isEmpty
            if panFound {
                print("✓ Pan servo (ID \(panServoId)) found (Model: \(panModel))")
            } else {
                print("✗ Pan servo (ID \(panServoId)) not responding")
            }
            
            print("Attempting to ping tilt servo (ID \(tiltServoId))...")
            let (tiltModel, tiltPingResult, tiltPingError) = handler.ping(port, servoId: tiltServoId)
            let tiltFound = tiltPingResult == .success && tiltPingError.isEmpty
            if tiltFound {
                print("✓ Tilt servo (ID \(tiltServoId)) found (Model: \(tiltModel))")
            } else {
                print("✗ Tilt servo (ID \(tiltServoId)) not responding")
            }
            
            // Initialize only the servos that were found
            if panFound || tiltFound {
                initializeServos()
                print("Initialization complete. Connected status: \(connectionStatus)")
            } else {
                print("Warning: USB connected but no servos detected")
            }
            
            // Return true if USB is open (even if servos aren't found)
            return true
            
        } catch {
            print("Failed to connect to \(portName): \(error)")
            portHandler?.closePort()
            portHandler = nil
            return false
        }
    }
    
    func disconnect() {
        portHandler?.closePort()
        portHandler = nil
    }
    
    private func initializeServos() {
        guard let port = portHandler, let handler = packetHandler else { return }
        
        // Initialize pan servo
        initializeServo(servoId: panServoId, port: port, handler: handler)
        
        // Initialize tilt servo
        initializeServo(servoId: tiltServoId, port: port, handler: handler)
        
        // Read current positions
        readCurrentPositions()
    }
    
    private func initializeServo(servoId: UInt8, port: PortHandler, handler: PacketHandlerProtocol) {
        print("\n=== Initializing servo \(servoId) ===")
        
        // Read current angle limits first to see what they are
        let (minLimitData, minReadResult, _) = handler.read2ByteTxRx(
            port,
            servoId: servoId,
            address: ControlTableAddress.minAngleLimit
        )
        print("Read min angle limit: \(minReadResult.description), value: \(minLimitData)")
        
        let (maxLimitData, maxReadResult, _) = handler.read2ByteTxRx(
            port,
            servoId: servoId,
            address: ControlTableAddress.maxAngleLimit
        )
        print("Read max angle limit: \(maxReadResult.description), value: \(maxLimitData)")
        
        // Set acceleration
        let (accResult, _) = handler.write1ByteTxRx(
            port,
            servoId: servoId,
            address: ControlTableAddress.goalAcc,
            data: movingAcc
        )
        print("Set acceleration: \(accResult.description)")
        
        // Set speed
        let (speedResult, _) = handler.write2ByteTxRx(
            port,
            servoId: servoId,
            address: ControlTableAddress.goalSpeed,
            data: movingSpeed
        )
        print("Set speed: \(speedResult.description)")
        
        // Set min angle limit to 0 for full rotation
        let (minResult, _) = handler.write2ByteTxRx(
            port,
            servoId: servoId,
            address: ControlTableAddress.minAngleLimit,
            data: 0
        )
        print("Set min angle limit to 0: \(minResult.description)")
        
        // Set max angle limit to 4095 for full rotation
        let (maxResult, _) = handler.write2ByteTxRx(
            port,
            servoId: servoId,
            address: ControlTableAddress.maxAngleLimit,
            data: 4095
        )
        print("Set max angle limit to 4095: \(maxResult.description)")
        
        // Read limits again to verify they were set
        let (minVerifyData, minVerifyResult, _) = handler.read2ByteTxRx(
            port,
            servoId: servoId,
            address: ControlTableAddress.minAngleLimit
        )
        print("Verify min angle limit after write: \(minVerifyResult.description), value: \(minVerifyData)")
        
        let (maxVerifyData, maxVerifyResult, _) = handler.read2ByteTxRx(
            port,
            servoId: servoId,
            address: ControlTableAddress.maxAngleLimit
        )
        print("Verify max angle limit after write: \(maxVerifyResult.description), value: \(maxVerifyData)")
        
        // Enable torque
        let (torqueResult, _) = handler.write1ByteTxRx(
            port,
            servoId: servoId,
            address: ControlTableAddress.torqueEnable,
            data: 1
        )
        print("Enable torque: \(torqueResult.description)")
        print("=== Servo \(servoId) initialized ===\n")
    }
    
    private func readCurrentPositions() {
        guard let port = portHandler, let handler = packetHandler else { return }
        
        // Read pan position
        let (panPos, panResult, panError) = handler.read2ByteTxRx(
            port,
            servoId: panServoId,
            address: ControlTableAddress.presentPosition
        )
        
        if panResult == .success && panError.isEmpty {
            currentPanPosition = panPos
        }
        
        // Read tilt position
        let (tiltPos, tiltResult, tiltError) = handler.read2ByteTxRx(
            port,
            servoId: tiltServoId,
            address: ControlTableAddress.presentPosition
        )
        
        if tiltResult == .success && tiltError.isEmpty {
            currentTiltPosition = tiltPos
        }
    }
    
    // MARK: - Servo Control
    
    func movePan(direction: PanDirection) {
        guard let port = portHandler, let handler = packetHandler else {
            print("Not connected")
            return
        }
        
        // Calculate new position with safe arithmetic
        let newPosition: UInt16
        switch direction {
        case .left:
            if currentPanPosition > positionStep {
                newPosition = currentPanPosition - positionStep
            } else {
                newPosition = minPosition
            }
        case .right:
            let potential = UInt32(currentPanPosition) + UInt32(positionStep)
            newPosition = potential > UInt32(maxPosition) ? maxPosition : UInt16(potential)
        }
        
        // Send position command
        let (result, error) = handler.write2ByteTxRx(
            port,
            servoId: panServoId,
            address: ControlTableAddress.goalPosition,
            data: newPosition
        )
        
        if result == .success && error.isEmpty {
            currentPanPosition = newPosition
            print("Pan moved to: \(newPosition)")
        } else {
            print("Failed to move pan: \(result.description)")
        }
    }
    
    func moveTilt(direction: TiltDirection) {
        guard let port = portHandler, let handler = packetHandler else {
            print("Not connected")
            return
        }
        
        // Calculate new position with safe arithmetic
        let newPosition: UInt16
        switch direction {
        case .up:
            let potential = UInt32(currentTiltPosition) + UInt32(positionStep)
            newPosition = potential > UInt32(maxPosition) ? maxPosition : UInt16(potential)
        case .down:
            if currentTiltPosition > positionStep {
                newPosition = currentTiltPosition - positionStep
            } else {
                newPosition = minPosition
            }
        }
        
        // Send position command
        let (result, error) = handler.write2ByteTxRx(
            port,
            servoId: tiltServoId,
            address: ControlTableAddress.goalPosition,
            data: newPosition
        )
        
        if result == .success && error.isEmpty {
            currentTiltPosition = newPosition
            print("Tilt moved to: \(newPosition)")
        } else {
            print("Failed to move tilt: \(result.description)")
        }
    }
}
