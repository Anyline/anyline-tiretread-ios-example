import Foundation
import AnylineTireTreadSdk
import Alamofire

protocol FeedbackViewModelDelegate: AnyObject {
    func didSendData()
    func showError(error: Int)
}

class FeedbackViewModel {
    
    // MARK: - Private Properties
    private weak var feedbackViewModelDelegate: FeedbackViewModelDelegate?
    
    // MARK: - Public Properties
    
    // MARK: - Init
    init(delegate: FeedbackViewModelDelegate) {
        self.feedbackViewModelDelegate = delegate
    }
    
    func postFeedbackData(resultUuid: String, treadResultRegions: [TreadResultRegion], comment: String) {
        DispatchQueue.global().async {
            AnylineTireTreadSdk.companion.sendTreadDepthResultFeedback(
                resultUuid: resultUuid,
                treadResultRegions: treadResultRegions,
                onSendTreadDepthResultSucceed: { [weak self] response in
                    response.body { resultDTO, error in
                        guard let self = self else { return }
                        
                        if let error = error {
                            DispatchQueue.main.async {
                                self.feedbackViewModelDelegate?.showError(error: error.asAFError?.responseCode ?? 0)
                            }
                            return
                        }
                        
                        // Handle success, perform subsequent actions
                        self.postFeedbackComment(uuid: resultUuid, comment: comment)
                    }
                },
                onSendTreadDepthResultFailed: { [weak self] response, exception in
                    DispatchQueue.main.async {
                        self?.feedbackViewModelDelegate?.showError(error: 0)
                    }
                }
            )
        }
    }
    
    func postFeedbackComment(uuid: String, comment: String) {
        DispatchQueue.global().async {
            AnylineTireTreadSdk.companion.sendCommentFeedback(
                resultUuidString: uuid,
                comment: comment,
                onSendCommentSucceed: { [weak self] response in
                    response.body { resultDTO, error in
                        guard let self = self else { return }
                        
                        if let error = error {
                            DispatchQueue.main.async {
                                self.feedbackViewModelDelegate?.showError(error: error.asAFError?.responseCode ?? 0)
                            }
                            return
                        }
                        
                        // Handle success
                        DispatchQueue.main.async {
                            self.feedbackViewModelDelegate?.didSendData()
                        }
                    }
                },
                onSendCommentFailed: { [weak self] response, exception in
                    DispatchQueue.main.async {
                        self?.feedbackViewModelDelegate?.showError(error: 0)
                    }
                }
            )
        }
    }
}
