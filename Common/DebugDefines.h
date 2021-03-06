//
//  DebugDefines.h
//  RandomPlayer
//
//  Created by Jonathan Duss on 10.02.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#ifndef RandomPlayer_DebugDefines_h
#define RandomPlayer_DebugDefines_h


#define DEBUG 1

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


#ifdef EXTREME_LOG
#   define ELog(...) NSLog(__VA_ARGS__);
#else
#   define ELog(...)
#endif

//warning log
#define W_LOG

#ifdef W_LOG
#   define WLog(...) NSLog(__VA_ARGS__);
#else
#   define WLog(...)
#endif

//Action log
#ifdef LOG
#   define ALog(...) NSLog(__VA_ARGS__);
#else
#   define ALog(...)
#endif

#endif
