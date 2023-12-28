import Foundation
import AnylineTireTreadSdk

protocol LoadingViewModelDelegate: AnyObject {
    func displayError()
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
        do {
            try AnylineTireTreadSdk.companion.getTreadDepthReportResult(
                measurementUuid: self.uuid,
                onGetTreadDepthReportResultSucceeded: { [weak self] treadDepthResult in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.loadingViewModelDelegate?.displayDepthResultView(uuid: self.uuid, treadDepthResult: treadDepthResult)
                    }
                },
                onGetTreadDepthReportResultFailed: { [weak self] measurementError in
                    print("Error code: " + (measurementError.errorCode ?? "not available"))
                    print("Error message: " + measurementError.errorMessage)
                    self?.loadingViewModelDelegate?.displayError()
                }, timeoutSeconds: 60
            )
        } catch {
            self.loadingViewModelDelegate?.displayError()
        }
    }
}
