import UIKit
import AnylineTireTreadSdk

protocol SettingsButtonActionsDelegate: AnyObject {
    func okButtonTapped()
    func testUploadButtonTapped()
    func cancelButtonTapped()
    func imperialSystemImageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    func showGuidanceImageTapped(tapGestureRecognizer: UITapGestureRecognizer)

    func scanQRCodeTapped()
    func scanSpeedDialogRequested(sender: UIButton, options: [ScanSpeed], completion: (ScanSpeed?) -> Void)
}

protocol CaptureSpeedViewDelegate: AnyObject {
    func buttonTapped(sender: UIButton)
}
