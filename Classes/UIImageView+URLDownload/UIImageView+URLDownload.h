//
//  UIImageView+URLDownload.h
//
//  Created by sho yakushiji on 2013/11/25.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, UIImageViewURLDownloadState)
{
    UIImageViewURLDownloadStateUnknown = 0,
    UIImageViewURLDownloadStateLoaded,
    UIImageViewURLDownloadStateWaitingForLoad,
    UIImageViewURLDownloadStateNowLoading,
    UIImageViewURLDownloadStateFailed,
};


@interface UIImageView (URLDownload)

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, readonly) UIImageViewURLDownloadState loadingState;
@property (nonatomic, strong) UIView *loadingView;

// Get instance
+ (id)imageViewWithURL:(NSURL*)url autoLoading:(BOOL)autoLoading;

// Get instance that has UIActivityIndicatorView as loadingView by default
+ (id)indicatorImageView;
+ (id)indicatorImageViewWithURL:(NSURL*)url autoLoading:(BOOL)autoLoading;


// Set UIActivityIndicatorView as loadingView
- (void)setDefaultLoadingView;


// Download
- (void)setUrl:(NSURL *)url autoLoading:(BOOL)autoLoading;
- (void)load;
- (void)loadWithCompletionBlock:(void(^)(UIImage *image, NSURL *url, NSError *error))handler;
- (void)loadWithURL:(NSURL *)url;
- (void)loadWithURL:(NSURL*)url completionBlock:(void(^)(UIImage *image, NSURL *url, NSError *error))handler;
//- (void)setImage:(UIImage *)image forURL:(NSURL*)url;


@end
