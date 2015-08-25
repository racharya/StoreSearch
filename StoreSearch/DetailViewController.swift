//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Rachana Acharya on 8/23/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 10//gives round corners to the popupview
        view.tintColor = UIColor(red:20/255, green: 160/255, blue: 160/255, alpha:1)
        
        //creates the new gesture recognizer and listens to the taps in the view and then calls close() in response
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("close"))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
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

extension DetailViewController: UIGestureRecognizerDelegate {
    //closes the detail popup when tap on outside it
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return (touch.view === view)
    }
} //end of DetailViewController: UIGestureRecognizerDelegate
