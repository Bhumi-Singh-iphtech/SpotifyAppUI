import UIKit

/// Helper class to handle push/pop with fade animation
final class NavigationHelper: NSObject, UINavigationControllerDelegate {
    
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        self.navigationController.delegate = self
    }
    
    /// Push a view controller with fade
    func push(_ viewController: UIViewController, duration: TimeInterval = 0.1) {
        let transition = CATransition()
        transition.duration = duration
        transition.type = .fade
        transition.subtype = .fromRight
        navigationController.view.layer.add(transition, forKey: kCATransition)
        navigationController.pushViewController(viewController, animated: false)
    }
    
    /// Pop current view controller with fade
    func pop(duration: TimeInterval = 0.1) {
        let transition = CATransition()
        transition.duration = duration
        transition.type = .fade
        transition.subtype = .fromLeft
        navigationController.view.layer.add(transition, forKey: kCATransition)
        navigationController.popViewController(animated: false)
    }
    
    // Optional: If you want interactive fade pop via back button
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeAnimator(operation: operation)
    }
}

/// Animator for fade transition (push and pop)
final class FadeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let operation: UINavigationController.Operation
    
    init(operation: UINavigationController.Operation) {
        self.operation = operation
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        if operation == .push {
            container.addSubview(toVC.view)
            toVC.view.alpha = 0
            UIView.animate(withDuration: 0.1, animations: {
                toVC.view.alpha = 1
            }) { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        } else if operation == .pop {
            container.insertSubview(toVC.view, belowSubview: fromVC.view)
            UIView.animate(withDuration: 0.1, animations: {
                fromVC.view.alpha = 0
            }) { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}
