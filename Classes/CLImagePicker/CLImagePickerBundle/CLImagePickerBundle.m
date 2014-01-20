//
//  CLImagePickerBundle.m
//
//  Created by sho yakushiji on 2014/01/17.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import "CLImagePickerBundle.h"

#import <CLImageEditor.h>

@interface CLImagePickerBundle()
@property (nonatomic, weak) id<CLImagePickerBundleDelegate> delegate;
@property (nonatomic, strong) NSString *bundleName;
@end

@implementation CLImagePickerBundle

#pragma mark - singleton pattern

static id _sharedInstance = nil;

+ (CLImagePickerBundle*)instance
{
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
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
        self.bundleName = @"CLImagePicker";
    }
    return self;
}

#pragma mark- claas methods

+ (void)setDelegate:(id<CLImagePickerBundleDelegate>)delegate
{
    self.instance.delegate = delegate;
}

+ (void)setBundleName:(NSString*)bundleName
{
    self.instance.bundleName = bundleName;
}

+ (NSString*)bundleName
{
    return self.instance.bundleName;
}

+ (NSBundle*)bundle
{
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:self.bundleName ofType:@"bundle"]];
}

+ (UIImage*)imageNamed:(NSString*)path
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@.bundle/%@", self.bundleName, path]];
}

+ (CLImageEditor*)imageEditor
{
    if([self.instance.delegate respondsToSelector:@selector(imageEditorForImagePicker)]){
        return [self.instance.delegate imageEditorForImagePicker];
    }
    return [CLImageEditor new];
}

@end
