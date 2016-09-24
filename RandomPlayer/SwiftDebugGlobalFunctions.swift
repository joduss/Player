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
    func dprint(_ a : String){print(a, terminator: ""); print("\n", terminator: "")}
    func debugAlertView(message : String) {
        UIAlertView(title: "DEBUG: ERROR", message: message, delegate: nil, cancelButtonTitle: "ok").show()
    }
    #else
    func dprint(_ msg : String){}
    func debugAlertView(_ message : String) {}
#endif


//LOG A LOT
#if EXTREME_LOG
    func elprint(_ msg : String){ print(msg, terminator: "\n")}
#else
    func elprint(_ msg : String){}
#endif


//LOG WHAT IS USEFULL
#if LOG
    func lprint(_ msg : String){ print(msg, terminator: "\n")}
#else
    func lprint(_ msg : String){}
#endif

func eprint(_ msg: String) {print("ERROR - \(msg)", terminator: "\n")}



