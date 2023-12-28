import Foundation
import AnylineTireTreadSdk
import UIKit

protocol ResultDetailsViewModelDelegate: AnyObject {
    func showPDF(pdfData: Data)
    func showError(error: String)
}

class ResultDetailsViewModel {
    
    // MARK: - Private Properties
    private weak var resultDetailsViewModelDelegate: ResultDetailsViewModelDelegate?
    private var uuid: String
    
    // MARK: - Public Properties
    private let anylineSDK = AnylineTireTreadSdk.companion
    
    // MARK: - Init
    init(delegate: ResultDetailsViewModelDelegate, uuid: String) {
        self.resultDetailsViewModelDelegate = delegate
        self.uuid = uuid
    }
    
    // Request PDF
    func requestPDF(context: UIViewController) async {
        do {
            let keychainManager = KeychainManager()

            guard let licenceID = keychainManager.getValue(forKey: KeychainKeys.licenseID) else {
                resultDetailsViewModelDelegate?.showError(error: "error.license.missing_key".localized())
                return
            }
            try anylineSDK.doInit(licenseKey: licenceID, context: context)

            anylineSDK.getTreadDepthReportPdf(measurementUuid: self.uuid) { pdfByteArray in
                print("PDF fetched from SDK.")
                
                // Convert ByteArray to Swift Data
                let data = pdfByteArray.toNSData()

                self.resultDetailsViewModelDelegate?.showPDF(pdfData: data)
            }
        } catch {
            resultDetailsViewModelDelegate?.showError(error: "error.description".localized())
        }
    }
}
