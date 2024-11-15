import Foundation
import AnylineTireTreadSdk
import UIKit
import AVFoundation

protocol LandingViewModelDelegate: AnyObject {
    func authenticationSuccessfully()
    func showError(error: String)
}

class LandingViewModel {

    // MARK: - Private Properties
    private weak var landingViewModelDelegate: LandingViewModelDelegate?
    
    // MARK: - Init
    init(delegate: LandingViewModelDelegate) {
        self.landingViewModelDelegate = delegate
    }

    var isInitialized: Bool {
        AnylineTireTreadSdk.shared.isInitialized
    }
    
    func tryInitializeSdk(context: UIViewController, completion: @escaping (Bool, String?) -> Void) {
        do {
            let keychainManager = KeychainManager()
            
            guard let licenseString = keychainManager.getValue(forKey: KeychainKeys.licenseID) else {
                completion(false, "error.license.missing_key".localized())
                return
            }
            
            // The customTag is meant for internal use only. Simply omit this parameter in your implementation.
            try AnylineTireTreadSdk.shared.doInit(licenseKey: licenseString, customTag: UserDefaultsManager.shared.customTag)
            
            if isInitialized {
                completion(true, nil)
            } else {
                let errorMessage = "error.invalid_license".localized()
                completion(false, errorMessage)
            }
        } catch {
            let errorMessage = "error.invalid_license".localized() + " (\(error.localizedDescription))"
            completion(false, errorMessage)
        }
    }
    
    func requestPermissionsAndProceed(context: UIViewController, completion: @escaping (Bool, String?) -> Void) {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .authorized:
            completion(true, nil)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        completion(true, nil)
                    } else {
                        let errorMessage = "error.camera_permission".localized()
                        completion(false, errorMessage)
                    }
                }
            }
        default:
            let errorMessage = "error.camera_permission".localized()
            completion(false, errorMessage)
        }
    }
}
