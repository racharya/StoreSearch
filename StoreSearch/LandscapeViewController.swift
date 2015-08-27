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
    var searchResults = [SearchResult]()
    private var firstTime = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.removeConstraints(view.constraints())//getting rid of storyboard's automatic constraints
        view.setTranslatesAutoresizingMaskIntoConstraints(true)//positioning and sizing our views manually
        
        pageControl.removeConstraints(pageControl.constraints())
        pageControl.setTranslatesAutoresizingMaskIntoConstraints(true)
        
        scrollView.removeConstraints(scrollView.constraints())
        scrollView.setTranslatesAutoresizingMaskIntoConstraints(true)
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        
        pageControl.numberOfPages = 0

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
            width:view.frame.size.width,
            height: pageControl.frame.size.height)
        
        if firstTime {
            firstTime = false
            tileButtons(searchResults)
    }
    }
    private func tileButtons(searchResults: [SearchResult]) {
        var columnsPerPage = 5
        var rowsPerPage = 3
        var itemWidth: CGFloat = 96
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 0
        var marginY: CGFloat = 20
            
        let scrollViewWidth = scrollView.bounds.size.width
            
        switch scrollViewWidth {
        case 568://4 in device or iPhone 5 models
            columnsPerPage  = 6
            itemWidth = 94
            marginX = 2
                
        case 667://4.7 in device or iPhone 6
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
                
        case 736:// 5.5 in device or iPhone 6 plus
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
                
        default: break
        }
        
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth)/2
        let paddingVert = (itemHeight - buttonHeight)/2
            
        var row = 0
        var column = 0
        var x = marginX
        //1.
        for (index, searchResult) in enumerate(searchResults) {
            //2.
            let button = UIButton.buttonWithType(.System) as! UIButton
            button.backgroundColor = UIColor.whiteColor()
            button.setTitle("\(index)", forState: .Normal)
                
            //3.
            button.frame = CGRect(x: x + paddingHorz,
                y: marginY + CGFloat(row)*itemHeight + paddingVert,
                width: buttonWidth,
                height: buttonHeight)
            //4.
            scrollView.addSubview(button)
            //5.
            ++row
            if row == rowsPerPage {
                row = 0
                ++column
                x += itemWidth
                    
                if column == columnsPerPage {
                    column = 0
                    x += marginX * 2
                }
            }
        }
            
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1)/buttonsPerPage
        scrollView.contentSize = CGSize(width: CGFloat(numPages)*scrollViewWidth, height: scrollView.bounds.size.height)
        println("Number of pages: \(numPages)")
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
    }
    

}// end of LandscapeViewController
