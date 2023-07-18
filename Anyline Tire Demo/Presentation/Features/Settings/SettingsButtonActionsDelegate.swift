import UIKit

protocol SettingsButtonActionsDelegate: AnyObject {
    func okButtonTapped()
    func testUploadButtonTapped()
    func cancelButtonTapped()
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    func switchChanged(mySwitch: UISwitch)
}
