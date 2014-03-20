//
//  CLImagePickerBundle.m
//
//  Created by sho yakushiji on 2014/01/17.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import "CLImagePickerBundle.h"

#import <CLImageEditor.h>
#import <CLImageViewerController.h>

@interface CLImagePickerBundle()
@property (nonatomic, weak) id<CLImagePickerBundleDelegate> delegate;
@property (nonatomic, strong) NSString *bundleName;
@property (nonatomic, strong) UIColor *tintColor;
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

+ (CLImageViewerController*)imageViewer
{
    if([self.instance.delegate respondsToSelector:@selector(imageViewerForImagePicker)]){
        return [self.instance.delegate imageViewerForImagePicker];
    }
    return [CLImageViewerController new];
}

+ (CAAnimation*)selectButtonAnimation:(BOOL)selected
{
    if([self.instance.delegate respondsToSelector:@selector(selectButtonAnimation:)]){
        return [self.instance.delegate selectButtonAnimation:selected];
    }
    
    // default animation
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    CGFloat scale1 = (selected) ? 1.2 : 0.8;
    CGFloat scale2 = (selected) ? 0.85 : 1.1;
    
    CATransform3D startScale = CATransform3DIdentity;
    CATransform3D overshootScale1 = CATransform3DMakeScale(scale1, scale1, 1);
    CATransform3D overshootScale2 = CATransform3DMakeScale(scale2, scale2, 1);
    CATransform3D endingScale = CATransform3DIdentity;
    
    NSMutableArray *values = [NSMutableArray arrayWithObject:[NSValue valueWithCATransform3D:startScale]];
    NSMutableArray *keyTimes = [NSMutableArray arrayWithObject:@0.0f];
    NSMutableArray *timingFunctions = [NSMutableArray arrayWithObject:[CAMediaTimingFunction functionWithControlPoints:0.2 :0.0 :0.3 :1.0]];
    
    [values addObject:[NSValue valueWithCATransform3D:overshootScale1]];
    [keyTimes addObject:@0.4f];
    [timingFunctions addObject:[CAMediaTimingFunction functionWithControlPoints:0.7 :0.0 :0.8 :1.0]];
    
    [values addObject:[NSValue valueWithCATransform3D:overshootScale2]];
    [keyTimes addObject:@0.7f];
    [timingFunctions addObject:[CAMediaTimingFunction functionWithControlPoints:0.8 :0.0 :0.9 :1.0]];
    
    [values addObject:[NSValue valueWithCATransform3D:endingScale]];
    [keyTimes addObject:@1.0f];
    [timingFunctions addObject:[CAMediaTimingFunction functionWithControlPoints:0.6 :0.0 :0.9 :1.0]];
    
    scaleAnimation.values = values;
    scaleAnimation.keyTimes = keyTimes;
    scaleAnimation.timingFunctions = timingFunctions;
    scaleAnimation.duration = 0.3;
    
    return scaleAnimation;
}

@end
