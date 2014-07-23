//
//  RPTools.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 12.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import Foundation


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
    
    return String(minutes) + ":" + nf.stringFromNumber(seconds)    
}


/**lean String for sorting by removing whitespaces
* @param string
        The string to clean
@return The cleaned string*/
func cleanStringForSort(string: String) -> String {
    let template = "$1"
    let pattern = "[\\s]" // remove any whitespace
    let regex = NSRegularExpression.regularExpressionWithPattern(pattern,
        options: NSRegularExpressionOptions.CaseInsensitive,
        error: nil)

    return regex.stringByReplacingMatchesInString(string,
        options: NSMatchingOptions.WithTransparentBounds,
        range: NSMakeRange(0, countElements(string)),
        withTemplate: template)
}


/** Return true if the first character is a letter */
func beginWithLetter(string : String) -> Bool {
    
    var processedString = string
    
    if(countElements(string) > 0){
        processedString = processedString.bridgeToObjectiveC().substringToIndex(1)
        let template = "$1"
        let pattern = "[a-zA-Z]" //remove any alphabetic
        let regex = NSRegularExpression.regularExpressionWithPattern(pattern,
            options: NSRegularExpressionOptions.CaseInsensitive,
            error: nil)
        
        processedString = regex.stringByReplacingMatchesInString(processedString,
            options: NSMatchingOptions.WithTransparentBounds,
            range: NSMakeRange(0, countElements(processedString)),
            withTemplate: template)
        
        return processedString == ""
        
    }
    return false
}