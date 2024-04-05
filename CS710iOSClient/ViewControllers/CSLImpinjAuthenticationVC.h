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

@interface CSLImpinjAuthenticationVC : UIViewController<CSLBleInterfaceDelegate, CSLBleReaderDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtSelectedEPC;
@property (weak, nonatomic) IBOutlet UITextField *txtSelectedTID;
@property (weak, nonatomic) IBOutlet UITextField *txtAccessPwd;
@property (weak, nonatomic) IBOutlet UIButton *btnVerify;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actIASVerifyIndicator;
@property (weak, nonatomic) IBOutlet UIButton *btnIASStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imgIASStatus;

@property (nonatomic, strong) NSString* selectedEPC;
@property (nonatomic, strong) NSString* selectedTID;

- (IBAction)btnVerifyPressed:(id)sender;
- (IBAction)txtAccessPwdEditied:(id)sender;
- (IBAction)txtSelectedEPCEdited:(id)sender;
- (IBAction)txtSelectedTIDEdited:(id)sender;
- (IBAction)btnIasConfigurations:(id)sender;

@end

NS_ASSUME_NONNULL_END
