//
//  CLAsset.h
//
//  Created by sho yakushiji on 2014/01/10.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AssetsLibrary/AssetsLibrary.h>

@interface CLAsset : NSObject

- (id)initWithAsset:(ALAsset*)asset;

- (NSURL*)assetURL;
- (UIImage*)thumbnail;
- (UIImage*)aspectRatioThumbnail;
- (UIImage*)fullScreenImage;

@end
