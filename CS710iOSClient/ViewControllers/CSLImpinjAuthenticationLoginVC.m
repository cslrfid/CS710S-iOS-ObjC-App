//
//  CSLTagKillVC.m
//  CS710SiOSClient
//
//  Created by Lam Ka Shun on 2021-10-30.
//  Copyright © 2021 Convergence Systems Limited. All rights reserved.
//

#import "CSLImpinjAuthenticationLoginVC.h"

@interface CSLImpinjAuthenticationLoginVC ()
{
    NSString* ApiErrorMessage;
}
@end

@implementation CSLImpinjAuthenticationLoginVC



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.btnLogin.layer.borderColor=[UIColor clearColor].CGColor;
    self.btnLogin.layer.cornerRadius=5.0f;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.txtUrl setDelegate:self];
    [self.txtPassword setDelegate:self];
    [self.txtEmailAddress setDelegate:self];
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


- (IBAction)btnLoginPressed:(id)sender {
    if ([self.txtEmailAddress.text isEqualToString:@""] || [self.txtPassword.text isEqualToString:@""]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Impinj Authentication" message:@"Invalid login information" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    self.view.userInteractionEnabled=false;
    [self.actAuthenticationLogin startAnimating];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
    
    [self ImpinjIasLogin:self.txtUrl.text emailAddress:self.txtEmailAddress.text password:self.txtPassword.text];
    
    if ([[CSLRfidAppEngine sharedAppEngine].settings.IasToken isEqualToString:@""] || [CSLRfidAppEngine sharedAppEngine].settings.IasTokenExpiry == 0) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Impinj Authentication" message:[NSString stringWithFormat:@"Login Failed: %@", ApiErrorMessage] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        //pop view model
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    self.view.userInteractionEnabled=true;
    [self.actAuthenticationLogin stopAnimating];
    
}

- (BOOL) ImpinjIasLogin:(NSString*)url emailAddress:(NSString*)email_address password:(NSString*)password {
    
    NSURLSessionConfiguration *defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration];
    
    NSURL *endpoint = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/auth/login", url]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:endpoint];
    
    //Make an NSDictionary that would be converted to an NSData object sent over as JSON with the request body
    NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:
                         email_address, @"email", password, @"password",
                         nil];
    
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    
    NSDictionary *headers = @{ @"Content-type": @"application/json"};
    [urlRequest setAllHTTPHeaderFields:headers];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:postData];
    
    __block BOOL done = NO;
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        if (httpResponse.statusCode == 200 && error == NULL) {
            [CSLRfidAppEngine sharedAppEngine].settings.IasToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Auth Token: %@",[CSLRfidAppEngine sharedAppEngine].settings.IasToken);
            //parse jwt and get expiry date
            NSArray *parts = [[CSLRfidAppEngine sharedAppEngine].settings.IasToken componentsSeparatedByString: @"."];
            //create NSData and put in the fill character "="
            NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:[NSString stringWithFormat:@"%@=", parts[1]] options:NSDataBase64DecodingIgnoreUnknownCharacters];
            NSString *decodedString = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];
            NSLog(@"Decoded token: %@", decodedString);
            NSDictionary  *object = [NSJSONSerialization
                                         JSONObjectWithData:decodeData
                                         options:0
                                         error:&error];

            if ([object objectForKey:@"exp"] != NULL) {
                [CSLRfidAppEngine sharedAppEngine].settings.IasTokenExpiry=[[object objectForKey:@"exp"] intValue];
                NSLog(@"Auth Token Expiry: %d",[CSLRfidAppEngine sharedAppEngine].settings.IasTokenExpiry);
                [CSLRfidAppEngine sharedAppEngine].settings.IasUrl = url;
                [[CSLRfidAppEngine sharedAppEngine] saveSettingsToUserDefaults];
            }
            else {
                [CSLRfidAppEngine sharedAppEngine].settings.IasToken = @"";
                [CSLRfidAppEngine sharedAppEngine].settings.IasTokenExpiry = 0;
                self->ApiErrorMessage = @"";
                
            }
        }
        else {
            NSLog(@"Authentication failed");
            [CSLRfidAppEngine sharedAppEngine].settings.IasToken = @"";
            [CSLRfidAppEngine sharedAppEngine].settings.IasTokenExpiry = 0;
            self->ApiErrorMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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
