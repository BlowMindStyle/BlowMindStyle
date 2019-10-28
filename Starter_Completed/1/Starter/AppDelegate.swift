import UIKit

enum Step {
    case firstStyle
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        let viewController = createViewController(for: .firstStyle)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        return true
    }

    func createViewController(for step: Step) -> UIViewController {
        switch step {
        case .firstStyle:
            let vc = ViewController1()
            vc.applyStyles()
            return vc
        }
    }
}

