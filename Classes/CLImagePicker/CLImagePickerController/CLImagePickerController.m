//
//  CLImagePickerController.m
//
//  Created by sho yakushiji on 2014/01/09.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import "CLImagePickerController.h"

#import "UIView+Frame.h"
#import "CLCacheManager.h"
#import "CLAddAssetCell.h"
#import "CLAssetCell.h"
#import "CLImagePickerBundle.h"
#import "CLImageViewerController.h"

NSString * const CLAssetCellReuseIdentifier = @"AssetCell";
NSString * const CLAddAssetCellReuseIdentifier = @"AddAssetCell";



#pragma mark- ExUIImagePickerController

@interface _ExUIImagePickerController : UIImagePickerController
@end

@implementation _ExUIImagePickerController
- (BOOL)prefersStatusBarHidden{ return YES; }
- (UIViewController *)childViewControllerForStatusBarHidden{ return nil; }
@end


#pragma mark- CLImagePickerController

@interface CLImagePickerController ()
<UICollectionViewDataSource, UICollectionViewDelegate, CLAssetCellDelegate, CLImageViewerControllerDataSource, CLImageViewerControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, assign) BOOL isLibraryInProgress;
@end


@implementation CLImagePickerController
{
    ALAssetsLibrary *_library;
    NSMutableArray *_assets;
    ALAssetsGroup *_currentGroup;
    
    NSMutableOrderedSet *_selectedURLs;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _selectedURLs = [NSMutableOrderedSet new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *nibName = NSLocalizedStringWithDefaultValue(@"CLAssetCell_NibName", nil, [CLImagePickerBundle bundle], @"CLAssetCell", @"");
    [_collectionView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellWithReuseIdentifier:CLAssetCellReuseIdentifier];
    
    nibName = NSLocalizedStringWithDefaultValue(@"CLAddAssetCell_NibName", nil, [CLImagePickerBundle bundle], @"CLAddAssetCell", @"");
    [_collectionView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellWithReuseIdentifier:CLAddAssetCellReuseIdentifier];
    
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.contentInset = UIEdgeInsetsMake(_navigationBar.bottom, 0, 0, 0);
    _collectionView.allowsMultipleSelection = YES;
    
    if([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self initAssets];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSelectedURLs:(NSArray*)selectedURLs
{
    _selectedURLs = [[NSMutableOrderedSet alloc] initWithArray:selectedURLs];
}

- (void)setIsLibraryInProgress:(BOOL)isLibraryInProgress
{
    if(isLibraryInProgress != _isLibraryInProgress){
        _isLibraryInProgress = isLibraryInProgress;
        _navigationBar.userInteractionEnabled = !isLibraryInProgress;
        self.navigationController.navigationBar.userInteractionEnabled = !isLibraryInProgress;
    }
}

#pragma mark- Caching

- (UIImage*)originalImageForAsset:(CLAsset*)asset
{
    return asset.fullScreenImage;
}

- (UIImage*)thumnailForAsset:(CLAsset*)asset aspectRatio:(BOOL)aspectRatio
{
    UIImage *image = [self.delegate imagePickerController:self thumnailImageForAssetURL:asset.assetURL];
    if(image==nil){
        image = (aspectRatio) ? asset.aspectRatioThumnail :asset.thumnail;
    }
    return image;
}

- (UIImage*)fullScreenImageForAsset:(CLAsset*)asset
{
    UIImage *image = [self.delegate imagePickerController:self fullScreenImageForAssetURL:asset.assetURL];
    if(image==nil){
        image = asset.fullScreenImage;
    }
    return image;
}

#pragma mark- Assets

- (void)initAssets
{
    _library = [ALAssetsLibrary new];
    
    [_library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                            usingBlock:^(ALAssetsGroup *group, BOOL *stop){
                                if(group){
                                    _currentGroup = group;
                                }
                                else{
                                    [self loadAssetsFromCurrentGroup];
                                }
                            }
                          failureBlock:^(NSError *error){
                              NSLog(@"%@", error.localizedDescription);
                          }
     ];
}

- (void)loadAssetsFromCurrentGroup
{
    if(_assets==nil){
        _assets = [NSMutableArray array];
    }
    [_assets removeAllObjects];
    
    _navigationBar.topItem.title = [_currentGroup valueForProperty:ALAssetsGroupPropertyName];
    
    [_currentGroup enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop){
        if(asset){
            NSArray *array = [asset valueForProperty:ALAssetPropertyRepresentations];
            NSString *representation = (array.count>0) ? [array objectAtIndex:0]:nil;
            
            if(representation.length>0 && [[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]){
                [_assets addObject:[[CLAsset alloc] initWithAsset:asset]];
            }
        }
        else{
            [_collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_assets.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        }
    }];
}

- (CLAsset*)assetAtIndex:(NSUInteger)index
{
    if(index<_assets.count){
        return _assets[index];
        //return _assets[_assets.count - index - 1];
    }
    return nil;
}

#pragma mark- Settings

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark- Button actions

- (IBAction)pushedDoneBtn:(id)sender
{
    [self.delegate imagePickerController:self didFinishPickingMediaWithSelectedAssetURLs:_selectedURLs.array];
}

- (IBAction)pushedCancelBtn:(id)sender
{
    if([self.delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]){
        [self.delegate imagePickerControllerDidCancel:self];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark- CLAssetCell delegate

- (void)cellDidPushSelectButton:(CLAssetCell *)cell
{
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    CLAsset *asset = [self assetAtIndex:indexPath.item];
    
    if(cell.selected){
        [_collectionView deselectItemAtIndexPath:indexPath animated:NO];
        
        [_selectedURLs removeObject:asset.assetURL];
    }
    else{
        [_collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        
        [_selectedURLs addObject:asset.assetURL];
        [self.delegate imagePickerController:self didTouchOriginalImage:asset.fullScreenImage withAssetURL:asset.assetURL];
    }
}

#pragma mark- UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return _assets.count + 1;
    }
    return _assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = (indexPath.item<_assets.count) ? CLAssetCellReuseIdentifier : CLAddAssetCellReuseIdentifier;
    
    UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if([cell isKindOfClass:[CLAssetCell class]]){
        CLAsset *asset = [self assetAtIndex:indexPath.item];
        
        CLAssetCell *_cell = (CLAssetCell*)cell;
        _cell.delegate = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [self thumnailForAsset:asset aspectRatio:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                _cell.image = image;
            });
        });
        
        BOOL selected = [_selectedURLs containsObject:asset.assetURL];
        if(_cell.selected != selected){
            if(selected){
                [_collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            }
            else{
                [_collectionView deselectItemAtIndexPath:indexPath animated:NO];
            }
            _cell.selected = selected;
        }
    }
    else if([cell isKindOfClass:[CLAddAssetCell class]]){
        CLAddAssetCell *_cell = (CLAddAssetCell*)cell;
        if(self.isLibraryInProgress){
            [_cell.indicatorView startAnimating];
        }
        else{
            [_cell.indicatorView stopAnimating];
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.alpha = 0.6;
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.alpha = 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    [self showImageViewerWithIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [self showImageViewerWithIndexPath:indexPath];
}

- (void)showImageViewerWithIndexPath:(NSIndexPath*)indexPath
{
    if(self.isLibraryInProgress){ return; }
    
    UICollectionViewCell* cell = [_collectionView cellForItemAtIndexPath:indexPath];
    if([cell isKindOfClass:[CLAssetCell class]]){
        CLAsset *asset = [self assetAtIndex:indexPath.item];
        CLAssetCell *_cell = (CLAssetCell*)cell;
        _cell.image = [self thumnailForAsset:asset aspectRatio:YES];
        [self showImageViewerWithIndex:indexPath.item];
    }
    else if([cell isKindOfClass:[CLAddAssetCell class]]){
        [self showCameraWithAddAssetCell:(CLAddAssetCell*)cell];
    }
}

#pragma mark- UIImagePicker

- (void)showCameraWithAddAssetCell:(CLAddAssetCell*)cell
{
    if(self.isLibraryInProgress){ return; }
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *ipc = (UIImagePickerController*)[_ExUIImagePickerController new];
        ipc.allowsEditing = NO;
        ipc.delegate      = self;
        
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        ipc.cameraDevice=UIImagePickerControllerCameraDeviceRear;
        
        [self presentViewController:ipc animated:YES completion:^{
            [cell.indicatorView startAnimating];
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.isLibraryInProgress = NO;
    [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_assets.count inSection:0]]];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSMutableDictionary *metadata = (NSMutableDictionary *)[info objectForKey:UIImagePickerControllerMediaMetadata];
    
    [_library writeImageToSavedPhotosAlbum:image.CGImage
                                  metadata:metadata
                           completionBlock:^(NSURL *assetURL, NSError *error) {
                               if(error==nil){
                                   [self addNewAssetForAssetURL:assetURL];
                               }
                               else{
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                   [alert show];
                                   
                                   self.isLibraryInProgress = NO;
                                   [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_assets.count inSection:0]]];
                               }
                           }
     ];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)addNewAssetForAssetURL:(NSURL*)assetURL
{
    [_library assetForURL:assetURL
              resultBlock:^(ALAsset *asset){
                  CLAsset *ast = [[CLAsset alloc] initWithAsset:asset];
                  [_assets addObject:ast];
                  [_selectedURLs addObject:ast.assetURL];
                  [self.delegate imagePickerController:self didTouchOriginalImage:ast.fullScreenImage withAssetURL:ast.assetURL];
                  
                  self.isLibraryInProgress = NO;
                  
                  [_collectionView performBatchUpdates:^{
                      [_collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_assets.count-1 inSection:0]]];
                   }
                                            completion:^(BOOL finished) {
                                                [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_assets.count inSection:0]]];
                                            }
                   ];
              }
             failureBlock:^(NSError *error){
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alert show];
                 
                 self.isLibraryInProgress = NO;
                 [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_assets.count inSection:0]]];
             }
     ];
}

#pragma mark- CLImageViewerController

- (void)showImageViewerWithIndex:(NSInteger)index
{
    NSString *nibName = NSLocalizedStringWithDefaultValue(@"CLImageViewerController_NibName", nil, [CLImagePickerBundle bundle], @"CLImageViewerController", @"");
    
    CLImageViewerController *viewer = [[CLImageViewerController alloc] initWithNibName:nibName bundle:nil];
    viewer.dataSource = self;
    viewer.delegate = self;
    
    [viewer showInViewController:self withIndex:index];
}

#pragma mark DataSource

- (NSInteger)imageViewerControllerNumberOfImages:(CLImageViewerController*)viewer
{
    return _assets.count;
}

- (UIImage*)imageViewerController:(CLImageViewerController*)viewer originalImageAtIndex:(NSInteger)index
{
    return [self originalImageForAsset:[self assetAtIndex:index]];
}

- (UIImage*)imageViewerController:(CLImageViewerController*)viewer thumnailImageAtIndex:(NSInteger)index
{
    return [self thumnailForAsset:[self assetAtIndex:index] aspectRatio:YES];
}

- (UIImage*)imageViewerController:(CLImageViewerController*)viewer fullScreenImageAtIndex:(NSInteger)index
{
    return [self fullScreenImageForAsset:[self assetAtIndex:index]];
}

- (BOOL)imageViewerController:(CLImageViewerController*)viewer isSelectedImageAtIndex:(NSInteger)index
{
    CLAsset *asset = [self assetAtIndex:index];
    return [_selectedURLs containsObject:asset.assetURL];
}

- (BOOL)imageViewerController:(CLImageViewerController*)viewer isEditedImageAtIndex:(NSInteger)index
{
    CLAsset *asset = [self assetAtIndex:index];
    return [self.delegate imagePickerController:self isEdittedImageWithAssetURL:asset.assetURL];
}

- (void)imageViewerController:(CLImageViewerController*)viewer didSelectImageAtIndex:(NSInteger)index
{
    [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    
    CLAsset *asset = [self assetAtIndex:index];
    [_selectedURLs addObject:asset.assetURL];
    
    [self.delegate imagePickerController:self didTouchOriginalImage:asset.fullScreenImage withAssetURL:asset.assetURL];
}

- (void)imageViewerController:(CLImageViewerController*)viewer didDeSelectImageAtIndex:(NSInteger)index
{
    [_collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:NO];
    
    CLAsset *asset = [self assetAtIndex:index];
    [_selectedURLs removeObject:asset.assetURL];
}

- (void)imageViewerController:(CLImageViewerController *)viewer willEditImageAtIndex:(NSInteger)index
{
    CLAsset *asset = [self assetAtIndex:index];
    [self.delegate imagePickerController:self didTouchOriginalImage:asset.fullScreenImage withAssetURL:asset.assetURL];
}

- (void)imageViewerController:(CLImageViewerController*)viewer didEditImageAtIndex:(NSInteger)index edittedImage:(UIImage*)image
{
    CLAsset *asset = [self assetAtIndex:index];
    [self.delegate imagePickerController:self didEditImage:image withAssetURL:asset.assetURL];
    
    CLAssetCell *cell = (CLAssetCell*)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    if(cell){
        cell.image = [self thumnailForAsset:[self assetAtIndex:index] aspectRatio:NO];
    }
}

- (void)imageViewerController:(CLImageViewerController*)viewer didRemoveEdittedImageAtIndex:(NSInteger)index
{
    CLAsset *asset = [self assetAtIndex:index];
    [self.delegate imagePickerController:self didRemoveEdittedImageWithAssetURL:asset.assetURL];
}

#pragma mark Delegate

- (UIImageView*)imageViewerController:(CLImageViewerController*)viewer imageViewAtIndex:(NSInteger)index
{
    CLAssetCell *cell = (CLAssetCell*)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return cell.imageView;
}

- (void)imageViewerController:(CLImageViewerController*)viewer willAppearWithIndex:(NSInteger)index
{
    CLAssetCell *cell = (CLAssetCell*)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    cell.hidden = YES;
}

- (void)imageViewerController:(CLImageViewerController*)viewer didAppearWithIndex:(NSInteger)index
{
    CLAssetCell *cell = (CLAssetCell*)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    cell.hidden = NO;
}

- (void)imageViewerController:(CLImageViewerController*)viewer willDismissWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    CLAssetCell *cell = (CLAssetCell*)[_collectionView cellForItemAtIndexPath:indexPath];
    
    if(cell==nil){
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (BOOL)imageViewerController:(CLImageViewerController *)viewer readyToDismissWithIndex:(NSInteger)index
{
    CLAssetCell *cell = (CLAssetCell*)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    cell.hidden = YES;
    
    return (cell!=nil);
}

- (void)imageViewerController:(CLImageViewerController*)viewer didDismissWithIndex:(NSInteger)index
{
    CLAssetCell *cell = (CLAssetCell*)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    cell.hidden = NO;
}

@end

