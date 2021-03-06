/**
 * DeviceDetailViewController.m
 * MetaWearApiTest
 *
 * Created by Stephen Schiffli on 7/30/14.
 * Copyright 2014-2015 MbientLab Inc. All rights reserved.
 *
 * IMPORTANT: Your use of this Software is limited to those specific rights
 * granted under the terms of a software license agreement between the user who
 * downloaded the software, his/her employer (which must be your employer) and
 * MbientLab Inc, (the "License").  You may not use this Software unless you
 * agree to abide by the terms of the License which can be found at
 * www.mbientlab.com/terms.  The License limits your use, and you acknowledge,
 * that the Software may be modified, copied, and distributed when used in
 * conjunction with an MbientLab Inc, product.  Other than for the foregoing
 * purpose, you may not use, reproduce, copy, prepare derivative works of,
 * modify, distribute, perform, display or sell this Software and/or its
 * documentation for any purpose.
 *
 * YOU FURTHER ACKNOWLEDGE AND AGREE THAT THE SOFTWARE AND DOCUMENTATION ARE
 * PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY, TITLE,
 * NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL
 * MBIENTLAB OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER CONTRACT, NEGLIGENCE,
 * STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR OTHER LEGAL EQUITABLE
 * THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES INCLUDING BUT NOT LIMITED
 * TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR CONSEQUENTIAL DAMAGES, LOST
 * PROFITS OR LOST DATA, COST OF PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY,
 * SERVICES, OR ANY CLAIMS BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY
 * DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
 *
 * Should you have any questions regarding your right to use this Software,
 * contact MbientLab via email: hello@mbientlab.com
 */

#import "DeviceDetailViewController.h"
#import "MBProgressHUD.h"
#import "APLGraphView.h"
#import "KiwiThirdpartySensorStream.h"
// packet period to update the UI at to show streaming data
#define kUIPacketRefreshPeriod 1

@interface DeviceDetailViewController () <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *connectionSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *kiwiSwitch;
@property (weak, nonatomic) IBOutlet UILabel *connectionStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong) KiwiThirdpartySensorStream *stream;
@property (strong, nonatomic) NSArray *sensorData;
@property (strong, nonatomic) NSArray *accelData;
@property (strong, nonatomic) NSArray *gyroData;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *allCells;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *infoAndStateCells;
@property (weak, nonatomic) IBOutlet UILabel *mfgNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *hwRevLabel;
@property (weak, nonatomic) IBOutlet UILabel *fwRevLabel;
@property (weak, nonatomic) IBOutlet UILabel *modelNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *firmwareUpdateLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *mechanicalSwitchCell;
@property (weak, nonatomic) IBOutlet UILabel *mechanicalSwitchLabel;
@property (weak, nonatomic) IBOutlet UIButton *startSwitch;
@property (weak, nonatomic) IBOutlet UIButton *stopSwitch;

@property (weak, nonatomic) IBOutlet UITableViewCell *ledCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *tempCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tempChannelSelector;
@property (weak, nonatomic) IBOutlet UILabel *channelTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempratureLabel;
@property (weak, nonatomic) IBOutlet UILabel *readPinLabel;
@property (weak, nonatomic) IBOutlet UITextField *readPinTextField;
@property (weak, nonatomic) IBOutlet UILabel *enablePinLabel;
@property (weak, nonatomic) IBOutlet UITextField *enablePinTextField;

@property (weak, nonatomic) IBOutlet UITableViewCell *accelerometerMMA8452QCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *accelerometerScale;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sampleFrequency;
@property (weak, nonatomic) IBOutlet UISwitch *highPassFilterSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *hpfCutoffFreq;
@property (weak, nonatomic) IBOutlet UISwitch *lowNoiseSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *activePowerScheme;
@property (weak, nonatomic) IBOutlet UISwitch *autoSleepSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sleepSampleFrequency;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sleepPowerScheme;
@property (weak, nonatomic) IBOutlet UIButton *startAccelerometer;
@property (weak, nonatomic) IBOutlet UIButton *stopAccelerometer;
@property (weak, nonatomic) IBOutlet UIButton *startLog;
@property (weak, nonatomic) IBOutlet UIButton *stopLog;
@property (weak, nonatomic) IBOutlet APLGraphView *accelerometerGraph;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tapDetectionAxis;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tapDetectionType;
@property (weak, nonatomic) IBOutlet UIButton *startTap;
@property (weak, nonatomic) IBOutlet UIButton *stopTap;
@property (weak, nonatomic) IBOutlet UILabel *tapLabel;
@property (nonatomic) int tapCount;
@property (weak, nonatomic) IBOutlet UIButton *startShake;
@property (weak, nonatomic) IBOutlet UIButton *stopShake;
@property (weak, nonatomic) IBOutlet UILabel *shakeLabel;
@property (nonatomic) int shakeCount;
@property (weak, nonatomic) IBOutlet UIButton *startOrientation;
@property (weak, nonatomic) IBOutlet UIButton *stopOrientation;
@property (weak, nonatomic) IBOutlet UILabel *orientationLabel;
@property (strong, nonatomic) NSArray *accelerometerDataArray;

@property (weak, nonatomic) IBOutlet UITableViewCell *accelerometerBMI160Cell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *accelerometerBMI160Scale;
@property (weak, nonatomic) IBOutlet UISegmentedControl *accelerometerBMI160Frequency;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StartStream;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StopStream;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StartLog;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StopLog;
@property (weak, nonatomic) IBOutlet APLGraphView *accelerometerBMI160Graph;
@property (weak, nonatomic) IBOutlet UISegmentedControl *accelerometerBMI160TapType;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StartTap;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StopTap;
@property (weak, nonatomic) IBOutlet UILabel *accelerometerBMI160TapLabel;
@property (nonatomic) int accelerometerBMI160TapCount;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StartFlat;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StopFlat;
@property (weak, nonatomic) IBOutlet UILabel *accelerometerBMI160FlatLabel;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StartOrient;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StopOrient;
@property (weak, nonatomic) IBOutlet UILabel *accelerometerBMI160OrientLabel;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StartStep;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StopStep;
@property (weak, nonatomic) IBOutlet UILabel *accelerometerBMI160StepLabel;
@property (nonatomic) int accelerometerBMI160StepCount;
@property (strong, nonatomic) NSArray *accelerometerBMI160Data;

@property (weak, nonatomic) IBOutlet UITableViewCell *gyroBMI160Cell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gyroBMI160Scale;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gyroBMI160Frequency;
@property (weak, nonatomic) IBOutlet UIButton *gyroBMI160StartStream;
@property (weak, nonatomic) IBOutlet UIButton *gyroBMI160StopStream;
@property (weak, nonatomic) IBOutlet UIButton *gyroBMI160StartLog;
@property (weak, nonatomic) IBOutlet UIButton *gyroBMI160StopLog;
@property (weak, nonatomic) IBOutlet APLGraphView *gyroBMI160Graph;
@property (strong, nonatomic) NSArray *gyroBMI160Data;

@property (weak, nonatomic) IBOutlet UITableViewCell *gpioCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gpioPinSelector;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gpioPinChangeType;
@property (weak, nonatomic) IBOutlet UIButton *gpioStartPinChange;
@property (weak, nonatomic) IBOutlet UIButton *gpioStopPinChange;
@property (weak, nonatomic) IBOutlet UILabel *gpioPinChangeLabel;
@property (nonatomic) int gpioPinChangeCount;
@property (weak, nonatomic) IBOutlet UILabel *gpioDigitalValue;
@property (weak, nonatomic) IBOutlet UIButton *gpioAnalogAbsoluteButton;
@property (weak, nonatomic) IBOutlet UILabel *gpioAnalogAbsoluteValue;
@property (weak, nonatomic) IBOutlet UIButton *gpioAnalogRatioButton;
@property (weak, nonatomic) IBOutlet UILabel *gpioAnalogRatioValue;

@property (weak, nonatomic) IBOutlet UITableViewCell *hapticCell;
@property (weak, nonatomic) IBOutlet UITextField *hapticPulseWidth;
@property (weak, nonatomic) IBOutlet UITextField *hapticDutyCycle;

@property (weak, nonatomic) IBOutlet UITableViewCell *iBeaconCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *barometerBMP280Cell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *barometerBMP280Oversampling;
@property (weak, nonatomic) IBOutlet UISegmentedControl *barometerBMP280Averaging;
@property (weak, nonatomic) IBOutlet UISegmentedControl *barometerBMP280Standby;
@property (weak, nonatomic) IBOutlet UIButton *barometerBMP280StartStream;
@property (weak, nonatomic) IBOutlet UIButton *barometerBMP280StopStream;
@property (weak, nonatomic) IBOutlet UILabel *barometerBMP280Altitude;

@property (weak, nonatomic) IBOutlet UITableViewCell *ambientLightLTR329Cell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ambientLightLTR329Gain;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ambientLightLTR329Integration;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ambientLightLTR329Measurement;
@property (weak, nonatomic) IBOutlet UIButton *ambientLightLTR329StartStream;
@property (weak, nonatomic) IBOutlet UIButton *ambientLightLTR329StopStream;
@property (weak, nonatomic) IBOutlet UILabel *ambientLightLTR329Illuminance;

/* kiwi variables */
@property (strong,nonatomic) KiwiThirdpartySensorStream* kiwiSensorStream;
@property (nonatomic, strong) NSMutableArray *streamingEvents;
@property (strong, nonatomic) NSMutableDictionary *sensorValues;
@property (strong,nonatomic) NSMutableArray* bufferOfAxyz;
@property (strong,nonatomic) NSMutableArray* bufferOfGxyz;

@end

@implementation DeviceDetailViewController


- (void)viewWillAppear:(BOOL)animated
{
    
    
    [super viewWillAppear:animated];
    
    // Use this array to keep track of all streaming events, so turn them off
    // in case the user isn't so responsible
    self.streamingEvents = [NSMutableArray array];
    
    // Hide every section in the beginning
    self.hideSectionsWithHiddenRows = YES;
    [self cells:self.allCells setHidden:YES];
    [self reloadDataAnimated:NO];
    
    // Write in the 2 fields we know at time zero
    self.connectionStateLabel.text = [self nameForState];
    self.nameLabel.text = self.device.name;
    
    // Listen for state changes
    [self.device addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    
    // Start off the connection flow
    [self connectDevice:YES];
    
    /* kiwi START*/
    
    self.kiwiSensorStream = [KiwiThirdpartySensorStream sharedInstance];
    
    self.sensorValues = [[NSMutableDictionary alloc] init];
    self.sensorValues[@"device_id"] = @"Meta2";

    /* kiwi END*/
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.device removeObserver:self forKeyPath:@"state"];
    
    for (MBLEvent *event in self.streamingEvents) {
        [event stopNotifications];
    }
    [self.streamingEvents removeAllObjects];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.connectionStateLabel.text = [self nameForState];
        if (self.device.state == CBPeripheralStateDisconnected) {
            [self deviceDisconnected];
        }
    }];
}

- (NSString *)nameForState
{
    switch (self.device.state) {
        case MBLConnectionStateConnected:
            return @"Connected";
        case MBLConnectionStateConnecting:
            return @"Connecting";
        case MBLConnectionStateDisconnected:
            return @"Disconnected";
        case MBLConnectionStateDisconnecting:
            return @"Disconnecting";
        case MBLConnectionStateDiscovery:
            return @"Discovery";
    }
}

- (void)logCleanup:(MBLErrorHandler)handler
{
    // In order for the device to actaully erase the flash memory we can't be in a connection
    // so temporally disconnect to allow flash to erase.
    [self.device removeObserver:self forKeyPath:@"state"];
    [self.device disconnectWithHandler:^(NSError *error) {
        [self.device addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
        if (error) {
            if (handler) {
                handler(error);
            }
        } else {
            [self.device connectWithTimeout:15 handler:^(NSError *error) {
                if (handler) {
                    handler(error);
                }
            }];
        }
    }];
}

- (void)deviceDisconnected
{
    [self.connectionSwitch setOn:NO animated:YES];
    
    [self cells:self.allCells setHidden:YES];
    [self reloadDataAnimated:YES];
}

- (void)deviceConnected
{
    [self.connectionSwitch setOn:YES animated:YES];
    // Perform all device specific setup
    
    // We always have the info and state features
    [self cells:self.infoAndStateCells setHidden:NO];
    self.mfgNameLabel.text = self.device.deviceInfo.manufacturerName;
    self.serialNumLabel.text = self.device.deviceInfo.serialNumber;
    self.hwRevLabel.text = self.device.deviceInfo.hardwareRevision;
    self.fwRevLabel.text = self.device.deviceInfo.firmwareRevision;
    self.modelNumberLabel.text = self.device.deviceInfo.modelNumber;
    // Automaticaly send off some reads
    [self readBatteryPressed:nil];
    [self readRSSIPressed:nil];
    [self checkForFirmwareUpdatesPressed:nil];
    
    
    // Go through each module and enable the correct cell for the modules on this particular MetaWear
    if (self.device.mechanicalSwitch) {
        [self cell:self.mechanicalSwitchCell setHidden:NO];
    }
    
    if (self.device.led) {
        [self cell:self.ledCell setHidden:NO];
    }
    
    if (self.device.temperature) {
        [self cell:self.tempCell setHidden:NO];
        // The number of channels is variable
        [self.tempChannelSelector removeAllSegments];
        for (int i = 0; i < self.device.temperature.channels.count; i++) {
            [self.tempChannelSelector insertSegmentWithTitle:[NSString stringWithFormat:@"%d", i] atIndex:i animated:NO];
        }
        [self.tempChannelSelector setSelectedSegmentIndex:0];
        [self tempChannelSelectorPressed:self.tempChannelSelector];
    }
    
    if ([self.device.accelerometer isKindOfClass:[MBLAccelerometerMMA8452Q class]]) {
        [self cell:self.accelerometerMMA8452QCell setHidden:NO];
    } else if ([self.device.accelerometer isKindOfClass:[MBLAccelerometerBMI160 class]]) {
        [self cell:self.accelerometerBMI160Cell setHidden:NO];
    }
    
    if ([self.device.gyro isKindOfClass:[MBLGyroBMI160 class]]) {
        [self cell:self.gyroBMI160Cell setHidden:NO];
        if ([self.device.gyro.dataReadyEvent isLogging]) {
            [self.gyroBMI160StartLog setEnabled:NO];
            [self.gyroBMI160StopLog setEnabled:YES];
            [self.gyroBMI160StartStream setEnabled:NO];
            [self.gyroBMI160StopStream setEnabled:NO];
        } else {
            [self.gyroBMI160StartLog setEnabled:YES];
            [self.gyroBMI160StopLog setEnabled:NO];
            [self.gyroBMI160StartStream setEnabled:YES];
            [self.gyroBMI160StopStream setEnabled:NO];
        }
    }
    
    if (self.device.gpio) {
        [self cell:self.gpioCell setHidden:NO];
    }
    
    if (self.device.hapticBuzzer) {
        [self cell:self.hapticCell setHidden:NO];
    }
    
    if (self.device.iBeacon) {
        [self cell:self.iBeaconCell setHidden:NO];
    }
    
    if ([self.device.barometer isKindOfClass:[MBLBarometerBMP280 class]]) {
        [self cell:self.barometerBMP280Cell setHidden:NO];
    }
    
    if ([self.device.ambientLight isKindOfClass:[MBLAmbientLightLTR329 class]]) {
        [self cell:self.ambientLightLTR329Cell setHidden:NO];
    }
    
    // Make the magic happen!
    [self reloadDataAnimated:YES];
}

- (void)connectDevice:(BOOL)on
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    if (on) {
        hud.labelText = @"Connecting...";
        [self.device connectWithTimeout:15 handler:^(NSError *error) {
            if (!error) {
                [self deviceConnected];
            }
            if ([error.domain isEqualToString:kMBLErrorDomain] && error.code == kMBLErrorOutdatedFirmware) {
                [hud hide:YES];
                self.firmwareUpdateLabel.text = @"Force Update";
                [self updateFirmware:nil];
                return;
            }
            
            hud.mode = MBProgressHUDModeText;
            if (error) {
                hud.labelText = error.localizedDescription;
                [hud hide:YES afterDelay:2];
            } else {
                [self deviceConnected];
                
                hud.labelText = @"Connected!";
                [hud hide:YES afterDelay:0.5];
            }
        }];
    } else {
        hud.labelText = @"Disconnecting...";
        [self.device disconnectWithHandler:^(NSError *error) {
            [self deviceDisconnected];
            hud.mode = MBProgressHUDModeText;
            if (error) {
                hud.labelText = error.localizedDescription;
                [hud hide:YES afterDelay:2];
            } else {
                hud.labelText = @"Disconnected!";
                [hud hide:YES afterDelay:0.5];
            }
        }];
    }
}

- (IBAction)connectionSwitchPressed:(id)sender
{
    [self connectDevice:self.connectionSwitch.on];
}

- (IBAction)kiwiSwitchPressed:(id)sender
{
    [self connectKiwi:self.kiwiSwitch.on];
}


- (IBAction)readBatteryPressed:(id)sender
{
    [self.device readBatteryLifeWithHandler:^(NSNumber *number, NSError *error) {
        self.batteryLevelLabel.text = [number stringValue];
    }];
}

- (IBAction)readRSSIPressed:(id)sender
{
    [self.device readRSSIWithHandler:^(NSNumber *number, NSError *error) {
        self.rssiLevelLabel.text = [number stringValue];
    }];
}

- (IBAction)checkForFirmwareUpdatesPressed:(id)sender
{
    [self.device checkForFirmwareUpdateWithHandler:^(BOOL isTrue, NSError *error) {
        self.firmwareUpdateLabel.text = isTrue ? @"AVAILABLE!" : @"Up To Date";
    }];
}

- (IBAction)updateFirmware:(id)sender
{
    // Pause the screen while update is going on
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.labelText = @"Updating...";
    
    [self.device updateFirmwareWithHandler:^(NSError *error) {
        hud.mode = MBProgressHUDModeText;
        if (error) {
            NSLog(@"Firmware update error: %@", error.localizedDescription);
            [[[UIAlertView alloc] initWithTitle:@"Update Error"
                                        message:[@"Please re-connect and try again, if you can't connect, try MetaBoot Mode to recover.\nError: " stringByAppendingString:error.localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:@"Okay"
                              otherButtonTitles:nil] show];
            [hud hide:YES];
        } else {
            hud.labelText = @"Success!";
            [hud hide:YES afterDelay:2.0];
        }
    } progressHandler:^(float number, NSError *error) {
        hud.progress = number;
        if (number == 1.0) {
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.labelText = @"Resetting...";
        }
    }];
}

- (IBAction)resetDevicePressed:(id)sender
{
    // Resetting causes a disconnection
    [self deviceDisconnected];
    // Preform the soft reset
    [self.device resetDevice];
}

- (IBAction)factoryDefaultsPressed:(id)sender
{
    // Resetting causes a disconnection
    [self deviceDisconnected];
    // Setting a nil configuration removes all state perisited in flash memory
    [self.device setConfiguration:nil handler:nil];
}


- (IBAction)readSwitchPressed:(id)sender
{
    [self.device.mechanicalSwitch.switchValue readWithHandler:^(MBLNumericData *obj, NSError *error) {
        self.mechanicalSwitchLabel.text = obj.value.boolValue ? @"Down" : @"Up";
    }];
}

- (IBAction)startSwitchNotifyPressed:(id)sender
{
    [self.startSwitch setEnabled:NO];
    [self.stopSwitch setEnabled:YES];
    
    [self.streamingEvents addObject:self.device.mechanicalSwitch.switchUpdateEvent];
    [self.device.mechanicalSwitch.switchUpdateEvent startNotificationsWithHandler:^(MBLNumericData *isPressed, NSError *error) {
        self.mechanicalSwitchLabel.text = isPressed.value.boolValue ? @"Down" : @"Up";
    }];
}

- (IBAction)stopSwitchNotifyPressed:(id)sender
{
    [self.startSwitch setEnabled:YES];
    [self.stopSwitch setEnabled:NO];
    
    [self.streamingEvents removeObject:self.device.mechanicalSwitch.switchUpdateEvent];
    [self.device.mechanicalSwitch.switchUpdateEvent stopNotifications];
}


- (IBAction)turnOnGreenLEDPressed:(id)sender
{
    [self.device.led setLEDColor:[UIColor greenColor] withIntensity:1.0];
}
- (IBAction)flashGreenLEDPressed:(id)sender
{
    [self.device.led flashLEDColor:[UIColor greenColor] withIntensity:1.0];
}

- (IBAction)turnOnRedLEDPressed:(id)sender
{
    [self.device.led setLEDColor:[UIColor redColor] withIntensity:1.0];
}
- (IBAction)flashRedLEDPressed:(id)sender
{
    [self.device.led flashLEDColor:[UIColor redColor] withIntensity:1.0];
}

- (IBAction)turnOnBlueLEDPressed:(id)sender
{
    [self.device.led setLEDColor:[UIColor blueColor] withIntensity:1.0];
}
- (IBAction)flashBlueLEDPressed:(id)sender
{
    [self.device.led flashLEDColor:[UIColor blueColor] withIntensity:1.0];
}

- (IBAction)turnOffLEDPressed:(id)sender
{
    [self.device.led setLEDOn:NO withOptions:1];
}


- (IBAction)tempChannelSelectorPressed:(id)sender
{
    MBLData *selected = self.device.temperature.channels[self.tempChannelSelector.selectedSegmentIndex];
    if (selected == self.device.temperature.internal) {
        self.channelTypeLabel.text = @"On-Die";
    } else if (selected == self.device.temperature.onboardThermistor) {
        self.channelTypeLabel.text = @"On-Board";
    } else if (selected == self.device.temperature.externalThermistor) {
        self.channelTypeLabel.text = @"External";
    } else {
        self.channelTypeLabel.text = @"Custom";
    }
    
    if ([selected isKindOfClass:[MBLExternalThermistor class]]) {
        [self.readPinLabel setHidden:NO];
        [self.readPinTextField setHidden:NO];
        [self.enablePinLabel setHidden:NO];
        [self.enablePinTextField setHidden:NO];
    } else {
        [self.readPinLabel setHidden:YES];
        [self.readPinTextField setHidden:YES];
        [self.enablePinLabel setHidden:YES];
        [self.enablePinTextField setHidden:YES];
    }
}

- (IBAction)readTempraturePressed:(id)sender
{
    MBLData *selected = self.device.temperature.channels[self.tempChannelSelector.selectedSegmentIndex];
    if ([selected isKindOfClass:[MBLExternalThermistor class]]) {
        ((MBLExternalThermistor *)selected).readPin = [self.readPinTextField.text intValue];
        ((MBLExternalThermistor *)selected).enablePin = [self.enablePinTextField.text intValue];
    }
    [selected readWithHandler:^(MBLNumericData *obj, NSError *error) {
        self.tempratureLabel.text = [obj.value.stringValue stringByAppendingString:@"°C"];
    }];
}


- (void)updateAccelerometerSettings
{
    MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)self.device.accelerometer;
    if (self.accelerometerScale.selectedSegmentIndex == 0) {
        self.accelerometerGraph.fullScale = 2;
    } else if (self.accelerometerScale.selectedSegmentIndex == 1) {
        self.accelerometerGraph.fullScale = 4;
    } else {
        self.accelerometerGraph.fullScale = 8;
    }
    
    accelerometerMMA8452Q.fullScaleRange = (int)self.accelerometerScale.selectedSegmentIndex;
    accelerometerMMA8452Q.sampleFrequency = [[self.sampleFrequency titleForSegmentAtIndex:self.sampleFrequency.selectedSegmentIndex] floatValue];
    accelerometerMMA8452Q.highPassFilter = self.highPassFilterSwitch.on;
    accelerometerMMA8452Q.highPassCutoffFreq = self.hpfCutoffFreq.selectedSegmentIndex;
    accelerometerMMA8452Q.lowNoise = self.lowNoiseSwitch.on;
    accelerometerMMA8452Q.activePowerScheme = (int)self.activePowerScheme.selectedSegmentIndex;
    accelerometerMMA8452Q.autoSleep = self.autoSleepSwitch.on;
    accelerometerMMA8452Q.sleepSampleFrequency = (int)self.sleepSampleFrequency.selectedSegmentIndex;
    accelerometerMMA8452Q.sleepPowerScheme = (int)self.sleepPowerScheme.selectedSegmentIndex;
    accelerometerMMA8452Q.tapDetectionAxis = (int)self.tapDetectionAxis.selectedSegmentIndex;
    accelerometerMMA8452Q.tapType = (int)self.tapDetectionType.selectedSegmentIndex;
}

- (IBAction)startAccelerationPressed:(id)sender
{
    [self.startAccelerometer setEnabled:NO];
    [self.stopAccelerometer setEnabled:YES];
    [self.startLog setEnabled:NO];
    [self.stopLog setEnabled:NO];
    
    [self updateAccelerometerSettings];
    
    // These variables are used for data recording
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:1000];
    self.accelerometerDataArray = array;
    
    [self.streamingEvents addObject:self.device.accelerometer.dataReadyEvent];
    [self.device.accelerometer.dataReadyEvent startNotificationsWithHandler:^(MBLAccelerometerData *acceleration, NSError *error) {
        [self.accelerometerGraph addX:acceleration.x y:acceleration.y z:acceleration.z];
        // Add data to data array for saving
        [array addObject:acceleration];
    }];
}

- (IBAction)stopAccelerationPressed:(id)sender
{
    [self.startAccelerometer setEnabled:YES];
    [self.stopAccelerometer setEnabled:NO];
    [self.startLog setEnabled:YES];
    
    [self.streamingEvents removeObject:self.device.accelerometer.dataReadyEvent];
    [self.device.accelerometer.dataReadyEvent stopNotifications];
}

- (IBAction)startAccelerometerLog:(id)sender
{
    [self.startLog setEnabled:NO];
    [self.stopLog setEnabled:YES];
    [self.startAccelerometer setEnabled:NO];
    [self.stopAccelerometer setEnabled:NO];
    
    [self updateAccelerometerSettings];
    
    [self.device.accelerometer.dataReadyEvent startLogging];
}

- (IBAction)stopAccelerometerLog:(id)sender
{
    [self.stopLog setEnabled:NO];
    [self.startLog setEnabled:YES];
    [self.startAccelerometer setEnabled:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.labelText = @"Downloading...";
    
    [self.device.accelerometer.dataReadyEvent downloadLogAndStopLogging:YES handler:^(NSArray *array, NSError *error) {
        [hud hide:YES];
        if (!error) {
            self.accelerometerDataArray = array;
            for (MBLAccelerometerData *acceleration in array) {
                [self.accelerometerGraph addX:acceleration.x y:acceleration.y z:acceleration.z];
            }
        }
    } progressHandler:^(float number, NSError *error) {
        hud.progress = number;
    }];
}

- (IBAction)sendDataPressed:(id)sender
{
    NSMutableData *accelerometerData = [NSMutableData data];
    for (MBLAccelerometerData *dataElement in self.accelerometerDataArray) {
        @autoreleasepool {
            [accelerometerData appendData:[[NSString stringWithFormat:@"%f,%f,%f,%f\n",
                                            dataElement.timestamp.timeIntervalSince1970,
                                            dataElement.x,
                                            dataElement.y,
                                            dataElement.z] dataUsingEncoding:NSUTF8StringEncoding]];
            
            //            [_sensorData appendData: [[NSArray
            //                                       dataElement.x,
            //                                       dataElement.y,
            //                                       dataElement.z]]];
            
        }
    }
    [self sendMail:accelerometerData title:@"AccData"];
}

- (void)sendMail:(NSData *)attachment title:(NSString *)title
{
    if (![MFMailComposeViewController canSendMail]) {
        [[[UIAlertView alloc] initWithTitle:@"Mail Error" message:@"This device does not have an email account setup" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
        return;
    }
    
    // Get current Time/Date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM_dd_yyyy-HH_mm_ss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
    emailController.mailComposeDelegate = self;
    
    // attachment
    NSString *name = [NSString stringWithFormat:@"%@_%@.csv", title, dateString];
    [emailController addAttachmentData:attachment mimeType:@"text/plain" fileName:name];
    
    // subject
    [emailController setSubject:name];
    
    NSMutableString *body = [[NSMutableString alloc] initWithFormat:@"The data was recorded on %@.\n", dateString];
    [emailController setMessageBody:body isHTML:NO];
    
    [self presentViewController:emailController animated:YES completion:NULL];
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)startTapPressed:(id)sender
{
    [self.startTap setEnabled:NO];
    [self.stopTap setEnabled:YES];
    
    [self updateAccelerometerSettings];
    MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)self.device.accelerometer;
    [self.streamingEvents addObject:accelerometerMMA8452Q.tapEvent];
    [accelerometerMMA8452Q.tapEvent startNotificationsWithHandler:^(id obj, NSError *error) {
        self.tapLabel.text = [NSString stringWithFormat:@"Tap Count: %d", ++self.tapCount];
    }];
}

- (IBAction)stopTapPressed:(id)sender
{
    [self.startTap setEnabled:YES];
    [self.stopTap setEnabled:NO];
    
    MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)self.device.accelerometer;
    [self.streamingEvents removeObject:accelerometerMMA8452Q.tapEvent];
    [accelerometerMMA8452Q.tapEvent stopNotifications];
    self.tapCount = 0;
    self.tapLabel.text = @"Tap Count: 0";
}

- (IBAction)startShakePressed:(id)sender
{
    [self.startShake setEnabled:NO];
    [self.stopShake setEnabled:YES];
    
    [self updateAccelerometerSettings];
    MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)self.device.accelerometer;
    [self.streamingEvents addObject:accelerometerMMA8452Q.shakeEvent];
    [accelerometerMMA8452Q.shakeEvent startNotificationsWithHandler:^(id obj, NSError *error) {
        self.shakeLabel.text = [NSString stringWithFormat:@"Shakes: %d", ++self.shakeCount];
    }];
}

- (IBAction)stopShakePressed:(id)sender
{
    [self.startShake setEnabled:YES];
    [self.stopShake setEnabled:NO];
    
    MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)self.device.accelerometer;
    [self.streamingEvents removeObject:accelerometerMMA8452Q.shakeEvent];
    [accelerometerMMA8452Q.shakeEvent stopNotifications];
    self.shakeCount = 0;
    self.shakeLabel.text = @"Shakes: 0";
}

- (IBAction)startOrientationPressed:(id)sender
{
    [self.startOrientation setEnabled:NO];
    [self.stopOrientation setEnabled:YES];
    
    [self updateAccelerometerSettings];
    MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)self.device.accelerometer;
    [self.streamingEvents addObject:accelerometerMMA8452Q.orientationEvent];
    [accelerometerMMA8452Q.orientationEvent startNotificationsWithHandler:^(MBLOrientationData *obj, NSError *error) {
        switch (obj.orientation) {
            case MBLAccelerometerOrientationPortrait:
                self.orientationLabel.text = @"Portrait";
                break;
            case MBLAccelerometerOrientationPortraitUpsideDown:
                self.orientationLabel.text = @"PortraitUpsideDown";
                break;
            case MBLAccelerometerOrientationLandscapeLeft:
                self.orientationLabel.text = @"LandscapeLeft";
                break;
            case MBLAccelerometerOrientationLandscapeRight:
                self.orientationLabel.text = @"LandscapeRight";
                break;
        }
    }];
}

- (IBAction)stopOrientationPressed:(id)sender
{
    [self.startOrientation setEnabled:YES];
    [self.stopOrientation setEnabled:NO];
    
    MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)self.device.accelerometer;
    [self.streamingEvents removeObject:accelerometerMMA8452Q.orientationEvent];
    [accelerometerMMA8452Q.orientationEvent stopNotifications];
    self.orientationLabel.text = @"XXXXXXXXXXXXXX";
}


- (void)updateAccelerometerBMI160Settings
{
    MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    switch (self.accelerometerBMI160Scale.selectedSegmentIndex) {
        case 0:
            accelerometerBMI160.fullScaleRange = MBLAccelerometerBMI160Range2G;
            self.accelerometerBMI160Graph.fullScale = 2;
            break;
        case 1:
            accelerometerBMI160.fullScaleRange = MBLAccelerometerBMI160Range4G;
            self.accelerometerBMI160Graph.fullScale = 4;
            break;
        case 2:
            accelerometerBMI160.fullScaleRange = MBLAccelerometerBMI160Range8G;
            self.accelerometerBMI160Graph.fullScale = 8;
            break;
        case 3:
            accelerometerBMI160.fullScaleRange = MBLAccelerometerBMI160Range16G;
            self.accelerometerBMI160Graph.fullScale = 16;
            break;
        default:
            NSLog(@"Unexpected accelerometerBMI160Scale value");
            break;
    }
    
    accelerometerBMI160.sampleFrequency = [[self.accelerometerBMI160Frequency titleForSegmentAtIndex:self.accelerometerBMI160Frequency.selectedSegmentIndex] floatValue];
    accelerometerBMI160.tapType = (int)self.tapDetectionType.selectedSegmentIndex;
}

- (IBAction)accelerometerBMI160StartStreamPressed:(id)sender
{
    
    [self.accelerometerBMI160StartStream setEnabled:NO];
    [self.accelerometerBMI160StopStream setEnabled:YES];
    [self.accelerometerBMI160StartLog setEnabled:NO];
    [self.accelerometerBMI160StopLog setEnabled:NO];
    
    [self updateAccelerometerBMI160Settings];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:1000];
    self.accelerometerBMI160Data = array;
    
    
    [self.streamingEvents addObject:self.device.accelerometer.dataReadyEvent];
    [self.device.accelerometer.dataReadyEvent startNotificationsWithHandler:^(MBLAccelerometerData *obj, NSError *error) {
        
        
        // send data to the server here.
        [self.accelerometerBMI160Graph addX:obj.x y:obj.y z:obj.z];
        [array addObject:obj];
        
        // kiwi
        self.sensorValues[@"ax"] = [NSNumber numberWithFloat:obj.x];
        self.sensorValues[@"ay"] = [NSNumber numberWithFloat:obj.y];
        self.sensorValues[@"az"] = [NSNumber numberWithFloat:obj.z];
        [self sendSensorBuffer];
        // kiwi
    }];
    
    
}

- (IBAction)accelerometerBMI160StopStreamPressed:(id)sender
{
    // Modiify the state here again if button pressed
    [self.accelerometerBMI160StartStream setEnabled:YES];
    [self.accelerometerBMI160StopStream setEnabled:NO];
    [self.accelerometerBMI160StartLog setEnabled:YES];
    
    [self.streamingEvents removeObject:self.device.accelerometer.dataReadyEvent];
    [self.device.accelerometer.dataReadyEvent stopNotifications];
}

- (IBAction)accelerometerBMI160StartLogPressed:(id)sender
{
    [self.accelerometerBMI160StartLog setEnabled:NO];
    [self.accelerometerBMI160StopLog setEnabled:YES];
    [self.accelerometerBMI160StartStream setEnabled:NO];
    [self.accelerometerBMI160StopStream setEnabled:NO];
    
    [self updateAccelerometerBMI160Settings];
    
    [self.device.accelerometer.dataReadyEvent startLogging];
}

- (IBAction)accelerometerBMI160StopLogPressed:(id)sender
{
    [self.accelerometerBMI160StartLog setEnabled:YES];
    [self.accelerometerBMI160StopLog setEnabled:NO];
    [self.accelerometerBMI160StartStream setEnabled:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.labelText = @"Downloading...";
    
    [self.device.accelerometer.dataReadyEvent downloadLogAndStopLogging:YES handler:^(NSArray *array, NSError *error) {
        if (!error) {
            self.accelerometerBMI160Data = array;
            for (MBLAccelerometerData *obj in array) {
                [self.accelerometerBMI160Graph addX:obj.x y:obj.y z:obj.z];
            }
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.labelText = @"Clearing Log...";
            [self logCleanup:^(NSError *error) {
                [hud hide:YES];
                if (error) {
                    [self connectDevice:NO];
                }
            }];
        } else {
            [self connectDevice:NO];
            [hud hide:YES];
        }
    } progressHandler:^(float number, NSError *error) {
        hud.progress = number;
    }];
}

- (IBAction)accelerometerBMI160EmailDataPressed:(id)sender
{
    NSMutableData *accelerometerData = [NSMutableData data];
    for (MBLAccelerometerData *dataElement in self.accelerometerBMI160Data) {
        @autoreleasepool {
            [accelerometerData appendData:[[NSString stringWithFormat:@"%f,%f,%f,%f\n",
                                            dataElement.timestamp.timeIntervalSince1970,
                                            dataElement.x,
                                            dataElement.y,
                                            dataElement.z] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    [self sendMail:accelerometerData title:@"AccData"];
}

- (IBAction)accelerometerBMI160StartTapPressed:(id)sender
{
    [self.accelerometerBMI160StartTap setEnabled:NO];
    [self.accelerometerBMI160StopTap setEnabled:YES];
    
    [self updateAccelerometerBMI160Settings];
    
    MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    [self.streamingEvents addObject:accelerometerBMI160.tapEvent];
    [accelerometerBMI160.tapEvent startNotificationsWithHandler:^(id obj, NSError *error) {
        self.accelerometerBMI160TapLabel.text = [NSString stringWithFormat:@"Tap Count: %d", ++self.accelerometerBMI160TapCount];
    }];
}

- (IBAction)accelerometerBMI160StopTapPressed:(id)sender
{
    [self.accelerometerBMI160StartTap setEnabled:YES];
    [self.accelerometerBMI160StopTap setEnabled:NO];
    
    MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    [self.streamingEvents removeObject:accelerometerBMI160.tapEvent];
    [accelerometerBMI160.tapEvent stopNotifications];
    self.accelerometerBMI160TapCount = 0;
    self.accelerometerBMI160TapLabel.text = @"Tap Count: 0";
}

- (IBAction)accelerometerBMI160StartFlatPressed:(id)sender
{
    [self.accelerometerBMI160StartFlat setEnabled:NO];
    [self.accelerometerBMI160StopFlat setEnabled:YES];
    
    [self updateAccelerometerBMI160Settings];
    
    MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    [self.streamingEvents addObject:accelerometerBMI160.flatEvent];
    [accelerometerBMI160.flatEvent startNotificationsWithHandler:^(MBLNumericData *obj, NSError *error) {
        self.accelerometerBMI160FlatLabel.text = obj.value.boolValue ? @"Flat" : @"Not Flat";
    }];
}

- (IBAction)accelerometerBMI160StopFlatPressed:(id)sender
{
    [self.accelerometerBMI160StartFlat setEnabled:YES];
    [self.accelerometerBMI160StopFlat setEnabled:NO];
    
    MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    [self.streamingEvents removeObject:accelerometerBMI160.flatEvent];
    [accelerometerBMI160.flatEvent stopNotifications];
    self.accelerometerBMI160FlatLabel.text = @"XXXXXXX";
}

- (IBAction)accelerometerBMI160StartOrientPressed:(id)sender
{
    [self.accelerometerBMI160StartOrient setEnabled:NO];
    [self.accelerometerBMI160StopOrient setEnabled:YES];
    
    [self updateAccelerometerBMI160Settings];
    MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    [self.streamingEvents addObject:accelerometerBMI160.orientationEvent];
    [accelerometerBMI160.orientationEvent startNotificationsWithHandler:^(MBLOrientationData *obj, NSError *error) {
        switch (obj.orientation) {
            case MBLAccelerometerOrientationPortrait:
                self.accelerometerBMI160OrientLabel.text = @"Portrait";
                break;
            case MBLAccelerometerOrientationPortraitUpsideDown:
                self.accelerometerBMI160OrientLabel.text = @"PortraitUpsideDown";
                break;
            case MBLAccelerometerOrientationLandscapeLeft:
                self.accelerometerBMI160OrientLabel.text = @"LandscapeLeft";
                break;
            case MBLAccelerometerOrientationLandscapeRight:
                self.accelerometerBMI160OrientLabel.text = @"LandscapeRight";
                break;
        }
    }];
}

- (IBAction)accelerometerBMI160StopOrientPressed:(id)sender
{
    [self.accelerometerBMI160StartOrient setEnabled:YES];
    [self.accelerometerBMI160StopOrient setEnabled:NO];
    
    MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    [self.streamingEvents removeObject:accelerometerBMI160.orientationEvent];
    [accelerometerBMI160.orientationEvent stopNotifications];
    self.accelerometerBMI160OrientLabel.text = @"XXXXXXXXXXXXXX";
}

- (IBAction)accelerometerBMI160StartStepPressed:(id)sender
{
    [self.accelerometerBMI160StartStep setEnabled:NO];
    [self.accelerometerBMI160StopStep setEnabled:YES];
    
    [self updateAccelerometerBMI160Settings];
    
    MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    [self.streamingEvents addObject:accelerometerBMI160.stepEvent];
    [accelerometerBMI160.stepEvent startNotificationsWithHandler:^(MBLNumericData *obj, NSError *error) {
        self.accelerometerBMI160StepLabel.text = [NSString stringWithFormat:@"Step Count: %d", ++self.accelerometerBMI160StepCount];
        
        
    }];
}

- (IBAction)accelerometerBMI160StopStepPressed:(id)sender
{
    [self.accelerometerBMI160StartStep setEnabled:YES];
    [self.accelerometerBMI160StopStep setEnabled:NO];
    
    MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    [self.streamingEvents removeObject:accelerometerBMI160.stepEvent];
    [accelerometerBMI160.stepEvent stopNotifications];
    self.accelerometerBMI160StepCount = 0;
    self.accelerometerBMI160StepLabel.text = @"Step Count: 0";
}

- (void)updateGyroBMI160Settings
{
    MBLGyroBMI160 *gyroBMI160 = (MBLGyroBMI160 *)self.device.gyro;
    switch (self.gyroBMI160Scale.selectedSegmentIndex) {
        case 0:
            gyroBMI160.fullScaleRange = MBLGyroBMI160Range125;
            self.gyroBMI160Graph.fullScale = 1;
            break;
        case 1:
            gyroBMI160.fullScaleRange = MBLGyroBMI160Range250;
            self.gyroBMI160Graph.fullScale = 2;
            break;
        case 2:
            gyroBMI160.fullScaleRange = MBLGyroBMI160Range500;
            self.gyroBMI160Graph.fullScale = 4;
            break;
        case 3:
            gyroBMI160.fullScaleRange = MBLGyroBMI160Range1000;
            self.gyroBMI160Graph.fullScale = 8;
            break;
        case 4:
            gyroBMI160.fullScaleRange = MBLGyroBMI160Range2000;
            self.gyroBMI160Graph.fullScale = 16;
            break;
        default:
            NSLog(@"Unexpected gyroBMI160Scale value");
            break;
    }
    gyroBMI160.sampleFrequency = [[self.gyroBMI160Frequency titleForSegmentAtIndex:self.gyroBMI160Frequency.selectedSegmentIndex] floatValue];
}

- (IBAction)gyroBMI160StartStreamPressed:(id)sender
{
    [self.gyroBMI160StartStream setEnabled:NO];
    [self.gyroBMI160StopStream setEnabled:YES];
    [self.gyroBMI160StartLog setEnabled:NO];
    [self.gyroBMI160StopLog setEnabled:NO];
    
    [self updateGyroBMI160Settings];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:1000];
    self.gyroBMI160Data = array;
    
    [self.streamingEvents addObject:self.device.gyro.dataReadyEvent];
    [self.device.gyro.dataReadyEvent startNotificationsWithHandler:^(MBLGyroData *obj, NSError *error) {
        // TODO: Come up with a better graph interface, we need to scale value
        // to show up right
        
        [self.gyroBMI160Graph addX:obj.x * .008 y:obj.y * .008 z:obj.z * .008];
        [array addObject:obj];
        
        // kiwi
        self.sensorValues[@"gx"] = [NSNumber numberWithFloat:obj.x];
        self.sensorValues[@"gy"] = [NSNumber numberWithFloat:obj.y];
        self.sensorValues[@"gz"] = [NSNumber numberWithFloat:obj.z];
        [self sendSensorBuffer];
        // kiwi
    }];
}

- (IBAction)gyroBMI160StopStreamPressed:(id)sender
{
    [self.gyroBMI160StartStream setEnabled:YES];
    [self.gyroBMI160StopStream setEnabled:NO];
    [self.gyroBMI160StartLog setEnabled:YES];
    
    [self.streamingEvents removeObject:self.device.gyro.dataReadyEvent];
    [self.device.gyro.dataReadyEvent stopNotifications];
}

- (IBAction)gyroBMI160StartLogPressed:(id)sender
{
    [self.gyroBMI160StartLog setEnabled:NO];
    [self.gyroBMI160StopLog setEnabled:YES];
    [self.gyroBMI160StartStream setEnabled:NO];
    [self.gyroBMI160StopStream setEnabled:NO];
    
    [self updateGyroBMI160Settings];
    
    [self.device.gyro.dataReadyEvent startLogging];
}

- (IBAction)gyroBMI160StopLogPressed:(id)sender
{
    [self.gyroBMI160StartLog setEnabled:YES];
    [self.gyroBMI160StopLog setEnabled:NO];
    [self.gyroBMI160StartStream setEnabled:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.labelText = @"Downloading...";
    
    [self.device.gyro.dataReadyEvent downloadLogAndStopLogging:YES handler:^(NSArray *array, NSError *error) {
        [hud hide:YES];
        if (!error) {
            self.gyroBMI160Data = array;
            for (MBLGyroData *obj in array) {
                [self.gyroBMI160Graph addX:obj.x * .008 y:obj.y * .008 z:obj.z * .008];
            }
        }
    } progressHandler:^(float number, NSError *error) {
        hud.progress = number;
    }];
}

- (IBAction)gyroBMI160EmailDataPressed:(id)sender
{
    NSMutableData *gyroData = [NSMutableData data];
    for (MBLGyroData *dataElement in self.gyroBMI160Data) {
        @autoreleasepool {
            [gyroData appendData:[[NSString stringWithFormat:@"%f,%f,%f,%f\n",
                                   dataElement.timestamp.timeIntervalSince1970,
                                   dataElement.x,
                                   dataElement.y,
                                   dataElement.z] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    [self sendMail:gyroData title:@"GyroData"];
}

- (IBAction)gpioPinSelectorPressed:(id)sender
{
    // As of now only pins 0-3 have analog read capabilities
    if (self.gpioPinSelector.selectedSegmentIndex > 3) {
        [self.gpioAnalogAbsoluteButton setHidden:YES];
        [self.gpioAnalogAbsoluteValue setHidden:YES];
        [self.gpioAnalogRatioButton setHidden:YES];
        [self.gpioAnalogRatioValue setHidden:YES];
    } else {
        [self.gpioAnalogAbsoluteButton setHidden:NO];
        [self.gpioAnalogAbsoluteValue setHidden:NO];
        [self.gpioAnalogRatioButton setHidden:NO];
        [self.gpioAnalogRatioValue setHidden:NO];
    }
}

- (IBAction)setPullUpPressed:(id)sender
{
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    pin.configuration = MBLPinConfigurationPullup;
}

- (IBAction)setPullDownPressed:(id)sender
{
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    pin.configuration = MBLPinConfigurationPulldown;
}

- (IBAction)setNoPullPressed:(id)sender
{
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    pin.configuration = MBLPinConfigurationNopull;
}

- (IBAction)setPinPressed:(id)sender
{
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    [pin setToDigitalValue:YES];
}

- (IBAction)clearPinPressed:(id)sender
{
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    [pin setToDigitalValue:NO];
}

- (IBAction)gpioStartPinChangePressed:(id)sender
{
    [self.gpioStartPinChange setEnabled:NO];
    [self.gpioStopPinChange setEnabled:YES];
    
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    if (self.gpioPinChangeType.selectedSegmentIndex == 0) {
        pin.changeType = MBLPinChangeTypeRising;
    } else if (self.gpioPinChangeType.selectedSegmentIndex == 1) {
        pin.changeType = MBLPinChangeTypeFalling;
    } else {
        pin.changeType = MBLPinChangeTypeAny;
    }
    [self.streamingEvents addObject:pin.changeEvent];
    [pin.changeEvent startNotificationsWithHandler:^(MBLNumericData *isPressed, NSError *error) {
        self.gpioPinChangeLabel.text = [NSString stringWithFormat:@"Change Count: %d", ++self.gpioPinChangeCount];
    }];
}

- (IBAction)gpioStopPinChangePressed:(id)sender
{
    [self.gpioStartPinChange setEnabled:YES];
    [self.gpioStopPinChange setEnabled:NO];
    
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    [self.streamingEvents removeObject:pin.changeEvent];
    [pin.changeEvent stopNotifications];
    self.gpioPinChangeCount = 0;
    self.gpioPinChangeLabel.text = @"Change Count: 0";
}

- (IBAction)readDigitalPressed:(id)sender
{
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    [pin.digitalValue readWithHandler:^(MBLNumericData *obj, NSError *error) {
        self.gpioDigitalValue.text = obj.value.boolValue ? @"1" : @"0";
    }];
}

- (IBAction)readAnalogAbsolutePressed:(id)sender
{
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    [pin.analogAbsolute readWithHandler:^(MBLNumericData *obj, NSError *error) {
        self.gpioAnalogAbsoluteValue.text = [NSString stringWithFormat:@"%.3fV", obj.value.doubleValue];
    }];
}
- (IBAction)readAnalogRatioPressed:(id)sender
{
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    [pin.analogRatio readWithHandler:^(MBLNumericData *obj, NSError *error) {
        self.gpioAnalogRatioValue.text = [NSString stringWithFormat:@"%.3f", obj.value.doubleValue];
    }];
}


- (IBAction)startHapticDriverPressed:(UIButton *)sender
{
    int dcycle = [self.hapticDutyCycle.text intValue];
    dcycle = MIN(dcycle, 248);
    dcycle = MAX(dcycle, 0);
    int pwidth = [self.hapticPulseWidth.text intValue];
    pwidth = MIN(pwidth, 10000);
    pwidth = MAX(pwidth, 0);
    
    [sender setEnabled:NO];
    [self.device.hapticBuzzer startHapticWithDutyCycle:dcycle pulseWidth:pwidth completion:^{
        [sender setEnabled:YES];
    }];
}

- (IBAction)startBuzzerDriverPressed:(UIButton *)sender
{
    int pwidth = [self.hapticPulseWidth.text intValue];
    pwidth = MIN(pwidth, 10000);
    pwidth = MAX(pwidth, 0);
    
    [sender setEnabled:NO];
    [self.device.hapticBuzzer startBuzzerWithPulseWidth:pwidth completion:^{
        [sender setEnabled:YES];
    }];
}


- (IBAction)startiBeaconPressed:(id)sender
{
    // TODO: Expose the other iBeacon parameters
    [self.device.iBeacon setBeaconOn:YES];
}

- (IBAction)stopiBeaconPressed:(id)sender
{
    [self.device.iBeacon setBeaconOn:NO];
}


- (IBAction)barometerBMP280StartStreamPressed:(id)sender
{
    [self.barometerBMP280StartStream setEnabled:NO];
    [self.barometerBMP280StopStream setEnabled:YES];
    
    MBLBarometerBMP280 *barometerBMP280 = (MBLBarometerBMP280 *)self.device.barometer;
    if (self.barometerBMP280Oversampling.selectedSegmentIndex == 0) {
        barometerBMP280.pressureOversampling = MBLBarometerBMP280OversampleUltraLowPower;
    } else if (self.barometerBMP280Oversampling.selectedSegmentIndex == 1) {
        barometerBMP280.pressureOversampling = MBLBarometerBMP280OversampleLowPower;
    } else if (self.barometerBMP280Oversampling.selectedSegmentIndex == 2) {
        barometerBMP280.pressureOversampling = MBLBarometerBMP280OversampleStandard;
    } else if (self.barometerBMP280Oversampling.selectedSegmentIndex == 3) {
        barometerBMP280.pressureOversampling = MBLBarometerBMP280OversampleHighResolution;
    } else {
        barometerBMP280.pressureOversampling = MBLBarometerBMP280OversampleUltraHighResolution;
    }
    
    if (self.barometerBMP280Averaging.selectedSegmentIndex == 0) {
        barometerBMP280.hardwareAverageFilter = MBLBarometerBMP280FilterOff;
    } else if (self.barometerBMP280Averaging.selectedSegmentIndex == 1) {
        barometerBMP280.hardwareAverageFilter = MBLBarometerBMP280FilterAverage2;
    } else if (self.barometerBMP280Averaging.selectedSegmentIndex == 2) {
        barometerBMP280.hardwareAverageFilter = MBLBarometerBMP280FilterAverage4;
    } else if (self.barometerBMP280Averaging.selectedSegmentIndex == 3) {
        barometerBMP280.hardwareAverageFilter = MBLBarometerBMP280FilterAverage8;
    } else {
        barometerBMP280.hardwareAverageFilter = MBLBarometerBMP280FilterAverage16;
    }
    
    if (self.barometerBMP280Standby.selectedSegmentIndex == 0) {
        barometerBMP280.standbyTime = MBLBarometerBMP280Standby0_5;
    } else if (self.barometerBMP280Standby.selectedSegmentIndex == 1) {
        barometerBMP280.standbyTime = MBLBarometerBMP280Standby62_5;
    } else if (self.barometerBMP280Standby.selectedSegmentIndex == 2) {
        barometerBMP280.standbyTime = MBLBarometerBMP280Standby125;
    } else if (self.barometerBMP280Standby.selectedSegmentIndex == 3) {
        barometerBMP280.standbyTime = MBLBarometerBMP280Standby250;
    } else if (self.barometerBMP280Standby.selectedSegmentIndex == 4) {
        barometerBMP280.standbyTime = MBLBarometerBMP280Standby500;
    } else if (self.barometerBMP280Standby.selectedSegmentIndex == 5) {
        barometerBMP280.standbyTime = MBLBarometerBMP280Standby1000;
    } else if (self.barometerBMP280Standby.selectedSegmentIndex == 6) {
        barometerBMP280.standbyTime = MBLBarometerBMP280Standby2000;
    } else {
        barometerBMP280.standbyTime = MBLBarometerBMP280Standby4000;
    }
    
    [self.streamingEvents addObject:barometerBMP280.periodicAltitude];
    [barometerBMP280.periodicAltitude startNotificationsWithHandler:^(MBLNumericData *obj, NSError *error) {
        self.barometerBMP280Altitude.text = [NSString stringWithFormat:@"%.3f", obj.value.floatValue];
    }];
}

- (IBAction)barometerBMP280StopStreamPressed:(id)sender
{
    [self.barometerBMP280StartStream setEnabled:YES];
    [self.barometerBMP280StopStream setEnabled:NO];
    
    MBLBarometerBMP280 *barometerBMP280 = (MBLBarometerBMP280 *)self.device.barometer;
    [self.streamingEvents removeObject:barometerBMP280.periodicAltitude];
    [barometerBMP280.periodicAltitude stopNotifications];
    self.barometerBMP280Altitude.text = @"X.XXX";
}


- (IBAction)ambientLightLTR329StartStreamPressed:(id)sender
{
    [self.ambientLightLTR329StartStream setEnabled:NO];
    [self.ambientLightLTR329StopStream setEnabled:YES];
    
    MBLAmbientLightLTR329 *ambientLightLTR329 = (MBLAmbientLightLTR329 *)self.device.ambientLight;
    switch (self.ambientLightLTR329Gain.selectedSegmentIndex) {
        case 0:
            ambientLightLTR329.gain = MBLAmbientLightLTR329Gain1X;
            break;
        case 1:
            ambientLightLTR329.gain = MBLAmbientLightLTR329Gain2X;
            break;
        case 2:
            ambientLightLTR329.gain = MBLAmbientLightLTR329Gain4X;
            break;
        case 3:
            ambientLightLTR329.gain = MBLAmbientLightLTR329Gain8X;
            break;
        case 4:
            ambientLightLTR329.gain = MBLAmbientLightLTR329Gain48X;
            break;
        default:
            ambientLightLTR329.gain = MBLAmbientLightLTR329Gain96X;
            break;
    }
    
    switch (self.ambientLightLTR329Integration.selectedSegmentIndex) {
        case 0:
            ambientLightLTR329.integrationTime = MBLAmbientLightLTR329Integration50ms;
            break;
        case 1:
            ambientLightLTR329.integrationTime = MBLAmbientLightLTR329Integration100ms;
            break;
        case 2:
            ambientLightLTR329.integrationTime = MBLAmbientLightLTR329Integration150ms;
            break;
        case 3:
            ambientLightLTR329.integrationTime = MBLAmbientLightLTR329Integration200ms;
            break;
        case 4:
            ambientLightLTR329.integrationTime = MBLAmbientLightLTR329Integration250ms;
            break;
        case 5:
            ambientLightLTR329.integrationTime = MBLAmbientLightLTR329Integration300ms;
            break;
        case 6:
            ambientLightLTR329.integrationTime = MBLAmbientLightLTR329Integration350ms;
            break;
        default:
            ambientLightLTR329.integrationTime = MBLAmbientLightLTR329Integration400ms;
            break;
    }
    
    switch (self.ambientLightLTR329Measurement.selectedSegmentIndex) {
        case 0:
            ambientLightLTR329.measurementRate = MBLAmbientLightLTR329Rate50ms;
            break;
        case 1:
            ambientLightLTR329.measurementRate = MBLAmbientLightLTR329Rate100ms;
            break;
        case 2:
            ambientLightLTR329.measurementRate = MBLAmbientLightLTR329Rate200ms;
            break;
        case 3:
            ambientLightLTR329.measurementRate = MBLAmbientLightLTR329Rate500ms;
            break;
        case 4:
            ambientLightLTR329.measurementRate = MBLAmbientLightLTR329Rate1000ms;
            break;
        default:
            ambientLightLTR329.measurementRate = MBLAmbientLightLTR329Rate2000ms;
            break;
    }
    
    [self.streamingEvents addObject:ambientLightLTR329.periodicIlluminance];
    [ambientLightLTR329.periodicIlluminance startNotificationsWithHandler:^(MBLNumericData *obj, NSError *error) {
        self.ambientLightLTR329Illuminance.text = [NSString stringWithFormat:@"%.3f", obj.value.floatValue];
    }];
}


- (IBAction)ambientLightLTR329StopStreamPressed:(id)sender
{
    [self.ambientLightLTR329StartStream setEnabled:YES];
    [self.ambientLightLTR329StopStream setEnabled:NO];
    
    MBLAmbientLightLTR329 *ambientLightLTR329 = (MBLAmbientLightLTR329 *)self.device.ambientLight;
    [self.streamingEvents removeObject:ambientLightLTR329.periodicIlluminance];
    [ambientLightLTR329.periodicIlluminance stopNotifications];
    self.ambientLightLTR329Illuminance.text = @"X.XXX";
}



#pragma mark - kiwi


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
    self.sensorValues[@"ax"] = @0;
    self.sensorValues[@"ay"] = @0;
    self.sensorValues[@"az"] = @0;
    self.sensorValues[@"gx"] = @0;
    self.sensorValues[@"gy"] = @0;
    self.sensorValues[@"gz"] = @0;
}

// toggle button connection
- (void)connectKiwi:(BOOL)on
{
    //run sensorData function every time new data is available
    @try {
        
        //set sample rate at 50Hz
//        [[self.accelerometerBMI160Frequency titleForSegmentAtIndex:self.accelerometerBMI160Frequency.selectedSegmentIndex] floatValue];
//        [[self.gyroBMI160Frequency titleForSegmentAtIndex:self.gyroBMI160Frequency.selectedSegmentIndex] floatValue];
        
        // Programmatically do button press and change state.
        [self.accelerometerBMI160StartStream sendActionsForControlEvents:UIControlEventTouchUpInside];
        
        // Programmatical do button press again..
        [self.gyroBMI160StartStream sendActionsForControlEvents:UIControlEventTouchUpInside];
        
        //run onSensorData function
        NSLog(@"streaming sensor values");
    }
    @catch (NSException *exception) {
        NSLog(@"streaming error");
    }
}

@end
