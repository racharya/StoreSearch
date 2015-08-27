//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Rachana Acharya on 8/26/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.removeConstraints(view.constraints())//getting rid of storyboard's automatic constraints
        view.setTranslatesAutoresizingMaskIntoConstraints(true)//positioning and sizing our views manually
        
        pageControl.removeConstraints(pageControl.constraints())
        pageControl.setTranslatesAutoresizingMaskIntoConstraints(true)
        
        scrollView.removeConstraints(scrollView.constraints())
        scrollView.setTranslatesAutoresizingMaskIntoConstraints(true)
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        scrollView.contentSize = CGSize(width: 1000, height: 1000)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //making sure the new view controller object is properly deallocated
    deinit {
        println("deinit \(self)")
    }
    
    //Creating our own layout
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.frame = view.bounds
        
        pageControl.frame = CGRect(x: 0,
            y: view.frame.size.height - pageControl.frame.size.height,
            width:view.frame.size.height,
            height: pageControl.frame.size.height)
        
    }


}// end of LandscapeViewController
