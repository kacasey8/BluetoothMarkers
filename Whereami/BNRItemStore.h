//
//  BNRItemStore.h
//  Whereami
//
//  Created by Kevin Casey on 3/5/13.
//  Copyright (c) 2013 Caseyrules. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class BNRMapPoint;

@interface BNRItemStore : NSObject
{
    NSMutableArray *allItems;
}
+ (BNRItemStore *) sharedStore;

- (NSString *)itemArchivePath;
- (BOOL)saveChanges;

- (NSMutableArray *)allItems;
- (BNRMapPoint *)createItemWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t date:(NSDate *)d;
- (void)reset;
- (void)clearAllButOne;
- (void)removeItem:(BNRMapPoint *)mp;
- (void)moveItemAtIndex:(int)from toIndex:(int)to;

@end
