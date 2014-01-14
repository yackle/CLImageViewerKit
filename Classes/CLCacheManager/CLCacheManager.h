//
//  CLCacheManager.h
//
//  Created by sho yakushiji on 2013/05/17.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CLCacheManager : NSObject

@property (nonatomic, readonly) NSString *identifier;

+ (CLCacheManager*)defaultManager;
+ (CLCacheManager*)managerWithIdentifier:(NSString*)identifier;


+ (void)limitNumberOfCacheFiles:(NSInteger)numberOfCacheFiles;
- (void)limitNumberOfCacheFiles:(NSInteger)numberOfCacheFiles;

+ (void)removeCacheForURL:(NSURL*)url;
- (void)removeCacheForURL:(NSURL*)url;

+ (void)removeCacheDirectory;
- (void)removeCacheDirectory;

// NSData caching
+ (void)storeData:(NSData*)data forURL:(NSURL*)url storeMemoryCache:(BOOL)storeMemoryCache;
- (void)storeData:(NSData*)data forURL:(NSURL*)url storeMemoryCache:(BOOL)storeMemoryCache;

+ (NSData*)localCachedDataWithURL:(NSURL*)url;
- (NSData*)localCachedDataWithURL:(NSURL*)url;

+ (NSData*)dataWithURL:(NSURL*)url storeMemoryCache:(BOOL)storeMemoryCache;
- (NSData*)dataWithURL:(NSURL*)url storeMemoryCache:(BOOL)storeMemoryCache;

// UIImage caching
+ (void)storeMemoryCacheWithImage:(UIImage*)image forURL:(NSURL*)url;
- (void)storeMemoryCacheWithImage:(UIImage*)image forURL:(NSURL*)url;

+ (UIImage*)imageWithURL:(NSURL*)url storeMemoryCache:(BOOL)storeMemoryCache;
- (UIImage*)imageWithURL:(NSURL*)url storeMemoryCache:(BOOL)storeMemoryCache;

@end
