//
//  CSLInventoryVC.m
//  CS710SiOSClient
//
//  Created by Lam Ka Shun on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import "CSLImpinjInventoryVC.h"
#import <AudioToolbox/AudioToolbox.h>
#import "CSLImpinjAuthenticationVC.h"

@interface CSLImpinjInventoryVC ()
{
    NSTimer * scrRefreshTimer;
    NSTimer * scrBeepTimer;
    NSString* selectedEPC;
    NSString* selectedTID;
}

- (NSString*)bankEnumToString:(MEMORYBANK)bank;

@end

@implementation CSLImpinjInventoryVC

@synthesize btnInventory;
@synthesize tblTagList;
@synthesize lbStatus;
@synthesize lbClear;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tabBarController setTitle:@"Inventory"];
    
    btnInventory.layer.borderWidth=1.0f;
    btnInventory.layer.borderColor=[UIColor clearColor].CGColor;
    btnInventory.layer.cornerRadius=5.0f;
    
    tblTagList.estimatedRowHeight=45.0;
    tblTagList.rowHeight = UITableViewAutomaticDimension;
    
    selectedEPC = @"";
    selectedTID = @"";
    
}



//Selector for timer event on updating UI
- (void)refreshTagListing {
    @autoreleasepool {
        if ([CSLRfidAppEngine sharedAppEngine].reader.connectStatus==TAG_OPERATIONS)
        {
            //[[CSLRfidAppEngine sharedAppEngine] soundAlert:1005];
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
    
    [self setTitle:@"Impinj Authentication"];
    
    //clear UI
    [[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer removeAllObjects];
    
    tblTagList.dataSource=self;
    tblTagList.delegate=self;
    tblTagList.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tblTagList.bounds.size.width, 0.01f)];
    [tblTagList reloadData];
    
    [CSLRfidAppEngine sharedAppEngine].reader.delegate = self;
    [CSLRfidAppEngine sharedAppEngine].reader.readerDelegate=self;
    
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

    
    
    self.view.userInteractionEnabled=false;
    [self.actInventorySpinner startAnimating];

}

- (void)viewDidAppear:(BOOL)animated {
    // Do any additional setup after loading the view.
    [CSLReaderConfigurations setAntennaPortsAndPowerForTagAccess:false];
    [CSLReaderConfigurations setConfigurationsForClearAllSelectionsAndMultibanks];
    [CSLReaderConfigurations setConfigurationsForImpinjTags];
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
        [[CSLRfidAppEngine sharedAppEngine].reader E710StartSelectMBInventory];
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
    [[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer removeAllObjects];
    [tblTagList reloadData];
}

- (IBAction)btnClearTable:(id)sender {
    [self ClearTable];
}

- (IBAction)btnAuthenticationPressed:(id)sender {

    CSLImpinjAuthenticationVC* authVC;
    authVC = (CSLImpinjAuthenticationVC*)[[UIStoryboard storyboardWithName:@"CSLRfidDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_ImpinjAuthenticationVC"];
    
    if (authVC != nil)
    {
        authVC.selectedEPC = selectedEPC;
        authVC.selectedTID = selectedTID;
        [[self navigationController] pushViewController:authVC animated:YES];
    }
    
}

- (IBAction)btnProtectedModePressed:(id)sender {

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
              
        if (data1 != NULL && data2 != NULL ) {
            cell.lbCellEPC.text = [NSString stringWithFormat:@"%d \u25CF %@", (int)(indexPath.row + 1), epc];
            if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber == CS463)
                cell.lbCellBank.text= [NSString stringWithFormat:@"%@=%@\n%@=%@\nRSSI: %d | Port: %d", data1bank, data1, data2bank, data2, rssi, portNumber+1];
            else
                cell.lbCellBank.text= [NSString stringWithFormat:@"%@=%@\n%@=%@\nRSSI: %d", data1bank, data1, data2bank, data2, rssi];
        }
        else if (data1 != NULL) {
            cell.lbCellEPC.text = [NSString stringWithFormat:@"%d \u25CF %@", (int)(indexPath.row + 1), epc];
            cell.lbCellBank.text= [NSString stringWithFormat:@"%@=%@\nRSSI: %d", data1bank, data1, rssi];
            if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber == CS463)
                cell.lbCellBank.text= [NSString stringWithFormat:@"%@=%@\nRSSI: %d | Port: %d", data1bank, data1, rssi, portNumber+1];
            else
                cell.lbCellBank.text= [NSString stringWithFormat:@"%@=%@\nRSSI: %d", data1bank, data1, rssi];
        }
        else {
            cell.lbCellEPC.text = [NSString stringWithFormat:@"%d \u25CF %@", (int)(indexPath.row + 1), epc];
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

        cell.lbCellEPC.text = [NSString stringWithFormat:@"%d \u25CF %@", (int)(indexPath.row + 1), bc];
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
    
    if ([[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row] isKindOfClass:[CSLBleTag class]]) {
        //[CSLRfidAppEngine sharedAppEngine].tagSelected= ((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).EPC;
        selectedEPC = ((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).EPC;
        selectedTID = ((CSLBleTag*)[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer objectAtIndex:indexPath.row]).DATA1;
    }
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


