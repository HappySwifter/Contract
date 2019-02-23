//
//  FullScrennImageController.swift
//  Contract
//
//  Created by Артем Валиев on 26/01/2019.
//  Copyright © 2019 Артем Валиев. All rights reserved.
//

import Foundation
import UIKit

private let offsetLeft: CGFloat = 10

class FullScreenImageVC: UIViewController {
    
    var didDismissHandler: (() -> Void)?
    var removeHandler: (() -> Void)?
    
    var imageView: UIImageView!
    var image: UIImage!
    var activityViewController: UIActivityViewController!
    let closeButton = UIButton(type: .custom)
    var scrollView: UIScrollView!
    var panGesture: UIPanGestureRecognizer!
    var doubleTap: UITapGestureRecognizer!
    var imageSize: CGSize = .zero
    var imageScale: CGFloat = 1.0
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: Share Button
    fileprivate lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "trash")!, for: .normal)
        button.backgroundColor = .clear
        button.frame.size = CGSize(width: realSize(40), height: realSize(40))
        button.frame.origin = CGPoint(x: offsetLeft, y: self.view.bounds.height - offsetLeft - button.frame.size.height)
        return button
    }()
    
    @objc func deleteImage() {
        removeHandler?()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeImage = UIImage(named: "close_white")
        closeButton.setImage(closeImage, for: .normal)
        closeButton.setImage(closeImage, for: .highlighted)
        closeButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        let swipeGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(FullScreenImageVC.dismissView))
        swipeGestureRecognizer.direction = [.up, .down]
        self.view.addGestureRecognizer(swipeGestureRecognizer)
        
        if (scrollView == nil) {
            
            scrollView = UIScrollView(frame: UIScreen.main.bounds)
            scrollView.backgroundColor = UIColor.clear
            scrollView.isPagingEnabled = false
            scrollView.alpha = 0.0
            scrollView.bounces = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            scrollView.alwaysBounceVertical = true
            scrollView.alwaysBounceHorizontal = false
            scrollView.delegate = self
            scrollView.decelerationRate = UIScrollView.DecelerationRate.fast
            scrollView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
            scrollView.minimumZoomScale = 0.5
            scrollView.maximumZoomScale = 5.0
            
            self.setupGestures()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .black
        if let first = UIApplication.shared.windows.first {
            first.backgroundColor = .clear
            if let first = first.subviews.first {
                first.backgroundColor = .clear
            }
        }
        for v in scrollView.subviews {
            v.removeFromSuperview()
        }
        self.view.addSubview(scrollView)
        self.view.addSubview(closeButton)
        self.view.addSubview(deleteButton)

        scrollView.contentSize = UIScreen.main.bounds.size
        
        imageView = UIImageView(frame: UIScreen.main.bounds)
        scrollView.addSubview(imageView)
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.addGestureRecognizer(self.panGesture)
        imageView.addGestureRecognizer(self.doubleTap)
        imageView.isUserInteractionEnabled = true
        self.view.bringSubviewToFront(self.closeButton)
        self.view.bringSubviewToFront(self.deleteButton)
        deleteButton.isHidden = false
        imageView.image = self.image


        imageSize = image.size
        if imageSize.height > 0 && imageSize.width > 0 {
            let zh = UIScreen.main.bounds.height / imageSize.height
            let zw = UIScreen.main.bounds.width / imageSize.width
            imageScale = min(zh, zw)
            imageSize.height *= imageScale
            imageSize.width *= imageScale
        }
        scrollView.alpha = 1.0
        zoomToFit()
        updateUIForCurrentOrientation()
    }
    
    override func viewDidLayoutSubviews() {
        //        dLog("")
        super.viewDidLayoutSubviews()
        self.closeButton.frame = CGRect(x: UIScreen.main.bounds.size.width - realSize(40 + 10),
                                        y: realSize(10),
                                        width: realSize(40),
                                        height: realSize(40))
        self.deleteButton.frame.origin = CGPoint(x: offsetLeft,
                                                y: UIScreen.main.bounds.height - offsetLeft - self.deleteButton.frame.size.height)
        
        self.scrollView.frame = UIScreen.main.bounds
        self.scrollView.contentSize = UIScreen.main.bounds.size
        self.imageView.center = self.contentCenter(forBoundingSize: UIScreen.main.bounds.size, contentSize: UIScreen.main.bounds.size)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //        dLog("")
        coordinator.animate(alongsideTransition: nil, completion: { _ in
            self.zoomToFit()
        })
    }
    
    fileprivate func zoomToFit() {
        //        dLog("")
        self.scrollView.setZoomScale(1, animated: false)
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.scrollView.frame = UIScreen.main.bounds
            self.scrollView.contentSize = UIScreen.main.bounds.size
            self.imageView.frame = UIScreen.main.bounds
        })
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //        dLog("")
        self.deallocRes()
        didDismissHandler?()
        super.viewDidDisappear(animated)
    }
    
    
    @objc func dismissView() {
        self.deallocRes()
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setupGestures() {
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delaysTouchesBegan = true
        
        panGesture = UIPanGestureRecognizer()
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        panGesture.delegate = self
        panGesture.addTarget(self, action: #selector(panGestureRecognized))
        
    }
    
    // MARK: Dealloc Resurces
    open func deallocRes() {
        //        dLog("")
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        self.scrollView.removeFromSuperview()
        self.closeButton.removeFromSuperview()
    }
    
    fileprivate func updateUIForCurrentOrientation() {
        //        dLog("")
        self.imageView.center = contentCenter(forBoundingSize: scrollView.bounds.size, contentSize: scrollView.contentSize)
        
    }

    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        //        dLog("")
        if (self.scrollView.zoomScale == self.scrollView.maximumZoomScale) {
            zoomToFit()
            updateUIForCurrentOrientation()
        } else {
            let touchPoint = sender.location(in: self.scrollView)
            self.scrollView.zoom(to: CGRect(origin: touchPoint, size: CGSize(width: 1, height: 1)), animated: true)
            self.imageView.center = contentCenter(forBoundingSize: scrollView.bounds.size, contentSize: scrollView.contentSize)
        }
    }
    
    @objc func panGestureRecognized(_ gesture: UIPanGestureRecognizer) {
        //        dLog("")
        let currentItem: UIView = gesture.view!
        
        let translatedPoint = gesture.translation(in: nil)
        
        let delta = translatedPoint.y
        let shiftY = (self.scrollView.contentSize.height-currentItem.bounds.height)/2 + delta
        let newAlpha = CGFloat(1 - fabsf(Float(delta/UIScreen.main.bounds.height)))
        
        if (gesture.state == UIGestureRecognizer.State.began || gesture.state == UIGestureRecognizer.State.changed) {
            scrollView.isScrollEnabled = false
            currentItem.frame = CGRect(x: currentItem.frame.origin.x, y: shiftY, width: currentItem.frame.size.width, height: currentItem.frame.size.height)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(newAlpha)
        } else if (gesture.state == UIGestureRecognizer.State.ended ) {
            scrollView.isScrollEnabled = true
            if (abs(delta) >= UIScreen.main.bounds.height*0.2) {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.view.backgroundColor = UIColor.clear
                    if (translatedPoint.y > 0) {
                        currentItem.frame = CGRect(x: currentItem.frame.origin.x,
                                                   y: UIScreen.main.bounds.height,
                                                   width: currentItem.frame.size.width,
                                                   height: currentItem.frame.size.height)
                    } else {
                        currentItem.frame = CGRect(x: currentItem.frame.origin.x,
                                                   y: -UIScreen.main.bounds.height,
                                                   width: currentItem.frame.size.width,
                                                   height: currentItem.frame.size.height)
                    }
                    
                }, completion: { (finished: Bool) -> Void in
                    if  (finished == true) {
                        self.dismissView()
                    }
                })
            } else {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.view.backgroundColor = .black
                    currentItem.center = self.contentCenter(forBoundingSize: self.scrollView.bounds.size, contentSize: self.scrollView.contentSize)
                    
                })
            }
        }
    }
    
}

// MARK: - gestureRecognizerShouldBegin

extension FullScreenImageVC: UIGestureRecognizerDelegate {
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let translatedPoint = (gestureRecognizer as! UIPanGestureRecognizer).translation(in: gestureRecognizer.view)
        return abs(translatedPoint.y) > abs(translatedPoint.x)
    }
}

extension FullScreenImageVC: UIScrollViewDelegate {
    open func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.imageView.center = contentCenter(forBoundingSize: scrollView.bounds.size, contentSize: scrollView.contentSize)
    }
    
    func contentCenter(forBoundingSize boundingSize: CGSize, contentSize: CGSize) -> CGPoint {
        
        let horizontalOffest = ceil((boundingSize.width > contentSize.width) ? ((boundingSize.width - contentSize.width) * 0.5): 0.0)
        let verticalOffset = ceil((boundingSize.height > contentSize.height) ? ((boundingSize.height - contentSize.height) * 0.5): 0.0)
        let point = CGPoint(x: ceil(contentSize.width * 0.5 + horizontalOffest), y: ceil(contentSize.height * 0.5 + verticalOffset))
        return point
    }
    
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}

