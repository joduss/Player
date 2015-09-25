//
//  RPTools.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 12.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import Foundation
import MediaPlayer


/*******************************
*   Class containing utility functions
*
********************************/


/**Convert and format input given in second to MINUTES:SECONDES*/
func formatTimeToMinutesSeconds(secondsToConvert : Int) -> String {
    
    let minutes : Int = secondsToConvert / 60
    let seconds : Int = secondsToConvert % 60
    
    let nf = NSNumberFormatter()
    nf.minimumIntegerDigits = 2
    
    return String(minutes) + ":" + nf.stringFromNumber(seconds)!
}


/**lean String for sorting by removing whitespaces
* @param string
The string to clean
@return The cleaned string*/
func cleanStringForSort(string: String) -> String {
    let template = "$1"
    let pattern = "[\\s]" // remove any whitespace
    let regex = (try? NSRegularExpression(pattern: pattern,
        options: NSRegularExpressionOptions.CaseInsensitive)) as NSRegularExpression!
    
    return regex.stringByReplacingMatchesInString(string,
        options: NSMatchingOptions.WithTransparentBounds,
        range: NSMakeRange(0, string.characters.count),
        withTemplate: template)
}


/** Return true if the first character is a letter */
func beginWithLetter(string : String) -> Bool {
    
    var processedString = string
    
    if(string.characters.count > 0){
        let idx : String.Index = processedString.startIndex.advancedBy(1)
        processedString = processedString.substringToIndex(idx)
        let template = "$1"
        let pattern = "[a-zA-Z]" //remove any alphabetic
        let regex = (try? NSRegularExpression(pattern: pattern,
            options: NSRegularExpressionOptions.CaseInsensitive)) as NSRegularExpression!
        
        processedString = regex.stringByReplacingMatchesInString(processedString,
            options: NSMatchingOptions.WithTransparentBounds,
            range: NSMakeRange(0, processedString.characters.count),
            withTemplate: template)
        
        return processedString == ""
        
    }
    return false
}


func shuffleAndSeparateSimilarElement<T : Equatable>(array: [T]) -> [T] {
    var newArray = array
    
    if(newArray.isEmpty == false){
        var numRepeat = 1+arc4random() % 5
        
        while(numRepeat > 0) {
            for(var i = 0; i < newArray.count - 2; i++) {
                let a = newArray[i]
                let b = newArray[i+1]
                let c = newArray[i+2]
                
                if( (a == b) && (b == c)){
                    let r = Int(arc4random_uniform(UInt32(newArray.count)))
                    let temp = newArray[r]
                    newArray[r] = b
                    newArray[i+1] = temp
                }
                else if(a == b){
                    newArray[i+1] = c
                    newArray[i+2] = b
                }
                else if(b == c) {
                    newArray[i] = b
                    newArray[i+1] = a
                }
            }
            numRepeat--
        }
    }
    
    return newArray
    
}


class RPTools {
    
    /**Return the number of album for the given artist*/
    class func numberAlbumOfArtistFormattedString(artist : MPMediaItemCollection) -> String {
        if(artist.albumCount > 1){
            return "\(artist.albumCount) albums"
        }
        else {
            return "1 album"
        }
    }
    
    /**Return the number of song of the given artist or album*/
    class func numberSongInCollection(artist : MPMediaItemCollection) -> String {
        if(artist.items.count > 1){
            return "\(artist.items.count) songs"
        }
        else {
            return "1 song"
        }
    }
    
    /**Return the number MPMediaItem*/
    class func numberSong(items : Array<MPMediaItem>) -> String {
        
        //        let now = NSDate().timeIntervalSince1970
        //        let a = items.count
        //        a > 1
        //        let now1 = NSDate().timeIntervalSince1970
        //        items.count > 1 //BETTER
        //        items.count
        //        let now2 = NSDate().timeIntervalSince1970
        //
        //        dprint("sol 1: \(now1-now)")
        //        dprint("sol 2: \(now2 - now1)")
        if(items.count > 1){
            return "\(items.count) songs"
        }
        else {
            return "1 song"
        }
    }
    
    
}



extension Array {
    func shuffleArray() -> [Element] {
        var arr = self
        var newArray = [Element]()
        
        var randNum = 0
        while(arr.count > 0) {
            randNum = Int(arc4random_uniform(UInt32(arr.count)))
            newArray.append(arr.removeAtIndex(randNum))
        }
        return newArray
    }
    
}

extension MPMediaItemCollection {
    
    var albumCount : Int {
        get {
            var query = MPMediaQuery.albumsQuery()
            let filterPredicate = MPMediaPropertyPredicate(
                value: representativeItem!.valueForProperty(MPMediaItemPropertyArtistPersistentID),
                forProperty: MPMediaItemPropertyArtistPersistentID)
            query.filterPredicates = Set(arrayLiteral: filterPredicate)
            
            return query.collections!.count
        }
    }
    
    
}


