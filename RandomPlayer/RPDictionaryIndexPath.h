//
//  RPDictionaryIndexPath.h
//  RandomPlayer
//
//  Created by Jonathan Duss on 10.02.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPDictionaryIndexPath : NSObject

-(void) addObject: (id)object withKey:(NSString *)key inSection: (NSString *)section;

/*!Add object*/
-(void) addObject: (id)object inSection: (NSString *)section;

-(id)objectAt:(NSIndexPath *)path forKey:(NSString *)key;

/*!Return object. (When not using key)*/
-(id)objectAt:(NSIndexPath *)path;

-(BOOL)containsKey:(NSString *)key;

-(NSUInteger)sectionCount;

-(NSUInteger)rowCountInSection:(NSUInteger)section;

-(NSString *)sectionTitleforSection:(NSUInteger)section;


@end
