//
//  CLZoomingImageView.h
//
//  Created by sho yakushiji on 2013/11/24.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLZoomingImageView : UIView

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, readonly) BOOL isViewing;

- (void)setImageView:(UIImageView *)imageView;

@end
