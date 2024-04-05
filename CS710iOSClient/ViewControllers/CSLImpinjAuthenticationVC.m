//
//  CSLTagKillVC.m
//  CS710SiOSClient
//
//  Created by Lam Ka Shun on 2021-10-30.
//  Copyright © 2021 Convergence Systems Limited. All rights reserved.
//

#import "CSLImpinjAuthenticationVC.h"

@interface CSLImpinjAuthenticationVC ()
{
}
@end

@implementation CSLImpinjAuthenticationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.btnVerify.layer.borderColor=[UIColor clearColor].CGColor;
    self.btnVerify.layer.cornerRadius=5.0f;
    
    self.txtSelectedEPC.text = self.selectedEPC;
    self.txtSelectedTID.text = self.selectedTID;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)txtSelectedEPCEdited:(id)sender {
    //Validate if input is hex value
    NSCharacterSet *chars = [[NSCharacterSet
                              characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
    if (([[self.txtSelectedEPC.text uppercaseString] rangeOfCharacterFromSet:chars].location != NSNotFound)) {
        self.txtSelectedEPC.text = @"";
    }
}

- (IBAction)txtAccessPwdEditied:(id)sender {
    //Validate if input is hex value
    NSCharacterSet *chars = [[NSCharacterSet
                              characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
    if (([[self.txtAccessPwd.text uppercaseString] rangeOfCharacterFromSet:chars].location != NSNotFound) || [self.txtAccessPwd.text length] != 8) {
        self.txtAccessPwd.text = @"00000000";
    }
}

- (IBAction)btnIasConfigurations:(id)sender {
}

- (IBAction)txtSelectedTIDEdited:(id)sender {
    //Validate if input is hex value
    NSCharacterSet *chars = [[NSCharacterSet
                              characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
    if (([[self.txtSelectedEPC.text uppercaseString] rangeOfCharacterFromSet:chars].location != NSNotFound)) {
        self.txtSelectedEPC.text = @"";
    }
}

- (IBAction)btnVerifyPressed:(id)sender {
    
    if ([self.txtSelectedEPC.text isEqualToString:@""] || [self.txtSelectedTID.text isEqualToString:@""]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Impinj Authentication" message:@"No EPC Selected" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![[CSLRfidAppEngine sharedAppEngine].tagSelected isEqualToString:@""]) {
        self.txtSelectedEPC.text=[CSLRfidAppEngine sharedAppEngine].tagSelected;
    }
    
    [self.txtSelectedEPC setDelegate:self];
    [self.txtAccessPwd setDelegate:self];
    
    [CSLRfidAppEngine sharedAppEngine].reader.delegate = self;
    [CSLRfidAppEngine sharedAppEngine].reader.readerDelegate=self;

}

- (void) didInterfaceChangeConnectStatus: (CSLBleInterface *) sender {
    
}

- (void) didReceiveTagResponsePacket: (CSLBleReader *) sender tagReceived:(CSLBleTag*)tag {
    
}
- (void) didReceiveTagAccessData:(CSLBleReader *)sender tagReceived:(CSLBleTag *)tag {
    
}

- (void) didReceiveBatteryLevelIndicator: (CSLBleReader *) sender batteryPercentage:(int)battPct {
    [CSLRfidAppEngine sharedAppEngine].readerInfo.batteryPercentage=battPct;
}

- (void) didTriggerKeyChangedState: (CSLBleReader *) sender keyState:(BOOL)state {

}

- (void) didReceiveBarcodeData: (CSLBleReader *) sender scannedBarcode:(CSLReaderBarcode*)barcode {
    
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}



@end
