//
//  BluetoothViewController.h
//  Whereami
//
//  Created by Kevin Casey on 3/30/13.
//  Copyright (c) 2013 Caseyrules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>

@interface BluetoothViewController : UIViewController <CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource, CBPeripheralDelegate, UIAlertViewDelegate>
{
    //CBCentralManager *bluetoothManager;
    NSMutableArray *foundPeripherals;
    bool cBReady;
    __weak IBOutlet UITableView *bluetoothTable;
    IBOutlet UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, strong) NSMutableArray *foundPeripherals;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) CBCentralManager *bluetoothManager;

- (void) discoveryStatePowerOff;
- (IBAction)startScan:(id)sender;
- (IBAction)stopScan:(id)sender;

- (void)addPinToMap;
- (void)showAlert:(NSString *)title;
@end
