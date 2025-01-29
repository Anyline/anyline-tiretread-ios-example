import SwiftUI
import UIKit
import AnylineTireTreadSdk

struct ContentView: View {

    @State private var isLoading: Bool = false
    @State private var sdkStatus: String = "not initialized"
    @State private var isModalDisplayed: Bool = false

    var body: some View {
        VStack {
            Text("Last SDK status: \(sdkStatus)")
                .padding()

            if isLoading {
                ProgressView()
            } else {
                Button {
                    Task {
                        await initSDK()
                    }
                } label: {
                    Text("Init the SDK")
                }
            }

            Button {
                isModalDisplayed = true
            } label: {
                Text("Start the scanner!")
            }
            .fullScreenCover(isPresented: $isModalDisplayed) {
                FullScreenModalView()
            }
            .disabled(isLoading || sdkStatus != "successful")
            .padding()

        }
        .padding()
    }

    func initSDK() async  {
        isLoading = true
        let result = await Utilities.initializeSDK()

        DispatchQueue.main.async {
            switch result {
            case .success:
                sdkStatus = "successful"
            case .failure(let error):
                sdkStatus = error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct FullScreenModalView: View {

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            // Text("This is a full screen modal view").padding()
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Dismiss")
            }
            MyViewControllerRepresentable()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
}


struct MyViewControllerRepresentable: UIViewControllerRepresentable {

    var callus = Callus()

    private var theViewController = UIViewController()

    func makeUIViewController(context: Context) -> some UIViewController {

        let shouldShowGuidance = false
        let customUiConfig = DefaultUiConfig()
        customUiConfig.howToScanTooltipConfig.visible = shouldShowGuidance
        customUiConfig.tireOverlayConfig.visible = shouldShowGuidance
        customUiConfig.lineProgressBarConfig.visible = shouldShowGuidance

        let config = TireTreadScanViewConfig()
        config.measurementSystem = .metric
        config.scanSpeed = .fast
        config.defaultUiConfig = customUiConfig

        TireTreadScanViewKt.TireTreadScanView(context: theViewController, config: config, callback: callus) { error in
            // self?.displayError(uuid: "")
            print("Initialization failed: \(error)")
        }

        callus.dismissViewController = {
            // dismiss it!
            print("dismissing")

        }

        addScanViewControllerAsChild()
        // this is where you're supposed to be adding the TireTreadVC

        // Configure your viewController if needed
        theViewController.view.backgroundColor = .red

        return theViewController
    }

    private func addScanViewControllerAsChild() {
        guard let scannerViewController = callus.scannerViewController else {
            // displayError(uuid: "")
            return
        }
        theViewController.addChild(scannerViewController)
        theViewController.view.addSubview(scannerViewController.view)

        scannerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scannerViewController.view.leadingAnchor.constraint(equalTo: theViewController.view.leadingAnchor),
            scannerViewController.view.trailingAnchor.constraint(equalTo: theViewController.view.trailingAnchor),
            scannerViewController.view.topAnchor.constraint(equalTo: theViewController.view.topAnchor),
            scannerViewController.view.bottomAnchor.constraint(equalTo: theViewController.view.bottomAnchor)
        ])
        scannerViewController.didMove(toParent: theViewController)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // Update the view controller if needed
    }
}

class Callus : ScannerViewControllerHolder {

    var dismissViewController: (() -> Void)?

    var scannerViewController: UIViewController?
}


#Preview {
    ContentView()
}
