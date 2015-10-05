//
//  SwiftDebugGlobalFunctions.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 18.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

//import Foundation
import UIKit
import Foundation


//Global constant


//Just for debug stuff
#if DEBUG
    func dprint(a : String){print(a, terminator: ""); print("\n", terminator: "")}
    func debugAlertView(message : String) {
        UIAlertView(title: "DEBUG: ERROR", message: message, delegate: nil, cancelButtonTitle: "ok").show()
    }
    #else
    func dprint(msg : String){}
    func debugAlertView(message : String) {}
#endif


//LOG A LOT
#if EXTREME_LOG
    func elprint(msg : String){ print(msg, terminator: "\n")}
#else
    func elprint(msg : String){}
#endif


//LOG WHAT IS USEFULL
#if LOG
    func lprint(msg : String){ print(msg, terminator: "\n")}
#else
    func lprint(msg : String){}
#endif

func eprint(msg: String) {print("ERROR - \(msg)", terminator: "\n")}



