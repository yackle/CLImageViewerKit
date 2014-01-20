//
//  CLZoomingImageCell.m
//
//  Created by sho yakushiji on 2014/01/15.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import "CLZoomingImageCell.h"

#import "CLZoomingImageView.h"

@implementation CLZoomingImageCell
{
    CLZoomingImageView *_zoomingView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _zoomingView = [[CLZoomingImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_zoomingView];
    }
    return self;
}

- (UIScrollView*)scrollView
{
    return _zoomingView.scrollView;
}

- (UIImageView*)imageView
{
    return _zoomingView.imageView;
}

- (BOOL)isViewing
{
    return _zoomingView.isViewing;
}

- (void)setThumnailImage:(UIImage *)thumnailImage
{
    _thumnailImage   = thumnailImage;
    _fullScreenImage = nil;
    _zoomingView.image = thumnailImage;
}

- (void)setFullScreenImage:(UIImage *)fullScreenImage
{
    _thumnailImage   = nil;
    _fullScreenImage = fullScreenImage;
    _zoomingView.image = fullScreenImage;
}

@end
