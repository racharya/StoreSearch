//
//  Search.swift
//  StoreSearch
//
//  Created by Rachana Acharya on 8/28/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import Foundation

class Search {
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    
    private var dataTask: NSURLSessionDataTask? = nil
    
    func performSearchForText(text: String, category: Int) {
        println("Searching...")
    }
}
