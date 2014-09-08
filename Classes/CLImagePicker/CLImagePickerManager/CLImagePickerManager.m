//
//  CLImagePickerManager.m
//
//  Created by sho yakushiji on 2014/01/14.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import "CLImagePickerManager.h"

#import "UIImage+Utility.h"
#import "CLCacheManager.h"
#import "CLImagePickerBundle.h"
#import "CLImagePickerController.h"
#import "CLImageViewerController.h"


@interface CLImagePickerManager()
<CLImagePickerControllerDelegate, CLImageViewerControllerDataSource>
@end

@implementation CLImagePickerManager
{
    CLCacheManager *_cacheManager;
    NSMutableOrderedSet *_selectedURLs;
    NSString *_identifier;
}

static NSMapTable *_managerPool = nil;

+ (CLImagePickerManager*)managerWithDelegate:(id<CLImagePickerManagerDelegate>)delegate;
{
    if(_managerPool==nil){ _managerPool = [NSMapTable strongToWeakObjectsMapTable]; }
    
    CLImagePickerManager *instance = [[CLImagePickerManager alloc] init];
    instance.delegate = delegate;
    
    [_managerPool setObject:instance forKey:instance.identifier];
    
    return instance;
}

+ (NSString*)availableIdentifier
{
    NSInteger i = 0;
    NSString *key = [NSString stringWithFormat:@"%@%ld", NSStringFromClass(self.class), i];
    
    while ([_managerPool objectForKey:key]!=nil) {
        ++i;
        key = [NSString stringWithFormat:@"%@%ld", NSStringFromClass(self.class), i];
    }
    return key;
}

- (id)init
{
    self = [super init];
    if(self){
        _identifier = [self.class availableIdentifier];
        _cacheManager = [CLCacheManager managerWithIdentifier:_identifier];
        [_cacheManager removeCacheDirectory];
        
        _selectedURLs = [NSMutableOrderedSet new];
    }
    return self;
}

- (void)dealloc
{
    [_cacheManager removeCacheDirectory];
}

- (NSUInteger)numberOfSelectedImages
{
    return _selectedURLs.count;
}

- (NSString*)identifier
{
    return _identifier;
}

#pragma mark- Instance method

- (UIImage*)thumnailImageAtIndex:(NSUInteger)index
{
    NSURL *url = [self thumnailURLAtIndex:index];
    if(url){
        return [self cachedImageWithURL:url];
    }
    return nil;
}

- (UIImage*)fullScreenImageAtIndex:(NSUInteger)index
{
    NSURL *url = [self fullScreenURLAtIndex:index];
    if(url){
        return [self cachedImageWithURL:url];
    }
    return nil;
}

- (NSURL*)thumnailURLAtIndex:(NSUInteger)index
{
    if(index<_selectedURLs.count){
        NSURL *url = _selectedURLs[index];
        NSURL *edittedThumnailURL = [self thumnailURLForURL:[self edittedImageURLForURL:url]];
        if([self existsImageForURL:edittedThumnailURL]){
            return edittedThumnailURL;
        }
        return [self thumnailURLForURL:url];
    }
    return nil;
}

- (NSURL*)fullScreenURLAtIndex:(NSUInteger)index
{
    if(index<_selectedURLs.count){
        NSURL *url = _selectedURLs[index];
        NSURL *edittedImageURL = [self edittedImageURLForURL:url];
        if([self existsImageForURL:edittedImageURL]){
            return edittedImageURL;
        }
        return url;
    }
    return nil;
}

- (void)selectImage:(UIImage*)image forURL:(NSURL*)url
{
    if(url.absoluteString.length<=0){ return; }
    
    if(image && ![self existsImageForURL:url]){
        [self cacheImage:image forURL:url];
    }
    [_selectedURLs addObject:url];
}

- (void)setImage:(UIImage*)image forSelectedURL:(NSURL*)url
{
    if(image && [_selectedURLs containsObject:url]){
        [self cacheImage:image forURL:url];
    }
}

#pragma mark- Get Image

- (UIImage*)thumnailImageForURL:(NSURL*)url
{
    NSURL *edittedThumnailURL = [self thumnailURLForURL:[self edittedImageURLForURL:url]];
    if([self existsImageForURL:edittedThumnailURL]){
        return [self cachedImageWithURL:edittedThumnailURL];
    }
    return [self cachedImageWithURL:[self thumnailURLForURL:url]];
}

- (UIImage*)fullScreenImageForURL:(NSURL*)url
{
    NSURL *edittedImageURL = [self edittedImageURLForURL:url];
    if([self existsImageForURL:edittedImageURL]){
        return [self cachedImageWithURL:edittedImageURL];
    }
    return [self cachedImageWithURL:url];
}

#pragma mark- Caching

- (NSURL*)edittedImageURLForURL:(NSURL*)url
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@_editted", url.absoluteString]];
}

- (NSURL*)thumnailURLForURL:(NSURL*)url
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@_thumnail", url.absoluteString]];
}

- (void)storeImage:(UIImage*)image forURL:(NSURL*)url
{
    NSData *data = UIImagePNGRepresentation(image);
    [_cacheManager storeData:data forURL:url storeMemoryCache:NO];
}

- (BOOL)existsImageForURL:(NSURL*)url
{
    return [_cacheManager existsDataForURL:url];
}

- (void)cacheImage:(UIImage*)image forURL:(NSURL*)url
{
    CGFloat ratio = MAX(255.0/image.size.width, 255.0/image.size.height);
    UIImage *thumnailImage = [image aspectFill:CGSizeMake(ratio*image.size.width, ratio*image.size.height)];
    NSURL *thumnailURL = [self thumnailURLForURL:url];
    
    [self storeImage:thumnailImage forURL:thumnailURL];
    [self storeImage:image forURL:url];
}

- (void)removeCachedImageForURL:(NSURL*)url
{
    [_cacheManager removeCacheForURL:url];
    [_cacheManager removeCacheForURL:[self thumnailURLForURL:url]];
}

- (UIImage*)cachedImageWithURL:(NSURL*)url
{
    return [_cacheManager imageWithURL:url storeMemoryCache:NO];
}

#pragma mark- CLImagePickerController

-(UIViewController*)pickerViewController
{
    NSString *nibName = NSLocalizedStringWithDefaultValue(@"CLImagePickerController_NibName", nil, [CLImagePickerBundle bundle], @"CLImagePickerController", @"");
    
    CLImagePickerController *picker = [[CLImagePickerController alloc] initWithNibName:nibName bundle:nil];
    picker.delegate = self;
    picker.selectedURLs = _selectedURLs.array;
    
    return picker;
}

- (void)dismissPickerViewController:(CLImagePickerController*)picker canceled:(BOOL)canceled
{
    if([self.delegate respondsToSelector:@selector(imagePickerManagerWillDismissImagePicker:canceled:)]){
        [self.delegate imagePickerManagerWillDismissImagePicker:self canceled:canceled];
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        if([self.delegate respondsToSelector:@selector(imagePickerManagerDidDismissImagePicker:canceled:)]){
            [self.delegate imagePickerManagerDidDismissImagePicker:self canceled:canceled];
        }
    }];
}

#pragma mark Delegate

- (void)imagePickerController:(CLImagePickerController *)picker didTouchOriginalImage:(UIImage *)image withAssetURL:(NSURL *)url
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(![self existsImageForURL:url]){
            [self cacheImage:image forURL:url];
        }
    });
}

- (void)imagePickerController:(CLImagePickerController *)picker didEditImage:(UIImage*)image withAssetURL:(NSURL*)url
{
    [self cacheImage:image forURL:[self edittedImageURLForURL:url]];
}

- (void)imagePickerController:(CLImagePickerController *)picker didRemoveEdittedImageWithAssetURL:(NSURL*)url
{
    [self removeCachedImageForURL:[self edittedImageURLForURL:url]];
}

- (BOOL)imagePickerController:(CLImagePickerController *)picker isEdittedImageWithAssetURL:(NSURL*)url
{
    return [self existsImageForURL:[self edittedImageURLForURL:url]];
}

- (UIImage*)imagePickerController:(CLImagePickerController *)picker thumnailImageForAssetURL:(NSURL*)url
{
    return [self thumnailImageForURL:url];
}

- (UIImage*)imagePickerController:(CLImagePickerController *)picker fullScreenImageForAssetURL:(NSURL*)url
{
    return [self fullScreenImageForURL:url];
}

- (void)imagePickerController:(CLImagePickerController *)picker didFinishPickingMediaWithSelectedAssetURLs:(NSArray*)selectedURLs
{
    _selectedURLs = [[NSMutableOrderedSet alloc] initWithArray:selectedURLs];
    [self dismissPickerViewController:picker canceled:NO];
}

- (void)imagePickerControllerDidCancel:(CLImagePickerController *)picker
{
    [self dismissPickerViewController:picker canceled:NO];
}

#pragma mark- CLImageViewerController

- (void)showImageViewerInViewController:(UIViewController<CLImageViewerControllerDelegate>*)controller withIndex:(NSUInteger)index
{
    if(_selectedURLs.count>0){
        CLImageViewerController *viewer = [CLImagePickerBundle imageViewer];
        viewer.dataSource = self;
        viewer.delegate = controller;
        
        [viewer showInViewController:controller withIndex:index];
    }
}

- (void)showImageViewerInWindowWithDelegate:(id<CLImageViewerControllerDelegate>)delegate index:(NSUInteger)index
{
    if(_selectedURLs.count>0){
        CLImageViewerController *viewer = [CLImagePickerBundle imageViewer];
        viewer.dataSource = self;
        viewer.delegate = delegate;
        
        [viewer showInWindowWithIndex:index];
    }
}

#pragma mark DataSource

- (NSInteger)imageViewerControllerNumberOfImages:(CLImageViewerController*)viewer
{
    return _selectedURLs.count;
}

- (UIImage*)imageViewerController:(CLImageViewerController*)viewer originalImageAtIndex:(NSInteger)index
{
    if(index<_selectedURLs.count){
        return [self cachedImageWithURL:[_selectedURLs objectAtIndex:index]];
    }
    return nil;
}

- (UIImage*)imageViewerController:(CLImageViewerController*)viewer thumnailImageAtIndex:(NSInteger)index
{
    return [self thumnailImageAtIndex:index];
}

- (UIImage*)imageViewerController:(CLImageViewerController*)viewer fullScreenImageAtIndex:(NSInteger)index
{
    return [self fullScreenImageAtIndex:index];
}

- (BOOL)imageViewerController:(CLImageViewerController*)viewer isSelectedImageAtIndex:(NSInteger)index
{
    return YES;
}

- (BOOL)imageViewerController:(CLImageViewerController*)viewer isEditedImageAtIndex:(NSInteger)index
{
    if(index<_selectedURLs.count){
        return [self existsImageForURL:[self edittedImageURLForURL:[_selectedURLs objectAtIndex:index]]];
    }
    return NO;
}

- (void)imageViewerController:(CLImageViewerController*)viewer didSelectImageAtIndex:(NSInteger)index
{
    
}

- (void)imageViewerController:(CLImageViewerController*)viewer didDeSelectImageAtIndex:(NSInteger)index
{
    [_selectedURLs removeObjectAtIndex:index];
    [viewer removeImageAtIndex:index];
    
    if(_selectedURLs.count==0){
        [viewer dismissFromParentViewController];
    }
}

- (void)imageViewerController:(CLImageViewerController *)viewer willEditImageAtIndex:(NSInteger)index
{
    
}

- (void)imageViewerController:(CLImageViewerController*)viewer didEditImageAtIndex:(NSInteger)index edittedImage:(UIImage*)image
{
    if(index<_selectedURLs.count){
        [self cacheImage:image forURL:[self edittedImageURLForURL:[_selectedURLs objectAtIndex:index]]];
    }
}

- (void)imageViewerController:(CLImageViewerController*)viewer didRemoveEdittedImageAtIndex:(NSInteger)index
{
    if(index<_selectedURLs.count){
        [self removeCachedImageForURL:[self edittedImageURLForURL:[_selectedURLs objectAtIndex:index]]];
    }
}

@end
