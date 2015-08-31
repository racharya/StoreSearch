//
//  ViewController.swift
//  StoreSearch
//
//  Created by Rachana Acharya on 8/15/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
   
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var landscapeViewController: LandscapeViewController?
    weak var splitViewDetail: DetailViewController?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    let search = Search()
    
    //new struct to reuse identifier
    struct TableViewCellIdentifiers {
        //common trick to use static let
        //static value can be used without an instance
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tells table view to add a 64 pt margin at the top, (20 for status bar and 44 for search bar)
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        
        //load nib, ask table view to register it using identifier
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        title = NSLocalizedString("Search", comment: "Split-view master button")
        tableView.rowHeight = 80
        
        //disable keyboard appearance in iPad when the app is just launched
        if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
            searchBar.becomeFirstResponder()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be re-created.
    }

    func showNetworkError(){
        let alert = UIAlertController(
            title: NSLocalizedString("Whoops...", comment: "Error alert: title"),
            message: NSLocalizedString("There was an error reading from the iTunes Store. Please try again",comment:"Error alert: message"),
            preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
     
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        performSearch()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        performSearch()
    }
    
    //invoked on device rotations
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        
        switch newCollection.verticalSizeClass {
        case .Compact:
            showLandscapeViewWithCoordinator(coordinator)
        case .Regular, .Unspecified:
            hideLandscapeViewWithCoordinator(coordinator)
        }
    }
    
    //shows new LandscapeViewControler as a modal screen. It is a child view controller of SearchViewController
    func showLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
        //1. makes sure that the view controller does not instantiates a second view when already looking at one
        precondition(landscapeViewController == nil)
        //2. instantiate "LandscapeViewController". Since there is no segue, we do it manually.
        landscapeViewController = storyboard!.instantiateViewControllerWithIdentifier("LandscapeViewController") as? LandscapeViewController
        if let controller = landscapeViewController {
            controller.search  = search// access searchResults before accessing view property from LSviewControler
            //3. set the size and position of new view controller. It is of the same size as the SearchViewController.
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            //4. minimum steps to add one view controller to another
            view.addSubview(controller.view)//first step: add landscape controller vies as a subview
            addChildViewController(controller)//2nd step: tell the SearchViewController that the new view controller manages the part of the screen
            coordinator.animateAlongsideTransition({_ in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder() //disappear keyboard when flip the device
                if self.presentedViewController != nil {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                },
                completion: {_ in
                    controller.didMoveToParentViewController(self)//3rd step: tell new view controller that it now has a parent view controller
            })
            
        }
    }
    
    //hides the landscape view controller
    func hideLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeViewController {
            controller.willMoveToParentViewController(nil)//tells the view controller that it is leaving the view controller hierarchy
            coordinator.animateAlongsideTransition({_ in
                controller.view.alpha = 0
                if self.presentedViewController != nil {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
        }, completion: {_ in
            controller.view.removeFromSuperview()//remove the view from the screen
            controller.removeFromParentViewController()// truly dispose of the view controller
            self.landscapeViewController = nil//removes the last strong reference to the LandscapeViewController
        })
        }
    }
    
    func hideMasterPane() {
        UIView.animateWithDuration(0.25, animations: {
            self.splitViewController!.preferredDisplayMode = .PrimaryHidden
        }, completion: { _ in
            self.splitViewController!.preferredDisplayMode = .Automatic
        })
    }
}//end of SearchViewController

extension SearchViewController: UISearchBarDelegate {
    func performSearch() {
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
        search.performSearchForText(searchBar.text, category: category ,completion: { success in
            if !success {
                self.showNetworkError()
            }
            self.tableView.reloadData()
            if let controller = self.landscapeViewController {
                controller.searchResultsReceived()
            }
            })
        tableView.reloadData()
        searchBar.resignFirstResponder()
        }
        
}
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            switch search.state {
            case .Results(let list):
                let detailViewController = segue.destinationViewController as! DetailViewController
                let indexPath = sender as! NSIndexPath
                let searchResult = list[indexPath.row]
                detailViewController.searchResult = searchResult
                detailViewController.isPopUp = true
            default:
                break
            }
        }
    }
}//end of extension UISearchBarDelegate

extension SearchViewController: UITableViewDataSource {
            
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch search.state {
        case .NotSearchedYet:
            return 0
        case .Loading:
            return 1
        case .NoResults:
            return 1
        case .Results(let list):
            return list.count
        }
    }
            
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch search.state {
        case .NotSearchedYet:
            fatalError("Should never get here")
        case .Loading:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as! UITableViewCell
                let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
                    spinner.startAnimating()
                return cell
                        
        case .NoResults:
                return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! UITableViewCell
            
        case .Results(let list):
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
            let searchResult = list[indexPath.row]
            cell.configureForSearchResult(searchResult)
            return cell
        }
    }
            
}//end of UITableViewDataSource

extension SearchViewController: UITableViewDelegate {
    //deselects the row with animation
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchBar.resignFirstResponder()
        if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .Compact {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ShowDetail", sender: indexPath) // manually triggers the segue when user taps on row
        } else {
            switch search.state {
            case .Results(let list):
                splitViewDetail?.searchResult = list[indexPath.row]
            default:
                break
            }
            if splitViewController!.displayMode != .AllVisible {
                hideMasterPane()
            }
        }
    }
                            
    //make sure to select only row with actual search results
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        switch search.state {
        case .NotSearchedYet, .Loading, .NoResults:
            return nil
        case .Results:
            return indexPath
        }
    }
                            
}//end of UITableViewDelegate
