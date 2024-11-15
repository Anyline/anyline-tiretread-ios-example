import Foundation
import AnylineTireTreadSdk

struct UserDefaultsManager {
    static var shared = UserDefaultsManager()
    private init() {}
    
    var imperialSystem: Bool {
        get {
            if UserDefaults.standard.object(forKey: "imperialSystem") == nil {
                UserDefaults.standard.set(false, forKey: "imperialSystem")
            }
            return UserDefaults.standard.bool(forKey: "imperialSystem")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "imperialSystem")
        }
    }

    var scanSpeed: ScanSpeed {
        get {
            switch Int32(UserDefaults.standard.integer(forKey: "scanSpeed")) {
            case ScanSpeed.fast.ordinal:
                return .fast
            case ScanSpeed.slow.ordinal:
                return .slow
            default:
                return .slow
            }
        }
        set {
            UserDefaults.standard.setValue(newValue.ordinal, forKey: "scanSpeed")
        }
    }

    var showGuidance: Bool {
        get {
            let showGuidanceObject = UserDefaults.standard.object(forKey: "showGuidance")

            if (showGuidanceObject == nil){
                return true
            }
            return UserDefaults.standard.bool(forKey: "showGuidance")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "showGuidance")
        }
    }

    var customTag: String? {
        get {
            return UserDefaults.standard.string(forKey: "customTag")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "customTag")
        }
    }
    
    func addNewTireRegistration(tireId: String) {
        let keychainManager = KeychainManager()
        let licenseString = keychainManager.getValue(forKey: KeychainKeys.licenseID) ?? ""
        var tireRegistration = UserDefaults.standard.dictionary(forKey: "tireRegistration") as? [String: [String: Int]] ?? [:]
        var registrationCount = tireRegistration[licenseString]?[tireId] ?? 0
        registrationCount += 1

        if var licenseEntry = tireRegistration[licenseString] {
            licenseEntry[tireId] = registrationCount
            tireRegistration[licenseString] = licenseEntry
        } else {
            tireRegistration[licenseString] = [tireId: registrationCount]
        }
        
        UserDefaults.standard.set(tireRegistration, forKey: "tireRegistration")
    }
    
    func loadTireRegistration(tireId: String) -> Int {
        
        let keychainManager = KeychainManager()
        let licenseString = keychainManager.getValue(forKey: KeychainKeys.licenseID) ?? ""
        
        if let tireRegistration = UserDefaults.standard.dictionary(forKey: "tireRegistration") as? [String: [String: Int]] {
            if let tireRegistationForLicense = tireRegistration[licenseString] {
                if let count = tireRegistationForLicense[tireId] {
                    return count
                }
            }
        }
        return 0
    }

}
