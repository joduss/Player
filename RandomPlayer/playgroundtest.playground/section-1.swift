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
        processedString = processedString.bridgeToObjectiveC().substringToIndex(1)
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



class Test {
    var b = 5
    var a : Int {
        get {
            return 4*b
        }
    set {
        b = newValue / 10
    }
    }
}

let testClass  = Test()

testClass.b = 10
testClass.a = 10
testClass.b
testClass.a


var blabla:Float = 1.0
++blabla

var haha = CGRectMake(10, 10, 20, 20)

haha.width






