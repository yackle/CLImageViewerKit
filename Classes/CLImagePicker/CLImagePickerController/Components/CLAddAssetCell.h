//
//  CLAddAssetCell.h
//
//  Created by sho yakushiji on 2014/02/04.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLAddAssetCell : UICollectionViewCell
{
    IBOutlet __weak UIImageView *_imageView;
    IBOutlet __weak UIActivityIndicatorView *_indicatorView;
}
@property (nonatomic, readonly) UIActivityIndicatorView *indicatorView;

@end
