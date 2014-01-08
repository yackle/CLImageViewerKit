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

@interface CLFileAttribute : NSObject
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSDictionary *fileAttributes;
@property (nonatomic, readonly) NSDate *fileModificationDate;
- (id)initWithPath:(NSString*)filePath attributes:(NSDictionary*)attributes;
@end


@implementation CLCacheManager
{
    NSCache *_memoryCache;
}

#pragma mark- singleton pattern

static CLCacheManager *_sharedInstance = nil;
static NSString *_sharedCacheDirectoryPath = nil;

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

#pragma mark- wrapper

+ (void)removeCacheDirectory
{
    [self.manager removeCacheDirectory];
    _sharedCacheDirectoryPath = nil;
}

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
    if(_sharedCacheDirectoryPath==nil){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _sharedCacheDirectoryPath = [paths.lastObject stringByAppendingPathComponent:NSStringFromClass(self)];
        [self checkWorkspace:_sharedCacheDirectoryPath];
    }
    
    return _sharedCacheDirectoryPath;
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

+ (NSArray*)fileAttributesInWorkSpace
{
    NSString *rootDir = self.cacheDirectory;
    NSMutableArray *files = [NSMutableArray array];
    
    for(int i=0; i<16; i++) {
        for(int j=0; j<16; j++) {
            NSString *subDir = [NSString stringWithFormat:@"%@/%X%X", rootDir, i, j];
            NSArray *list = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:subDir error:nil];
            
            for(id name in list){
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", subDir, name];
                NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
                if(attr){
                    [files addObject:[[CLFileAttribute alloc] initWithPath:filePath attributes:attr]];
                }
            }
        }
    }
    return files;
}

+ (NSString*)pathForHash:(NSString*)hash
{
    return  [NSString stringWithFormat:@"%@/%@/%@", self.cacheDirectory, [hash substringToIndex:2], hash];
}

#pragma mark- Caching control

+ (void)limitNumberOfCacheFiles:(NSInteger)numberOfCacheFiles
{
    NSArray *list = [self fileAttributesInWorkSpace];
    
    NSSortDescriptor *dsc = [NSSortDescriptor sortDescriptorWithKey:@"fileModificationDate" ascending:NO];
    list = [list sortedArrayUsingDescriptors:@[dsc]];
    
    for(NSInteger i=numberOfCacheFiles; i<list.count; ++i){
        CLFileAttribute *file = list[i];
        [[NSFileManager defaultManager] removeItemAtPath:file.filePath error:nil];
    }
}

+ (void)didAccessToDataForHash:(NSString*)hash
{
    NSString *path = [CLCacheManager pathForHash:hash];
    
    NSError *err = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableDictionary *fileAttribute = [[fileManager attributesOfItemAtPath:path error:&err] mutableCopy];
    
    if(err){ return; }
    
    fileAttribute[NSFileModificationDate] = [NSDate date];
    [fileManager setAttributes:fileAttribute ofItemAtPath:path error:nil];
}

#pragma mark- Caching control

- (void)removeCacheForHash:(NSString*)hash
{
    [_memoryCache removeObjectForKey:hash];
    
    [[NSFileManager defaultManager] removeItemAtPath:[CLCacheManager pathForHash:hash] error:nil];
}

- (void)removeCacheDirectory
{
    [_memoryCache removeAllObjects];
    [[NSFileManager defaultManager] removeItemAtPath:[CLCacheManager cacheDirectory] error:nil];
}

#pragma mark- NSData caching

- (NSData*)localCachedDataWithHash:(NSString*)hash
{
    [CLCacheManager didAccessToDataForHash:hash];
    return [NSData dataWithContentsOfFile:[CLCacheManager pathForHash:hash]];
}

- (NSData*)cachedDataWithHash:(NSString*)hash storeMemoryCache:(BOOL)storeMemoryCache
{
    NSData   *data = [_memoryCache objectForKey:hash];
    if(data){
        [CLCacheManager didAccessToDataForHash:hash];
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
    [CLCacheManager didAccessToDataForHash:hash];
    
    if(storeMemoryCache){
        [_memoryCache setObject:data forKey:hash];
    }
    [data writeToFile:[CLCacheManager pathForHash:hash] atomically:NO];
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



@implementation CLFileAttribute

- (id)initWithPath:(NSString *)filePath attributes:(NSDictionary *)attributes
{
    self = [super init];
    if(self){
        self.filePath = filePath;
        self.fileAttributes = attributes;
    }
    return self;
}

- (NSDate*)fileModificationDate
{
    return [_fileAttributes fileModificationDate];
}

@end
