import KeychainSwift

struct KeychainKeys {
    static let keychainPrefix = "AnylineTireDemo_"
    static let licenseID = "LicenseID"
}

class KeychainManager {
    private let keychain = KeychainSwift(keyPrefix: KeychainKeys.keychainPrefix)
    
    func save(_ value: String, forKey key: String) {
        keychain.set(value, forKey: key)
    }
    
    func getValue(forKey key: String) -> String? {
        return keychain.get(key)
    }
    
    func removeValue(forKey key: String) {
        keychain.delete(key)
    }
    
}
