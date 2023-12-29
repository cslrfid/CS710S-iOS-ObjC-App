//
//  CSLMoreFunctionsVC.m
//  CS710SiOSClient
//
//  Created by Lam Ka Shun on 19/2/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import "CSLMoreFunctionsVC.h"
#import "CSLMQTTClientSettings.h"
#import "CSLMultibankAccessVC.h"
#import "CSLFilterTabVC.h"
#import "CSLImpinjInventoryVC.h"

@interface CSLMoreFunctionsVC ()

@end

@implementation CSLMoreFunctionsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    self.view.userInteractionEnabled=true;

}



- (IBAction)btnMultibankPressed:(id)sender {
    CSLMultibankAccessVC* multibank;
    multibank = (CSLMultibankAccessVC*)[[UIStoryboard storyboardWithName:@"CSLRfidDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_MultibankVC"];
    
    if (multibank != nil)
    {
        [[self navigationController] pushViewController:multibank animated:YES];
    }
    
}

- (IBAction)btnFiltersPressed:(id)sender {
        
    CSLFilterTabVC * tabVC = (CSLFilterTabVC*)[[UIStoryboard storyboardWithName:@"CSLRfidDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_FilterTabVC"];
    
    if ([CSLRfidAppEngine sharedAppEngine].reader.readerModelNumber == CS710)
        return;
    
    [tabVC setActiveView:CSL_VC_RFIDTAB_PREFILTER_VC_IDX];
    self.view.userInteractionEnabled=false;
    if (tabVC != nil)
    {
        [[self navigationController] pushViewController:tabVC animated:YES];
    }
    
}

- (IBAction)btnAuthenticationPressed:(id)sender {
    CSLImpinjInventoryVC* impinjVC;
    impinjVC = (CSLImpinjInventoryVC*)[[UIStoryboard storyboardWithName:@"CSLRfidDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_ImpinjInventoryVC"];
    
    if (impinjVC != nil)
    {
        [[self navigationController] pushViewController:impinjVC animated:YES];
    }
    
}

- (IBAction)btnMQTTPressed:(id)sender {
    CSLMQTTClientSettings* mqttSettings;
    mqttSettings = (CSLMQTTClientSettings*)[[UIStoryboard storyboardWithName:@"CSLRfidDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_MQTTSettingsVC"];
        
    if (mqttSettings != nil)
    {
        [[self navigationController] pushViewController:mqttSettings animated:YES];
    }
    
}
@end
