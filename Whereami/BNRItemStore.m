//
//  BNRItemStore.m
//  Whereami
//
//  Created by Kevin Casey on 3/5/13.
//  Copyright (c) 2013 Caseyrules. All rights reserved.
//

#import "BNRItemStore.h"
#import "BNRMapPoint.h"

@implementation BNRItemStore

+ (BNRItemStore *)sharedStore
{
    static BNRItemStore *sharedStore = nil;
    if (!sharedStore)
        sharedStore = [[super allocWithZone:nil] init];
    
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

- (BOOL)saveChanges
{
    NSString *path = [self itemArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:allItems toFile:path];
}

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"items.archive"];
}


- (id) init
{
    self = [super init];
    if (self) {
        
        NSString *path = [self itemArchivePath];
        allItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if (!allItems)
            allItems = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSMutableArray *)allItems
{
    return allItems;
}

- (BNRMapPoint *)createItemWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t date:(NSDate *)d
{
    BNRMapPoint *p = [[BNRMapPoint alloc] initWithCoordinate:c title:t date:d];
    [allItems addObject:p];
    [self saveChanges];
    return p;
}

- (void)reset
{
    allItems = [[NSMutableArray alloc] init];
    [self saveChanges];
}

- (void)clearAllButOne
{
    if ([allItems count] == 0) {
        return;
    }
    if (allItems) {
        allItems = [NSMutableArray arrayWithObject:[allItems objectAtIndex:[allItems count] - 1]];
        [self saveChanges];
    }
}

- (void)removeItem:(BNRMapPoint *)mp
{
    [allItems removeObjectIdenticalTo:mp];
    [self saveChanges];
}

- (void)moveItemAtIndex:(int)from toIndex:(int)to
{
    if (from == to) {
        return;
    }
    
    BNRMapPoint *mp = [allItems objectAtIndex:from];
    
    [allItems removeObjectAtIndex:from];
    
    [allItems insertObject:mp atIndex:to];
    
    [self saveChanges];
}

- (void) dealloc
{
    [self saveChanges];
}

@end
