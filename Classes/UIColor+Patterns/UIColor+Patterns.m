//
//  UIColor+Patterns.m
//
//  Created by sho yakushiji on 2013/12/14.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "UIColor+Patterns.h"

@implementation UIColor (Patterns)


+ (UIImage*)checkImage:(CGFloat)size
{
    UIGraphicsBeginImageContext(CGSizeMake(2*size, 2*size));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:1 alpha:1] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 2*size, 2*size));
    
    CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:0.9 alpha:1] CGColor]);
    
    CGContextBeginPath(context);
    CGContextAddPath(context, [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size, size)].CGPath);
    CGContextAddPath(context, [UIBezierPath bezierPathWithRect:CGRectMake(size, size, size, size)].CGPath);
    CGContextFillPath(context);
    
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tmp;
}

+ (UIColor*)checkBoard:(CGFloat)size
{
    return [UIColor colorWithPatternImage:[self checkImage:size]];
}

@end
