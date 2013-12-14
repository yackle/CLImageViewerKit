//
//  ViewController.m
//  CLColorPickerViewDemo
//
//  Created by sho yakushiji on 2013/12/14.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "ViewController.h"

#import "CLColorPickerView.h"
#import "UIColor+Patterns.h"
#import "UIView+Frame.h"

@interface ViewController ()
<CLColorPickerViewDelegate>
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
    _label.font = [UIFont boldSystemFontOfSize:40];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"SAMPLE TEXT.";
    [self.view addSubview:_label];
    
    CLColorPickerView *picker = [[CLColorPickerView alloc] initWithFrame:CGRectMake(0, 0, 300, 180)];
    picker.center = self.view.center;
    picker.top = _label.bottom + 50;
    picker.layer.cornerRadius = 5;
    picker.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    picker.delegate = self;
    [self.view addSubview:picker];
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

@end
