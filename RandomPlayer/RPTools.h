//
//  RPTools.h
//  RandomPlayer
//
//  Created by Jonathan Duss on 29.05.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPTools : NSObject

+(NSString *)minutesSecondsConversion:(double) length;

+(NSString *)clearStringForSort:(NSString*)string;

+(bool)beginWithLetter:(NSString *)string;
@end
