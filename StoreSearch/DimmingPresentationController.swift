//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Rachana Acharya on 8/23/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import Foundation
import UIKit

class DimmingPresentationController: UIPresentationController {
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
    
    lazy var dimmingView = GradientView(frame: CGRect.zeroRect)
    
    //invoked when the new view controller is about to be shown on the screen
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView.bounds
        
        containerView.insertSubview(dimmingView, atIndex: 0)
        
        //makes the gradient view fade in
        dimmingView.alpha = 0
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ _ in
                self.dimmingView.alpha = 1}, completion: nil)
        }
    }
    
    //makes the gradient view fade out
    override func dismissalTransitionWillBegin() {
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({_ in
                self.dimmingView.alpha = 0
                }, completion: nil)
        }
    }
}// end of DimmingPresentationController
