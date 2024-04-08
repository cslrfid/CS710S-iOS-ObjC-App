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
    
    //NSString *postParams = [NSString stringWithFormat:@"{ \"email\": \"%@\", \"password\": \"%@\" }", email_address, password];
    //NSData *postData = [postParams dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    
    NSDictionary *headers = @{ @"Content-type": @"application/json"};
    [urlRequest setAllHTTPHeaderFields:headers];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:postData];
    
    __block BOOL done = NO;
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"Response: %@",response);
        NSLog(@"Data: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"Error: %@",error);
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
