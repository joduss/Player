// Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


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




class Test2 {
    var a : Int = 0 {
    didSet{
        self.a = 2 * a
    }
    }
}

var test2 = Test2()
test2.a = 5





struct st {
    var a = 10
    static var b = 20
}


var b = st()
b.a = 20
st.b = 50

var c = st()


var array = ["a"]
array[1...0]


enum enumTest : Int {
    case a
    case b
    case c
}

class C : NSObject{
    var c : enumTest = enumTest.c
}



var cla = C()

cla.c == enumTest.c

cla.c = enumTest.a

cla.c == enumTest.a



var artistFrequency = ["a" : 10, "b" : 15, "c" : 1, "d" : 11, "e" : 0, "f" : 30]
var artistFreqKey = Array(artistFrequency.keys)




//var queue : Array<String> = ["a", "a" , "a", "a", "b" , "b", "b", "c", "c", "d", "e", "f", "g", "a", "a", "a","a","a","a", "a" , "a", "a", "b" , "b", "b","a", "a" , "a", "a", "b" , "b", "b", "c", "c", "d"]

var queue : Array<String> = ["a", "a", "a", "b", "c", "d"]

func randomizeQueue() {
    //TODO
    /**warning - no implemented*/
    //queue = queue.sorted({(_,_) in return arc4random() % 2 == 0})
    
    var newQueue : Array<String> = Array()
    
    var queueSize = queue.count
    
    while(queueSize > 0) {
        
        var randNum = Int(rand()) % queueSize
    
        
        
        let item = queue[randNum]
        queue.removeAtIndex(randNum)
        
        newQueue += item
        queueSize = queue.count
    }
    
    queue = newQueue
    
}

queue = ["k", "a", "b","c", "b", "b", "b", "a", "a", "a", "a", "k", "c", "a", "a", "b", "c"]

func randoPlus() {
    
    for(var i = 0; i < queue.count - 2; i++) {
        let a = queue[i]
        let b = queue[i+1]
        let c = queue[i+2]
        
        if( a == b && b == c){
            queue[i+1] = setAndgetRandom(b)
        }
        else if(a == b){
            queue[i+1] = c
            queue[i+2] = b
        }
        else if(b == c) {
            queue[i] = b
            queue[i+1] = a
        }
    }
    
}

func setAndgetRandom(a : String) -> String {
    let r = Int(arc4random()) % queue.count
    let toReturn = queue[r]
    queue[r] = a
    return toReturn
}

//randomizeQueue()
////queue
//randomizeQueue()
//randoPlus()
//queue
//randoPlus()
//randoPlus()
//randoPlus()
//randoPlus()
//queue


var s1 = "test"
var s2 = "test"

s2.hashValue



class CC : NSObject
{
    var c : Int = 0
}

var cla1 = CC()
var cla2 = CC()
cla1.c = 20
cla2.c = 20

cla1.hashValue
cla2.hashValue


extension Array {
    func shuffleArray() -> [T] {
        var arr = self
        var newArray = [T]()
        
        var arrSize = arr.count
        
        while(arrSize > 0) {
            
            var randNum = Int(arc4random()) % arrSize
            
            let item: T = arr[randNum]
            arr.removeAtIndex(randNum)
            
            newArray += item
            arrSize = arr.count
        }
        
        return newArray
    }
    
}



func randomizeAndSeparateSimilarElement(arr : Array<String>) -> Array<String>{
    var newArray = arr
    
    var numRepeat = 1+arc4random() % 5
    
    while(numRepeat > 0) {
        for(var i = 0; i < arr.count - 2; i++) {
            let a = newArray[i]
            let b = newArray[i+1]
            let c = newArray[i+2]
            
            if( (a == b) && (b == c)){
                let r = Int(arc4random()) % newArray.count
                let temp = newArray[r]
                println("\(r)")
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
    
    return newArray
    
}

print("test")
var testQueue = ["a", "a", "a", "c", "a", "a", "c" ,"c", "b", "d"]
testQueue = testQueue.shuffleArray()
testQueue = randomizeAndSeparateSimilarElement(testQueue)

















