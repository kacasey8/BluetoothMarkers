//
//  WhereamiViewController.m
//  Whereami
//
//  Created by Kevin Casey on 3/3/13.
//  Copyright (c) 2013 Caseyrules. All rights reserved.
//

#import "WhereamiViewController.h"
#import "BNRItemStore.h"
#import "AnnotationViewController.h"

NSString * const WhereamiMapTypePrefKey = @"WhereamiMapTypePrefKey";
NSString * const WhereamiLastLatitudePrefKey = @"WhereamiLastLatitudePrefKey";
NSString * const WhereamiLastLongitudePrefKey = @"WhereamiLastLongitudePrefKey";

@implementation WhereamiViewController
@synthesize nextPointShouldBeGreen, shouldZoomOnUpdate;
@synthesize locationTitleField;

+ (void)initialize
{
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], WhereamiMapTypePrefKey, [NSNumber numberWithDouble:37.874699], WhereamiLastLatitudePrefKey, [NSNumber numberWithDouble:-122.258899], WhereamiLastLongitudePrefKey, nil];
    
    NSMutableDictionary *mutDefaults = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithDouble:0] forKey:WhereamiLastLongitudePrefKey];
    NSMutableDictionary *mutDefaults1 = [NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:51] forKey:WhereamiLastLatitudePrefKey];
    [mutDefaults addEntriesFromDictionary:mutDefaults1];
    
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (IBAction)changeMapType:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:[sender selectedSegmentIndex]
                                               forKey:WhereamiMapTypePrefKey];
    
    switch ([sender selectedSegmentIndex]) {
        case 0:
        {
            [worldView setMapType:MKMapTypeStandard];
        } break;
        case 1:
        {
            [worldView setMapType:MKMapTypeSatellite];
        } break;
        case 2:
        {
            [worldView setMapType:MKMapTypeHybrid];
        } break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self findLocation];
    [textField resignFirstResponder];
    return YES;
}

- (void)findLocation
{
    [locationManager startUpdatingLocation];
    [activityIndicator startAnimating];
    [locationTitleField setHidden:YES];
}

- (void)foundLocation:(CLLocation *)loc
{
    CLLocationCoordinate2D coord = [loc coordinate];
    
    // Create an instance of BNRMapPoint with the current data
    BNRMapPoint *mp = [[BNRItemStore sharedStore] createItemWithCoordinate:coord title:[locationTitleField text] date:[loc timestamp]];
    
    if ([self nextPointShouldBeGreen]) {
        mp.shouldBeBlue = YES;
        [self setNextPointShouldBeGreen:NO];
    }
    
    
    // Add it to the map view
    [worldView addAnnotation:mp];
    
    // Zoom the region to this location
    [self zoomOnLocation:coord];
    
    // Reset the UI
    [locationTitleField setText:@""];
    [activityIndicator stopAnimating];
    [locationTitleField setHidden:NO];
}

- (void)zoomOnLocation:(CLLocationCoordinate2D)coord
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 250, 250);
    [worldView setRegion:region animated:YES];
    if ([locationTitleField isFirstResponder]) {
        [locationTitleField resignFirstResponder];
    }
}

- (void) popAnnotationAndZoom:(BNRMapPoint *)mp
{
    [[self navigationController] popViewControllerAnimated:YES];
    [self zoomOnLocation:mp.coordinate];
    [self setShouldZoomOnUpdate:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [worldView setShowsUserLocation:YES];
    
    NSInteger mapTypeValue = [[NSUserDefaults standardUserDefaults] integerForKey:WhereamiMapTypePrefKey];
    
    // Update the UI
    [mapTypeControl setSelectedSegmentIndex:mapTypeValue];
    
    // Update the map
    [self changeMapType:mapTypeControl];
        
    NSArray *savedPoints = [[BNRItemStore sharedStore] allItems];
    if (savedPoints) {
        for (int i = 0; i < [savedPoints count]; i++) {
            [worldView addAnnotation:[savedPoints objectAtIndex:i]];
        }
    }
    
}

- (void)mapView:(MKMapView *)mapView
didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D loc = [userLocation coordinate];
    [[NSUserDefaults standardUserDefaults] setDouble:loc.latitude forKey:WhereamiLastLatitudePrefKey];
    [[NSUserDefaults standardUserDefaults] setDouble:loc.longitude forKey:WhereamiLastLongitudePrefKey];
    
    if (shouldZoomOnUpdate) {
        [self zoomOnUser:nil];
        [self setShouldZoomOnUpdate:NO];
    }
}

- (void)zoomOnUser:(id)sender
{
    CLLocationCoordinate2D loc;
    loc.latitude = (CLLocationDegrees) [[NSUserDefaults standardUserDefaults] doubleForKey:WhereamiLastLatitudePrefKey];
    loc.longitude = (CLLocationDegrees) [[NSUserDefaults standardUserDefaults] doubleForKey:WhereamiLastLongitudePrefKey];
    NSLog(@"%f", loc.latitude);
    NSLog(@"%f", loc.longitude);
    [self zoomOnLocation:loc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Create location manager object
        locationManager = [[CLLocationManager alloc] init];
                
        [locationManager setDelegate:self];
                
        // And we want it to be as accurate as possible regardless of how much time/power it takes
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                             target:self
                                                                             action:@selector(showTable:)];
        
        UIBarButtonItem *bbi2 = [[UIBarButtonItem alloc] initWithTitle:@"Zoom" style:UIBarButtonItemStyleBordered target:self action:@selector(zoomOnUser:)];
        
        [[self navigationItem] setRightBarButtonItems:[NSArray arrayWithObjects:bbi, bbi2, nil]];
        
        timer = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(zoomOnUser:) userInfo:nil repeats:NO]; // attempt to forcibly zoom on user the first time this view is created.
        // The timer waits 3 seconds to see if it can get an updated position first.
        
        [self setNextPointShouldBeGreen:NO];
        [self setShouldZoomOnUpdate:YES];
                
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[BNRItemStore sharedStore] saveChanges];
    
}

- (void)showTable:(id)sender
{
    AnnotationViewController *avc = [[AnnotationViewController alloc] init];
    [avc setController:self];
    [[self navigationController] pushViewController:avc animated:YES];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    // How many seconds ago was this new location created?
    NSTimeInterval t = [[newLocation timestamp] timeIntervalSinceNow];
    
    // CLLocationManagers will return the last found location of the device first, you don't want that data in this case. If this location was made more than 1 minutes ago, ignore it.
    if (t < -10) {
        // This is cached data, you don't want it, keep looking
        return;
    }
    
    [self foundLocation:newLocation];
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Could not find location :%@", error);
}

-(void)dealloc
{
    // Tell the location manager to stop sending us messages
    [locationManager setDelegate:nil];
}

- (void)removeAnAnnotation:(BNRMapPoint *)mp
{
    [worldView removeAnnotation:mp];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (![annotation isKindOfClass:[BNRMapPoint class]])
        return nil;
    
    static NSString *reuseId = @"pin";
    MKPinAnnotationView *pav = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (pav == nil)
    {
        pav = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        pav.draggable = YES;
        pav.canShowCallout = YES;
        pav.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    else
    {
        pav.annotation = annotation;
    }
    
    BNRMapPoint *mvAnn = (BNRMapPoint *)annotation;
    if (mvAnn.isBlue)
    {
        pav.pinColor = MKPinAnnotationColorGreen;
    }
    else
    {
        pav.pinColor = MKPinAnnotationColorRed;
    }
    
    
    
    return pav;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    [self openMapsWithDirectionsTo:view.annotation.coordinate];
    
    
}

- (void)openMapsWithDirectionsTo:(CLLocationCoordinate2D)to {
    Class itemClass = [MKMapItem class];
    if (itemClass && [itemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:to addressDictionary:nil]];
        toLocation.name = @"Destination";
        [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil]
                       launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil]
                                                                 forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
    } else {
        NSMutableString *mapURL = [NSMutableString stringWithString:@"http://maps.google.com/maps?"];
        [mapURL appendFormat:@"saddr=Current Location"];
        [mapURL appendFormat:@"&daddr=%f,%f", to.latitude, to.longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[mapURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
}

@end
