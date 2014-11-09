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
    
    var nf = NSNumberFormatter()
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
    let regex = NSRegularExpression(pattern: pattern,
        options: NSRegularExpressionOptions.CaseInsensitive,
        error: nil) as NSRegularExpression!
    
    return regex.stringByReplacingMatchesInString(string,
        options: NSMatchingOptions.WithTransparentBounds,
        range: NSMakeRange(0, countElements(string)),
        withTemplate: template)
}


/** Return true if the first character is a letter */
func beginWithLetter(string : String) -> Bool {
    
    var processedString = string
    
    if(countElements(string) > 0){
        let idx : String.Index = advance(processedString.startIndex, 1)
        processedString = processedString.substringToIndex(idx)
        let template = "$1"
        let pattern = "[a-zA-Z]" //remove any alphabetic
        let regex = NSRegularExpression(pattern: pattern,
            options: NSRegularExpressionOptions.CaseInsensitive,
            error: nil) as NSRegularExpression!
        
        processedString = regex.stringByReplacingMatchesInString(processedString,
            options: NSMatchingOptions.WithTransparentBounds,
            range: NSMakeRange(0, countElements(processedString)),
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
    
    
}



extension Array {
    func shuffleArray() -> [T] {
        var arr = self
        var newArray = [T]()
        
        var arrSize = arr.count
        
        while(arrSize > 0) {
            
            var randNum = Int(arc4random_uniform(UInt32(arrSize)))
            
            let item: T = arr[randNum]
            arr.removeAtIndex(randNum)
            
            newArray.append(item)
            arrSize = arr.count
        }
        
        return newArray
    }

}

extension MPMediaItemCollection {
    
    var albumCount : Int {
        get {
        var query = MPMediaQuery.albumsQuery()
        let filterPredicate = MPMediaPropertyPredicate(
            value: representativeItem.valueForProperty(MPMediaItemPropertyArtistPersistentID),
            forProperty: MPMediaItemPropertyArtistPersistentID)
        query.filterPredicates = NSSet(object: filterPredicate)
        
        return query.collections.count
        }
    }


}


