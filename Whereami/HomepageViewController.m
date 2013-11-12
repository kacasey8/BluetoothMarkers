//
//  HomepageViewController.m
//  Whereami
//
//  Created by Kevin Casey on 3/7/13.
//  Copyright (c) 2013 Caseyrules. All rights reserved.
//

#import "HomepageViewController.h"
#import "WhereamiViewController.h"
#import "BNRItemStore.h"
#import "BluetoothViewController.h"

@interface HomepageViewController ()

@end

@implementation HomepageViewController
 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *n = [self navigationItem];
        
        [n setTitle:@"Bluetooth Markers!"];
        
        // Create a new bbar button item that will send addNewItem: to ItemsViewController
        //UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             //target:self
                                                                            // action:@selector(showMap:)];
        
        //[[self navigationItem] setRightBarButtonItem:bbi];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self newPinCount];
}

- (void)newPinCount
{
    NSLog(@"Update Pins");
    int pinCount = [[[BNRItemStore sharedStore] allItems] count];
    if (pinCount == 1) {
        [currentPins setText:[NSString stringWithFormat:@"Currently there is one pin"]];
        return;
    }
    [currentPins setText:[NSString stringWithFormat:@"Currently there are %d pins", [[[BNRItemStore sharedStore] allItems] count]]];
}

- (IBAction)showMap:(id)sender
{
    WhereamiViewController *wvc = [[WhereamiViewController alloc] init];
    
    [[self navigationController] pushViewController:wvc animated:YES];
}

- (IBAction)clearData:(id)sender
{
    [[BNRItemStore sharedStore] reset];
    [self newPinCount];
}

- (IBAction)findLastPoint:(id)sender
{
    [[BNRItemStore sharedStore] clearAllButOne];
    [self newPinCount];
}

- (IBAction)showBluetooth:(id)sender
{
    BluetoothViewController *bvc = [[BluetoothViewController alloc] init];
    [[self navigationController] pushViewController: bvc animated:YES];
}
@end
