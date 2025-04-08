import FirebaseAuth
import AuthenticationServices
import SafariServices

class CustomAuthUIDelegate: NSObject, AuthUIDelegate {
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        
        // Present the reCAPTCHA view controller
        rootViewController.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        
        // Dismiss the reCAPTCHA view controller
        rootViewController.dismiss(animated: flag, completion: completion)
    }

    func present(_ viewControllerToPresent: UIViewController) {
        if let topVC = UIApplication.shared.windows.first?.rootViewController?.topMostViewController() {
            topVC.present(viewControllerToPresent, animated: true, completion: nil)
        }
    }
    
    // This method is called to present the SFSafariViewController
    func presentationAnchor(for authorizationController: ASAuthorizationController) -> ASPresentationAnchor {
        // Return the topmost window
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
    
    // Optional: Customize the presentation of the SFSafariViewController

    
    // Optional: Dismiss the SFSafariViewController
    func dismiss(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        viewController.dismiss(animated: animated, completion: completion)
    }
}

// Extension to get the topmost view controller
extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presentedVC = self.presentedViewController {
            return presentedVC.topMostViewController()
        }
        if let navVC = self as? UINavigationController {
            return navVC.visibleViewController?.topMostViewController() ?? navVC
        }
        if let tabVC = self as? UITabBarController {
            return tabVC.selectedViewController?.topMostViewController() ?? tabVC
        }
        return self
    }
}
