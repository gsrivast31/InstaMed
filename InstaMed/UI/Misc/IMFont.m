//
//  IMFont.m
//  HealthMemoir
//
//  Created by GAURAV SRIVASTAVA on 30/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "IMFont.h"

@implementation IMFont

+ (UIFont *)standardRegularFontWithSize:(CGFloat)size
{
    return [UIFont systemFontOfSize:size];// [UIFont fontWithName:@"AvenirNext-Regular" size:size];
}
+ (UIFont *)standardMediumFontWithSize:(CGFloat)size
{
    return [UIFont systemFontOfSize:size];//[UIFont fontWithName:@"AvenirNext-Medium" size:size];
}
+ (UIFont *)standardDemiBoldFontWithSize:(CGFloat)size
{
    return [UIFont systemFontOfSize:size];//[UIFont fontWithName:@"AvenirNext-DemiBold" size:size];
}
+ (UIFont *)standardBoldFontWithSize:(CGFloat)size
{
    return [UIFont boldSystemFontOfSize:size];//[UIFont fontWithName:@"AvenirNext-Bold" size:size];
}
+ (UIFont *)standardUltraLightFontWithSize:(CGFloat)size
{
    return [UIFont systemFontOfSize:size];//[UIFont fontWithName:@"AvenirNext-UltraLight" size:size];
}
+ (UIFont *)standardUltraLightItalicFontWithSize:(CGFloat)size
{
    return [UIFont italicSystemFontOfSize:size];
}
+ (UIFont *)standardItalicFontWithSize:(CGFloat)size
{
    return [UIFont italicSystemFontOfSize:size];//[UIFont fontWithName:@"AvenirNext-Italic" size:size];
}

@end
