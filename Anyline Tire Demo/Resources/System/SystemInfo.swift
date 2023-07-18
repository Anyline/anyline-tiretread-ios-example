import UIKit

class SystemInfo {
    
    static func getAppVersion() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return appVersion ?? ""
    }
    
    static func getDeviceName() -> String {
        let deviceModel = UIDevice.current.model
        let deviceOSVersion = UIDevice.current.systemVersion
        let versionString = "\(deviceModel) (\(deviceOSVersion))"
        return versionString
    }
}
