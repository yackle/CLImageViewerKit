//
//  CLImageViewerLayout.m
//
//  Created by sho yakushiji on 2014/01/20.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import "CLImageViewerLayout.h"

#import "UIView+Frame.h"

@interface CLImageViewerLayout()
@property (nonatomic, assign) CGSize cellSize;
@property (nonatomic, readonly) NSInteger numberOfCells;
@end


@implementation CLImageViewerLayout
{
    NSMutableArray *_deleteIndexPaths;
}

- (id)initWithCellSize:(CGSize)size
{
    self = [super init];
    if(self){
        self.cellSize = size;
    }
    return self;
}

- (NSInteger)numberOfCells
{
    return [self.collectionView numberOfItemsInSection:0];
}

- (void)prepareLayout
{
    
}

-(CGSize)collectionViewContentSize
{
    CGSize size = CGSizeMake(self.collectionView.width*self.numberOfCells, self.collectionView.height);
    return size;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
    attributes.size = self.cellSize;
    attributes.center = CGPointMake((path.item+0.5)*self.collectionView.width, self.collectionView.height/2);
    
    return attributes;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* attributes = [NSMutableArray array];
    for (NSInteger i=0 ; i<self.numberOfCells; ++i) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return attributes;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
    _deleteIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *update in updateItems){
        if (update.updateAction == UICollectionUpdateActionDelete){
            [_deleteIndexPaths addObject:update.indexPathBeforeUpdate];
        }
    }
}

- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];
    _deleteIndexPaths = nil;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    
    if ([_deleteIndexPaths containsObject:itemIndexPath]){
        if (attributes==nil){
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        }
        
        attributes.alpha = 0;
        attributes.transform = CGAffineTransformMakeScale(0.1, 0.1);
    }
    
    return attributes;
}

@end
