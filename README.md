# Anyline Tire Tread SDK Showcase

This application runs on the **Anyline Tire Tread SDK** that helps users easily and
accurately assess the health of their vehicle's tires. The application code is included
to help developers build the SDK into their own iOS applications.

For more information and additional guidance, please check the 
[Tire Tread SDK iOS Documentation](https://documentation.anyline.com/tiretreadsdk-component/latest/ios/overview.html). 

## Requirements

- Xcode version: 14.3 or later
- iOS version: 15.0 or later
- Dependency manager: Swift Package Manager (Cocoapods also supported)

## How to Run The Showcase App

1. Clone the repository
2. Open the `Anyline Tire Demo.xcodeproj`
3. Install dependencies
4. Build and run the project on a simulator or a device

## Integrate the Anyline Tire Tread SDK into a Native iOS App

The following guide will walk you through the process of integrating `AnylineTireTreadSdk` into a native iOS application.

### 1. Import the `AnylineTireTreadSdk` Framework

#### With Swift Package Manager

- In Xcode, go to `File -> Swift Packages -> Add Package Dependency` and enter the Swift Package repository of
`AnylineTireTreadSdk`.

After cloning the `AnylineTireTreadSdk` repository, you may import the framework into your native iOS
application code:

```
import AnylineTireTreadSdk
```

#### With CocoaPods

- Add the following line to your `Podfile`:

    ```
    pod 'AnylineTireTreadSdk', '~>2'
    ```

- Run `pod install`.

### 2. Licensing

In order to use the `AnylineTireTreadSdk`, a valid license key is required. Please contact presales@anyline.com to
obtain a license key if needed.

Before making any calls with `AnylineTireTreadSdk`, initialize it with a license key as follows:

```
func tryInitializeSdk(context: UIViewController) {
    do {
        let licenseKey = "<your-license-key>"
        
        try AnylineTireTreadSdk.companion.doInit(licenseKey: licenseKey, context: context)
        
        // Continue setup after successful initialization
    } catch {
        // Handle initialization error
    }
}
```

In the code above, replace `<your-license-key>` with your actual license key string. This function attempts to
initialize `AnylineTireTreadSdk` with the license key provided. If the SDK fails to initialize, you should handle
this error appropriately.

It is recommended to store the license key securely (such as in the system keychain).

### 3. Check Camera Permissions

Before starting the scan process, it is crucial to check and request camera permissions, as they are required
in order for the SDK to function correctly.

First, in your application's Info.plist file, add an `NSCameraUsageDescription` string value which explains
to your users why the app would be requiring camera permission access from them.

Then, right before requesting for a scan view from the SDK, call the following: 

```
func requestPermissionsAndProceed(context: UIViewController) {
    let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    
    switch cameraAuthorizationStatus {
    case .authorized:
        // Continue with setup
    case .notDetermined:
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    // Continue with setup
                } else {
                    // Handle denied access
                }
            }
        }
    default:
        // Handle other cases
    }
}
```

### 4. Implement the `ScannerViewControllerHolder` Interface

In order to set up the scan view correctly, make your UIViewController subclass implement the
`ScannerViewControllerHolder` interface.

This interface gives your view controller two properties:

1. `scannerViewController`: This property will hold an instance of `TireTreadScannerViewController`, which
takes over the scanning process. Once it becomes available, you should add its main view into your
UIViewController's view hierarchy.
2. `dismissViewController`: This is a function property that will handle the event of the scan view being
dismissed. Assign it with a block that removes the scan view from your UIViewController's view hierarchy. 

Here is an example of how to implement the ScannerViewControllerHolder interface:
```
class YourViewController: UIViewController, ScannerViewControllerHolder {

    // Implement the properties defined by the ScannerViewControllerHolder interface
    var scannerViewController: UIViewController?
    var dismissViewController: (() -> Void)?

    // The rest of your class implementation
}
```

Remember to replace `YourViewController` with the actual name of your view controller.

### 5. Set up the Scan View Controller

Once the SDK has been initialized and the necessary permissions have been granted, you can setup the
scan view controller.

```
private func setupTireTreadScanView() {
    let config = TireTreadScanViewConfig(measurementSystem: .metric, useDefaultUi: true, useDefaultHaptic: false)
    TireTreadScanViewKt.TireTreadScanView(context: self, config: config) { error in
        // Handle initialization error
    }
}

private func addScanViewControllerAsChild() {
    guard let scannerViewController = scannerViewController else {
        // Handle error
        return
    }
    addChild(scannerViewController)
    view.addSubview(scannerViewController.view)
    scannerViewController.didMove(toParent: self)
}
```

Once added, the Tire Tread scan view will be displayed, and the user will be guided by on-screen
prompts to scan a tire correctly and submit the results online for analysis. 

### 6. Implementing the `TireTreadScanViewCallback`

Your UIViewController should also implement `TireTreadScanViewCallback` to handle scan events.
For example:

```
extension YourViewController: TireTreadScanViewCallback {
    func onUploadCompleted(uuid: String?) {
        // Handle upload completion
    }
    
    // Implement the rest of the callback methods...
}
```

`onUploadCompleted` is called when the scanner has taken enough tire image frames and have
successfully uploaded them to the cloud for processing. A UUID string associated with the tire
scan session is provided in the callback in order for you to make the subsequent request for
the scan results.

### 7. Fetch the Scan Results

Once the scan has been successfully completed, use the scan's UUID to retrieve the measurement
values from `AnylineTireTreadSdk`:

```
private func fetchTreadDepthResult() {
    AnylineTireTreadSdk.companion.getTreadDepthReportResult(
        measurementUuid: uuid,
        onGetTreadDepthReportResultSucceed: { [weak self] response in
            response.body { resultDTO, error in
                guard let self = self else { return }
                guard let status = resultDTO?.measurement.status else {
                    // handle error
                    return
                }

                // obtain the scan results
                self.handleTreadDepthResult(treadDepthResult: resultDTO?.result, status: status)
            }
        },
        onGetTreadDepthReportResultFailed: { [weak self] response, exception in
            // handle error
        }
    )
}
```

We recommend implementing this call with a polling logic (e.g. running every 3 seconds or more),
until the final results become available.


## Dependencies

List of third-party libraries and frameworks used in the project:
- Alamofire - Networking library
- SnapKit - Auto Layout DSL
- KeychainSwift - Keychain helper library

## Project Structure

- DataStorage: Contains the modules responsible for managing the app's local data storage
- Domain: Responsible for handling network requests and other domain-specific logic
- Presentation: Contains the UIKit components
- Resources: Contains the supplementary assets and helper classes
- Fonts

---

## Get Help (Support)

We don't actively monitor the GitHub Issues, please raise a support request using the [Anyline Helpdesk](https://support.anyline.com/).
When raising a support request based on this GitHub Issue, please fill out and include the following information:

```
Support request concerning Anyline GitHub Repository: anyline-tiretread-showcase-app-ios
```

Thank you!

## License

See LICENSE file.