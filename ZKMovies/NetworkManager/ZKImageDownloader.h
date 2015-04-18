//
//  ZKImageDownloadOperation.h
//  ZKMovies
//
//  Created by Zeeshan Khan on 07/04/15.
//  Copyright (c) 2015 Zeeshan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ImageDownloadDelegate;
@interface ZKImageDownloader : NSOperation
- (instancetype)initWithUrl:(NSString*)url path:(NSIndexPath*)path callback:(id<ImageDownloadDelegate>)delegate;
@end

@protocol ImageDownloadDelegate <NSObject>
- (void)imageLoaded:(UIImage*)img forPath:(NSIndexPath*)path;
@end
