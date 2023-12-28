import Foundation

protocol LandingButtonActionsDelegate: AnyObject {
    func startButtonTapped()
    func settingsButtonTapped()
    func cancelButtonTapped()
    func tutorialButtonTapped()
}
