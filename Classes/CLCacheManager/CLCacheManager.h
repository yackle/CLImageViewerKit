//
//  CLCacheManager.h
//
//  Created by sho yakushiji on 2013/05/17.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CLCacheManager : NSObject

+ (void)removeCacheDirectory;
+ (void)limitNumberOfCacheFiles:(NSInteger)numberOfCacheFiles;

+ (NSData*)localCachedDataWithURL:(NSURL*)url;
+ (void)removeCacheForURL:(NSURL*)url;

// NSData caching
+ (void)storeData:(NSData*)data forURL:(NSURL*)url storeMemoryCache:(BOOL)storeMemoryCache;
+ (NSData*)dataWithURL:(NSURL*)url;
+ (NSData*)dataWithURL:(NSURL*)url storeMemoryCache:(BOOL)storeMemoryCache;

// UIImage caching
+ (void)storeMemoryCacheWithImage:(UIImage*)image forURL:(NSURL*)url;
+ (UIImage*)imageWithURL:(NSURL*)url;
+ (UIImage*)imageWithURL:(NSURL*)url storeMemoryCache:(BOOL)storeMemoryCache;

@end
