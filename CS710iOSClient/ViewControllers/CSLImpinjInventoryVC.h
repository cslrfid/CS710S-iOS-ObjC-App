//
//  CSLInventoryVC.h
//  CS710SiOSClient
//
//  Created by Lam Ka Shun on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLRfidAppEngine.h"
#import "CSLTagListCell.h"
#import "CSLTabVC.h"

@interface CSLImpinjInventoryVC : UIViewController<CSLBleReaderDelegate, CSLBleInterfaceDelegate, UITableViewDataSource, UITableViewDelegate> {

}
@property (weak, nonatomic) IBOutlet UIButton *btnInventory;
@property (weak, nonatomic) IBOutlet UIButton *btnAuthenticate;
@property (weak, nonatomic) IBOutlet UIButton *btnProtectedMode;
@property (weak, nonatomic) IBOutlet UITableView *tblTagList;
@property (weak, nonatomic) IBOutlet UILabel *lbStatus;
@property (weak, nonatomic) IBOutlet UIButton *lbClear;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actInventorySpinner;


- (IBAction)btnInventoryPressed:(id)sender;
- (IBAction)btnAuthenticationPressed:(id)sender;
- (IBAction)btnProtectedModePressed:(id)sender;
- (IBAction)btnClearTable:(id)sender;



@end
