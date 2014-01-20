//
//  CLImagePickerController.h
//
//  Created by sho yakushiji on 2014/01/09.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CLImagePickerControllerDelegate;


@interface CLImagePickerController : UIViewController
{
    IBOutlet __weak UICollectionView *_collectionView;
    IBOutlet __weak UINavigationBar *_navigationBar;
}
@property (nonatomic, weak) id<CLImagePickerControllerDelegate> delegate;

- (void)setSelectedURLs:(NSArray*)selectedURLs;

- (IBAction)pushedDoneBtn:(id)sender;
- (IBAction)pushedCancelBtn:(id)sender;

@end



@protocol CLImagePickerControllerDelegate <NSObject>
@required

- (void)imagePickerController:(CLImagePickerController *)picker didTouchOriginalImage:(UIImage*)image withAssetURL:(NSURL*)url;
- (void)imagePickerController:(CLImagePickerController *)picker didEditImage:(UIImage*)image withAssetURL:(NSURL*)url;
- (void)imagePickerController:(CLImagePickerController *)picker didRemoveEdittedImageWithAssetURL:(NSURL*)url;

- (BOOL)imagePickerController:(CLImagePickerController *)picker isEdittedImageWithAssetURL:(NSURL*)url;


- (UIImage*)imagePickerController:(CLImagePickerController *)picker thumnailImageForAssetURL:(NSURL*)url;
- (UIImage*)imagePickerController:(CLImagePickerController *)picker fullScreenImageForAssetURL:(NSURL*)url;

- (void)imagePickerController:(CLImagePickerController *)picker didFinishPickingMediaWithSelectedAssetURLs:(NSArray*)selectedURLs;

@optional
- (void)imagePickerControllerDidCancel:(CLImagePickerController *)picker;

@end
