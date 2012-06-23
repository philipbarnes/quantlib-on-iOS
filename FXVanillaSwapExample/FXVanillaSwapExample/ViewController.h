//
//  ViewController.h
//  FXVanillaSwapExample
//
//  Created by Philip Barnes on 11/06/2012.
//  Copyright (c) 2012 Striding Edge Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXVanillaSwapPricer.h"

@interface ViewController : UIViewController<UITextFieldDelegate>{
    FXVanillaSwapPricer * fxvanillaswappricer;
}

@property (weak, nonatomic) IBOutlet UITextField *quote;
@property (weak, nonatomic) IBOutlet UITextField *strikePrice;
@property (weak, nonatomic) IBOutlet UITextField *foreignRate;
@property (weak, nonatomic) IBOutlet UITextField *domesticRate;
@property (weak, nonatomic) IBOutlet UITextField *volatility;
@property (weak, nonatomic) IBOutlet UIDatePicker *maturity;
@property (weak, nonatomic) IBOutlet UIDatePicker *today;
@property (weak, nonatomic) IBOutlet UIDatePicker *settlement;
@property (weak, nonatomic) IBOutlet UIButton *calculateButton;
@property (weak, nonatomic) IBOutlet UILabel *price;

- (IBAction)quoteChanged:(UITextField *)sender;
- (IBAction)strikePriceChanged:(UITextField *)sender;
- (IBAction)foreignRateChanged:(UITextField *)sender;
- (IBAction)domesticRateChanged:(UITextField *)sender;
- (IBAction)volatilityChanged:(UITextField *)sender;
- (IBAction)maturityChanged:(UIDatePicker *)sender;
- (IBAction)todayChanged:(UIDatePicker *)sender;
- (IBAction)settlementChanged:(UIDatePicker *)sender;
- (IBAction)calculate:(UIButton *)sender;

@end
