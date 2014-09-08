//
//  CLAsset.m
//
//  Created by sho yakushiji on 2014/01/10.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import "CLAsset.h"

@implementation CLAsset
{
    ALAsset *_asset;
}

- (id)initWithAsset:(ALAsset *)asset
{
    self = [super init];
    if(self){
        _asset = asset;
    }
    return self;
}

- (NSURL*)assetURL
{
    return [[_asset valueForProperty:ALAssetPropertyURLs] objectForKey:[[_asset defaultRepresentation] UTI]];
}

- (UIImage*)thumbnail
{
    return [UIImage imageWithCGImage:[_asset thumbnail]];
}

- (UIImage*)aspectRatioThumbnail
{
    return [UIImage imageWithCGImage:[_asset aspectRatioThumbnail]];
}

- (UIImage*)fullScreenImage
{
    return [UIImage imageWithCGImage:[[_asset defaultRepresentation] fullScreenImage]];
}

@end
