//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Rachana Acharya on 8/15/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import Foundation

class SearchResult {
    var name = ""
    var artistName = ""
    var artworkURL60 = ""
    var artworkURL100 = ""
    var storeURL = ""
    var kind = ""
    var currency = ""
    var price = 0.0
    var genre = ""
    
    func kindForDisplay() -> String {
        //?? makes sure to return original value of kind if dictionary gives nil
        return displayNamesForKind[kind] ?? kind
    }
    
    //converts internal identifier to the text we want to show to the user
    //if Localizable.strings file is available, following code looks for "Album" and returns the translation as specified in the file
    private let displayNamesForKind = ["album": NSLocalizedString("Album",comment: "Localized kind: Album"),
            "audiobook": NSLocalizedString("Audio Book",comment: "Localized kind: Audio Book"),
            "book": NSLocalizedString("Book",comment: "Localized kind: Book"),
            "ebook": NSLocalizedString("E-Book",comment: "Localized kind: E-Book"),
            "feature-movie": NSLocalizedString("Movie",comment: "Localized kind: Feature Movie"),
            "music-video": NSLocalizedString("Music Video",comment: "Localized kind: Music Video"),
            "podcast": NSLocalizedString("Podcast",comment: "Localized kind: Podcast"),
            "software": NSLocalizedString("Software",comment: "Localized kind: Software"),
            "song": NSLocalizedString("Song",comment: "Localized kind: Song"),
            "tv-episode": NSLocalizedString("TV Episode",comment: "Localized kind: TV Episode"),]
}// end of SearchResult class

//Operator overloading. creating "<" function to help in sorting
func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == NSComparisonResult.OrderedAscending
}

//Exercise: Sort in decending order of the name
func > (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == NSComparisonResult.OrderedDescending
}

