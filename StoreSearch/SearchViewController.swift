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
//    @IBOutlet weak var searchBar2: UISearchBar!
   
    //new struct to reuse identifier
    struct TableViewCellIdentifiers {
        //common trick to use static let
        //static value can be used without an instance
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tells table view to add a 64 pt margin at the top, (20 for status bar and 44 for search bar)
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        //load nib, ask table view to register it using identifier
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        tableView.rowHeight = 80
        searchBar.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Builds url as a string by placing the text from the search bar behind the "term=" param and then returns this string into an NSURL obj
    func urlWithSearchText(searchText: String) -> NSURL {
        
        let escapedSearchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!//escape the special characters
        let urlString = String(format: "http://itunes.apple.com/search?term=%@", escapedSearchText)
        let url = NSURL(string: urlString)
        //force unwrapping failable initializers to return an actual NSURL obj
        return url!
    }
    
    func performStoreRequestWithURL(url: NSURL) -> String? {
        
        var error: NSError?
        // String(contentsOfURL, encoding, error) is a constructor of the String class that returns a
        //new string object with the data that it receives from the server at the other end of the URL
        if let resultString = String(contentsOfURL: url, encoding: NSUTF8StringEncoding, error: &error) {
            return resultString
        } else if let error = error {
            println("Download Error: \(error)")
        } else {
            println("Unknown Download Error")
        }
        return nil
    }
    
    func parseJSON(jsonString: String) -> [String: AnyObject]? { // returns dictionary of type [String: AnyObject]
        
        //Since JSON is alreay in a String form, need to put it into an NSData object before conversion to dictionary
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
            var error: NSError?
            //Using NSJSONSerialization class to conver the JSON search results to a Dictionary
            if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as? [String: AnyObject] {
                return json
            } else if let error = error {
                println("Unknown JSON Error")
            }
        }
        return nil
    }
}//end of SearchViewController

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        if !searchBar.text.isEmpty {
            searchBar.resignFirstResponder() // tells UISearchBar that it should no longer listen to keyboard input
            println("The search text is: '\(searchBar.text)'")
            hasSearched = true
        
            searchResults = [SearchResult]()//clear old collection
            let url = urlWithSearchText(searchBar.text)
            println("URL: '\(url)'")
            if let jsonString = performStoreRequestWithURL(url) {//invokes search and returns json data received from the server
                println("Received JSON string '\(jsonString)'")
                if let dictionary = parseJSON(jsonString) { // new parseJSON()
                    println("****Dictionary \(dictionary)")
                }
            }
            
            tableView.reloadData()
        }
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}//end of extension UISearchBarDelegate

extension SearchViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        if searchResults.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! UITableViewCell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            cell.artistNameLabel.text = searchResult.artistName
        
        return cell
        }
    }
}//end of UITableViewDataSource

extension SearchViewController: UITableViewDelegate {
    //deselects the row with animation
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    //make sure to select only row with actual search results
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if searchResults.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
    
}//end of UITableViewDelegate
