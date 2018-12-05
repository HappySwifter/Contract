
import Foundation
import UIKit


typealias dispatch_cancelable_closure = (_ cancel: Bool) -> Void

@discardableResult func delay(_ time: TimeInterval, closure: @escaping () -> Void) -> dispatch_cancelable_closure? {

    func dispatch_later(_ clsr: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: clsr)
    }

    var closure:(() -> Void)? = closure

    var cancelableClosure: dispatch_cancelable_closure?

    let delayedClosure: dispatch_cancelable_closure = { cancel in
        if closure != nil {
            if (cancel == false) {
                DispatchQueue.main.async(execute: closure!)
            }
        }
        cancelableClosure = nil
        closure = nil
    }

    cancelableClosure = delayedClosure

    dispatch_later {
        if let delayedClosure = cancelableClosure {
            delayedClosure(false)
        }
    }

    return cancelableClosure
}

func cancel_delay(_ closure: dispatch_cancelable_closure?) {
    if closure != nil {
        closure!(true)
    }
}

func presentAlert(title: String, text: String) {
    let contr = UIAlertController(title: title, message: text, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    contr.addAction(okAction)
    UIViewController.topMostViewController()?.present(contr, animated: true, completion: nil)
}
