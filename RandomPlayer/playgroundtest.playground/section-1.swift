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




struct s {
    static var queue : Array<Int> = Array()
}

extension Test2 {
    func f(arr : Array<Int>){
        s.queue.join(arr)
    }
}

var arr : Array<Int> = Array()
arr.append(5)
arr.append(10)
arr
arr += [12, 15]
s.queue = arr

s.queue[0...2]


var list = [0, 1, 2,3 ,4 ,5 ,6 ,7 ,8 ,9]

list = list.sorted({(_,_) in return arc4random() % 2 == 0})

list

var shoppingList = ["Eggs", "Milk"]
shoppingList.append("Flour")
shoppingList += "Baking Powder"
shoppingList[0] = "Six eggs"
shoppingList
let index = (shoppingList.endIndex) - 1
shoppingList[0...index]





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








