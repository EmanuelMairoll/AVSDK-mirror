import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.init(for: type(of: self)))
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = storyboard.instantiateInitialViewController()
        window?.makeKeyAndVisible()
        return true
    }

}
