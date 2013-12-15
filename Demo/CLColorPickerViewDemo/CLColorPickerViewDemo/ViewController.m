//
//  ViewController.m
//  CLColorPickerViewDemo
//
//  Created by sho yakushiji on 2013/12/14.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "ViewController.h"

#import "CLFontPicker.h"
#import "CLColorPickerView.h"
#import "UIColor+Patterns.h"
#import "UIView+Frame.h"


@interface ViewController ()
<CLColorPickerViewDelegate, CLFontPickerDelegate>
@end

@implementation ViewController
{
    UILabel *_label;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor checkBoard:50];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 320, 50)];
    _label.backgroundColor = [UIColor clearColor];
    _label.font = [UIFont boldSystemFontOfSize:38];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"SAMPLE TEXT.";
    [self.view addSubview:_label];
    
    CLColorPickerView *picker = [CLColorPickerView new];
    picker.center = self.view.center;
    picker.top = _label.bottom + 50;
    picker.layer.cornerRadius = 5;
    picker.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    picker.delegate = self;
    [self.view addSubview:picker];
    
    
    CLFontPicker *fontPicker = [[CLFontPicker alloc] initWithFrame:CGRectMake(0, 0, picker.width, 140)];
    fontPicker.center = self.view.center;
    fontPicker.top = picker.bottom + 10;
    fontPicker.layer.cornerRadius = 5;
    fontPicker.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.5];
    fontPicker.foregroundColor = [UIColor colorWithWhite:0.5 alpha:0.7];
    fontPicker.delegate = self;
    //fontPicker.sizeComponentHidden = YES;
    fontPicker.font = [fontPicker.font fontWithSize:38];
    [self.view addSubview:fontPicker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark- Color picker delegate

- (void)colorPickerView:(CLColorPickerView *)picker colorDidChange:(UIColor *)color
{
    _label.textColor = color;
}

#pragma mark- Font picker delegate

- (void)fontPicker:(CLFontPicker *)picker didSelectFont:(UIFont *)font
{
    _label.font = font;
}

@end
