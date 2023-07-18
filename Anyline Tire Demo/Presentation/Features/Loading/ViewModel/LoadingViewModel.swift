import Foundation
import AnylineTireTreadSdk

protocol LoadingViewModelDelegate: AnyObject {
    func displayError()
    func displayDepthResultView(uuid: String, treadDepthResult: TreadDepthResultDTO)
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
        DispatchQueue.global().asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.fetchTreadDepthResult()
        }
    }
    
    private func fetchTreadDepthResult() {
        AnylineTireTreadSdk.companion.getTreadDepthReportResult(
            measurementUuid: self.uuid,
            onGetTreadDepthReportResultSucceed: { [weak self] response in
                response.body { resultDTO, error in
                    guard let self = self else { return }
                    guard let status = resultDTO?.measurement.status else {
                        self.loadingViewModelDelegate?.displayError()
                        return
                    }
                    
                    self.handleTreadDepthResult(treadDepthResult: resultDTO?.result, status: status)
                }
            },
            onGetTreadDepthReportResultFailed: { [weak self] response, exception in
                self?.loadingViewModelDelegate?.displayError()
            }
        )
    }
}

// MARK: - Private Actions
private extension LoadingViewModel {
    
    func isValidTreadDepthResult(treadDepthResult: TreadDepthResultDTO) -> Bool {
        return treadDepthResult.global.confidence > 0
    }
    
    private func handleTreadDepthResult(treadDepthResult: TreadDepthResultDTO?, status: MeasurementStatusDTO) {
        switch status {
        case .completed:
            guard let treadDepthResult = treadDepthResult, isValidTreadDepthResult(treadDepthResult: treadDepthResult) else {
                DispatchQueue.main.async {
                    self.loadingViewModelDelegate?.displayError()
                }
                return
            }
            DispatchQueue.main.async {
                self.loadingViewModelDelegate?.displayDepthResultView(uuid: self.uuid, treadDepthResult: treadDepthResult)
            }
        case .failed, .unknown:
            DispatchQueue.main.async {
                self.loadingViewModelDelegate?.displayError()
            }
        case .processing, .waitingforimages:
            if processingAttempts < 10 {
                DispatchQueue.global().asyncAfter(deadline: .now() + 3) { [weak self] in
                    self?.processingAttempts += 1
                    self?.fetchTreadDepthResult()
                }
            } else {
                DispatchQueue.main.async {
                    self.loadingViewModelDelegate?.displayError()
                }
            }
        default:
            break
        }
    }
}
