//
//  FadeOutAnimationController.swift
//  StoreSearch
//
//  Created by Rachana Acharya on 8/26/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import Foundation
import UIKit

class FadeOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.4
    }
    
    //sets alpha value to 0 to fade out
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey){
            let duration = transitionDuration(transitionContext)
            UIView.animateWithDuration(duration, animations: {
                fromView.alpha = 0
                }, completion: { finished in
                    transitionContext.completeTransition(finished)
            })
        }
    }
}