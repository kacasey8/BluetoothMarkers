//
//  BluetoothViewController.m
//  Whereami
//
//  Created by Kevin Casey on 3/30/13.
//  Copyright (c) 2013 Caseyrules. All rights reserved.
//

#import "BluetoothViewController.h"
#import "WhereamiViewController.h"

@implementation BluetoothViewController
@synthesize foundPeripherals;
@synthesize activityIndicator;
@synthesize bluetoothManager;

- (id)init
{
    self = [super init];
    
    if (self) {
        bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        foundPeripherals = [[NSMutableArray alloc] init];
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:self
                                                                             action:@selector(addPinToMap)];
        [[self navigationItem] setRightBarButtonItems:[NSArray arrayWithObjects:bbi, nil]];
    }
    return self;
}

- (void)addPinToMap
{
    WhereamiViewController *wvc = [[WhereamiViewController alloc] init];
    [wvc setNextPointShouldBeGreen:YES];
    [[self navigationController] pushViewController:wvc animated:YES];
    [[wvc locationTitleField] setText:@"Bluetooth"];
    [wvc findLocation];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (error) {
        // An unexpected disconnected...This probably means device went out of range or turned off, should add a pin
        [self addPinToMap];
    }
    [bluetoothTable reloadData];
}

- (void)showAlert:(NSString *)title
{
    UIAlertView *alert;
    NSString *message = [NSString stringWithFormat:@"Would you like to add a pin?"];
    alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles: @"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        [self addPinToMap];
    }
}

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    cBReady = false;
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CoreBluetooth BLE hardware is powered off");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
            cBReady = true;
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CoreBluetooth BLE hardware is resetting");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CoreBluetooth BLE state is unauthorized");
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"CoreBluetooth BLE state is unknown");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
            break;
        default:
            break;
    }
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (![foundPeripherals containsObject:peripheral])
    {
        [foundPeripherals addObject:peripheral];
    }
        
    [bluetoothTable reloadData];
}

- (void) discoveryStatePoweredOff
{
    NSString *title     = @"Bluetooth Power";
    NSString *message   = @"You must turn on Bluetooth in Settings in order to use LE";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}


- (IBAction)startScan:(id)sender
{
    if (cBReady) {
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
                
        [bluetoothManager scanForPeripheralsWithServices:nil
                                                 options:options];
        [[self activityIndicator] startAnimating];
        NSLog(@"Scan started");
    } else {
        [self discoveryStatePoweredOff];
    }
}

- (IBAction)stopScan:(id)sender
{
    NSLog(@"Scan stopped");
    [bluetoothManager stopScan];
    [[self activityIndicator] stopAnimating];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [foundPeripherals count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Reusable cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Reusable cell"];
    }
    
    CBPeripheral *peripheral = [foundPeripherals objectAtIndex:[indexPath row]];
    
    if ([[peripheral name] length])
        [[cell textLabel] setText:[peripheral name]];
    else
        [[cell textLabel] setText:@"Peripheral"];
    
    [[cell detailTextLabel] setText:[peripheral isConnected] ? @"Connected" : @"Not connected"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral *peripheral = [foundPeripherals objectAtIndex:[indexPath row]];
    if ([peripheral isConnected]) {
        [bluetoothManager cancelPeripheralConnection:peripheral];
        NSLog(@"Selection disconnect");
    } else {
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],CBConnectPeripheralOptionNotifyOnDisconnectionKey, nil];
        [bluetoothManager connectPeripheral:peripheral options:options];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connection successfull to peripheral: %@ with UUID: %@",peripheral,peripheral.UUID);
    [bluetoothTable reloadData];
    
}
- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    NSLog(@"Connection failed to peripheral: %@ with UUID: %@",peripheral,peripheral.UUID);
}

@end
