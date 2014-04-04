//
//  CLImageView.m
//
//  Created by sho yakushiji on 2013/11/25.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "CLImageView.h"

#import "CLCacheManager.h"



#pragma mark- UIImageView+URLDownload's private methods

@interface UIImageView (URLDownloadPrivate)
- (UIImage*)didFinishDownloadWithData:(NSData*)data forURL:(NSURL*)url error:(NSError*)error;
- (void)setImage:(UIImage *)image forURL:(NSURL *)url;
@end




#pragma mark- CLImageView

@implementation CLImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self customInit];
    }
    return self;
    
}

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if(self){
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    _useLocalCache = NO;
}

- (void)load
{
    if(self.useLocalCache){
        UIImage *img = [CLCacheManager imageWithURL:self.url storeMemoryCache:YES];
        if(img){
            [super setImage:img forURL:self.url];
            return;
        }
    }
    [super load];
}

- (UIImage*)didFinishDownloadWithData:(NSData *)data forURL:(NSURL *)url error:(NSError *)error
{
    if(self.useLocalCache){
        [CLCacheManager storeData:data forURL:url storeMemoryCache:NO];
    }
    return [super didFinishDownloadWithData:data forURL:url error:error];
}

- (void)setImage:(UIImage *)image forURL:(NSURL *)url
{
    [super setImage:image forURL:url];
    
    if(self.useLocalCache){
        [CLCacheManager storeMemoryCacheWithImage:image forURL:url];
    }
}

@end
