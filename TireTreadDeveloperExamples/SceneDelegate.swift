import UIKit

/// Owns the app's window under the UIKit scene life cycle.
///
/// An app built against the iOS 27 SDK is terminated at launch unless it adopts this life
/// cycle, so the window is built here rather than in the app delegate. Building it from the
/// window scene also keeps the SDK's orientation handling correct: the scanner resolves the
/// interface orientation through `view.window.windowScene`, which is only populated for a
/// window that belongs to a scene.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Sized from the scene rather than from UIScreen.main, which is deprecated as of iOS 26.
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(
            rootViewController: ApiExplorerViewController()
        )
        window.makeKeyAndVisible()
        self.window = window
    }
}
