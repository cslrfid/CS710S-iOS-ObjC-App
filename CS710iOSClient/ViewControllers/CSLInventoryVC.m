//
//  CSLInventoryVC.m
//  CS710SiOSClient
//
//  Created by Lam Ka Shun on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLInventoryVC.h"
#import <AudioToolbox/AudioToolbox.h>

@interface CSLInventoryVC ()
{
    NSTimer * scrRefreshTimer;
    NSTimer * scrBeepTimer;
    UISwipeGestureRecognizer* swipeGestureRecognizer;
    UIImageView *tempImageView;
    MQTTCFSocketTransport *transport;
    MQTTSession* session;
    BOOL isMQTTConnected;
}

- (NSString*)bankEnumToString:(MEMORYBANK)bank;

@end

@implementation CSLInventoryVC

@synthesize btnInventory;
@synthesize lbTagRate;
@synthesize lbUniqueTagRate;
@synthesize lbTagCount;
@synthesize tblTagList;
@synthesize lbStatus;
@synthesize lbClear;
@synthesize lbMode;
@synthesize uivSendTagData;
@synthesize lbElapsedTime;
@synthesize btnTagDisplay;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tabBarController setTitle:@"Inventory"];
    
    btnInventory.layer.borderWidth=1.0f;
    btnInventory.layer.borderColor=[UIColor clearColor].CGColor;
    btnInventory.layer.cornerRadius=5.0f;
    
    swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(handleSwipes:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeGestureRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:swipeGestureRecognizer];
    
    swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]
                              initWithTarget:self
                              action:@selector(handleSwipes:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    swipeGestureRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:swipeGestureRecognizer];
    
    tblTagList.estimatedRowHeight=45.0;
    tblTagList.rowHeight = UITableViewAutomaticDimension;
    
}

- (void)handleSwipes:(UISwipeGestureRecognizer*)gestureRecognizer {
    @autoreleasepool {
        
        if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==TAG_OPERATIONS)
            return;
        
        if ([[tempImageView accessibilityIdentifier] containsString:@"tagList-bg-rfid-swipe"]) {
            tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tagList-bg-barcode-swipe"]];
            [tempImageView setAccessibilityIdentifier:@"tagList-bg-barcode-swipe"];
            [tempImageView setFrame:self.tblTagList.frame];
            self.tblTagList.backgroundView = tempImageView;
            [[CSLRfidAppEngine sharedAppEngine] soundAlert:kSystemSoundID_Vibrate];
            [CSLRfidAppEngine sharedAppEngine].isBarcodeMode=true;
            lbMode.text=@"Mode: BC";
            [lbClear sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
        else {
            tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tagList-bg-rfid-swipe"]];
            [tempImageView setAccessibilityIdentifier:@"tagList-bg-rfid-swipe"];
            [tempImageView setFrame:self.tblTagList.frame];
            self.tblTagList.backgroundView = tempImageView;
            [[CSLRfidAppEngine sharedAppEngine] soundAlert:kSystemSoundID_Vibrate];
            [CSLRfidAppEngine sharedAppEngine].isBarcodeMode=false;
            lbMode.text=@"Mode: RFID";
            [lbClear sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}

//Selector for timer event on updating UI
- (void)refreshTagListing {
    @autoreleasepool {
        if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==TAG_OPERATIONS)
        {
            //[[CSLRfidAppEngine sharedAppEngine] soundAlert:1005];
            //update table
            [tblTagList reloadData];
            
            //update inventory count
            lbTagCount.text=[NSString stringWithFormat: @"%ld", (long)[tblTagList numberOfRowsInSection:0]];
            
            //update tag rate
            NSLog(@"Total Tag Count: %ld, Unique Tag Coun t: %ld, time elapsed: %ld, reader tag rate: %ld",
                  ((long)[CSLRfidAppEngine sharedAppEngine].reader.rangingTagCount),
                  ((long)[CSLRfidAppEngine sharedAppEngine].reader.uniqueTagCount),
                  (long)[[NSDate date] timeIntervalSinceDate:tagRangingStartTime],
                  ((long)[CSLRfidAppEngine sharedAppEngine].reader.readerTagRate));
            if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber == CS710)
                lbTagRate.text = [NSString stringWithFormat: @"%ld", ((long)[CSLRfidAppEngine sharedAppEngine].reader.readerTagRate)];
            else
                lbTagRate.text = [NSString stringWithFormat: @"%ld", ((long)[CSLRfidAppEngine sharedAppEngine].reader.rangingTagCount)];
            lbUniqueTagRate.text = [NSString stringWithFormat: @"%ld", ((long)[CSLRfidAppEngine sharedAppEngine].reader.uniqueTagCount)];
            [CSLRfidAppEngine sharedAppEngine].reader.rangingTagCount =0;
            [CSLRfidAppEngine sharedAppEngine].reader.uniqueTagCount =0;
            
            //incrememt elapse time
            lbElapsedTime.text = [NSString stringWithFormat: @"%.1f", [lbElapsedTime.text doubleValue] + 0.2];
            
        }
        else if ([CSLRfidAppEngine sharedAppEngine].isBarcodeMode) {
            //update table
            [tblTagList reloadData];
        }
            
        self.lbStatus.text=[NSString stringWithFormat:@"Battery: %d%%", [CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage];
        
        if ([CSLRfidAppEngine sharedAppEngine].reader.lastMacErrorCode != 0x0000)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"RFID Error"
                                                                           message:[NSString stringWithFormat:@"Error Code: 0x%04X", [CSLRfidAppEngine sharedAppEngine].reader.lastMacErrorCode]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            [CSLRfidAppEngine sharedAppEngine].reader.lastMacErrorCode=0x0000;
        }
    }
}

- (void)playBeepSound {
    @autoreleasepool {
        if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==TAG_OPERATIONS)
        {
            [[CSLRfidAppEngine sharedAppEngine] soundAlert:1005];
        }
    }
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tabBarController setTitle:@"Inventory"];
    
    //clear UI
    lbTagRate.text=@"0";
    lbTagCount.text=@"0";
    [[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer removeAllObjects];
    
    tblTagList.dataSource=self;
    tblTagList.delegate=self;
    tblTagList.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tblTagList.bounds.size.width, 0.01f)];
    [tblTagList reloadData];
    
    [CSLRfidAppEngine sharedAppEngine].reader.delegate = self;
    [CSLRfidAppEngine sharedAppEngine].reader.readerDelegate=self;
    
    tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tagList-bg-rfid-swipe"]];
    [tempImageView setAccessibilityIdentifier:@"tagList-bg-rfid-swipe"];
    [tempImageView setFrame:self.tblTagList.frame];
    self.tblTagList.backgroundView = tempImageView;
    
    //timer event on updating UI
    scrRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:[CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber==CS710 ? 0.2 : 1.0
                                                       target:self
                                                     selector:@selector(refreshTagListing)
                                                     userInfo:nil
                                                      repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:scrRefreshTimer forMode:NSRunLoopCommonModes];
    
    //timer event on beeping during tag read
    
    scrBeepTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                    target:self
                                                  selector:@selector(playBeepSound)
                                                  userInfo:nil
                                                   repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:scrBeepTimer forMode:NSRunLoopCommonModes];

    
    if ([CSLRfidAppEngine sharedAppEngine].MQTTSettings.isMQTTEnabled) {
        transport = [[MQTTCFSocketTransport alloc] init];
        transport.host = [CSLRfidAppEngine sharedAppEngine].MQTTSettings.brokerAddress;
        transport.port = [CSLRfidAppEngine sharedAppEngine].MQTTSettings.brokerPort;
        transport.tls = [CSLRfidAppEngine sharedAppEngine].MQTTSettings.isTLSEnabled;
        
        session = [[MQTTSession alloc] init];
        session.transport = transport;
        session.userName=[CSLRfidAppEngine sharedAppEngine].MQTTSettings.userName;
        session.password=[CSLRfidAppEngine sharedAppEngine].MQTTSettings.password;
        session.keepAliveInterval = 60;
        session.clientId=[CSLRfidAppEngine sharedAppEngine].MQTTSettings.clientId;
        session.willFlag=true;
        session.willMsg=[@"offline" dataUsingEncoding:NSUTF8StringEncoding];
        session.willTopic=[NSString stringWithFormat:@"devices/%@/messages/events/", session.clientId];
        session.willQoS=[CSLRfidAppEngine sharedAppEngine].MQTTSettings.QoS;
        session.willRetainFlag=[CSLRfidAppEngine sharedAppEngine].MQTTSettings.retained;
        
        [self->uivSendTagData setHidden:false];
        
        [session connectWithConnectHandler:^(NSError *error) {
            if (error == nil) {
                NSLog(@"Connected to MQTT Broker");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"MQTT broker" message:@"Connected" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
                self->isMQTTConnected=true;
            }
            else {
                NSLog(@"Fail connecting to MQTT Broker");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"MQTT broker" message:[NSString stringWithFormat:@"Error: %@", error.debugDescription] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
                self->isMQTTConnected=false;
            }
        }];
    }
    else {
                [self->uivSendTagData setHidden:true];
    }
    
    self.view.userInteractionEnabled=false;
    [self.actInventorySpinner startAnimating];

}

- (void)viewDidAppear:(BOOL)animated {
    // Do any additional setup after loading the view.
    [CSLReaderConfigurations setAntennaPortsAndPowerForTags:false];
    [CSLReaderConfigurations setConfigurationsForClearAllSelectionsAndMultibanks];
    [CSLReaderConfigurations setConfigurationsForTags:self.swLEDTag.isOn];
    self.view.userInteractionEnabled=true;
    [self.actInventorySpinner stopAnimating];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self.actInventorySpinner stopAnimating];
    self.view.userInteractionEnabled=true;
    
    //stop inventory if it is still running
    if (btnInventory.enabled)
    {
        if ([[btnInventory currentTitle] isEqualToString:@"Stop"])
            [btnInventory sendActionsForControlEvents:UIControlEventTouchUpInside];

    }
    
    //remove delegate assignment so that trigger key will not triggered when out of this page
    [CSLRfidAppEngine sharedAppEngine].reader.delegate = nil;
    [CSLRfidAppEngine sharedAppEngine].reader.readerDelegate=nil;
    
    tblTagList.dataSource=nil;
    tblTagList.delegate=nil;
    
    [scrRefreshTimer invalidate];
    scrRefreshTimer=nil;
    
    [scrBeepTimer invalidate];
    scrBeepTimer=nil;
    
    [CSLRfidAppEngine sharedAppEngine].isBarcodeMode=false;
    [self.view removeGestureRecognizer:swipeGestureRecognizer];
    
    [session disconnect];
    [transport close];
    session=nil;
    transport=nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnInventoryPressed:(id)sender {
    
    if ([CSLRfidAppEngine sharedAppEngine].isBarcodeMode && [[btnInventory currentTitle] isEqualToString:@"Start"]) {
        [[CSLRfidAppEngine sharedAppEngine] soundAlert:1033];
        btnInventory.enabled=false;
        
        [[CSLRfidAppEngine sharedAppEngine].reader startBarcodeReading];
        [btnInventory setTitle:@"Stop" forState:UIControlStateNormal];
        btnInventory.enabled=true;
        
    }
    else if ([CSLRfidAppEngine sharedAppEngine].isBarcodeMode && [[btnInventory currentTitle] isEqualToString:@"Stop"]) {
        [[CSLRfidAppEngine sharedAppEngine] soundAlert:1033];
        btnInventory.enabled=false;
        
        [[CSLRfidAppEngine sharedAppEngine].reader stopBarcodeReading];
        [btnInventory setTitle:@"Start" forState:UIControlStateNormal];
        btnInventory.enabled=true;
    }
    else if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==CONNECTED && [[btnInventory currentTitle] isEqualToString:@"Start"])
    {
        [[CSLRfidAppEngine sharedAppEngine] soundAlert:1033];
        btnInventory.enabled=false;

        //start inventory
        [CSLRfidAppEngine sharedAppEngine].reader.readerTagRate = 0;
        tagRangingStartTime=[NSDate date];
        
        //For CS710S, there are four inventory mode here:
        // 1) Regular inventory at high speed (startInventory)
        // 2) Mulitbank inventory with filtering (E710StartSelectMBInventory)
        // 3) Mulitbank inventory with no filtering (E710StartMBInventory)
        // 4) Single bank inventory with filtering (E710StartSelectCompactInventory)
        [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:false];
        if (self.swLEDTag.isOn && 
            [CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber == CS710) {
            [[CSLRfidAppEngine sharedAppEngine].reader E710StartSelectMBInventory];
        }
        else if ([CSLRfidAppEngine sharedAppEngine].settings.isMultibank1Enabled &&
                 [CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber == CS710 &&
                 [CSLRfidAppEngine sharedAppEngine].settings.prefilterIsEnabled) {
            [[CSLRfidAppEngine sharedAppEngine].reader E710StartSelectMBInventory];
        }
        else if ([CSLRfidAppEngine sharedAppEngine].settings.isMultibank1Enabled &&
            [CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber == CS710)
            [[CSLRfidAppEngine sharedAppEngine].reader E710StartMBInventory];
        else if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber == CS710 &&
                 [CSLRfidAppEngine sharedAppEngine].settings.prefilterIsEnabled) {
            [[CSLRfidAppEngine sharedAppEngine].reader E710StartSelectCompactInventory];
        }
        else
            [[CSLRfidAppEngine sharedAppEngine].reader startInventory];
        [btnInventory setTitle:@"Stop" forState:UIControlStateNormal];
        btnInventory.enabled=true;
    }
    else if ([[btnInventory currentTitle] isEqualToString:@"Stop"])
    {
        [[CSLRfidAppEngine sharedAppEngine] soundAlert:1033];
        if([[CSLRfidAppEngine sharedAppEngine].reader stopInventory])
        {
            [btnInventory setTitle:@"Start" forState:UIControlStateNormal];
            btnInventory.enabled=true;
            [[CSLRfidAppEngine sharedAppEngine].reader setPowerMode:true];
        }
        else
        {
            [btnInventory setTitle:@"Stop" forState:UIControlStateNormal];
            btnInventory.enabled=true;
        }
    }
    
    
}

- (void)ClearTable {
    //clear UI
    lbTagRate.text=@"0";
    lbTagCount.text=@"0";
    lbElapsedTime.text=@"0";
    lbUniqueTagRate.text=@"0";
    [[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer removeAllObjects];
    [tblTagList reloadData];
}

- (IBAction)btnClearTable:(id)sender {
    [self ClearTable];
}

- (IBAction)swLEDTagToggled:(id)sender {
    self.view.userInteractionEnabled=false;
    [self.actInventorySpinner startAnimating];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
    //[CSLReaderConfigurations setAntennaPortsAndPowerForTags:false];
    [CSLReaderConfigurations setConfigurationsForClearAllSelectionsAndMultibanks];
    [CSLReaderConfigurations setConfigurationsForTags:self.swLEDTag.isOn];
    self.view.userInteractionEnabled=true;
    [self.actInventorySpinner stopAnimating];
}

- (IBAction)btnTagDispalyPressed:(id)sender {
   if ([[self->btnTagDisplay currentTitle] containsString:@"HEX"]) {
       [self ClearTable];
       [btnTagDisplay setTitle:@"Display: ASCII" forState:UIControlStateNormal];
   }
   else {
       [self ClearTable];
       [btnTagDisplay setTitle:@"Display: HEX" forState:UIControlStateNormal];
   }
   
}

- (IBAction)btnSaveData:(id)sender {
    bool IsAsciiDisplay = [[self->btnTagDisplay currentTitle] containsString:@"ASCII"];
    
    NSString* fileContent = @"TIMESTAMP,EPC,DATA1,DATA2,RSSI\n";

    for (CSLBleTag* tag in [CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer) {
        
        //tag read timestamp
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/YY HH:mm:ss"];
        NSDate* date=tag.timestamp;
        NSString *stringFromDate = [dateFormatter stringFromDate:date];
        

        fileContent=[fileContent stringByAppendingString:[NSString stringWithFormat:@"%@,%@,%@,%@,%@\n", stringFromDate, (IsAsciiDisplay ? [CSLReaderBarcode convertHexStringToAscii:tag.EPC] : tag.EPC), (IsAsciiDisplay ? [CSLReaderBarcode convertHexStringToAscii:tag.DATA1] : tag.DATA1), (IsAsciiDisplay ? [CSLReaderBarcode convertHexStringToAscii:tag.DATA2] : tag.DATA2), [NSString stringWithFormat:@"%d",tag.rssi]]];
    }
    
    NSArray *objectsToShare = @[fileContent];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
    
}

- (IBAction)btnSendTagData:(id)sender {
    //check MQTT settings.  Connect to broker and send tag data
    __block BOOL allTagPublishedSuccess=true;
    if ([CSLRfidAppEngine sharedAppEngine].MQTTSettings.isMQTTEnabled && isMQTTConnected==true) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"MQTT broker" message:@"Send Tag Data?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            for (CSLBleTag* tag in [CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer) {
                //build an info object and convert to json
                NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [[NSUUID UUID] UUIDString],
                                      @"messageId",
                                      [NSString stringWithFormat:@"%d",tag.rssi],
                                      @"rssi",
                                      tag.EPC,
                                      @"EPC",
                                      nil];
                
                NSError * err;
                NSData * jsonData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&err];
                BOOL retain=[CSLRfidAppEngine sharedAppEngine].MQTTSettings.retained;
                MQTTQosLevel level=[CSLRfidAppEngine sharedAppEngine].MQTTSettings.QoS;
                NSString* topic=[NSString stringWithFormat:@"devices/%@/messages/events/", self->session.clientId];
                
                [self->session publishData:jsonData onTopic:topic retain:retain qos:level publishHandler:^(NSError *error) {
                    if (error != nil) {
                        NSLog(@"Failed sending EPC=%@ to MQTT broker. Error message: %@", tag.EPC, error.debugDescription);
                        allTagPublishedSuccess=false;
                    }
                }];
            }
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

- (void) didInterfaceChangeConnectStatus: (CSLBleInterface *) sender {
    
}

- (void) didReceiveTagResponsePacket: (CSLBleReader *) sender tagReceived:(CSLBleTag*)tag {
    //[tagListing reloadData];
}
- (void) didReceiveTagAccessData: (CSLBleReader *) sender tagReceived:(CSLBleTag*)tag {
    //no used
}

- (void) didReceiveBatteryLevelIndicator: (CSLBleReader *) sender batteryPercentage:(int)battPct {
    [CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage=battPct; 
}

- (void) didTriggerKeyChangedState: (CSLBleReader *) sender keyState:(BOOL)state {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->btnInventory.enabled)
        {
            if (state) {
                if ([[self->btnInventory currentTitle] isEqualToString:@"Start"])
                    [self->btnInventory sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            else {
                if ([[self->btnInventory currentTitle] isEqualToString:@"Stop"])
                    [self->btnInventory sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
    });
}


- (void) didReceiveBarcodeData: (CSLBleReader *) sender scannedBarcode:(CSLReaderBarcode*)barcode {
    [[CSLRfidAppEngine sharedAppEngine] soundAlert:1005];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    bool IsAsciiDisplay = [[self->btnTagDisplay currentTitle] containsString:@"ASCII"];
    CSLTagListCell * cell;
    //for rfid data
    if ([[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row] isKindOfClass:[CSLBleTag class]]) {
        
        NSString* epc=((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).EPC;
        NSString* data1=((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).DATA1;
        NSString* data1bank=[self bankEnumToString:[CSLRfidAppEngine sharedAppEngine].settings.multibank1];
        NSString* data2=((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).DATA2;
        NSString* data2bank=[self bankEnumToString:[CSLRfidAppEngine sharedAppEngine].settings.multibank2];
        int rssi=(int)((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).rssi;
        int portNumber=((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).portNumber;
        
        cell=[tableView dequeueReusableCellWithIdentifier:@"TagCell"];
        if (cell == nil) {
            [tableView registerNib:[UINib nibWithNibName:@"CSLTagListCell" bundle:nil] forCellReuseIdentifier:@"TagCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"TagCell"];
        }
              
        if (data1 != NULL && data2 != NULL && !self.swLEDTag.isOn ) {
            cell.lbCellEPC.text = [NSString stringWithFormat:@"%d \u25CF %@", (int)(indexPath.row + 1), (IsAsciiDisplay ? [CSLReaderBarcode convertHexStringToAscii:epc] : epc)];
            if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber == CS463)
                cell.lbCellBank.text= [NSString stringWithFormat:@"%@=%@\n%@=%@\nRSSI: %d | Port: %d", data1bank, (IsAsciiDisplay ? [CSLReaderBarcode convertHexStringToAscii:data1] : data1), data2bank, (IsAsciiDisplay ? [CSLReaderBarcode convertHexStringToAscii:data2] : data2), rssi, portNumber+1];
            else
                cell.lbCellBank.text= [NSString stringWithFormat:@"%@=%@\n%@=%@\nRSSI: %d", data1bank, (IsAsciiDisplay ? [CSLReaderBarcode convertHexStringToAscii:data1] : data1), data2bank, (IsAsciiDisplay ? [CSLReaderBarcode convertHexStringToAscii:data2] : data2), rssi];
        }
        else if (data1 != NULL && !self.swLEDTag.isOn ) {
            cell.lbCellEPC.text = [NSString stringWithFormat:@"%d \u25CF %@", (int)(indexPath.row + 1), (IsAsciiDisplay ? [CSLReaderBarcode convertHexStringToAscii:epc] : epc)];
            cell.lbCellBank.text= [NSString stringWithFormat:@"%@=%@\nRSSI: %d", data1bank, (IsAsciiDisplay ? [CSLReaderBarcode convertHexStringToAscii:data1] : data1), rssi];
            if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber == CS463)
                cell.lbCellBank.text= [NSString stringWithFormat:@"%@=%@\nRSSI: %d | Port: %d", data1bank, (IsAsciiDisplay ? [CSLReaderBarcode convertHexStringToAscii:data1] : data1), rssi, portNumber+1];
            else
                cell.lbCellBank.text= [NSString stringWithFormat:@"%@=%@\nRSSI: %d", data1bank, (IsAsciiDisplay ? [CSLReaderBarcode convertHexStringToAscii:data1] : data1), rssi];
        }
        else {
            cell.lbCellEPC.text = [NSString stringWithFormat:@"%d \u25CF %@", (int)(indexPath.row + 1), (IsAsciiDisplay ? [CSLReaderBarcode convertHexStringToAscii:epc] : epc)];
            if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber == CS463)
                cell.lbCellBank.text= [NSString stringWithFormat:@"RSSI: %d | Port: %d", rssi, portNumber+1];
            else
                cell.lbCellBank.text= [NSString stringWithFormat:@"RSSI: %d", rssi];
            
        }
    }
    //for barcode data
    else if ([[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row] isKindOfClass:[CSLReaderBarcode class]]) {
        NSString* bc=((CSLReaderBarcode*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).barcodeValue;

        cell=[tableView dequeueReusableCellWithIdentifier:@"TagCell"];
        if (cell == nil) {
            [tableView registerNib:[UINib nibWithNibName:@"CSLTagListCell" bundle:nil] forCellReuseIdentifier:@"TagCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"TagCell"];
        }

        cell.lbCellEPC.text = [NSString stringWithFormat:@"%d \u25CF %@", (int)(indexPath.row + 1), (IsAsciiDisplay ? [CSLReaderBarcode convertHexStringToAscii:bc] : bc)];
        cell.lbCellBank.text= [NSString stringWithFormat:@"[%@]", ((CSLReaderBarcode*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).codeId];
        
    }
    else
        return nil;
    
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row] isKindOfClass:[CSLBleTag class]])
        [CSLRfidAppEngine sharedAppEngine].tagSelected= ((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).EPC;
    else if ([[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row] isKindOfClass:[CSLReaderBarcode class]])
        [CSLRfidAppEngine sharedAppEngine].tagSelected= ((CSLReaderBarcode*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).barcodeValue;
    else
        [CSLRfidAppEngine sharedAppEngine].tagSelected=@"";
        
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tag Selected" message:[CSLRfidAppEngine sharedAppEngine].tagSelected  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSString*)bankEnumToString:(MEMORYBANK)bank {
    NSString *result = nil;
    
    switch(bank) {
        case RESERVED:
            result = @"RESERVED";
            break;
        case EPC:
            result = @"EPC";
            break;
        case TID:
            result = @"TID";
            break;
        case USER:
            result = @"USER";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected FormatType."];
    }
    
    return result;
}

@end


