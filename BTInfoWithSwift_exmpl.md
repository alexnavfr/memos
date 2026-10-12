To get battery information about a Bluetooth device on macOS using Python, you can utilize the `CoreBluetooth` framework, which provides access to Bluetooth device information, including battery levels. However, since macOS does not have a direct Python library for accessing this information, you might need to interact with macOS APIs via `pyobjc` or use the `ioreg` system utility.

### Method 1: Using `pyobjc`
The `pyobjc` library allows Python to interact with macOS APIs. To access Bluetooth battery levels, you can use CoreBluetooth or interact with the IOBluetooth framework.

#### Example:
```python
from Foundation import NSBundle
from objc import loadBundleFunctions, loadBundleVariables

# Load IOBluetooth bundle
iokit = NSBundle.bundleWithIdentifier_("com.apple.IOBluetooth")
functions = [
    ("IOBluetoothDeviceGetBatteryLevel", b"@@@"),
]
loadBundleFunctions(iokit, globals(), functions)

# Function to get the battery level
def get_bluetooth_battery_level(device_address):
    # Replace this with code to resolve the device using CoreBluetooth
    device = None  # Placeholder for device object
    if device:
        return IOBluetoothDeviceGetBatteryLevel(device)
    return None

# Example usage
battery_level = get_bluetooth_battery_level("XX-XX-XX-XX-XX-XX")
print(f"Battery level: {battery_level}")
```

This approach requires familiarity with CoreBluetooth and macOS APIs. 

### Method 2: Using `ioreg`
You can query macOS's `ioreg` utility to fetch Bluetooth device information, including battery levels.

#### Example:
```python
import subprocess
import json

def get_bluetooth_battery_level():
    try:
        # Run the ioreg command
        output = subprocess.check_output(["ioreg", "-l", "-n", "AppleDeviceManagementHIDEventService", "-r", "-a"])
        devices = json.loads(output.decode("utf-8"))
        
        battery_info = {}
        for device in devices:
            name = device.get("BluetoothDeviceName", "Unknown Device")
            battery_level = device.get("BatteryPercent", None)
            battery_info[name] = battery_level
        
        return battery_info
    except Exception as e:
        print(f"Error: {e}")
        return {}

# Example usage
battery_levels = get_bluetooth_battery_level()
for device, level in battery_levels.items():
    print(f"{device}: {level}%")
```

### Notes
1. The first method may require additional configuration to work with macOS's strict app sandboxing rules.
2. The second method relies on `ioreg`, which might not provide detailed battery information for all Bluetooth devices.
3. Make sure to have Python installed with `pyobjc` for method 1 (`pip install pyobjc`).

Let me know if you'd like to refine or expand on these approaches!


-----


If you'd like to explore another programming language to fetch Bluetooth battery information, **Swift** is a great choice on macOS, as it integrates seamlessly with Apple's CoreBluetooth framework and other system APIs.

Here’s how you can do it in Swift:

### Swift Example
You can use Apple's CoreBluetooth framework to interact with Bluetooth devices. However, getting the battery level requires that the Bluetooth device supports the **Battery Service** (a GATT profile).

#### Full Example Code
```swift
import Foundation
import CoreBluetooth

class BluetoothBatteryReader: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var targetPeripheral: CBPeripheral?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Start scanning for devices
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth is not powered on.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("Discovered \(peripheral.name ?? "Unknown Device")")
        if let name = peripheral.name, name.contains("YourDeviceName") {
            targetPeripheral = peripheral
            targetPeripheral?.delegate = self
            centralManager.stopScan()
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown Device")")
        peripheral.discoverServices([CBUUID(string: "180F")]) // Battery Service UUID
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == CBUUID(string: "180F") {
                    peripheral.discoverCharacteristics([CBUUID(string: "2A19")], for: service) // Battery Level Characteristic UUID
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == CBUUID(string: "2A19") {
                    peripheral.readValue(for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value, characteristic.uuid == CBUUID(string: "2A19") {
            let batteryLevel = value.first ?? 0
            print("Battery Level: \(batteryLevel)%")
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
}

let reader = BluetoothBatteryReader()
RunLoop.main.run()
```

### Steps to Run
1. Open **Xcode**.
2. Create a new **macOS Command Line Tool** project.
3. Select Swift as the language.
4. Replace the contents of `main.swift` with the above code.
5. Replace `"YourDeviceName"` with the name of your Bluetooth device.
6. Build and run the project.

### How It Works
1. The `CBCentralManager` scans for nearby Bluetooth devices.
2. When the target device is found, the app connects to it.
3. It queries the **Battery Service (UUID: 180F)** and reads the **Battery Level Characteristic (UUID: 2A19)**.

### Notes
- This requires your Bluetooth device to support the Battery Service.
- Make sure Bluetooth permissions are set in your app's `.plist`:
  - Add `NSBluetoothAlwaysUsageDescription` with an appropriate description.
- Swift is the most native and efficient way to achieve this on macOS.
