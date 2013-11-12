//
//  WhereamiViewController.h
//  Whereami
//
//  Created by Kevin Casey on 3/3/13.
//  Copyright (c) 2013 Caseyrules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "BNRMapPoint.h"

@interface WhereamiViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate>
{
    CLLocationManager *locationManager;
    
    IBOutlet MKMapView *worldView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UITextField *locationTitleField;
    __weak IBOutlet UISegmentedControl *mapTypeControl;
    NSTimer *timer;
    bool nextPointShouldBeGreen;
    bool shouldZoomOnUpdate;
}

@property (nonatomic, strong) UITextField *locationTitleField;
@property (nonatomic) bool nextPointShouldBeGreen;
@property (nonatomic) bool shouldZoomOnUpdate;

- (void)popAnnotationAndZoom:(BNRMapPoint *)mp;

- (IBAction)changeMapType:(id)sender;

- (void)findLocation;
- (void)foundLocation:(CLLocation *)loc;
- (void)showTable:(id)sender;
- (void)zoomOnLocation:(CLLocationCoordinate2D)loc;
- (void)zoomOnUser:(id)sender;
- (void)removeAnAnnotation:(BNRMapPoint *)mp;

@end
