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
    var searchResult: SearchResult!
    var downloadTask: NSURLSessionDownloadTask?// to cancel the download task
    
    //enum to determine which animation is chosen for the Detail popup
    enum AnimationStyle {
        case Slide
        case Fade
    }
    var dismissAnimationStyle = AnimationStyle.Fade
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 10//gives round corners to the popupview
        view.tintColor = UIColor(red:20/255, green: 160/255, blue: 160/255, alpha:1)
        
        //creates the new gesture recognizer and listens to the taps in the view and then calls close() in response
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("close"))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        if searchResult != nil {
        updateUI()
        
        view.backgroundColor = UIColor.clearColor()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func close() {
        dismissAnimationStyle = .Slide
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //loads the view controller from the storyboard
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //tells UIKit that this view controller uses custom presentation
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }
    
    //updates the detains in the detail pop-up
    func updateUI() {
        nameLabel.text = searchResult.name
        if searchResult.artistName.isEmpty {
            artistNameLabel.text = "Unknown"
        } else {
            artistNameLabel.text = searchResult.artistName
        }
        kindLabel.text = searchResult.kindForDisplay()
        genreLabel.text = searchResult.genre
        
        //formatting currency
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.currencyCode = searchResult.currency
        var priceText: String
        if searchResult.price == 0 {
            priceText = "Free"
        } else if let text = formatter.stringFromNumber(searchResult.price) {
            priceText = text
        } else {
            priceText = ""
        }
        priceButton.setTitle(priceText, forState: .Normal)
        
        if let url = NSURL(string: searchResult.artworkURL100) {
            downloadTask = artworkImageView.loadImageWithURL(url)
        }
    }
    
    @IBAction func openInStore() {
        if let url = NSURL(string: searchResult.storeURL) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    //cancels image download if user closes the pop-up before the image has been download completely
    deinit {
        downloadTask?.cancel()
    }
    
}//end of DetailViewController class


extension DetailViewController: UIViewControllerTransitioningDelegate {
    
    //tells UIKit what objectes to use to perform the transition to the Detail View Controller
    //uses DimingPresentationController instead of standard presentation controller
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch dismissAnimationStyle {
        case .Slide:
            return SlideOutAnimationController()
        case .Fade:
            return FadeOutAnimationController()
        }
    }
    
}//end of DetailViewController: UIViewControllerTransitioningDelegate

extension DetailViewController: UIGestureRecognizerDelegate {
    //closes the detail popup when tap on outside it
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return (touch.view === view)
    }
} //end of DetailViewController: UIGestureRecognizerDelegate
