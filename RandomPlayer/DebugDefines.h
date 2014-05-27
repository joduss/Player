//
//  DebugDefines.h
//  RandomPlayer
//
//  Created by Jonathan Duss on 10.02.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#ifndef RandomPlayer_DebugDefines_h
#define RandomPlayer_DebugDefines_h

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
//#   define DLog(...) NSLog(__VA_ARGS__);
#else
#   define DLog(...)
#endif


#ifdef DEBUG
#   define LLog(...) NSLog(__VA_ARGS__);
#else
#   define LLog(...)
#endif


#endif
