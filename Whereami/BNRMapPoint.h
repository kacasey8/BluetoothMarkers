//
//  BNRMapPoint.h
//  Whereami
//
//  Created by Kevin Casey on 3/3/13.
//  Copyright (c) 2013 Caseyrules. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface BNRMapPoint : NSObject <MKAnnotation, NSCoding>
{
    bool shouldBeBlue;
}
// A new designated initializer for instacnes of BNRMapPoint
- (id)initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t;
- (id)initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t date:(NSDate *)d;

// This is a required property from MKAnnotation
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

// This is an optional property from MKAnnotation
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) bool shouldBeBlue;

- (NSString *)timeDateString;
- (bool)isBlue;

@end
