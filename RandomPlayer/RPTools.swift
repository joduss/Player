//
//  RPTools.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 12.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import Foundation
import MediaPlayer


//*******************************
//*   Class containing utility functions
//*
//********************************/



/**
Format a number of secondes into a string with format "MINUTES:SECONDS"
- parameter secondsToConvert the number of seconds to format
- returns : the formatted string
*/
func formatTimeToMinutesSeconds(_ secondsToConvert : Int) -> String {
    
    let minutes : Int = secondsToConvert / 60
    let seconds : Int = secondsToConvert % 60
    
    let nf = NumberFormatter()
    nf.minimumIntegerDigits = 2
    
    return String(minutes) + ":" + nf.string(from: NSNumber(value: seconds))!
}


/**clean String for sorting by removing whitespaces
-param string The string to clean
- Returns: The cleaned string
*/
func cleanStringForSort(_ string: String) -> String {
    let template = "$1"
    let pattern = "[\\s]" // remove any whitespace
    let regex = (try? NSRegularExpression(pattern: pattern,
        options: NSRegularExpression.Options.caseInsensitive)) as NSRegularExpression!
    
    return regex!.stringByReplacingMatches(in: string,
        options: NSRegularExpression.MatchingOptions.withTransparentBounds,
        range: NSMakeRange(0, string.characters.count),
        withTemplate: template)
}


/** Return true if the first character of the specified string is alphabetic */
func beginWithLetter(_ string : String) -> Bool {
    
    var processedString = string
    
    if(string.characters.count > 0){
        let idx : String.Index = processedString.characters.index(processedString.startIndex, offsetBy: 1)
        processedString = processedString.substring(to: idx)
        let template = "$1"
        let pattern = "[a-zA-Z]" //remove any alphabetic
        let regex = (try? NSRegularExpression(pattern: pattern,
            options: NSRegularExpression.Options.caseInsensitive)) as NSRegularExpression!
        
        processedString = (regex?.stringByReplacingMatches(in: processedString,
                                                                   options: NSRegularExpression.MatchingOptions.withTransparentBounds,
                                                                   range: NSMakeRange(0, processedString.characters.count),
                                                                   withTemplate: template))!
        
        return processedString == ""
        
    }
    return false
}


/**
* Shuffle the array and separate similar elements*/
func shuffleAndSeparateSimilarElement<T : Equatable>(of array: [T]) -> [T] {
    var newArray = array
    
    if(newArray.isEmpty == false){
        var numRepeat = 1+arc4random() % 5
        
        while(numRepeat > 0) {
            for i in (0 ..< newArray.count - 2) {
                let a = newArray[i]
                let b = newArray[i+1]
                let c = newArray[i+2]
                
                if( (a == b) && (b == c)){
                    //if 33 same are neighbors, we take the one in the middle and put it
                    //somewhere else
                    let r = Int(arc4random_uniform(UInt32(newArray.count)))
                    let temp = newArray[r]
                    newArray[r] = b
                    newArray[i+1] = temp
                }
                else if(a == b){
                    //if a and b are same (neighbor),
                    //we invert the c and b to separate a and b
                    newArray[i+1] = c
                    newArray[i+2] = b
                }
                else if(b == c) {
                    //similar reasoning as above
                    newArray[i] = b
                    newArray[i+1] = a
                }
            }
            numRepeat -= 1
        }
    }
    return newArray
}



class RPTools {
    
    /**
    Create the following a string that gives the number of album (ex: "5 album").
    - parameter collection: the artist
    - returns: a string showing the number of album of the specified artist
    */
    class func numberAlbumOfArtistFormattedString(_ artist : MPMediaItemCollection) -> String {
        if(artist.albumCount > 1){
            return "\(artist.albumCount) albums"
        }
        else {
            return "1 album"
        }
    }
    
    /**
    Create the following a string that gives the number of song (ex: "5 songs").
    - parameter collection: the collection
    - returns: a string showing the number of sing in the collection
    */
    class func numberSongInCollection(_ collection : MPMediaItemCollection) -> String {
        if(collection.items.count > 1){
            return "\(collection.items.count) songs"
        }
        else {
            return "1 song"
        }
    }
    
    /**
    Create the following a string that gives the number of song (ex: "5 songs").
    - parameter items: array of MediaItems
    - returns: a string showing the number of sing in the array
    */
    class func numberSong(_ items : Array<MPMediaItem>) -> String {
        
        if(items.count > 1){
            return "\(items.count) songs"
        }
        else {
            return "1 song"
        }
    }
}



//Extension of Array type
//add a function that shuffle the array
extension Array {
    func shuffleArray()->Array {
        var arr = self
        let c = UInt32(arr.count)
        for i in 0..<(c-1) {
            let j = arc4random_uniform(c)
            if i != j {
                swap(&arr[Int(i)], &arr[Int(j)])
            }
        }
        return arr
    }
}

//extension that adds an easy way to have the count of different albums
extension MPMediaItemCollection {
    var albumCount : Int {
        get {
            let query = MPMediaQuery.albums()
            let filterPredicate = MPMediaPropertyPredicate(
                value: representativeItem!.value(forProperty: MPMediaItemPropertyArtistPersistentID),
                forProperty: MPMediaItemPropertyArtistPersistentID)
            query.filterPredicates = Set(arrayLiteral: filterPredicate)
            
            return query.collections!.count
        }
    }
    
    
}


