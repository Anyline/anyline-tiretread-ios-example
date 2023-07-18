import Foundation
import AnylineTireTreadSdk
import UIKit
import AVFoundation

protocol LandingViewModelDelegate: AnyObject {
    func authenticationSuccessfully()
    func showError(error: String)
}

class LandingViewModel {
    
    // MARK: - Private Let's & Var's
    private weak var landingViewModelDelegate: LandingViewModelDelegate?
    
    // MARK: - Public Let's & Var's
    
    // MARK: - Init
    init(delegate: LandingViewModelDelegate) {
        self.landingViewModelDelegate = delegate
    }
    
    func tryInitializeSdk(context: UIViewController) {
        do {
            let keychainManager = KeychainManager()
            
            guard let licenceID = keychainManager.getValue(forKey: KeychainKeys.licenseID) else {
                landingViewModelDelegate?.showError(error: "error.license.missing_key".localized())
                return
            }
            
            try AnylineTireTreadSdk.companion.doInit(licenseKey: licenceID, context: context)
            
            if AnylineTireTreadSdk.companion.isInitialized {
                requestPermissionsAndProceed(context: context)
            } else {
                let errorMessage = "error.invalid_license".localized()
                self.landingViewModelDelegate?.showError(error: errorMessage)
            }
        } catch {
            let errorMessage = "error.invalid_license".localized() + " (\(error.localizedDescription))"
            self.landingViewModelDelegate?.showError(error: errorMessage)
        }
    }
    
    func requestPermissionsAndProceed(context: UIViewController) {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .authorized:
            self.landingViewModelDelegate?.authenticationSuccessfully()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.landingViewModelDelegate?.authenticationSuccessfully()
                    } else {
                        let errorMessage = "error.camera_permission".localized()
                        self.landingViewModelDelegate?.showError(error: errorMessage)
                    }
                }
            }
        default:
            let errorMessage = "error.camera_permission".localized()
            self.landingViewModelDelegate?.showError(error: errorMessage)
        }
    }
}
