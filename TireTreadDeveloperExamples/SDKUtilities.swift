import Foundation
import AnylineTireTreadSdk

struct SDKUtilities {
    struct Constants {
        static let timeoutInSec: Int32 = 60
    }

    static let licenseStringMissingErrorMessage = "utilities.error_message.missing_license_string".localized

    static func getLicenseString() -> String {
        let envDict = Bundle.main.infoDictionary?["LSEnvironment"] as! Dictionary<String, String>
        if let envStr = envDict["TTR_SDK_DEVEX_LICENSE_KEY"], !envStr.isEmpty {
            return envStr
        }
        return licenseStringMissingErrorMessage
    }

    static func initializeSDK() async -> Result<Void, Error> {
        await withCheckedContinuation { continuation in
            let licenseString = SDKUtilities.getLicenseString()
            AnylineTireTread.shared.initialize(licenseKey: licenseString) { sdkResult in
                if sdkResult.isOk {
                    continuation.resume(returning: .success(()))
                } else if let error = sdkResult.error {
                    let message = "\(error.code): \(error.message)"
                    continuation.resume(returning: .failure(NSError(domain: "TTRInit", code: 1, userInfo: [NSLocalizedDescriptionKey: message])))
                }
            }
        }
    }

    static func fetchTreadDepthResult(uuid: String, timeout: Int32 = Constants.timeoutInSec) async -> Result<TreadDepthResult, Error> {
        await withCheckedContinuation { continuation in
            AnylineTireTread.shared.getResult(measurementUUID: uuid, timeoutSeconds: timeout) { sdkResult in
                if sdkResult.isOk, let result = sdkResult.result {
                    continuation.resume(returning: .success(result))
                } else if let error = sdkResult.error {
                    let message = "\(error.code): \(error.message)"
                    continuation.resume(returning: .failure(NSError(domain: "TTRResult", code: 1, userInfo: [NSLocalizedDescriptionKey: message])))
                }
            }
        }
    }
}
