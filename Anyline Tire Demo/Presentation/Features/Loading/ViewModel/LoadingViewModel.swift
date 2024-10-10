import Foundation
import AnylineTireTreadSdk

protocol LoadingViewModelDelegate: AnyObject {
    func displayError(code: String?, message: String?)
    func displayDepthResultView(uuid: String, treadDepthResult: TreadDepthResult)
}

class LoadingViewModel {
    
    // MARK: - Private properties
    private weak var loadingViewModelDelegate: LoadingViewModelDelegate?
    private var processingAttempts = 0

    // MARK: - Public properties
    var uuid: String
    
    // MARK: - Init
    init(delegate: LoadingViewModelDelegate, uuid: String) {
        self.loadingViewModelDelegate = delegate
        self.uuid = uuid
    }
    
    // MARK: - Actions
    func startDataProcessing() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.fetchTreadDepthResult()
        }
    }
    
    private func fetchTreadDepthResult() {
        AnylineTireTreadSdk.shared.getTreadDepthReportResult(measurementUuid: self.uuid, timeoutSeconds: 60) { [weak self] response in
                guard let self = self else { return }
            
                switch(response) {
                case let response as ResponseSuccess<TreadDepthResult>:
                    DispatchQueue.main.async {
                        self.loadingViewModelDelegate?.displayDepthResultView(uuid: self.uuid, treadDepthResult: response.data)
                    }
                    break;
                case let response as ResponseError<TreadDepthResult>:
                    self.loadingViewModelDelegate?.displayError(code: response.errorCode, message: response.errorMessage)
                    break;
                case let response as ResponseException<TreadDepthResult>:
                    self.loadingViewModelDelegate?.displayError(code: nil, message: response.exception.message)
                    break;
                default:
                    break;
                }
        }
    }
}
