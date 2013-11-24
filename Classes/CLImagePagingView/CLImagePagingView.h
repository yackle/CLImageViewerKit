//
//  CLImagePagingView.h
//
//  Created by sho yakushiji on 2013/11/21.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLImagePagingView : UIView

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, readonly) NSArray *imageViews;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign) BOOL allowsFullscreenSlideshow;

- (void)addImage:(UIImage*)image;
- (void)setPageIndex:(NSInteger)pageIndex animated:(BOOL)animated;

@end
