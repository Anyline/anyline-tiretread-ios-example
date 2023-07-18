import Foundation

protocol FeedbackButtonActionsDelegate: AnyObject {
    func submitButtonTapped()
    func cancelButtonTapped()
}
