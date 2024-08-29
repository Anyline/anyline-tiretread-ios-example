import Foundation
import AnylineTireTreadSdk

struct UserDefaultsManager {
    static var shared = UserDefaultsManager()
    private init() {}
    
    var imageQuality: Int {
        get {
            if UserDefaults.standard.object(forKey: "imageQuality") == nil {
                UserDefaults.standard.set(50, forKey: "imageQuality")
            }
            return UserDefaults.standard.integer(forKey: "imageQuality")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "imageQuality")
        }
    }
    
    var imageQualitySwitchValue: Bool {
        get {
            if UserDefaults.standard.object(forKey: "imageQualitySwitchButton") == nil {
                UserDefaults.standard.set(false, forKey: "imageQualitySwitchButton")
            }
            return UserDefaults.standard.bool(forKey: "imageQualitySwitchButton")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "imageQualitySwitchButton")
        }
    }
    
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
