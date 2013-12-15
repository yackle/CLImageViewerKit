//
//  CLFontPicker.h
//  CLColorPickerViewDemo
//
//  Created by sho yakushiji on 2013/12/14.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CLFontPickerDelegate;

@interface CLFontPicker : UIView

@property (nonatomic, weak) id<CLFontPickerDelegate> delegate;
@property (nonatomic, strong) NSArray *fontList;
@property (nonatomic, strong) NSArray *fontSizes;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) BOOL sizeComponentHidden;
@property (nonatomic, strong) UIColor *foregroundColor;

@end


@protocol CLFontPickerDelegate <NSObject>
@optional
- (void)fontPicker:(CLFontPicker*)picker didSelectFont:(UIFont*)font;

@end