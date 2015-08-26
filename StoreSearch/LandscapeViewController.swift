//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Rachana Acharya on 8/26/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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
    


}
