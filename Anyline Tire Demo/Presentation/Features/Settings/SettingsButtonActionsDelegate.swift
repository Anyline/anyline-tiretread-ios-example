import UIKit
import AnylineTireTreadSdk

protocol SettingsButtonActionsDelegate: AnyObject {
    func okButtonTapped()
    func testUploadButtonTapped()
    func cancelButtonTapped()
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    func switchChanged(mySwitch: UISwitch)

    func scanQRCodeTapped()
    func scanSpeedDialogRequested(sender: UIButton, options: [ScanSpeed], completion: (ScanSpeed?) -> Void)
}

protocol CaptureSpeedViewDelegate: AnyObject {
    func buttonTapped(sender: UIButton)
}
