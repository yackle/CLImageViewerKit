//
//  CLAddAssetCell.m
//
//  Created by sho yakushiji on 2014/02/04.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import "CLAddAssetCell.h"

@implementation CLAddAssetCell

- (void)customInit
{
    _indicatorView.frame = self.bounds;
    _indicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _indicatorView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self customInit];
}

@end
