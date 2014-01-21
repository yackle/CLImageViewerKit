//
//  CLImagePickerManager.h
//
//  Created by sho yakushiji on 2014/01/14.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLImageViewerController.h"

@protocol CLImagePickerManagerDelegate;

@interface CLImagePickerManager : NSObject

@property (nonatomic, weak) id<CLImagePickerManagerDelegate> delegate;
@property (nonatomic, readonly) NSUInteger numberOfSelectedImages;

+ (CLImagePickerManager*)managerWithDelegate:(UIViewController<CLImagePickerManagerDelegate>*)delegate;

- (UIViewController*)pickerViewController;

- (UIImage*)thumnailImageAtIndex:(NSUInteger)index;
- (UIImage*)fullScreenImageAtIndex:(NSUInteger)index;

- (void)showImageViewerInViewController:(UIViewController<CLImageViewerControllerDelegate>*)controller withIndex:(NSUInteger)index;
- (void)showImageViewerInWindowWithDelegate:(id<CLImageViewerControllerDelegate>)delegate index:(NSUInteger)index;

@end


@protocol CLImagePickerManagerDelegate <NSObject>
@optional
- (void)imagePickerManagerWillDismissImagePicker:(CLImagePickerManager*)manager canceled:(BOOL)canceled;
- (void)imagePickerManagerDidDismissImagePicker:(CLImagePickerManager*)manager canceled:(BOOL)canceled;

@end