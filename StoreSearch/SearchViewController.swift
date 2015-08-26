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
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    var dataTask: NSURLSessionDataTask?
    var landscapeViewController: LandscapeViewController?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
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
        
        tableView.rowHeight = 80
        searchBar.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Builds url as a string by placing the text from the search bar behind the "term=" param and then returns this string into an NSURL obj
    func urlWithSearchText(searchText: String, category: Int) -> NSURL {
        
        var entityName: String
        //turns category index from a number into a string
        switch category {
        case 1: entityName = "musicTrack"
        case 2: entityName = "software"
        case 3: entityName = "ebook"
        default: entityName = ""
        }
        
        let escapedSearchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!//escape the special characters
        let urlString = String(format: "http://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, entityName)
        let url = NSURL(string: urlString)
        //force unwrapping failable initializers to return an actual NSURL obj
        return url!
    }
    
    func parseJSON(data: NSData) -> [String: AnyObject]? { // returns dictionary of type [String: AnyObject]
        
        var error: NSError?
        if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as? [String: AnyObject] {
            return json
        } else if let error = error {
            println("JSON Error: \(error)")
        } else {
            println("Unknown JSON Error")
        }
        return nil
    }
    
    func showNetworkError(){
        let alert = UIAlertController(title: "Whoops...", message: "There was an error reading from the iTunes Store. Please try again", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // goes through top-level dictionary and looks at each search result in turn
    func parseDictionary(dictionary: [String: AnyObject]) ->  [SearchResult] {
        
        var searchResults = [SearchResult]()
        //1.making sure dictionary has a key named "results" that contains an array
        if let array: AnyObject = dictionary["results"] {
            //2. Loop through the each items in the array(each items are dictionary)
            for resultDict in array as! [AnyObject] {
                //3.casting each dictionary items(type AnyObject) to the right type(AnyObject)
                if let resultDict = resultDict as? [String: AnyObject] {
                    var searchResult: SearchResult?
                    //if found item is a "track" then create a SearchResult object using parseTrack()
                    if let wrapperType = resultDict["wrapperType"] as? String {
                        switch wrapperType {
                        case "track":
                            searchResult = parseTrack(resultDict)
                        case "audiobook":
                            searchResult = parseAudioBook(resultDict)
                        case "software":
                            searchResult = parseSoftware(resultDict)
                        default:
                            break // does nothing and moves along
                        }
                    }
                        //since ebook doesnot have a wrapperType field
                    else if let kind = resultDict["kind"] as? String {
                        if kind == "ebook" {
                            searchResult = parseEBook(resultDict)
                        }
                    }
                    if let result = searchResult {
                        searchResults.append(result) //add to searchResults array
                    }
                    //5. If something went wrong, print out a message for debugging purposes
                } else {
                    println("Expected a dictionary")
                }
            }
        } else {
            println("Expected 'results' array")
        }
        return searchResults
    }
    
    //instantiate a new SearchResult object then get the values out of the dictionary and put them in the SearchResult's properties
    func parseTrack(dictionary: [String : AnyObject]) -> SearchResult {
        
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String //cast price (number) to string
        
        if let price = dictionary["trackPrice"] as? Double { // then cast price to double
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    func parseAudioBook(dictionary: [String : AnyObject]) -> SearchResult {
        
        let searchResult = SearchResult()
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String
        searchResult.kind = "audiobook" //AudioBooks don't have a kind so manually set it
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["collectionPrice"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult {
            let searchResult = SearchResult()
            searchResult.name = dictionary["trackName"] as! String
            searchResult.artistName = dictionary["artistName"] as! String
            searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
            searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
            searchResult.storeURL = dictionary["trackViewUrl"] as! String
            searchResult.kind = dictionary["kind"] as! String
            searchResult.currency = dictionary["currency"] as! String
            
            if let price = dictionary["price"] as? Double {
                searchResult.price = price
            }
            if let genre = dictionary["primaryGenreName"] as? String {
                searchResult.genre = genre
            }
            return searchResult
    }
    
    func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
                
                let searchResult = SearchResult()
                searchResult.name = dictionary["trackName"] as! String
                searchResult.artistName = dictionary["artistName"] as! String
                searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
                searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
                searchResult.storeURL = dictionary["trackViewUrl"] as! String
                searchResult.kind = dictionary["kind"] as! String
                searchResult.currency = dictionary["currency"] as! String
                if let price = dictionary["price"] as? Double {
                searchResult.price = price
                }
                if let genres: AnyObject = dictionary["genres"] {
                //ebook dont have a genre so manually set it using join()
                searchResult.genre = ", ".join(genres as! [String])
                }
                return searchResult
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
            //3. set the size and position of new view controller. It is of the same size as the SearchViewController.
            controller.view.frame = view.bounds
            //4. minimum steps to add one view controller to another
            view.addSubview(controller.view)//first step: add landscape controller vies as a subview
            addChildViewController(controller)//2nd step: tell the SearchViewController that the new view controller manages the part of the screen
            controller.didMoveToParentViewController(self)//3rd step: tell new view controller that it now has a parent view controller
        }
    }
    
    //hides the landscape view controller
    func hideLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeViewController {
            controller.willMoveToParentViewController(nil)//tells the view controller that it is leaving the view controller hierarchy
            controller.view.removeFromSuperview()//remove the view from the screen
            controller.removeFromParentViewController()// truly dispose of the view controller
            landscapeViewController = nil//removes the last strong reference to the LandscapeViewController
        }
    }
}//end of SearchViewController

extension SearchViewController: UISearchBarDelegate {
    func performSearch() {
                    
        if !searchBar.text.isEmpty {
        searchBar.resignFirstResponder() // tells UISearchBar that it should no longer listen to keyboard input
        dataTask?.cancel()//if there was an active data task this will cancel it so no old searches can ever get in the way of new search
        isLoading = true
        tableView.reloadData()
        
        hasSearched = true
        searchResults = [SearchResult]()//clear old collection
        
        //1.create NSURL object with search text
        let url = self.urlWithSearchText(searchBar.text, category: segmentedControl.selectedSegmentIndex)
        //2.obtain the NSURLSession obj
        let session = NSURLSession.sharedSession()
        //3. create dataTask for sending HTTP GET request. The code from completionHandler will be invoked after the data task has 
        //received the reply from the server
        dataTask = session.dataTaskWithURL(url, completionHandler:{
            data, response, error in
            
            //4. do this in case of error
            if let error = error {
                println("Failure! \(error)")
                //skip rest of the code in the closure if error code = -999
                if error.code == -999 {return}
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    //converting JSON into dictionary
                    if let dictionary = self.parseJSON(data){
                    self.searchResults = self.parseDictionary(dictionary)
                    self.searchResults.sort(<)
                    
                    // swtiching back to main thread to update UIs
                    dispatch_async(dispatch_get_main_queue()) {
                        self.isLoading = false
                        self.tableView.reloadData()
                    }
                    return
                }
                } else {
                    println("Failure!\(response)")
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.hasSearched = false
                self.isLoading = false
                self.tableView.reloadData()
                self.showNetworkError()
            }
        })
            //5. once data task is created, we work on background thread to start it
            dataTask?.resume()// makes asynchronous
        
     }
}
                    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let detailViewController = segue.destinationViewController as! DetailViewController
            let indexPath = sender as! NSIndexPath
            let searchResult = searchResults[indexPath.row]
            detailViewController.searchResult = searchResult
        }
    }
}//end of extension UISearchBarDelegate

extension SearchViewController: UITableViewDataSource {
            
            func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if isLoading {
            return 1
        } else if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
            }
            }
            
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
            if isLoading {
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as! UITableViewCell
                let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
                    spinner.startAnimating()
                    return cell
                        
            } else if searchResults.count == 0 {
                return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! UITableViewCell
            } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
                let searchResult = searchResults[indexPath.row]
                cell.configureForSearchResult(searchResult)
                    return cell
            }
    }
            
}//end of UITableViewDataSource

extension SearchViewController: UITableViewDelegate {
    //deselects the row with animation
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ShowDetail", sender: indexPath) // manually triggers the segue when user taps on row
    }
                            
    //make sure to select only row with actual search results
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if searchResults.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
                            
}//end of UITableViewDelegate
