//
//  HomepageViewController.h
//  Whereami
//
//  Created by Kevin Casey on 3/7/13.
//  Copyright (c) 2013 Caseyrules. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomepageViewController : UIViewController
{
    __weak IBOutlet UILabel *currentPins;
}

- (IBAction)showMap:(id)sender;

- (IBAction)clearData:(id)sender;
- (IBAction)findLastPoint:(id)sender;
- (IBAction)showBluetooth:(id)sender;

- (void)newPinCount;

@end
