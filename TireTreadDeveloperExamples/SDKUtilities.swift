import AnylineTireTreadSdk

enum TireTreadError: Error {
    case responseError(String)
    case responseException(String)
}

struct SDKUtilities {
    struct Constants {
        static let timeoutInSec: Int32 = 30
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
            do {
                // Initialize the Tire Tread SDK with your license key
                try AnylineTireTreadSdk.shared.doInit(licenseKey: licenseString)
                continuation.resume(returning: .success(()))
            } catch {
                // To get the error object from the TireTread SDK, you first need to convert it to a KotlinException
                var errorMessage = "Unable to initialize the Tire Tread SDK. Reason: \n"
                if let kException = (error as NSError).kotlinException {
                    switch kException {
                    case let ex as SdkLicenseKeyInvalidException:
                        errorMessage += " \(ex.message)"
                    case let ex as SdkLicenseKeyForbiddenException:
                        errorMessage += " \(ex.message)"
                    case let ex as NoConnectionException:
                        errorMessage += " \(ex.message)"
                    default:
                        errorMessage += " \(kException)"
                    }
                }
                continuation.resume(returning: .failure(TireTreadError.responseError(errorMessage)))
            }
        }
    }

    static func fetchHeatMap(uuid: String, timeout: Int32 = Constants.timeoutInSec) async -> Result<Heatmap, TireTreadError> {
        await withCheckedContinuation { continuation in
            AnylineTireTreadSdk.shared.getHeatmap(measurementUuid: uuid, timeoutSeconds: timeout) { response in
                switch(response) {
                case let response as ResponseSuccess<Heatmap>:
                    continuation.resume(returning: .success(response.data))
                case let response as ResponseError<Heatmap>:
                    let message = response.errorMessage ?? "Unable to get heatmap data."
                    continuation.resume(returning: .failure(TireTreadError.responseError(message)))
                    // continuation.resume(returning: .failure(.responseError("Unable to get heatmap data.")))
                case let responseException as ResponseException<Heatmap>:
                    let exceptionMessage = "Unable to get heatmap data: " + (responseException.exception.message ?? "Unknown exception")
                    // continuation.resume(returning: .failure(.responseException("Unable to get heatmap data.")))
                    continuation.resume(returning: .failure(TireTreadError.responseException(exceptionMessage)))
                default:
                    break
                }
            }
        }
    }

    static func fetchTreadDepthResult(uuid: String, timeout: Int32 = Constants.timeoutInSec) async -> Result<TreadDepthResult, TireTreadError> {
        await withCheckedContinuation { continuation in
            AnylineTireTreadSdk.shared.getTreadDepthReportResult(measurementUuid: uuid, timeoutSeconds: timeout) { response in
                switch(response) {
                case let response as ResponseSuccess<TreadDepthResult>:
                    continuation.resume(returning: .success(response.data))
                case let response as ResponseError<TreadDepthResult>:
                    // NOTE: response.errorCode is also available
                    let message = response.errorMessage ?? "Unknown error"
                    continuation.resume(returning: .failure(TireTreadError.responseError(message)))
                case let responseException as ResponseException<TreadDepthResult>:
                    let exceptionMessage = "Unable to get tread depth result: " + (responseException.exception.message ?? "Unknown exception")
                    continuation.resume(returning: .failure(TireTreadError.responseException(exceptionMessage)))
                default:
                    break
                }
            }
        }
    }
}
