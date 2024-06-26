//
//  CSLTagKillVC.m
//  CS710SiOSClient
//
//  Created by Lam Ka Shun on 2021-10-30.
//  Copyright © 2021 Convergence Systems Limited. All rights reserved.
//

#import "CSLImpinjAuthenticationVC.h"
#import "CSLImpinjAuthenticationLoginVC.h"

@interface CSLImpinjAuthenticationVC ()
{
    BOOL tagValidation;
}
@end

@implementation CSLImpinjAuthenticationVC

@synthesize btnIASStatus;
@synthesize imgIASStatus;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.btnVerify.layer.borderColor=[UIColor clearColor].CGColor;
    self.btnVerify.layer.cornerRadius=5.0f;
    
    self.btnIASStatus.layer.borderColor=[UIColor clearColor].CGColor;
    self.btnIASStatus.layer.cornerRadius=5.0f;
    
    self.btnIASConfiguration.layer.borderColor=[UIColor clearColor].CGColor;
    self.btnIASConfiguration.layer.cornerRadius=5.0f;
    
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

- (IBAction)btnIASConfigurationPressed:(id)sender {
    CSLImpinjAuthenticationLoginVC* loginVC;
    loginVC = (CSLImpinjAuthenticationLoginVC*)[[UIStoryboard storyboardWithName:@"CSLRfidDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_ImpinjAuthenticationLoginVC"];
    
    if (loginVC != nil)
    {
        [[self navigationController] pushViewController:loginVC animated:YES];
    }
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
    
//    [self ImpinjIasAuthenticate:[CSLRfidAppEngine sharedAppEngine].settings.IasUrl
//                            TID:@"e2c0e52320004000e9fbd3a3" challenge:@"023beea5f4f7" tagResponse:@"5781d0fed5119d7d"];
//    [self->imgIASStatus setImage:[UIImage imageNamed:@"verified-box"]];
//    [self->btnIASStatus setBackgroundColor:UIColorFromRGB(0x26A65B)];
//    [self->btnIASStatus setTitle:@"VALID" forState:UIControlStateNormal];
    
    if ([self.txtSelectedEPC.text isEqualToString:@""] || [self.txtSelectedTID.text isEqualToString:@""]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Impinj Authentication" message:@"No EPC/TID information" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [self.imgIASStatus setImage:[UIImage imageNamed:@"unknown-box"]];
    [self.btnIASStatus setBackgroundColor:UIColorFromRGB(0xA3A3A3)];
    [self.btnIASStatus setTitle:@"UNKNOWN" forState:UIControlStateNormal];
    self.view.userInteractionEnabled=false;
    [self.actIASVerifyIndicator startAnimating];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
    
    UInt32 accPwd=0;
    NSScanner* scanner = [NSScanner scannerWithString:[self.txtAccessPwd text]];
    [scanner scanHexInt:&accPwd];
    
    //select tag
    if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber==CS710) {
        if (![[CSLRfidAppEngine sharedAppEngine].reader E710SelectTag:0
                                                        maskBank:EPC
                                                     maskPointer:32
                                                      maskLength:[[self.txtSelectedEPC text] length] * 4
                                                        maskData:[CSLBleReader convertHexStringToData:[self.txtSelectedEPC text]]
                                                          target:4
                                                          action:0
                                                     postConfigDelay:0]) {
            
            
            self.view.userInteractionEnabled=true;
            [self.actIASVerifyIndicator stopAnimating];
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Impinj Authentication" message:@"Unable to seledct tag" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        
        
        //set authetnication registers
        if (![[CSLRfidAppEngine sharedAppEngine].reader setImpinjAuthentication:accPwd
                                                                   sendRep:1
                                                                 incRepLen:1
                                                                       csi:1 
                                                             messageLength:0x30
                                                       authenticateMessage:[CSLBleReader convertHexStringToData:@"009CA53E55EA"]
                                                                   responseLen:0x40]) {
            self.view.userInteractionEnabled=true;
            [self.actIASVerifyIndicator stopAnimating];
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Impinj Authentication" message:@"Unable to set Impinj authentication config" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            return;
            
        }
        
        if(![[CSLRfidAppEngine sharedAppEngine].reader E710SCSLRFIDAuthenticate]) {
            self.view.userInteractionEnabled=true;
            [self.actIASVerifyIndicator stopAnimating];
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Impinj Authentication" message:@"Unable to start Impinj authentication" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        self.view.userInteractionEnabled=true;
        [self.actIASVerifyIndicator stopAnimating];
        
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
    
    self.txtSelectedEPC.text = self.selectedEPC;
    self.txtSelectedTID.text = self.selectedTID;
    
    NSDate *now = [NSDate date];
    NSTimeInterval nowEpochSeconds = [now timeIntervalSince1970];
    
    if ([[CSLRfidAppEngine sharedAppEngine].settings.IasToken isEqualToString:@""]) {
        [self.btnIASConfiguration setTitle:@"IAS Login" forState:UIControlStateNormal];
        [self.btnVerify setEnabled:false];
    }
    else if (nowEpochSeconds > [CSLRfidAppEngine sharedAppEngine].settings.IasTokenExpiry &&
             [CSLRfidAppEngine sharedAppEngine].settings.IasTokenExpiry != 0) {
        //Clear token
        [CSLRfidAppEngine sharedAppEngine].settings.IasToken = @"";
        [CSLRfidAppEngine sharedAppEngine].settings.IasTokenExpiry = 0;
        [[CSLRfidAppEngine sharedAppEngine] saveSettingsToUserDefaults];
        
        [self.btnIASConfiguration setTitle:@"IAS Login" forState:UIControlStateNormal];
        [self.btnVerify setEnabled:false];
    }
    else  {
        [self.btnIASConfiguration setTitle:@"IAS Ready" forState:UIControlStateNormal];
        [self.btnVerify setEnabled:true];
    }

}

- (void) didInterfaceChangeConnectStatus: (CSLBleInterface *) sender {
    
}

- (void) didReceiveTagResponsePacket: (CSLBleReader *) sender tagReceived:(CSLBleTag*)tag {
    
}
- (void) didReceiveTagAccessData:(CSLBleReader *)sender tagReceived:(CSLBleTag *)tag {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (tag.DATA == NULL) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Impinj Authentication" message:@"No Authentication Response" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else if (tag.AccessError == 0x10 && tag.BackScatterError == 0x00) {
            
            //verify against IAS service
            
            [self ImpinjIasAuthenticate:[CSLRfidAppEngine sharedAppEngine].settings.IasUrl
                                    TID:@"e2c0e52320004000e9fbd3a3" challenge:@"023beea5f4f7" tagResponse:@"5781d0fed5119d7d"];
            
            if (self->tagValidation) {
                [self->imgIASStatus setImage:[UIImage imageNamed:@"verified-box"]];
                [self->btnIASStatus setBackgroundColor:UIColorFromRGB(0x26A65B)];
                [self->btnIASStatus setTitle:@"VALID" forState:UIControlStateNormal];
            }
            else {
                [self->imgIASStatus setImage:[UIImage imageNamed:@"invalid-box"]];
                [self->btnIASStatus setBackgroundColor:UIColorFromRGB(0xd63031)];
                [self->btnIASStatus setTitle:@"INVALID" forState:UIControlStateNormal];
            }
        }
    });
    
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


- (BOOL) ImpinjIasAuthenticate:(NSString*)url TID:(NSString*)tid challenge:(NSString*)challenge tagResponse:(NSString*)tag_response {
    
    NSURLSessionConfiguration *defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration];
    
    NSURL *endpoint = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/ImpinjAuthentication/authenticate", url]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:endpoint];
    
    //Make an NSDictionary that would be converted to an NSData object sent over as JSON with the request body
    NSDictionary *tagVerifyObject = [[NSDictionary alloc] initWithObjectsAndKeys:
                         tid, @"tid", challenge, @"challenge", tag_response, @"tagResponse",
                         nil];
    
    NSDictionary *postObject = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSArray arrayWithObjects:tagVerifyObject, nil], @"tagVerify", @YES, @"sendSignature", @YES, @"sendSalt", @YES, @"sendTime",
                         nil];
    
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postObject options:0 error:&error];
    
    NSDictionary *headers = @{ @"Content-type": @"application/json",
                               @"Authorization": [NSString stringWithFormat:@"Bearer %@", [CSLRfidAppEngine sharedAppEngine].settings.IasToken]};
    [urlRequest setAllHTTPHeaderFields:headers];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:postData];
    
    __block BOOL done = NO;
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        if (httpResponse.statusCode == 200 && error == NULL) {
            NSLog(@"Auth response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            
            //Check result
            NSDictionary  *object = [NSJSONSerialization
                                         JSONObjectWithData:data
                                         options:0
                                         error:&error];

            if ([object objectForKey:@"tagValidity"] != NULL) {
                if ([((NSArray*)[object objectForKey:@"tagValidity"])[0] objectForKey:@"tagValid"]) {
                    self->tagValidation = true;
                }
                else {
                    self->tagValidation = false;
                }
                NSLog(@"%@", [NSString stringWithFormat:@"Tag valid: %s", (self->tagValidation ? "true" : "false")]);
                
            }
                
            
        }
        else {
            NSLog(@"Authentication failed");
        }
            
        done = YES;
    }];
    [dataTask resume];

    while (!done) {
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:0.1];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    return true;
}
@end
