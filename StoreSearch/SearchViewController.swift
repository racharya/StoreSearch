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
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
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
    func urlWithSearchText(searchText: String) -> NSURL {
        
        let escapedSearchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!//escape the special characters
        let urlString = String(format: "http://itunes.apple.com/search?term=%@&limit=200", escapedSearchText)
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
    
    //converts internal identifier to the text we want to show to the user
    func kindForDisplay(kind: String) -> String {
                    switch kind {
                case "album": return "Album"
                case "audiobook": return "Audio Book"
                case "book": return "Book"
                case "ebook": return "E-Book"
                case "feature-movie": return "Movie"
                case "music-video": return "Music Video"
                case "podcast": return "Podcast"
                case "software": return "App"
                case "song": return "Song"
                case "tv-episode": return "TV Episode"
                default: return kind
                    }
    }
    
}//end of SearchViewController

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
                    
        if !searchBar.text.isEmpty {
        searchBar.resignFirstResponder() // tells UISearchBar that it should no longer listen to keyboard input
        isLoading = true
        tableView.reloadData()
        
        hasSearched = true
        searchResults = [SearchResult]()//clear old collection
        
        //1.gets a reference to the queue
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        //2.once we have the queue, we can dispatch a closure on it
        dispatch_async(queue) {
        // this is the closure which gets put on the queue and executes asynchronously in the background
        let url = self.urlWithSearchText(searchBar.text)
                    
        if let jsonString = self.performStoreRequestWithURL(url){
            if let dictionary = self.parseJSON(jsonString) {
                self.searchResults = self.parseDictionary(dictionary)
                self.searchResults.sort(<)
                        
        dispatch_async(dispatch_get_main_queue()){//dispatch_get_main_queue returns reference to the main queue and dispatch_async 
        //schedules a new closure on that queue
            self.isLoading = false
            self.tableView.reloadData()
        }
    
                }
            }
        dispatch_async(dispatch_get_main_queue()) {
            self.showNetworkError()
            }
        }
    }
}
                    
                    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
                        return .TopAttached
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
                        cell.nameLabel.text = searchResult.name
                        if searchResult.artistName.isEmpty {
                cell.artistNameLabel.text = "Unknown"//if no artist name found
            } else {
                //adding kind property tells user what kind of product it is
                cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, kindForDisplay(searchResult.kind))
                        }
                        
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
        if searchResults.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
                            
}//end of UITableViewDelegate
