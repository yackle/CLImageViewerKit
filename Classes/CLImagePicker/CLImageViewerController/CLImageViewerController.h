//
//  CLImageViewerController.h
//
//  Created by sho yakushiji on 2014/01/15.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CLImageViewerControllerDataSource;
@protocol CLImageViewerControllerDelegate;


@interface CLImageViewerController : UIViewController
{
    IBOutlet __weak UIView *_backgroundView;
    IBOutlet __weak UIView *_foregroundView;
    IBOutlet __weak UICollectionView *_collectionView;
    
    IBOutlet __weak UIButton *_selectBtn;
    IBOutlet __weak UIButton *_editCancelBtn;
}
@property (nonatomic, weak) id<CLImageViewerControllerDataSource> dataSource;
@property (nonatomic, weak) id<CLImageViewerControllerDelegate> delegate;

- (void)showInViewController:(UIViewController*)controller withIndex:(NSInteger)index;
- (void)showInWindowWithIndex:(NSInteger)index;

- (void)dismissFromParentViewController;

- (void)removeImageAtIndex:(NSInteger)index;

- (IBAction)pushedSelectBtn:(id)sender;
- (IBAction)pushedEditBtn:(id)sender;
- (IBAction)pushedClearEditBtn:(id)sender;

@end




@protocol CLImageViewerControllerDataSource <NSObject>
@required
- (NSInteger)imageViewerControllerNumberOfImages:(CLImageViewerController*)viewer;
- (UIImage*)imageViewerController:(CLImageViewerController*)viewer originalImageAtIndex:(NSInteger)index;
- (UIImage*)imageViewerController:(CLImageViewerController*)viewer thumbnailImageAtIndex:(NSInteger)index;
- (UIImage*)imageViewerController:(CLImageViewerController*)viewer fullScreenImageAtIndex:(NSInteger)index;

- (BOOL)imageViewerController:(CLImageViewerController*)viewer isSelectedImageAtIndex:(NSInteger)index;
- (BOOL)imageViewerController:(CLImageViewerController*)viewer isEditedImageAtIndex:(NSInteger)index;

- (void)imageViewerController:(CLImageViewerController*)viewer didSelectImageAtIndex:(NSInteger)index;
- (void)imageViewerController:(CLImageViewerController*)viewer didDeSelectImageAtIndex:(NSInteger)index;

- (void)imageViewerController:(CLImageViewerController*)viewer willEditImageAtIndex:(NSInteger)index;
- (void)imageViewerController:(CLImageViewerController*)viewer didEditImageAtIndex:(NSInteger)index edittedImage:(UIImage*)image;
- (void)imageViewerController:(CLImageViewerController*)viewer didRemoveEdittedImageAtIndex:(NSInteger)index;

@end


@protocol CLImageViewerControllerDelegate<NSObject>
@optional

- (UIImageView*)imageViewerController:(CLImageViewerController*)viewer imageViewAtIndex:(NSInteger)index;

- (void)imageViewerController:(CLImageViewerController*)viewer willDisplayImageView:(UIImageView*)imageView forIndex:(NSInteger)index;

- (void)imageViewerController:(CLImageViewerController*)viewer willAppearWithIndex:(NSInteger)index;
- (void)imageViewerController:(CLImageViewerController*)viewer didAppearWithIndex:(NSInteger)index;
- (void)imageViewerController:(CLImageViewerController*)viewer willDismissWithIndex:(NSInteger)index;
- (BOOL)imageViewerController:(CLImageViewerController*)viewer readyToDismissWithIndex:(NSInteger)index;
- (void)imageViewerController:(CLImageViewerController*)viewer didDismissWithIndex:(NSInteger)index;

@end
