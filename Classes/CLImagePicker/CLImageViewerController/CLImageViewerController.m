//
//  CLImageViewerController.m
//
//  Created by sho yakushiji on 2014/01/15.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import "CLImageViewerController.h"

#import <CLImageEditor.h>
#import "UIView+Frame.h"
#import "CLZoomingImageCell.h"
#import "CLImageViewerLayout.h"
#import "CLImagePickerBundle.h"

NSString * const CLZoomingImageCellReuseIdentifier = @"ZoomingImageCell";


@interface CLImageViewerController ()
<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLImageEditorTransitionDelegate>

@property (nonatomic, assign) NSInteger currentPageIndex;

@end


@implementation CLImageViewerController
{
    void(^_removeImageBlock)();
    UIViewController *_retainedSelf;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _currentPageIndex = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_collectionView registerClass:[CLZoomingImageCell class] forCellWithReuseIdentifier:CLZoomingImageCellReuseIdentifier];
    _collectionView.alwaysBounceHorizontal = YES;
    _collectionView.allowsMultipleSelection = YES;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.collectionViewLayout = [[CLImageViewerLayout alloc] initWithCellSize:self.view.frame.size];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)];
    pan.maximumNumberOfTouches = 1;
    [_foregroundView addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)];
    [_foregroundView addGestureRecognizer:tap];
    
    [_foregroundView addGestureRecognizer:_collectionView.panGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark- View transition

- (UIImageView*)imageViewAtIndex:(NSInteger)index
{
    UIImageView *imageView = nil;
    if([self.delegate respondsToSelector:@selector(imageViewerController:imageViewAtIndex:)]){
        imageView = [self.delegate imageViewerController:self imageViewAtIndex:self.currentPageIndex];
    }
    return imageView;
}

- (void)copyImageViewInfo:(UIImageView*)fromView toView:(UIImageView*)toView containedImage:(BOOL)contained
{
    CGAffineTransform transform = fromView.transform;
    fromView.transform = CGAffineTransformIdentity;
    
    toView.transform = CGAffineTransformIdentity;
    toView.frame = [toView.superview convertRect:fromView.frame fromView:fromView.superview];
    toView.transform = transform;
    toView.contentMode = fromView.contentMode;
    toView.clipsToBounds = fromView.clipsToBounds;
    toView.layer.cornerRadius = fromView.layer.cornerRadius;
    if(contained){ toView.image = fromView.image; }
    
    fromView.transform = transform;
}

- (void)showInViewController:(UIViewController*)controller withIndex:(NSInteger)index
{
    [controller addChildViewController:self];
    [self didMoveToParentViewController:controller];
    
    [self showInView:controller.view withIndex:index];
}

- (void)showInWindowWithIndex:(NSInteger)index
{
    _retainedSelf = self;
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [self showInView:window withIndex:index];
}

- (void)showInView:(UIView*)view withIndex:(NSInteger)index
{
    self.view.frame = view.bounds;
    [view addSubview:self.view];
    
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    self.currentPageIndex = index;
    
    UIImageView *fromView = [self imageViewAtIndex:index];
    UIImageView *animateView = nil;
    if(fromView){
        animateView = [UIImageView new];
        [self.view addSubview:animateView];
        [self copyImageViewInfo:fromView toView:animateView containedImage:YES];
    }
    
    _collectionView.hidden = (animateView!=nil);
    _collectionView.alpha  = 0;
    _foregroundView.hidden = YES;
    _foregroundView.alpha  = 0;
    _backgroundView.alpha  = 0;
    _backgroundView.backgroundColor = self.view.backgroundColor;
    self.view.backgroundColor = [UIColor clearColor];
    
    if([self.delegate respondsToSelector:@selector(imageViewerController:willAppearWithIndex:)]){
        [self.delegate imageViewerController:self willAppearWithIndex:index];
    }
    [self showWithAnimateView:animateView];
}

- (void)showWithAnimateView:(UIImageView*)animateView
{
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _backgroundView.alpha = 1;
                         _collectionView.alpha = 1;
                         
                         if(animateView){
                             CGSize size = (animateView.image) ? animateView.image.size : self.view.frame.size;
                             CGFloat ratio = MIN(self.view.frame.size.width / size.width, self.view.frame.size.height / size.height);
                             CGFloat W = ratio * size.width;
                             CGFloat H = ratio * size.height;
                             animateView.transform = CGAffineTransformIdentity;
                             animateView.frame = CGRectMake((self.view.width-W)/2, (self.view.height-H)/2, W, H);
                         }
                     }
                     completion:^(BOOL finished) {
                         _collectionView.hidden = NO;
                         [animateView removeFromSuperview];
                         
                         if([self.delegate respondsToSelector:@selector(imageViewerController:didAppearWithIndex:)]){
                             [self.delegate imageViewerController:self didAppearWithIndex:self.currentPageIndex];
                         }
                         
                         _foregroundView.hidden = NO;
                         [UIView animateWithDuration:0.25 animations:^{ _foregroundView.alpha = 1; }];
                     }
     ];
}

- (void)prepareToDismiss
{
    _foregroundView.hidden = YES;
    
    if([self.delegate respondsToSelector:@selector(imageViewerController:willDismissWithIndex:)]){
        [self.delegate imageViewerController:self willDismissWithIndex:self.currentPageIndex];
    }
}

- (void)dismissFromParentViewControllerWithZoomingCell:(CLZoomingImageCell*)cell
{
    if([self.delegate respondsToSelector:@selector(imageViewerController:readyToDismissWithIndex:)]){
        if(![self.delegate imageViewerController:self readyToDismissWithIndex:self.currentPageIndex]){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self dismissFromParentViewControllerWithZoomingCell:cell];
            });
            return;
        }
    }
    
    UIImageView *fromView = cell.imageView;
    UIImageView *toView = [self imageViewAtIndex:self.currentPageIndex];
    
    UIImageView *animateView = nil;
    if(fromView && toView){
        animateView = [UIImageView new];
        [self.view addSubview:animateView];
        [self copyImageViewInfo:fromView toView:animateView containedImage:NO];
        animateView.image = cell.imageView.image;
    }
    
    _collectionView.hidden = (animateView!=nil);
    
    [self willMoveToParentViewController:nil];
    [self dismissWithAnimateView:animateView targetView:toView];
}

- (void)dismissWithAnimateView:(UIImageView*)animateView targetView:(UIImageView*)targetView
{
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _backgroundView.alpha = 0;
                         _collectionView.alpha  = 0;
                         
                         if(animateView){
                             if(targetView){
                                 [self copyImageViewInfo:targetView toView:animateView containedImage:NO];
                             }
                             else{
                                 animateView.left = -animateView.width;
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                         [self removeFromParentViewController];
                         
                         _retainedSelf = nil;
                         
                         if([self.delegate respondsToSelector:@selector(imageViewerController:didDismissWithIndex:)]){
                             [self.delegate imageViewerController:self didDismissWithIndex:self.currentPageIndex];
                         }
                     }
     ];
}

- (void)dismissFromParentViewController
{
    [self prepareToDismiss];
    [self dismissFromParentViewControllerWithZoomingCell:self.presentingCell];
}

- (void)currentPageDidChange
{
    _selectBtn.selected = [self.dataSource imageViewerController:self isSelectedImageAtIndex:self.currentPageIndex];
    [self setClearBtnHidden:![self.dataSource imageViewerController:self isEditedImageAtIndex:self.currentPageIndex]];
}

- (void)setClearBtnHidden:(BOOL)hidden
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         if(hidden){
                             _editCancelBtn.alpha = 0;
                         }
                         else{
                             _editCancelBtn.alpha = 1;
                         }
                     }
                     completion:^(BOOL finished) {
                     }
     ];
}

#pragma mark- Properties

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex
{
    if(currentPageIndex !=  _currentPageIndex){
        _currentPageIndex = currentPageIndex;
        [self currentPageDidChange];
    }
}

- (CLZoomingImageCell*)presentingCell
{
    NSInteger index = self.currentPageIndex;
    return (CLZoomingImageCell*)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

#pragma mark- Item

- (void)removeImageAtIndex:(NSInteger)index
{
    NSInteger N = [_collectionView numberOfItemsInSection:0];
    if(index==N-1 && index>0){
        [_collectionView setContentOffset:CGPointMake(_collectionView.contentOffset.x-10, _collectionView.contentOffset.y) animated:NO];
        if(N==2){
            [_collectionView setContentOffset:CGPointMake(_collectionView.width*(index-1), _collectionView.contentOffset.y) animated:YES];
        }
    }
    
    [_collectionView performBatchUpdates:^
        {
            [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
        }
          completion:^(BOOL finished) {
              if(finished){
                  _currentPageIndex = (_collectionView.contentOffset.x + _collectionView.width/2) / _collectionView.width;
                  [self currentPageDidChange];
              }
          }
     ];
}

#pragma mark- Button actions

- (IBAction)pushedSelectBtn:(id)sender
{
    if(_selectBtn.selected){
        if([self.dataSource respondsToSelector:@selector(imageViewerController:didDeSelectImageAtIndex:)]){
            [self.dataSource imageViewerController:self didDeSelectImageAtIndex:self.currentPageIndex];
        }
    }
    else{
        if([self.dataSource respondsToSelector:@selector(imageViewerController:didSelectImageAtIndex:)]){
            [self.dataSource imageViewerController:self didSelectImageAtIndex:self.currentPageIndex];
        }
    }
    _selectBtn.selected = !_selectBtn.selected;
    
    UIButton *btn = sender;
    CAAnimation *animation = [CLImagePickerBundle selectButtonAnimation:btn.selected];
    
    [CATransaction begin];
    [btn.layer addAnimation:animation forKey:nil];
    [CATransaction commit];
}

- (IBAction)pushedEditBtn:(id)sender
{
    if([self.dataSource respondsToSelector:@selector(imageViewerController:willEditImageAtIndex:)]){
        [self.dataSource imageViewerController:self willEditImageAtIndex:self.currentPageIndex];
    }
    
    CLImageEditor *editor = [CLImagePickerBundle imageEditor];
    editor.delegate = self;
    [editor showInViewController:self withImageView:self.presentingCell.imageView];
}

- (IBAction)pushedClearEditBtn:(id)sender
{
    if([self.dataSource respondsToSelector:@selector(imageViewerController:didEditImageAtIndex:edittedImage:)]){
        UIImage *originalImage = [self.dataSource imageViewerController:self originalImageAtIndex:self.currentPageIndex];
        self.presentingCell.fullScreenImage = originalImage;
        [self.dataSource imageViewerController:self didRemoveEdittedImageAtIndex:self.currentPageIndex];
    }
    [self setClearBtnHidden:YES];
}

#pragma mark- CLImageEditor

- (void)imageEditor:(CLImageEditor *)editor willDismissWithImageView:(UIImageView *)imageView canceled:(BOOL)canceled
{
    self.presentingCell.fullScreenImage = imageView.image;
}

- (void)imageEditor:(CLImageEditor *)editor didDismissWithImageView:(UIImageView *)imageView canceled:(BOOL)canceled
{
    if(!canceled){
        if([self.dataSource respondsToSelector:@selector(imageViewerController:didEditImageAtIndex:edittedImage:)]){
            [self.dataSource imageViewerController:self didEditImageAtIndex:self.currentPageIndex edittedImage:imageView.image];
        }
        [self setClearBtnHidden:NO];
    }
}

#pragma mark- UIScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView==_collectionView){
        self.currentPageIndex = (_collectionView.contentOffset.x + _collectionView.width/2) / _collectionView.width;
    }
}

#pragma mark- UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource imageViewerControllerNumberOfImages:self];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.view.frame.size;
    //return CGSizeMake(_collectionView.width, _collectionView.height-_collectionView.contentInset.top-_collectionView.contentInset.bottom);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:CLZoomingImageCellReuseIdentifier forIndexPath:indexPath];
    
    if([cell isKindOfClass:[CLZoomingImageCell class]]){
        CLZoomingImageCell *_cell = (CLZoomingImageCell*)cell;
        _cell.thumnailImage = [self.dataSource imageViewerController:self thumnailImageAtIndex:indexPath.item];
        
        if(_cell.scrollView.panGestureRecognizer){
            [_foregroundView addGestureRecognizer:_cell.scrollView.panGestureRecognizer];
        }
        if(_cell.scrollView.pinchGestureRecognizer){
            [_foregroundView addGestureRecognizer:_cell.scrollView.pinchGestureRecognizer];
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [self.dataSource imageViewerController:self fullScreenImageAtIndex:indexPath.item];
            dispatch_async(dispatch_get_main_queue(), ^{
                _cell.fullScreenImage = image;
                
                if([self.delegate respondsToSelector:@selector(imageViewerController:willDisplayImageView:forIndex:)]){
                    [self.delegate imageViewerController:self willDisplayImageView:_cell.imageView forIndex:indexPath.item];
                }
            });
        });
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([cell isKindOfClass:[CLZoomingImageCell class]]){
        CLZoomingImageCell *_cell = (CLZoomingImageCell*)cell;
        [_foregroundView removeGestureRecognizer:_cell.scrollView.panGestureRecognizer];
        [_foregroundView removeGestureRecognizer:_cell.scrollView.pinchGestureRecognizer];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    //UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    //UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
}

#pragma mark- Gesture events

- (void)viewDidTap:(UIPanGestureRecognizer*)sender
{
    [self dismissFromParentViewController];
}

- (void)viewDidPan:(UIPanGestureRecognizer*)sender
{
    static UIImageView *animateView = nil;
    static BOOL ready = NO;
    
    if(sender.state == UIGestureRecognizerStateBegan){
        CLZoomingImageCell *cell = self.presentingCell;
        
        if(cell.imageView && !cell.isViewing){
            animateView = [UIImageView new];
            [self.view addSubview:animateView];
            [self copyImageViewInfo:cell.imageView toView:animateView containedImage:YES];
            
            _collectionView.hidden = YES;
            [self prepareToDismiss];
        }
    }
    
    if(!ready){
        if([self.delegate respondsToSelector:@selector(imageViewerController:readyToDismissWithIndex:)]){
            ready = [self.delegate imageViewerController:self readyToDismissWithIndex:self.currentPageIndex];
        }
        else{
            ready = YES;
        }
    }
    
    if(animateView && ready){
        if(sender.state == UIGestureRecognizerStateEnded){
            if(_backgroundView.alpha>0.5){
                [self showWithAnimateView:animateView];
            }
            else{
                UIImageView *target = [self imageViewAtIndex:self.currentPageIndex];
                [self dismissWithAnimateView:animateView targetView:target];
            }
            animateView = nil;
            ready = NO;
        }
        else{
            CGPoint p = [sender translationInView:self.view];
            
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0, p.y);
            transform = CGAffineTransformScale(transform, 1 - fabs(p.y)/1000, 1 - fabs(p.y)/1000);
            animateView.transform = transform;
            
            CGFloat r = 1-fabs(p.y)/200;
            _backgroundView.alpha = MAX(0, MIN(1, r));
        }
    }
}

@end
