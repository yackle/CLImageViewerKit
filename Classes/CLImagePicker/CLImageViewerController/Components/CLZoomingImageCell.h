//
//  CLZoomingImageCell.h
//
//  Created by sho yakushiji on 2014/01/15.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLZoomingImageCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *thumnailImage;
@property (nonatomic, strong) UIImage *fullScreenImage;
@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, readonly) BOOL isViewing;

@end
