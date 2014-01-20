//
//  CLAssetCell.h
//
//  Created by sho yakushiji on 2014/01/10.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLAsset.h"

@protocol CLAssetCellDelegate;

@interface CLAssetCell : UICollectionViewCell
{
    IBOutlet __weak UIImageView *_imageView;
    IBOutlet __weak UIButton *_selectBtn;
}
@property (nonatomic, weak) id<CLAssetCellDelegate> delegate;
@property (nonatomic, readonly) UIImageView *imageView;

- (IBAction)pushedSelectBtn:(id)sender;
- (void)setImage:(UIImage*)image;

@end


@protocol CLAssetCellDelegate <NSObject>
@required
- (void)cellDidPushSelectButton:(CLAssetCell*)cell;

@end
