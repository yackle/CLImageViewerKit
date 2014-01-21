//
//  CLImagePickerBundle.h
//
//  Created by sho yakushiji on 2014/01/17.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLImageEditor;
@protocol CLImagePickerBundleDelegate;

@interface CLImagePickerBundle : NSObject

+ (void)setDelegate:(id<CLImagePickerBundleDelegate>)delegate;
+ (void)setBundleName:(NSString*)bundleName;

+ (NSString*)bundleName;
+ (NSBundle*)bundle;
+ (UIImage*)imageNamed:(NSString*)path;
+ (CLImageEditor*)imageEditor;

+ (CAAnimation*)selectButtonAnimation:(BOOL)selected;

@end


@protocol CLImagePickerBundleDelegate <NSObject>
@optional
- (CLImageEditor*)imageEditorForImagePicker;
- (CAAnimation*)selectButtonAnimation:(BOOL)selected;

@end
