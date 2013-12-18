//
//  CLFullscreenImageViewer.h
//
//  Created by sho yakushiji on 2013/11/24.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CLFullscreenImageViewerDelegate;

@interface CLFullscreenImageViewer : UIView

@property (nonatomic, weak) id<CLFullscreenImageViewerDelegate> delegate;
@property (nonatomic, assign) CGFloat backgroundScale;

- (void)showWithImageViews:(NSArray*)views selectedView:(UIImageView*)selectedView;

@end


@protocol CLFullscreenImageViewerDelegate <NSObject>
@optional
- (void)fullscreenImageViewer:(CLFullscreenImageViewer*)view  willDismissWithSelectedView:(UIImageView*)selectedView;

@end
