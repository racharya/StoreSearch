//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Rachana Acharya on 8/23/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //loads the view controller from the storyboard
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //tells UIKit that this view controller uses custom presentation
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }
}//end of DetailViewController: UIViewController


extension DetailViewController: UIViewControllerTransitioningDelegate {
    
    //tells UIKit what objectes to use to perform the transition to the Detail View Controller
    //uses DimingPresentationController instead of standard presentation controller
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
}//end of DetailViewController: UIViewControllerTransitioningDelegate
