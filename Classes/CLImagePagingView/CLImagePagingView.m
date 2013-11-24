//
//  CLImagePagingView.m
//
//  Created by sho yakushiji on 2013/11/21.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "CLImagePagingView.h"

#import "../CLFullscreenImageViewer/CLFullscreenImageViewer.h"

@interface CLImagePagingView()
<CLFullscreenImageViewerDelegate>
@end

@implementation CLImagePagingView
{
    UIScrollView *_scrollView;
    NSMutableArray *_imgViews;
    UITapGestureRecognizer *_tapGesture;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self customInit];
}

- (void)customInit
{
    _imgViews = [NSMutableArray array];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator   = NO;
    _scrollView.clipsToBounds = NO;
    [self addSubview:_scrollView];
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedScrollView:)];
    self.allowsFullscreenSlideshow = YES;
}

- (void)resetViews
{
    for(UIView *view in _imgViews){ [view removeFromSuperview]; }
    [_imgViews removeAllObjects];
    
    for(UIImage *image in self.images){
        if([image isKindOfClass:[UIImage class]]){
            [self addImageViewWithImage:image];
        }
    }
}

- (CGRect)contentFrameWithIndex:(NSInteger)index
{
    CGRect rct = _scrollView.bounds;
    rct.origin.x = self.contentInset.left + index * rct.size.width;
    rct.origin.y = self.contentInset.top;
    rct.size.width  -= (self.contentInset.left + self.contentInset.right);
    rct.size.height -= (self.contentInset.top + self.contentInset.bottom);
    return rct;
}

- (void)addImageViewWithImage:(UIImage*)image
{
    UIImageView *view = [[UIImageView alloc] initWithFrame:[self contentFrameWithIndex:_imgViews.count]];
    view.image = image;
    view.contentMode = UIViewContentModeScaleAspectFill;
    view.clipsToBounds = YES;
    view.tag = _imgViews.count;
    
    [_imgViews addObject:view];
    [_scrollView addSubview:view];
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _imgViews.count, 0);
}

#pragma mark- Properties

- (void)setAllowsFullscreenSlideshow:(BOOL)allowsFullscreenSlideshow
{
    _allowsFullscreenSlideshow = allowsFullscreenSlideshow;
    
    if(_allowsFullscreenSlideshow){
        [_scrollView addGestureRecognizer:_tapGesture];
    }
    else{
        [_scrollView removeGestureRecognizer:_tapGesture];
    }
}

- (void)setImages:(NSArray *)images
{
    if(images != _images){
        _images = images;
        [self resetViews];
    }
}

- (NSArray*)imageViews
{
    return [_imgViews copy];
}

- (void)addImage:(UIImage *)image
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:_images];
    [array addObject:image];
    _images = [array copy];
    
    [self addImageViewWithImage:image];
}

- (NSInteger)pageIndex
{
    return (_scrollView.contentOffset.x / _scrollView.frame.size.width + 0.5);
}

- (void)setPageIndex:(NSInteger)pageIndex
{
    [self setPageIndex:pageIndex animated:NO];
}

- (void)setPageIndex:(NSInteger)pageIndex animated:(BOOL)animated
{
    if(pageIndex>=0 && pageIndex<_imgViews.count){
        [_scrollView setContentOffset:CGPointMake(pageIndex * _scrollView.frame.size.width, 0) animated:animated];
    }
}

- (void)setPageIndexWithImage:(UIImage*)image animated:(BOOL)animated
{
    [self setPageIndex:[self.images indexOfObject:image] animated:animated];
}

#pragma mark- Gesture event

- (void)tappedScrollView:(UITapGestureRecognizer*)sender
{
    if(_imgViews.count>0){
        CLFullscreenImageViewer *full = [CLFullscreenImageViewer new];
        full.delegate = self;
        
        [full showWithImageViews:_imgViews selectedView:_imgViews[self.pageIndex]];
    }
}

#pragma CLFullscreenImageViewerDelegate

- (void)fullscreenImageViewer:(CLFullscreenImageViewer *)view willDismissWithSelectedView:(UIImageView *)selectedView
{
    self.pageIndex = [_imgViews indexOfObject:selectedView];
}

@end
