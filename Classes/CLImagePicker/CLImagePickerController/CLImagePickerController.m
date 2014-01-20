//
//  CLImagePickerController.m
//
//  Created by sho yakushiji on 2014/01/09.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import "CLImagePickerController.h"

#import "UIView+Frame.h"
#import "CLCacheManager.h"
#import "CLAssetCell.h"
#import "CLImagePickerBundle.h"
#import "CLImageViewerController.h"

NSString * const CLAssetCellReuseIdentifier = @"AssetCell";


@interface CLImagePickerController ()
<UICollectionViewDataSource, UICollectionViewDelegate, CLAssetCellDelegate, CLImageViewerControllerDataSource, CLImageViewerControllerDelegate>
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

#pragma mark- Caching

- (UIImage*)originalImageForAsset:(CLAsset*)asset
{
    return asset.fullScreenImage;
}

- (UIImage*)thumnailForAsset:(CLAsset*)asset
{
    UIImage *image = [self.delegate imagePickerController:self thumnailImageForAssetURL:asset.assetURL];
    if(image==nil){
        image = asset.thumnail;
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
        }
    }];
}

- (CLAsset*)assetAtIndex:(NSUInteger)index
{
    if(index<_assets.count){
        return _assets[_assets.count - index - 1];
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
    return _assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:CLAssetCellReuseIdentifier forIndexPath:indexPath];
    
    if([cell isKindOfClass:[CLAssetCell class]]){
        CLAsset *asset = [self assetAtIndex:indexPath.item];
        
        CLAssetCell *_cell = (CLAssetCell*)cell;
        _cell.delegate = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [self thumnailForAsset:asset];
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
    //UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    [self showImageViewerWithIndex:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    
    [self showImageViewerWithIndex:indexPath.item];
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
    return [self thumnailForAsset:[self assetAtIndex:index]];
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
        cell.image = [self thumnailForAsset:[self assetAtIndex:index]];
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
