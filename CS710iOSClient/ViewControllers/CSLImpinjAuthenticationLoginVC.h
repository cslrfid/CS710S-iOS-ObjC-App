//
//  CSLTagKillVC.h
//  CS710SiOSClient
//
//  Created by Lam Ka Shun on 2021-10-30.
//  Copyright © 2021 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLRfidAppEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSLImpinjAuthenticationLoginVC : UIViewController<CSLBleInterfaceDelegate, CSLBleReaderDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtUrl;
@property (weak, nonatomic) IBOutlet UITextField *txtEmailAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actAuthenticationLogin;


- (IBAction)btnLoginPressed:(id)sender;

@end

NS_ASSUME_NONNULL_END
