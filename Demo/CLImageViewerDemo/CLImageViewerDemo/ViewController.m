//
//  ViewController.m
//  FullscreenImageViewer
//
//  Created by sho yakushiji on 2013/11/24.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "ViewController.h"

#import <CLImagePagingView.h>
#import <CLFullscreenImageViewer.h>
#import <UIImage+Placeholder.h>


@interface ViewController ()
<CLFullscreenImageViewerDelegate>
@end

@implementation ViewController
{
    NSMutableArray *_imageViews;
    CLImagePagingView *_pagingView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    
    _imageViews = [NSMutableArray array];
    [_imageViews addObject:[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 200)]];
    [_imageViews addObject:[[UIImageView alloc] initWithFrame:CGRectMake(160, 0, 160, 150)]];
    [_imageViews addObject:[[UIImageView alloc] initWithFrame:CGRectMake(160, 150, 160, 50)]];
    [_imageViews addObject:[[UIImageView alloc] initWithFrame:CGRectMake(5, 440, 200, 100)]];
    [_imageViews addObject:[[UIImageView alloc] initWithFrame:CGRectMake(110, 440, 100, 200)]];
    [_imageViews addObject:[[UIImageView alloc] initWithFrame:CGRectMake(215, 440, 100, 100)]];
    
    
    for(UIImageView *view in _imageViews){
        [self.view addSubview:view];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedScrollView:)];
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:gesture];
        
        if([_imageViews indexOfObject:view]<3){
            [UIImage placekitten:CGSizeMake(view.frame.size.width*2, view.frame.size.height*2) completionBlock:^(UIImage *image) {
                view.image = image;
            }];
        }
        else{
            view.image = [UIImage placeholder:CGSizeMake(view.frame.size.width*2, view.frame.size.height*2)];
            
            CGFloat scale = (arc4random()%1000)/1000.0 + 0.2;
            CGAffineTransform trans = CGAffineTransformIdentity;
            trans = CGAffineTransformRotate(trans, 2*M_PI*(arc4random()%1000)/1000.0);
            trans = CGAffineTransformScale(trans, scale, scale);
            view.transform = trans;
        }
    }
    
    _pagingView = [[CLImagePagingView alloc] initWithFrame:CGRectMake(20, 220, 280, 200)];
    _pagingView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    [self.view addSubview:_pagingView];
    
    for(int i=0;i<3; ++i){
        [UIImage placekitten:CGSizeMake(arc4random()%500+100, arc4random()%500+100) completionBlock:^(UIImage *image) {
            [_pagingView addImage:image];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Gesture event

- (void)tappedScrollView:(UITapGestureRecognizer*)sender
{
    CLFullscreenImageViewer *full = [CLFullscreenImageViewer new];
    full.delegate = self;
    
    [full showWithImageViews:_imageViews selectedView:(UIImageView*)sender.view];
}

#pragma mark- CLFullscreenImageViewerDelegate

- (void)fullscreenImageViewer:(CLFullscreenImageViewer *)view willDismissWithSelectedView:(UIImageView *)selectedView
{
    
}

@end
