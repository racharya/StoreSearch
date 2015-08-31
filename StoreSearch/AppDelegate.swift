//
//  AppDelegate.swift
//  StoreSearch
//
//  Created by Rachana Acharya on 8/15/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var splitViewController: UISplitViewController {
        return window!.rootViewController as! UISplitViewController
    }
    
    var searchViewController: SearchViewController {
        return splitViewController.viewControllers.first as! SearchViewController
    }

    var detailNavigationController: UINavigationController {
        return splitViewController.viewControllers.last as! UINavigationController
    }
    
    var detailViewController: DetailViewController {
        return detailNavigationController.topViewController as! DetailViewController
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        customizeAppearance()
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func customizeAppearance(){
        let barTintColor = UIColor(red: 20/225, green: 160/225, blue: 160/225, alpha: 1)
        //changes all search bars in the application
        UISearchBar.appearance().barTintColor = barTintColor
        window!.tintColor = UIColor(red: 10/225, green: 80/225, blue: 80/225, alpha: 1)
    }
    
    

}

