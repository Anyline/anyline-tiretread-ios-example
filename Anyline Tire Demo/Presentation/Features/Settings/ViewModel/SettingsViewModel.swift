import Foundation
import AnylineTireTreadSdk
import UIKit
import AVFoundation

protocol SettingsViewModelDelegate: AnyObject {
    func showSuccess()
    func showError(error: String)
}

class SettingsViewModel {
    
    // MARK: - Private Properties
    private weak var settingsViewModelDelegate: SettingsViewModelDelegate?
    
    // MARK: - Public Properties
    
    // MARK: - Init
    init(delegate: SettingsViewModelDelegate) {
        self.settingsViewModelDelegate = delegate
    }
    
    func testSetup(context: UIViewController) {
        do {
            let keychainManager = KeychainManager()
            
            guard let licenceID = keychainManager.getValue(forKey: KeychainKeys.licenseID) else {
                settingsViewModelDelegate?.showError(error: "error.invalid_license".localized())
                return
            }
            
            try AnylineTireTreadSdk.companion.doInit(licenseKey: licenceID, context: context)
            
            if AnylineTireTreadSdk.companion.isInitialized {
                requestPermissionsAndProceed(context: context)
            } else {
                let errorMessage = "error.invalid_license".localized()
                self.settingsViewModelDelegate?.showError(error: errorMessage)
            }
        } catch {
            let errorMessage = "error.invalid_license".localized() + " (\(error.localizedDescription))"
            self.settingsViewModelDelegate?.showError(error: errorMessage)
        }
    }
    
    func requestPermissionsAndProceed(context: UIViewController) {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .authorized:
            self.settingsViewModelDelegate?.showSuccess()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.settingsViewModelDelegate?.showSuccess()
                    } else {
                        let errorMessage = "error.camera_permission".localized()
                        self.settingsViewModelDelegate?.showError(error: errorMessage)
                    }
                }
            }
        default:
            let errorMessage = "error.camera_permission".localized()
            self.settingsViewModelDelegate?.showError(error: errorMessage)
        }
    }
}
