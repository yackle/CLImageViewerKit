//
//  CLImageView.h
//
//  Created by sho yakushiji on 2013/11/25.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "../UIImageView+URLDownload/UIImageView+URLDownload.h"


@interface CLImageView : UIImageView

@property (nonatomic, assign) BOOL useLocalCache;

@end
