//
//  FXVanillaSwapPricer.m
//  FXVanillaSwapExample
//
//  Created by Philip Barnes on 11/06/2012.
//  Copyright (c) 2012 Striding Edge Technologies. All rights reserved.
//
// As this is some simple demo code that has been written to show how the
// PIMPL implementation works, I'm not too bothered about the mutators
// (interface) provided by the class other than to demonstrate how you
// would encapsulate the QuantLib calls in Objective-C++.
//
// I have based the price function on the simple bare-bones
// implementation provided by Bojan Nikolic at http://www.bnikolic.co.uk/
//
// The class gets all the properties at the start of the price method,
// but in real life you may want the mutators to convert the Objective-C
// types to QuantLib types to make the class more dynamic. The maturity
// get and set methods at the end of the file show how this could be
// achieved. It's painful. I expect that a lot of convertor functions
// would need to be written to support this properly.

#import "FXVanillaSwapPricer.h"
#include <ql/quantlib.hpp>

using namespace QuantLib;

// example interface

@interface FXVanillaSwapPricer ()
{  
    QuantLib::Real _S;         // simple quote value
    QuantLib::Real _K;         // strike price
    QuantLib::Spread _f;       // Foreign rate
    QuantLib::Rate _r;         // Domestic rate
    QuantLib::Volatility _vol; // volatility
    QuantLib::Date _maturity;
    QuantLib::Date _todaysDate;
    QuantLib::Date _settlementDate;
    
    NSDate * maturity;
}
@end

@implementation FXVanillaSwapPricer

@synthesize quote;
@synthesize strikePrice;
@synthesize foreignRate;
@synthesize domesticRate;
@synthesize volatility;
//@synthesize maturity;
@synthesize today;
@synthesize settlement;

- (double) price
{
    using namespace QuantLib;
    
    QuantLib::DayCounter _dayCounter = Actual365Fixed();
    
    // get the parameters used to generate the price
    // if we hand crafted the mutators like the maturity example
    // we would not need to do this
    
    _S = quote;
    _K = strikePrice;
    _f = foreignRate;
    _r = domesticRate;
    _vol = volatility;
    
    // convert the maturity date
    //
    // we don't need to do this as the set mutator in this example
    // class does this for us.
    
    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
//    dateFormatter.dateFormat = @"dd";
//    NSString *dayString = [dateFormatter stringFromDate: maturity];
//    dateFormatter.dateFormat = @"MM";
//    NSString *monthString = [dateFormatter stringFromDate: maturity];
//    dateFormatter.dateFormat = @"YYYY";
//    NSString *yearString = [dateFormatter stringFromDate: maturity];
//    
//    NSLog(@"maturity day %@ month %@ year %@", dayString, monthString, yearString);
//    
//    QuantLib::Day day = [dayString intValue];
//    QuantLib::Month month = intToQLMonth([monthString intValue]);
//    QuantLib::Year year = [yearString intValue];
//    
//    _maturity = Date(day, month, year);
    
    // convert the settlement date
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd";
    NSString *dayString = [dateFormatter stringFromDate: settlement];
    dateFormatter.dateFormat = @"MM";
    NSString *monthString = [dateFormatter stringFromDate: settlement];
    dateFormatter.dateFormat = @"YYYY";
    NSString *yearString = [dateFormatter stringFromDate: settlement];
    
    NSLog(@"settlement day %@ month %@ year %@", dayString, monthString, yearString);
    
    QuantLib::Day day = [dayString intValue];
    QuantLib::Month month = intToQLMonth([monthString intValue]);
    QuantLib::Year year = [yearString intValue];
    
    _settlementDate = Date(day, month, year);
    
    // convert todays date
    
    dateFormatter.dateFormat = @"dd";
    dayString = [dateFormatter stringFromDate: today];
    dateFormatter.dateFormat = @"MM";
    monthString = [dateFormatter stringFromDate: today];
    dateFormatter.dateFormat = @"YYYY";
    yearString = [dateFormatter stringFromDate: today];
    
    NSLog(@"todays day %@ month %@ year %@", dayString, monthString, yearString);
    
    day = [dayString intValue];
    month = intToQLMonth([monthString intValue]);
    year = [yearString intValue];
    
    _todaysDate = Date(day, month, year);

    dateFormatter = nil;
    
    Calendar calendar = TARGET();
    Settings::instance().evaluationDate() = _todaysDate;
    
    // create the vanilla option as an American exercise type
    // American-style option contracts can be exercised at any time up to the
    // option's expiration
    //
    // Garman and Kohlhagen is used to price European Options only!?
    
    boost::shared_ptr<Exercise>
    americanExercise(new AmericanExercise(_settlementDate,
                                          _maturity));
    
    boost::shared_ptr<StrikedTypePayoff>
    payoff(new PlainVanillaPayoff(Option::Call, // option type
                                  _K));
    
    VanillaOption amerOpt(payoff, americanExercise);
    
    // create the pricing process (calculation method) for the
    // vanilla swap
    
    Handle<Quote>
    underlyingH(boost::shared_ptr<Quote>(new SimpleQuote(_S)));
    
    // Flat Yield Curve: These curves indicate that the market environment is sending mixed signals
    // to investors, who are interpreting interest rate movements in various ways.
    // During such an environment, it is difficult for the market to determine whether interest
    // rates will move significantly in either direction farther into the future. A flat yield
    // curve usually occurs when the market is making a transition that emits different
    // but simultaneous indications of what interest rates will do. In other words, there may
    // be some signals that short-term interest rates will rise and other signals that
    // long-term interest rates will fall. This condition will create a curve that is flatter
    // than its normal positive slope.
    // Read more: http://www.investopedia.com/university/advancedbond/advancedbond4.asp#ixzz1xfsRWG2f
    
    Handle<YieldTermStructure>
    rTS(boost::shared_ptr<YieldTermStructure>(new FlatForward(_settlementDate,
                                                              _r,
                                                              _dayCounter)));
    Handle<YieldTermStructure>
    fTS(boost::shared_ptr<YieldTermStructure>(new FlatForward(_settlementDate,
                                                              _f,
                                                              _dayCounter)));
    Handle<BlackVolTermStructure>
    flatVolTS(boost::shared_ptr<BlackVolTermStructure>(new BlackConstantVol(_settlementDate,
                                                                            calendar,
                                                                            _vol,
                                                                            _dayCounter)));
    
    // In the interbank foreign exchange market, options are not quoted with prices.
    // They are quoted indirectly with implied volatilities. The convention for
    // converting volatilities to prices is the Garman and Kohlhagen (1983) option
    // pricing formula. Mathematically, the formula is identical to Merton's (1973)
    // formula for options on dividend-paying stocks. Only the term q, which did
    // represent a stock's dividend yield, now represents the foreign currency's
    // continuously compounded risk-free rate. Like the Merton formula, the Garman
    // and Kohlhagen formula applies only to European options. Generally, OTC currency
    // options are European.
    
    // Garman and Kohlhagen extension of the Black Scholes models for FX
    boost::shared_ptr<GarmanKohlagenProcess>
    process(new GarmanKohlagenProcess(underlyingH,
                                      fTS, // Foreign Risk Free Yield Term Structure
                                      rTS, // Domestic Risk Free Yield Term Structure
                                      flatVolTS));
    
    boost::shared_ptr<PricingEngine> pe(new BinomialVanillaEngine<CoxRossRubinstein>(process, 100));
    amerOpt.setPricingEngine(pe);
    
    double npv = amerOpt.NPV();
    
    NSLog(@"price %f", npv);
    
    return npv;
}


- (id) init
{
    self = [super init];
    if(self)
    {
    }

    return self;
}

- (void) dealloc
{
}

QuantLib::Month intToQLMonth(int monthAsInteger)
{
    NSLog(@"intToQLMonth month = %i", monthAsInteger);
    
    QuantLib::Month month = January;
    
    switch (monthAsInteger) {
        case 1:
            month = January;
            break;
        case 2:
            month = February;
            break;
        case 3:
            month = March;
            break;
        case 4:
            month = April;
            break;
        case 5:
            month = May;
            break;
        case 6:
            month = June;
            break;
        case 7:
            month = July;
            break;
        case 8:
            month = August;
            break;
        case 9:
            month = September;
            break;
        case 10:
            month = October;
            break;
        case 11:
            month = November;
            break;
        case 12:
            month = December;
            break;
            
        default:
            break;
    }
    
    return (month);
}

// example mutator methods to show how what is involved in interfacing
// between objective-c and C++ - the price method pulls in the maturity,
// but these show the sort of conversions that would need to be done 
// if you wanted to fully expand the mutators in the Objective-C++ class.

- (NSDate *) maturity
{
    NSLog(@"Maturity get mutator called");
    
    // convert the QuantLib::Date to NSDate using a Date Formatter
    // it helps that the QuantLib day/month/year are defined as ints
    // so the compiler does the implicit conversions for us
    
    QuantLib::Day day = _maturity.dayOfMonth();
    QuantLib::Month month = _maturity.month();
    QuantLib::Year year = _maturity.year();
    
    NSString * dateString = [[NSString alloc]initWithFormat:@"%d-%02d-%02d", year, month, day];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSLog(@"maturity day %@", dateString);
    
    NSDate * date = [dateFormatter dateFromString:dateString];
    
    return date;
}

- (void) setMaturity:(NSDate *) newMaturity
{
    NSLog(@"Maturity set mutator called");
    
    // convert the maturity date from an NSDate to a QuantLib::Date
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd";
    NSString *dayString = [dateFormatter stringFromDate: newMaturity];
    dateFormatter.dateFormat = @"MM";
    NSString *monthString = [dateFormatter stringFromDate: newMaturity];
    dateFormatter.dateFormat = @"YYYY";
    NSString *yearString = [dateFormatter stringFromDate: newMaturity];
    
    NSLog(@"maturity day %@ month %@ year %@", dayString, monthString, yearString);
    
    QuantLib::Day day = [dayString intValue];
    QuantLib::Month month = intToQLMonth([monthString intValue]);
    QuantLib::Year year = [yearString intValue];
    
    _maturity = Date(day, month, year);
      
    // no need to set the maturity here
    // maturity = newMaturity;
}

@end
