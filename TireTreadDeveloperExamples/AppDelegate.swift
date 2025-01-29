import UIKit

@main
class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?

    private var viewController: UIViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.viewController = HomeViewController()
        self.window?.rootViewController = UINavigationController(rootViewController: self.viewController)
        self.window?.makeKeyAndVisible()
        return true
    }
}

