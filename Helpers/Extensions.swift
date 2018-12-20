//
//  Extensions.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 27/11/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import DrawerController
import UIKit


let MenuWillOpenNotification = Notification.Name("MenuWillOpenNotification")
let screenBounds = UIScreen.main.bounds

func realSize(_ val: CGFloat) -> CGFloat {
    return ceil(val * screenBounds.width / 375) // 375 - ширина iPhone 6, 7
}

func getController<T>(forName name: T.Type, showMenuButton: Bool = true) -> T {
    let contr = UIStoryboard(name: String(describing: name), bundle: Bundle.main)
        .instantiateViewController(withIdentifier: String(describing: name))
    if showMenuButton {
        contr.addMenuButton()
    }

    return contr as! T
}

extension UIViewController {
    
    
    func setCenter(controller: UIViewController) {
        let nav = UINavigationController(rootViewController: controller)
        evo_drawerController?.setCenter(nav, withCloseAnimation: true, completion: nil)
    }
    
    
    func setCenter(controllerName name: UIViewController.Type) {
        
        let contr = getController(forName: name)
        setCenter(controller: contr)
    }
    
    func push(controllerName: UIViewController.Type) {
        let contr = getController(forName: controllerName)
        self.navigationController?.pushViewController(contr, animated: true)
    }
    
    func push(controller: UIViewController) {
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func addMenuButton() {
        let leftDrawerButton =  UIBarButtonItem(image: UIImage(named: "mobile-menu"), style: .plain, target: self, action: #selector(self.leftDrawerButtonPress))
        leftDrawerButton.tintColor = .black
        self.navigationItem.setLeftBarButton(leftDrawerButton, animated: false)
    }
    
    @objc private func leftDrawerButtonPress(sender: AnyObject?) {
        NotificationCenter.default.post(name: MenuWillOpenNotification, object: nil)
        self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    

}


extension UIColor {
    convenience init(hexString: String) {
        
        
        
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (0, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
        
        
        //        var cString = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        //
        //        if (cString.hasPrefix("#")) {
        //            cString = (cString as NSString).substring(from: 1)
        //        }
        //
        //        let rString = (cString as NSString).substring(to: 2)
        //        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        //        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        //
        //        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        //        Scanner(string: rString).scanHexInt32(&r)
        //        Scanner(string: gString).scanHexInt32(&g)
        //        Scanner(string: bString).scanHexInt32(&b)
        //
        //
        //        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
}



extension UIFont {
    
    @objc func mainFont(withSize size: CGFloat = 14) -> UIFont {
        return UIFont.init(name: "HelveticaNeue", size: size)!
    }
    
    @objc func mainItalicFont(withSize size: CGFloat = 14) -> UIFont {
        return UIFont.init(name: "HelveticaNeue-Italic", size: size)!
    }
    
    @objc func mainBoldFont(withSize size: CGFloat = 14) -> UIFont {
        return UIFont.init(name: "HelveticaNeue-Bold", size: size)!
    }
}



extension UIViewController {
    
    /// Returns the current application's top most view controller.
    open class func topMostViewController() -> UIViewController? {
        let rootViewController = UIApplication.shared.windows.first?.rootViewController
        return self.topMostViewControllerOfViewController(rootViewController)
    }
    
    /// Returns the top most view controller from given view controller's stack.
    class func topMostViewControllerOfViewController(_ viewController: UIViewController?) -> UIViewController? {
        // UITabBarController
        if let tabBarController = viewController as? UITabBarController,
            let selectedViewController = tabBarController.selectedViewController {
            return self.topMostViewControllerOfViewController(selectedViewController)
        }
        
        // UINavigationController
        if let navigationController = viewController as? UINavigationController,
            let visibleViewController = navigationController.visibleViewController {
            return self.topMostViewControllerOfViewController(visibleViewController)
        }
        
        // presented view controller
        if let presentedViewController = viewController?.presentedViewController {
            return self.topMostViewControllerOfViewController(presentedViewController)
        }
        
        // child view controller
        for subview in viewController?.view?.subviews ?? [] {
            if let childViewController = subview.next as? UIViewController, childViewController !== viewController {
                return self.topMostViewControllerOfViewController(childViewController)
            }
        }
        
        return viewController
    }
    
}

extension NSSet {
    func toArray<T>() -> [T] {
        let array = self.map({ $0 as! T})
        return array
    }
}
