//
//  BNRMapPoint.m
//  Whereami
//
//  Created by Kevin Casey on 3/3/13.
//  Copyright (c) 2013 Caseyrules. All rights reserved.
//

#import "BNRMapPoint.h"

@implementation BNRMapPoint

@synthesize coordinate, title, date;
@synthesize shouldBeBlue;

- (id)init
{
    return [self initWithCoordinate:CLLocationCoordinate2DMake(43.07, -89.32) title:@"Hometown"];
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t
{
    self = [super init];
    if (self) {
        coordinate = c;
        [self setTitle:t];
        [self setShouldBeBlue:NO];
    }
    return self;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t date:(NSDate *)d
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *dateString = [dateFormatter stringFromDate:d];
    NSArray *temp = [[NSArray alloc] initWithObjects:t, dateString, nil];
    NSString *newTitle = [temp componentsJoinedByString:@" "];
    [self setDate:d];
    return [self initWithCoordinate:c title:newTitle];
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeDouble:coordinate.latitude forKey:@"latitude"];
    [aCoder encodeDouble:coordinate.longitude forKey:@"longitude"];
    [aCoder encodeObject:title forKey:@"title"];
    [aCoder encodeObject:date forKey:@"date"];
    [aCoder encodeBool:shouldBeBlue forKey:@"shouldBeBlue"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        CLLocationCoordinate2D tempCoord = CLLocationCoordinate2DMake([aDecoder decodeDoubleForKey:@"latitude"], [aDecoder decodeDoubleForKey:@"longitude"]);
        [self setCoordinate:tempCoord];
        [self setTitle:[aDecoder decodeObjectForKey:@"title"]];
        [self setDate:[aDecoder decodeObjectForKey:@"date"]];
        [self setShouldBeBlue:[aDecoder decodeBoolForKey:@"shouldBeBlue"]];

    }
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    coordinate = newCoordinate;
}

- (NSString *)timeDateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

- (bool)isBlue {
    return [self shouldBeBlue];
}

@end
