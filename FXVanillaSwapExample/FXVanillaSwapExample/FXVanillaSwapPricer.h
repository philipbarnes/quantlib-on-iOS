//
//  FXVanillaSwapPricer.h
//  FXVanillaSwapExample
//
//  Created by Philip Barnes on 11/06/2012.
//  Copyright (c) 2012 Striding Edge Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FXVanillaSwapPricer : NSObject {
}

- (double) price;

// mutators - note that we don't create properties or mutators for the
// QuantLib data members else we will expose them to the rest of the
// Objective-C application that defeats the object of PIMPL.
//
// Instead we create use a facade-style interface and convert the
// Objective-C types to QuantLib types.
//
// For this example we do it in the maturity mutator only. See the .mm
// file for more information.

@property (nonatomic) double quote;
@property (nonatomic) double strikePrice;
@property (nonatomic) double foreignRate;
@property (nonatomic) double domesticRate;
@property (nonatomic) double volatility;
//@property (strong, nonatomic) NSDate *maturity;
@property (strong, nonatomic) NSDate *today;
@property (strong, nonatomic) NSDate *settlement;

- (NSDate *) maturity;
- (void) setMaturity:(NSDate *) newMaturity;

@end