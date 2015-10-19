//
//  ViewController.m
//  kiwi-metawear
//
//  Created by Dave Kim on 2015-10-16.
//  Copyright © 2015 kiwi. All rights reserved.
//

#import "ViewController.h"
#import <MetaWear/MetaWear.h>
#import "KiwiThirdpartySensorStream.h"
#import "KiwiMotionChannelMaster.h"
#import "KiwiUserModel.h"
#import "KiwiMotionModel.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *metaWearStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;
@property (weak, nonatomic) IBOutlet UILabel *kiwiStatusLabel;

// meta wear
@property (nonatomic, strong) NSArray *devices;
@property (nonatomic, strong) MBLMetaWear *connectedDevice;

// kiwi
@property (strong, nonatomic) NSMutableDictionary *sensorValues;
@property (strong, nonatomic) KiwiThirdpartySensorStream* kiwiSensorStream;
@property (strong, nonatomic) KiwiMotionChannelMaster* kiwiMotionChannelMaster;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.kiwiSensorStream = [KiwiThirdpartySensorStream sharedInstance];
    
    self.sensorValues = [[NSMutableDictionary alloc] init];
    self.sensorValues[@"device_id"] = @"Meta2";
    
    
    /* kiwi START*/
    _kiwiMotionChannelMaster = [KiwiMotionChannelMaster sharedInstance];
    [_kiwiMotionChannelMaster.tags addObject:@"metawear-demo"];
    
    // Set hyper accuracy true
    [_kiwiMotionChannelMaster setRobusta:YES];
    
    // Hook notification for motion recognitions.
    // I.e. Every time a motion is detected, a method in selector will be invoked.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveRecognizedMotion:)
                                                 name:@"KiwiMotionRecognition"
                                               object:nil];
    
    // Real-time analysis without any enhancements nor filtering
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMotionScore:)
                                                 name:@"KiwiMotionRecognitionNoFilter"
                                               object:nil];
    
    // Loading motion model from ewts demo profile
    [[KiwiUserModel sharedInstance]
     getUserWithEmail:@"ewts@kiwi.ai" AndPassword:@"12345678"
     success:^(KiwiUserModel *model){
         NSLog(@"KIWI: User fetched");
         [[KiwiMotionModel sharedInstance]
          getAllUserMotions:^(KiwiMotionModel *model){
              NSLog(@"KIWI: Motions fetched");
              for (NSMutableDictionary *motionModel in model.data){
                  [_kiwiMotionChannelMaster addTarget:motionModel];
              }
              _kiwiStatusLabel.text = @"Loaded";
//              success([[NSArray alloc] initWithArray:motionList]);
              
          } fail:^(KiwiMotionModel *model){
//              fail(@"error fetching motions");
              NSLog(@"error fetching motions");
          }];
     } fail:^(KiwiUserModel *model){
//         fail(@"error fetching user data");
         NSLog(@"error fetching user data");
     }];
    
    /* kiwi END */
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - kiwi
-(void)sendSensorBuffer {
    if ([self.sensorValues[@"ax"] floatValue] == 0
        || [self.sensorValues[@"gx"] floatValue] == 0) {return;}
    
    [self.kiwiSensorStream streamForDeviceId:self.sensorValues[@"device_id"]
                                          AX:self.sensorValues[@"ax"]
                                          AY:self.sensorValues[@"ay"]
                                          AZ:self.sensorValues[@"az"]
                                          GX:self.sensorValues[@"gx"]
                                          GY:self.sensorValues[@"gy"]
                                          GZ:self.sensorValues[@"gz"]];
    
    NSMutableDictionary *data = [self.sensorValues mutableCopy];
    NSNumber *timestamp = [NSNumber numberWithDouble:([[NSDate date] timeIntervalSince1970] * 1000)];
    [data setValue:timestamp forKey:@"ts"];
    
    [_kiwiMotionChannelMaster pushData:data];
    
//    NSLog(@"%@", self.sensorValues);
    self.sensorValues[@"ax"] = @0;
    self.sensorValues[@"ay"] = @0;
    self.sensorValues[@"az"] = @0;
    self.sensorValues[@"gx"] = @0;
    self.sensorValues[@"gy"] = @0;
    self.sensorValues[@"gz"] = @0;
}

- (void) didReceiveMotionScore:(NSNotification *) notification {
    NSArray *motionArray = notification.userInfo[@"results"];
    
    NSMutableArray *returnedMotionList = [[NSMutableArray alloc] init];
    
    for (NSDictionary *motionModel in motionArray){
        NSDictionary *motion = @{
                                 @"motion_id" : motionModel[@"motion_id"],
                                 @"motion_name" : motionModel[@"motion_name"],
                                 @"score" : @([motionModel[@"score"] floatValue] * 10),
                                 @"threshold" : @([motionModel[@"threshold"] floatValue] * 10)
                                 };
        [returnedMotionList addObject:motion];
    }
    NSLog(@"%@", returnedMotionList);
}

#pragma mark - Notifications
- (void) didReceiveRecognizedMotion:(NSNotification *) notification {
    NSDictionary* motionInfo = notification.userInfo;
    
    NSDictionary *motion = @{
                             @"motion_id" : motionInfo[@"motion_id"],
                             @"motion_name" : motionInfo[@"motion_name"],
                             @"score" : @([motionInfo[@"score"] floatValue] * 10),
                             @"threshold" : @([motionInfo[@"threshold"] floatValue] * 10)
                             };
    
}


# pragma mark - MetaWear
-(void) startScanning {
    // Only scan for nearby devices
    static const int MAX_ALLOWED_RSSI = -15; // The RSSI calculation sometimes produces erroneous values, we know anything above this value is invalid
    static const int MIN_ALLOWED_RSSI = -50; // Depending on your specific application this value will change!
    
    [[MBLMetaWearManager sharedManager] startScanForMetaWearsAllowDuplicates:YES handler:^(NSArray *array) {
        
        for (MBLMetaWear *device in array) {
            // Reject any value above a reasonable range
            if (device.discoveryTimeRSSI.integerValue > MAX_ALLOWED_RSSI) {
                continue;
            }
            // Reject if the signal strength is too low to be close enough (find through experiment)
            if (device.discoveryTimeRSSI.integerValue < MIN_ALLOWED_RSSI) {
                continue;
            }
            NSLog(@"%@", device.identifier.UUIDString);
            [self updateMetawearStatusLabel:@"Device detected - connecting"];
            [[MBLMetaWearManager sharedManager] stopScanForMetaWears];
            [self connectDevice:device];
        }
    }];
}

-(void) connectDevice:(MBLMetaWear*)device {
    [device connectWithHandler:^(NSError *error) {
        NSLog(@"Connected");
        [self updateMetawearStatusLabel:@"Connected"];
        _connectedDevice = device;
        
        device.accelerometer.sampleFrequency = 50; // Default: 100 Hz
        [device.accelerometer.dataReadyEvent startNotificationsWithHandler:^(MBLAccelerometerData *obj, NSError *error) {
//            NSLog(@"X = %f, Y = %f, Z = %f", obj.x, obj.y, obj.z);
            self.sensorValues[@"ax"] = [NSNumber numberWithFloat:obj.x];
            self.sensorValues[@"ay"] = [NSNumber numberWithFloat:obj.y];
            self.sensorValues[@"az"] = [NSNumber numberWithFloat:obj.z];
            [self sendSensorBuffer];
        }];
        device.gyro.sampleFrequency = 50; // Default: 100 Hz
        [device.gyro.dataReadyEvent startNotificationsWithHandler:^(MBLGyroData *obj, NSError *error) {
//            NSLog(@"X = %f, Y = %f, Z = %f", obj.x, obj.y, obj.z);
            self.sensorValues[@"gx"] = [NSNumber numberWithFloat:obj.x];
            self.sensorValues[@"gy"] = [NSNumber numberWithFloat:obj.y];
            self.sensorValues[@"gz"] = [NSNumber numberWithFloat:obj.z];
            [self sendSensorBuffer];
        }];
    }];
}

-(void) disconnectDevice:(MBLMetaWear*)device {
    [device disconnectWithHandler:^(NSError *error) {
        NSLog(@"Disconnected");
        [self updateMetawearStatusLabel:@"Disconnected"];
    }];
}

#pragma mark - UI

-(void)updateMetawearStatusLabel:(NSString*)status {
    _metaWearStatusLabel.text = status;
}

- (IBAction)scanAndConnectButtonTouched:(id)sender {
    [self updateMetawearStatusLabel:@"scanning..."];
    // Start scanning and automatically pair
    [self startScanning];
}


-(IBAction)disconnectButtonTouched:(UIButton *)sender {
    if (_connectedDevice){
        [self disconnectDevice:_connectedDevice];
    }
}

@end
