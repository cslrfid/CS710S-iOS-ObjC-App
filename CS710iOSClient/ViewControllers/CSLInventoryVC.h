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

@interface CSLInventoryVC : UIViewController<CSLBleReaderDelegate, CSLBleInterfaceDelegate, UITableViewDataSource, UITableViewDelegate> {
    NSDate * tagRangingStartTime;

}
@property (weak, nonatomic) IBOutlet UILabel *lbTagCount;
@property (weak, nonatomic) IBOutlet UILabel *lbTagRate;
@property (weak, nonatomic) IBOutlet UILabel *lbUniqueTagRate;
@property (weak, nonatomic) IBOutlet UIButton *btnInventory;
@property (weak, nonatomic) IBOutlet UITableView *tblTagList;
@property (weak, nonatomic) IBOutlet UILabel *lbStatus;
@property (weak, nonatomic) IBOutlet UIButton *lbClear;
@property (weak, nonatomic) IBOutlet UILabel *lbMode;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actInventorySpinner;
@property (weak, nonatomic) IBOutlet UILabel *lbElapsedTime;
@property (weak, nonatomic) IBOutlet UIButton *btnTagDisplay;
@property (weak, nonatomic) IBOutlet UISwitch *swLEDTag;

- (IBAction)btnInventoryPressed:(id)sender;
- (IBAction)btnClearTable:(id)sender;
- (IBAction)btnSaveData:(id)sender;
- (IBAction)btnTagDispalyPressed:(id)sender;
- (IBAction)swLEDTagToggled:(id)sender;


@end
