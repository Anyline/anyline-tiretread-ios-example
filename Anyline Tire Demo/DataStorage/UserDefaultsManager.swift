import Foundation

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
}
