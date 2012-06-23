//
//  ViewController.m
//  FXVanillaSwapExample
//
//  Created by Philip Barnes on 11/06/2012.
//  Copyright (c) 2012 Striding Edge Technologies. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize quote;
@synthesize strikePrice;
@synthesize foreignRate;
@synthesize domesticRate;
@synthesize volatility;
@synthesize maturity;
@synthesize today;
@synthesize settlement;
@synthesize calculateButton;
@synthesize price;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // initialise the pricing object
    
    fxvanillaswappricer = [[FXVanillaSwapPricer alloc] init];
    
    [fxvanillaswappricer setQuote:100.00];
    [fxvanillaswappricer setStrikePrice:100.00];    
    [fxvanillaswappricer setForeignRate:0.05];
    [fxvanillaswappricer setDomesticRate:0.02];
    [fxvanillaswappricer setVolatility:0.20];
    
    // set the dates to be today and tomorrow
    
    NSDate *todayDate = [NSDate date];
    NSTimeInterval secondsPerDayMaturity = 24 * 60 * 60 * 365;
    NSTimeInterval secondsPerDaySettlement = 24 * 60 * 60 * 2;
    NSDate *maturityDate = [[NSDate alloc] initWithTimeIntervalSinceNow:secondsPerDayMaturity];
    NSDate *settlementDate = [[NSDate alloc] initWithTimeIntervalSinceNow:secondsPerDaySettlement];

    [fxvanillaswappricer setMaturity:maturityDate];
    [fxvanillaswappricer setToday:todayDate];
    [fxvanillaswappricer setSettlement:settlementDate];
    
    // initialise the interface
    
    // hook up the callbacks to the GUI
    
    [quote addTarget:self action:@selector(quoteChanged:) forControlEvents:UIControlEventEditingDidEnd];
    [strikePrice addTarget:self action:@selector(strikePriceChanged:) forControlEvents:UIControlEventEditingDidEnd];
    [foreignRate addTarget:self action:@selector(foreignRateChanged:) forControlEvents:UIControlEventEditingDidEnd];
    [domesticRate addTarget:self action:@selector(domesticRateChanged:) forControlEvents:UIControlEventEditingDidEnd];
    [volatility addTarget:self action:@selector(volatilityChanged:) forControlEvents:UIControlEventEditingDidEnd];
    [maturity addTarget:self action:@selector(maturityChanged:) forControlEvents:UIControlEventValueChanged];
    [today addTarget:self action:@selector(todayChanged:) forControlEvents:UIControlEventValueChanged];
    [settlement addTarget:self action:@selector(settlementChanged:) forControlEvents:UIControlEventValueChanged];
    [calculateButton addTarget:self action:@selector(calculate:) forControlEvents:UIControlEventTouchUpInside];
    
    // set up the initial interface values
    
    [quote setText:[NSString stringWithFormat:@"%2.2f",[fxvanillaswappricer quote]]];
    [strikePrice setText:[NSString stringWithFormat:@"%2.2f", [fxvanillaswappricer strikePrice]]];
    [foreignRate setText:[NSString stringWithFormat:@"%2.2f", [fxvanillaswappricer foreignRate]]];
    [domesticRate setText:[NSString stringWithFormat:@"%2.2f", [fxvanillaswappricer domesticRate]]];
    [volatility setText:[NSString stringWithFormat:@"%2.2f", [fxvanillaswappricer volatility]]];
    [maturity setDate:[fxvanillaswappricer maturity] animated:YES];
    [today setDate:[fxvanillaswappricer today] animated:YES];
    [settlement setDate:[fxvanillaswappricer settlement] animated:YES];
    [price setText:[NSString stringWithFormat:@"%f", [fxvanillaswappricer price]]];
}

- (void)viewDidUnload
{
    fxvanillaswappricer = nil;

    // these have been inserted by xcode
    [self setQuote:nil];
    [self setStrikePrice:nil];
    [self setForeignRate:nil];
    [self setDomesticRate:nil];
    [self setVolatility:nil];
    [self setMaturity:nil];
    [self setCalculateButton:nil];
    [self setToday:nil];
    [self setSettlement:nil];
    [self setPrice:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

// callbacks to set the parameters for the FX Vanilla Swap Price object

- (IBAction)quoteChanged:(UITextField*)sender
{ 
    double quoteValue = [sender.text doubleValue];
 
    NSLog(@"quoteChanged %f", quoteValue);
    
    [fxvanillaswappricer setQuote:quoteValue];
}

- (IBAction)strikePriceChanged:(UITextField*)sender
{
    double strikePriceValue = [sender.text doubleValue];

    NSLog(@"strikePriceChanged %f", strikePriceValue);

    [fxvanillaswappricer setStrikePrice:strikePriceValue];
}

- (IBAction)foreignRateChanged:(UITextField*)sender
{
    double foreignRateValue = [sender.text doubleValue];

    NSLog(@"foreignRateChanged %f", foreignRateValue);

    [fxvanillaswappricer setForeignRate:foreignRateValue];
}

- (IBAction)domesticRateChanged:(UITextField*)sender
{
    double domesticRateValue = [sender.text doubleValue];

    NSLog(@"domesticRateChanged %f", domesticRateValue);
    
    [fxvanillaswappricer setDomesticRate:domesticRateValue];
}

- (IBAction)volatilityChanged:(UITextField*)sender
{
    double volatilityValue = [sender.text doubleValue];

    NSLog(@"volatilityChanged %f", volatilityValue);
    
    [fxvanillaswappricer setVolatility:volatilityValue];
}

- (IBAction)maturityChanged:(UIDatePicker *)sender
{
    NSDate *date = [sender date];
    
    NSLog(@"maturityChanged %@", date);
    
    [fxvanillaswappricer setMaturity:date];
}

- (IBAction)todayChanged:(UIDatePicker *)sender
{
    NSDate *date = [sender date];
    
    NSLog(@"todayChanged %@", date);
    
    [fxvanillaswappricer setToday:date];

}

- (IBAction)settlementChanged:(UIDatePicker *)sender
{
    NSDate *date = [sender date];
    
    NSLog(@"settlementChanged %@", date);
    
    [fxvanillaswappricer setSettlement:date];

}

- (IBAction)calculate:(UIButton *)sender
{
    NSLog(@"calculate");
    double npv;
    npv = [fxvanillaswappricer price];
    [price setText:[NSString stringWithFormat:@"%2.6f", npv]];
}

@end
