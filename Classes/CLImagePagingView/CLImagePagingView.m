//
//  CLImagePagingView.m
//
//  Created by sho yakushiji on 2013/11/21.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "CLImagePagingView.h"

#import "../CLFullscreenImageViewer/CLFullscreenImageViewer.h"

@interface CLImagePagingView()
<CLFullscreenImageViewerDelegate, UIScrollViewDelegate>
@property (nonatomic, assign) NSInteger pageIndex;
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
    self.backgroundColor = [UIColor clearColor];
    
    _imgViews = [NSMutableArray array];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator   = NO;
    _scrollView.clipsToBounds = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.delegate = self;
    
    [self addSubview:_scrollView];
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedScrollView:)];
    self.allowsFullscreenSlideshow = YES;
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

- (NSArray*)imageViews
{
    return [_imgViews copy];
}

- (void)addImageView:(UIImageView*)imageView
{
    imageView.frame = [self contentFrameWithIndex:_imgViews.count];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.tag = _imgViews.count;
    
    [_imgViews addObject:imageView];
    [_scrollView addSubview:imageView];
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _imgViews.count, 0);
}

- (void)addImage:(UIImage *)image
{
    [self addImageView:[[UIImageView alloc] initWithImage:image]];
}

- (void)removeAllImageViews
{
    for(UIView *view in _imgViews){ [view removeFromSuperview]; }
    [_imgViews removeAllObjects];
    _pageIndex = 0;
}

- (void)setPageIndex:(NSInteger)pageIndex
{
    if(pageIndex != _pageIndex){
        _pageIndex = pageIndex;
        
        if([self.delegate respondsToSelector:@selector(imagePagingView:didChangePageIndex:)]){
            [self.delegate imagePagingView:self didChangePageIndex:_pageIndex];
        }
    }
}

- (void)setPageIndex:(NSInteger)pageIndex animated:(BOOL)animated
{
    if(pageIndex != self.pageIndex && pageIndex>=0 && pageIndex<_imgViews.count){
        self.pageIndex = pageIndex;
        [_scrollView setContentOffset:CGPointMake(pageIndex * _scrollView.frame.size.width, 0) animated:animated];
    }
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

#pragma mark- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageIndex = (_scrollView.contentOffset.x / _scrollView.frame.size.width + 0.5);
}

#pragma CLFullscreenImageViewerDelegate

- (void)fullscreenImageViewer:(CLFullscreenImageViewer *)view willDismissWithSelectedView:(UIImageView *)selectedView
{
    [self setPageIndex:[_imgViews indexOfObject:selectedView] animated:NO];
}

@end
