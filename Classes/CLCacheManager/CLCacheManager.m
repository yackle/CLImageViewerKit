//
//  CLCacheManager.m
//
//  Created by sho yakushiji on 2013/05/17.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "CLCacheManager.h"

#import <CommonCrypto/CommonHMAC.h>
#import "UIImage+Utility.h"

@interface NSString(CLCacheManager)
- (NSString*)MD5Hash;
@end


@implementation CLCacheManager
{
    NSCache *_memoryCache;
}

#pragma mark- singleton pattern

static CLCacheManager *_sharedInstance = nil;

+ (CLCacheManager*)manager
{
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [CLCacheManager new];
    });
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [super allocWithZone:zone];
            return _sharedInstance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        _memoryCache = [NSCache new];
        _memoryCache.countLimit = 50;
    }
    return self;
}

- (void)dealloc
{
    [_memoryCache removeAllObjects];
}

#pragma mark- delete all

+ (void)removeCacheDirectory
{
    [_memoryCache removeAllObjects];
    
    NSString *path = [self cacheDirectory];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

#pragma mark- wrapper

+ (NSData*)localCachedDataWithURL:(NSURL*)url
{
    if(url.absoluteString.length>0){
        return [self.manager localCachedDataWithHash:url.absoluteString.MD5Hash];
    }
    return nil;
}

+ (void)removeCacheForURL:(NSURL *)url
{
    if(url.absoluteString.length>0){
        [self.manager removeCacheForHash:url.absoluteString.MD5Hash];
    }
}

#pragma mark- NSData caching

+ (void)storeData:(NSData *)data forURL:(NSURL *)url storeMemoryCache:(BOOL)storeMemoryCache
{
    if(data && url.absoluteString.length>0){
        [self.manager storeData:data forHash:url.absoluteString.MD5Hash storeMemoryCache:storeMemoryCache];
    }
}

+ (NSData*)dataWithURL:(NSURL*)url storeMemoryCache:(BOOL)storeMemoryCache
{
    return [self.manager dataWithURL:url storeMemoryCache:storeMemoryCache];
}

+ (NSData*)dataWithURL:(NSURL*)url
{
    return [self.manager dataWithURL:url storeMemoryCache:NO];
}

#pragma mark- UIImage caching

+ (void)storeMemoryCacheWithImage:(UIImage*)image forURL:(NSURL*)url
{
    if(image && url.absoluteString.length>0){
        [self.manager storeMemoryCacheWithImage:image forHash:url.absoluteString.MD5Hash];
    }
}

+ (UIImage*)imageWithURL:(NSURL*)url storeMemoryCache:(BOOL)storeMemoryCache
{
    return [self.manager imageWithURL:url storeMemoryCache:storeMemoryCache];
}

+ (UIImage*)imageWithURL:(NSURL*)url
{
    return [self.manager imageWithURL:url storeMemoryCache:YES];
}

#pragma mark- directory operation

+ (NSString*)cacheDirectory
{
    static NSString *cacheDir = nil;
    
    if(cacheDir==nil){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        cacheDir = [paths.lastObject stringByAppendingPathComponent:NSStringFromClass(self)];
        [self checkWorkspace:cacheDir];
    }
    
    return cacheDir;
}

+ (void)checkWorkspace:(NSString*)rootDir
{
    BOOL isDirectory = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:rootDir isDirectory:&isDirectory];
    
    if(!exists || !isDirectory){
        [[NSFileManager defaultManager] createDirectoryAtPath:rootDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    for(int i=0; i<16; i++) {
        for(int j=0; j<16; j++) {
            NSString *subDir = [NSString stringWithFormat:@"%@/%X%X", rootDir, i, j];
            isDirectory = NO;
            exists = [[NSFileManager defaultManager] fileExistsAtPath:subDir isDirectory:&isDirectory];
            if(!exists || !isDirectory){
                [[NSFileManager defaultManager] createDirectoryAtPath:subDir withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }
    }
}

+ (NSString*)pathForHash:(NSString*)hash
{
    return  [NSString stringWithFormat:@"%@/%@/%@", self.cacheDirectory, [hash substringToIndex:2], hash];
}

#pragma mark- NSData caching

- (NSData*)localCachedDataWithHash:(NSString*)hash
{
    return [NSData dataWithContentsOfFile:[CLCacheManager pathForHash:hash]];
}

- (NSData*)cachedDataWithHash:(NSString*)hash storeMemoryCache:(BOOL)storeMemoryCache
{
    NSData   *data = [_memoryCache objectForKey:hash];
    if(data){
        return data;
    }
    
    data = [self localCachedDataWithHash:hash];
    if(storeMemoryCache && data!=nil){
        [_memoryCache setObject:data forKey:hash];
    }
    return data;
}

- (void)storeData:(NSData*)data forHash:(NSString*)hash storeMemoryCache:(BOOL)storeMemoryCache
{
    if(storeMemoryCache){
        [_memoryCache setObject:data forKey:hash];
    }
    [data writeToFile:[CLCacheManager pathForHash:hash] atomically:NO];
}

- (void)removeCacheForHash:(NSString*)hash
{
    [_memoryCache removeObjectForKey:hash];
    
    NSString *path = [CLCacheManager pathForHash:hash];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (NSData*)dataWithURL:(NSURL*)url storeMemoryCache:(BOOL)storeMemoryCache
{
    if(url.absoluteString.length==0){
        return nil;
    }
    return [self cachedDataWithHash:url.absoluteString.MD5Hash storeMemoryCache:storeMemoryCache];
}

#pragma mark- UIImage caching

- (UIImage*)memoryCachedImageWithHash:(NSString*)hash
{
     id data = [_memoryCache objectForKey:hash];
     if([data isKindOfClass:[UIImage class]]){
         return data;
     }
     return nil;
}

- (void)storeMemoryCacheWithImage:(UIImage*)image forHash:(NSString*)hash
{
    [_memoryCache setObject:image forKey:hash];
}

- (UIImage*)imageWithURL:(NSURL*)url storeMemoryCache:(BOOL)storeMemoryCache
{
    if(url.absoluteString.length==0){
        return nil;
    }
    
    id data = [self dataWithURL:url storeMemoryCache:NO];
    
    if(data){
        UIImage *image = nil;
        
        if([data isKindOfClass:[NSData class]]){
            image = [UIImage fastImageWithData:data];
        }
        else if([data isKindOfClass:[UIImage class]]){
            image = (UIImage*)data;
        }
        
        if(image){
            if(storeMemoryCache){
                [self storeMemoryCacheWithImage:image forHash:url.absoluteString.MD5Hash];
            }
            return image;
        }
    }
    return nil;
}

@end



#pragma mark- Utility

@implementation NSString (CLCacheManager)

- (NSString*)MD5Hash
{
    if(self.length==0){ return nil; }
    
	const char *cStr = [self UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}

@end
