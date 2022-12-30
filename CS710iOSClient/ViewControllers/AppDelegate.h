//
//  AppDelegate.h
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 25/8/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLBleReader.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    CSLBleReader* reader;
    NSDate * tagRangingStartTime;
        
}
@property (strong, nonatomic) UIWindow *window;


@end

