//
//  SwiftDebugGlobalFunctions.swift
//  RandomPlayer
//
//  Created by Jonathan Duss on 18.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

import Foundation


//Just for debug stuff
#if DEBUG
    func dprint(a : String){print(a)}
#else
    func dprint(a : String){}
#endif


//LOG A LOT
#if EXTREME_LOG
    func elprint(a : String){ print(a)}
#else
    func elprint(a : String){}
#endif


//LOG WHAT IS USEFULL
#if EXTREME_LOG
    func lprint(a : String){ print(a)}
#else
    func lprint(a : String){}
#endif

