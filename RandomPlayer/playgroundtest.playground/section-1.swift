// Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

var test: String?


var a = 50

let b = 50/20

let c = 50%20


func formatTimeToMinutesSeconds(secondsToConvert : Int) -> String {
    
    let minutes : Int = secondsToConvert / 60
    let seconds : Int = secondsToConvert%60
    
    var nf = NSNumberFormatter()
    nf.minimumIntegerDigits = 2
    
    return String(minutes) + ":" + nf.stringFromNumber(seconds)
    
}

   formatTimeToMinutesSeconds(14328)




func beginWithLetter(string : String) -> Bool {
    
    var processedString = string
    
    if(countElements(string) > 0){
        processedString = processedString.substringToIndex(1)
        let template = "$1"
        let pattern = "[a-zA-Z]" //remove any alphabetic
        let regex = NSRegularExpression.regularExpressionWithPattern(pattern, options: NSRegularExpressionOptions.CaseInsensitive, error: nil)
        
        processedString = regex.stringByReplacingMatchesInString(processedString, options: NSMatchingOptions.WithTransparentBounds, range: NSMakeRange(0, countElements(processedString)), withTemplate: template)
        
        return processedString == ""
        
    }
    return false
}


beginWithLetter("zfdsa")


let l1 = "salut"
let l2 = "salut"

l1 == l2