//
//  AnnotationViewController.m
//  Whereami
//
//  Created by Kevin Casey on 4/15/13.
//  Copyright (c) 2013 Caseyrules. All rights reserved.
//

#import "AnnotationViewController.h"
#import "BNRItemStore.h"
#import "BNRMapPoint.h"

@interface AnnotationViewController ()

@end

@implementation AnnotationViewController
@synthesize controller;

- (id)init
{
    self = [super init];
    if (self) {
        [[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[BNRItemStore sharedStore] allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BNRMapPoint *mp = [[[BNRItemStore sharedStore] allItems] objectAtIndex:[indexPath row]];
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocationCoordinate2D coord = mp.coordinate;
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray* placemarks, NSError* error){
        if ([placemarks count] > 0)
        {
            CLPlacemark *aPlacemark = [placemarks objectAtIndex:0];
            [[cell detailTextLabel] setText:aPlacemark.name];
        }
        if (error != NULL) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
    NSString *newTitle = [NSString stringWithFormat:@"%@ %@", [mp title], [mp timeDateString]];
    [[cell textLabel] setText:newTitle];
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BNRMapPoint *mp = [[[BNRItemStore sharedStore] allItems] objectAtIndex:[indexPath row]];
    [controller popAnnotationAndZoom:mp];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BNRItemStore *ps = [BNRItemStore sharedStore];
        NSArray *items = [ps allItems];
        BNRMapPoint *mp = [items objectAtIndex:[indexPath row]];
        [ps removeItem:mp];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [controller removeAnAnnotation:mp];
    }
}

- (void) tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
       toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[BNRItemStore sharedStore] moveItemAtIndex:[sourceIndexPath row]
                                        toIndex:[destinationIndexPath row]];
}

@end
