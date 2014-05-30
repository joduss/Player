//
//  RPTools.m
//  RandomPlayer
//
//  Created by Jonathan Duss on 29.05.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "RPTools.h"

@implementation RPTools

+(NSString *)minutesSecondsConversion:(double)length
{
    int minutes = (int)length/60.0f;
    int seconds = (int) length%60;
    
    if(seconds < 10){
        return [NSString stringWithFormat:@"%d:0%d", minutes,seconds];
    }
    
    return [NSString stringWithFormat:@"%d:%d", minutes,seconds];
}

+(NSString *)clearStringForSort:(NSString*)string 
{
    //string = [string stringByReplacingOccurrencesOfString:@"The " withString:@""];
    
    NSString *template = @"$1";
    NSString *pattern = @"[\\s]"; //remove any whitespace
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                  options:NSRegularExpressionCaseInsensitive error:nil];
    
    string = [regex stringByReplacingMatchesInString:string options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [string length]) withTemplate:template];
    
    return string;
}

+(bool)beginWithLetter:(NSString *)string
{
    string = [string substringWithRange:NSMakeRange(0, 1)];
    
    NSString *template = @"$1";
    NSString *pattern = @"[a-zA-Z]"; //remove any alphabetic
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                  options:NSRegularExpressionCaseInsensitive error:nil];
    
    string = [regex stringByReplacingMatchesInString:string options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [string length]) withTemplate:template];
    
    return [string isEqualToString:@""];
}

@end
