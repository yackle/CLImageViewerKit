//
//  ViewController.m
//  CLImagePickerDemo
//
//  Created by sho yakushiji on 2014/01/09.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import "ViewController.h"

#import <CLImagePickerManager.h>
#import <UIImageView+URLDownload.h>

@interface ViewController ()
<CLImagePickerManagerDelegate, CLImageViewerControllerDelegate>
@end

@implementation ViewController
{
    CLImagePickerManager *_manager;
    NSMutableArray *_thumbnails;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _manager = [CLImagePickerManager managerWithDelegate:self];
    _thumbnails = [NSMutableArray array];
    
    [_manager selectImage:[UIImage imageNamed:@"default.jpg"] forURL:[NSURL URLWithString:@"test://testetestse"]];
    [_manager selectImage:nil forURL:[NSURL URLWithString:@"http://placekitten.com/1000/1000"]];
    [self resetImageViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushedBtn:(id)sender
{
    [self presentViewController:_manager.pickerViewController animated:YES completion:nil];
}

- (void)resetImageViews
{
    for(UIView *view in _thumbnails){ [view removeFromSuperview]; }
    [_thumbnails removeAllObjects];
    
    if(_manager.numberOfSelectedImages==0){ return; }
    
    CGPoint center = self.view.center;
    CGFloat da = 2*M_PI/_manager.numberOfSelectedImages;
    
    for(NSInteger index=0; index<_manager.numberOfSelectedImages; ++index){
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        view.contentMode = UIViewContentModeScaleAspectFill;
        view.layer.cornerRadius = view.frame.size.width/2;
        view.clipsToBounds = YES;
        
        view.center = CGPointMake(center.x + 120*cos(da*index + M_PI), center.y + 120*sin(da*index + M_PI));
        view.tag = index;
        
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbnailDidTapped:)]];
        
        [self.view insertSubview:view atIndex:0];
        [_thumbnails addObject:view];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [_manager thumbnailImageAtIndex:index];
            dispatch_async(dispatch_get_main_queue(), ^{
                view.image = image;
            });
        });
        
    }
}

- (void)thumbnailDidTapped:(UITapGestureRecognizer*)sender
{
    [_manager showImageViewerInViewController:self withIndex:sender.view.tag];
}

#pragma CLImagePickerManagerDelegate

- (void)imagePickerManagerWillDismissImagePicker:(CLImagePickerManager *)manager canceled:(BOOL)canceled
{
    if(!canceled){
        [self resetImageViews];
    }
}

- (void)imagePickerManagerDidDismissImagePicker:(CLImagePickerManager *)manager canceled:(BOOL)canceled
{
    
}

#pragma mark- CLImageViewerControllerDelegate

- (UIImageView*)imageViewerController:(CLImageViewerController*)viewer imageViewAtIndex:(NSInteger)index
{
    if(index<_thumbnails.count){
        return _thumbnails[index];
    }
    return nil;
}

- (void)imageViewerController:(CLImageViewerController *)viewer willDisplayImageView:(UIImageView *)imageView forIndex:(NSInteger)index
{
    if(imageView.image==nil){
        NSURL *url = [_manager fullScreenURLAtIndex:index];
        
        [imageView setDefaultLoadingView];
        imageView.loadingView.backgroundColor = [UIColor whiteColor];
        
        [imageView loadWithURL:url completionBlock:^(UIImage *image, NSURL *url, NSError *error) {
            if(error==nil && image){
                [_manager setImage:image forSelectedURL:url];
            }
        }];
    }
}

- (void)imageViewerController:(CLImageViewerController*)viewer willAppearWithIndex:(NSInteger)index
{
    
}

- (void)imageViewerController:(CLImageViewerController*)viewer didAppearWithIndex:(NSInteger)index
{
    
}

- (void)imageViewerController:(CLImageViewerController*)viewer willDismissWithIndex:(NSInteger)index
{
    [self resetImageViews];
}

- (BOOL)imageViewerController:(CLImageViewerController *)viewer readyToDismissWithIndex:(NSInteger)index
{
    if(index<_thumbnails.count){
        UIView *view = _thumbnails[index];
        view.hidden = YES;
    }
    return YES;
}

- (void)imageViewerController:(CLImageViewerController*)viewer didDismissWithIndex:(NSInteger)index
{
    if(index<_thumbnails.count){
        UIView *view = _thumbnails[index];
        view.hidden = NO;
    }
}

@end
