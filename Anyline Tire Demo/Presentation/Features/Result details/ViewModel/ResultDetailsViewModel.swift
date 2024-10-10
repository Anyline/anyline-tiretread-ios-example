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
    private let anylineSDK = AnylineTireTreadSdk.shared
    
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
            try anylineSDK.doInit(licenseKey: licenceID)

            anylineSDK.getTreadDepthReportPdf(measurementUuid: self.uuid) { response in
                print("PDF fetched from SDK.")
                
                switch(response){
                case let response as ResponseSuccess<KotlinByteArray>:
                    // Convert ByteArray to Swift Data
                    self.resultDetailsViewModelDelegate?.showPDF(pdfData: response.data.toNSData())
                    break;
                case let response as ResponseError<KotlinByteArray>:
                    self.resultDetailsViewModelDelegate?.showError(error: response.errorMessage ?? "error.description".localized())
                    break;
                case let response as ResponseException<KotlinByteArray>:
                    self.resultDetailsViewModelDelegate?.showError(error: response.exception.message ?? "error.description".localized())
                    break;
                default:
                    break;
                }
                
            }
        } catch {
            resultDetailsViewModelDelegate?.showError(error: "error.description".localized())
        }
    }
}
