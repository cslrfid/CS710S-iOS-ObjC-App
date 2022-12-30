//
//  CSLHomeVC.h
//  CS710iOSClient
//
//  Created by Lam Ka Shun on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLRfidAppEngine.h"

@interface CSLHomeVC : UIViewController<CSLBleReaderDelegate>

- (IBAction)btnInventoryPressed:(id)sender;
- (IBAction)btnSettingsPressed:(id)sender;
- (IBAction)btnConnectReaderPressed:(id)sender;
- (IBAction)btnAboutPressed:(id)sender;
- (IBAction)btnTagAccessPressed:(id)sender;
- (IBAction)btnTagSearchPressed:(id)sender;
- (IBAction)btnFunctionsPressed:(id)sender;
- (IBAction)btnReadTemperaturePressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnConnectReader;
@property (weak, nonatomic) IBOutlet UILabel *lbConnectReader;
@property (weak, nonatomic) IBOutlet UILabel *lbReaderStatus;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actHomeSpinner;
@property (weak, nonatomic) IBOutlet UIButton *btnReadTemperature;

@end
