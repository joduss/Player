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
    func dprint(a : String){}
    func debugAlertView(message : String) {}
#endif


//LOG A LOT
#if EXTREME_LOG
    func elprint(a : String){ print(a, terminator: ""); print("\n", terminator: "")}
#else
    func elprint(a : String){}
#endif


//LOG WHAT IS USEFULL
#if LOG
    func lprint(a : String){ print(a, terminator: ""); print("\n", terminator: "")}
#else
    func lprint(a : String){}
#endif

