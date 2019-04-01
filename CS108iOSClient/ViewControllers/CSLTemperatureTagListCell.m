//
//  CSLTemperatureTagListCell.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2/3/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

#import "CSLTemperatureTagListCell.h"

@implementation CSLTemperatureTagListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (double) calculateCalibratedTemperatureValue:(NSString*) tempCodeInHexString calibration:(NSString*) calibrationInHexString {
    NSScanner *scanner;
    UInt32 tmp = 0;
    UInt32 temperatureCode = 0;
    UInt32 code1 = 0;
    UInt32 temp1_1, temp1_2, temp1 = 0;
    UInt32 code2_1, code2_2, code2 = 0;
    UInt32 temp2 = 0;
    double temperatureValue=0.0;
    
    //temperature code
    scanner = [NSScanner scannerWithString:tempCodeInHexString];
    [scanner scanHexInt:&temperatureCode];
    temperatureCode &= 0x00000FFF;  //least significant bits
    
    //Calibration - CODE1
    scanner = [NSScanner scannerWithString:[calibrationInHexString substringWithRange:NSMakeRange(4, 4)]];
    [scanner scanHexInt:&tmp];
    temp1_1 = (tmp << 7) & 0x00000780;     //capture the partial TEMP1 from the 0x9 address
    code1 = (tmp >> 4) & 0x00000FFF;  //least significant bits
    
    //Calibration - TEMP1
    scanner = [NSScanner scannerWithString:[calibrationInHexString substringWithRange:NSMakeRange(8, 4)]];
    [scanner scanHexInt:&tmp];
    code2_1 = (tmp << 3) & 0x00000FF8;   //capture the partial CODE2 from the 0xA address
    temp1_2 = (tmp >> 9) & 0x0000007F;  //least significant bits
    temp1=temp1_1+temp1_2;
    
    //Calibration - CODE2
    scanner = [NSScanner scannerWithString:[calibrationInHexString substringWithRange:NSMakeRange(12, 4)]];
    [scanner scanHexInt:&tmp];
    code2_2 = (tmp >> 13) & 0x00000007;  //least significant bits
    code2=code2_1+code2_2;
    
    //Calibration - TEMP2
    temp2 = (tmp >> 2) & 0x000007FF;  //least significant bits
    
    // calculate temperature value from temperature code
    //Temperature in Degrees Celsius=(1/10)[TEMP2−TEMP1CODE2−CODE1(C−CODE1)+TEMP1−800]
    temperatureValue = (((double)temp2-(double)temp1)/((double)code2-(double)code1));
    temperatureValue *= ((double)temperatureCode-(double)code1);
    temperatureValue += (double)temp1;
    temperatureValue -= 800;
    temperatureValue /= 10;
    
    return temperatureValue;
}
- (void) spinTemperatureValueIndicator {
    if ([self.lbTemperature.text isEqualToString:@"  -  "])
        self.lbTemperature.text = @"  \\  ";
    else if ([self.lbTemperature.text isEqualToString:@"  \\  "])
        self.lbTemperature.text = @"  |  ";
    else if ([self.lbTemperature.text isEqualToString:@"  |  "])
        self.lbTemperature.text = @"  /  ";
    else if ([self.lbTemperature.text isEqualToString:@"  /  "])
        self.lbTemperature.text = @"  -  ";
    else
        self.lbTemperature.text = @"  -  ";
}

@end
