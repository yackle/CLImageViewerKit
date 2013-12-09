//
//  CLImagePagingView.h
//
//  Created by sho yakushiji on 2013/11/21.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CLImagePagingViewDelegate;


@interface CLImagePagingView : UIView

@property (nonatomic, weak) id<CLImagePagingViewDelegate> delegate;
@property (nonatomic, readonly) NSArray *imageViews;
@property (nonatomic, readonly) NSInteger pageIndex;
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign) BOOL allowsFullscreenSlideshow;

- (void)addImage:(UIImage*)image;
- (void)addImageView:(UIImageView*)imageView;

- (void)removeAllImageViews;

- (void)setPageIndex:(NSInteger)pageIndex animated:(BOOL)animated;

@end

@protocol CLImagePagingViewDelegate <NSObject>
@optional
- (void)imagePagingView:(CLImagePagingView*)view didChangePageIndex:(NSInteger)pageIndex;

@end