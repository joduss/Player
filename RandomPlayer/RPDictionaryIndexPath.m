//
//  RPDictionaryIndexPath.m
//  RandomPlayer
//
//  Created by Jonathan Duss on 10.02.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "RPDictionaryIndexPath.h"

//typedef enum RPDIC_KEY {
//    RPDIC_TITLE,
//    RPDIC_MEDIAITEM,
//    RPDIC_SUBTITLE,
//};


@interface RPDictionaryIndexPath ()

@property (nonatomic, strong) NSMutableDictionary *dic;

@property (nonatomic, strong) NSArray *keys;

@end



@implementation RPDictionaryIndexPath

//CONSTANT
NSString *const DEFAUT_KEY = @"DEFAULT_KEY";

-(id)init
{
    self = [super init];
    _dic = [NSMutableDictionary dictionary];
    return self;
}

-(void) addObject: (id)object withKey:(NSString *)key inSection: (NSString *)section
{
    if([[_dic allKeys] containsObject:section] == false)
    {
        [_dic setObject:[[NSMutableDictionary alloc] init] forKey:section];
    }
    
    if([[[_dic objectForKey:section] allKeys] containsObject:key] == false)
    {
        [[_dic objectForKey:section] setObject:[NSMutableArray array] forKey:key];
    }
   
    NSMutableArray *array = [[_dic objectForKey:section] objectForKey:key];
    
    id objectToStore = object;
    if(object == nil)
        objectToStore = [NSNull null];
    [array addObject:objectToStore];

    _keys = nil;
}


-(void) addObject: (id)object inSection: (NSString *)section
{
    [self addObject:object withKey:DEFAUT_KEY inSection:section];
}


-(id)objectAt:(NSIndexPath *)path forKey:(NSString *)key
{
    
    if(path.section > [self.keys count])
    {
                [NSException raise:@"Array out of bound" format:@"Array out of bound with section index: %ld / %lu", (long)path.section, (unsigned long)[_keys count]];
    }
    else
    {
        NSString *section = [self.keys objectAtIndex:path.section];
        
        NSMutableDictionary *container = [_dic objectForKey:section];
        
        if([[container allKeys] containsObject:key] == false)
        {
            [NSException raise:@"No such key" format:@"There is no key %@ to get this object at indexpath %@", key, path];
        }
        else
        {
            NSMutableArray *array = [container objectForKey:key];
            
            if([array count] < path.row)
                [NSException raise:@"out of bound" format:@"Trying to access out of bound index: %ld / %lu", (long)path.row, (unsigned long)[array count]];
            else
                return [array objectAtIndex:path.row];
        }
    }
    
    [NSException raise:@"Should not see this error" format:@"You should not see this error. If you see it, then there is an error in the code of RPDictionaryIndexPath"];
    return nil;
}


-(id)objectAt:(NSIndexPath *)path
{
    return [self objectAt:path forKey:DEFAUT_KEY];
}



-(NSArray *)keys
{
    if(_keys == nil)
    {
        NSMutableArray *ma = [NSMutableArray arrayWithArray:[_dic allKeys]];
        _keys = [[ma sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:) ] copy];
    }
    return _keys;
}


-(BOOL)containsKey:(NSString *)key
{
    if([self.keys count] > 0)
    {
        NSString *section = [self.keys objectAtIndex:0];
        NSMutableDictionary *container = [_dic objectForKey:section];
        
        return [[container allKeys] containsObject:key];
    }
    else
        return NO;
}

-(NSUInteger)sectionCount
{
    return [self.dic count];
}

-(NSUInteger)rowCountInSection:(NSUInteger)section
{
    if(self.keys.count == 0)
        return 0;
    
    NSMutableDictionary *container = [_dic objectForKey:[_keys objectAtIndex:section]];
    
    if(container.count == 0)
        return 0;
    
    NSMutableArray *array = [container objectForKey:[[container allKeys] objectAtIndex:0]];
    return [array count];
    
    
}

-(NSString *)sectionTitleforSection:(NSUInteger)section
{
    return [self.keys objectAtIndex:section];
}
@end
