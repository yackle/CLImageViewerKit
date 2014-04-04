//
//  CLDownloadManager.h
//  CLImageViewerDemo
//
//  Created by sho yakushiji on 2014/04/04.
//  Copyright (c) 2014年 CALACULU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLDownloadManager : NSObject
{
    NSMutableArray *_downloadURLs;
}

+ (void)downloadFromURL:(NSURL*)url completion:(void(^)(NSData *data, NSURL *url, NSError *error))completionBlock;

@end
