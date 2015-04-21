//
//  ZKImageDownloadOperation.m
//  ZKMovies
//
//  Created by Zeeshan Khan on 07/04/15.
//  Copyright (c) 2015 Zeeshan. All rights reserved.
//

#import "ZKImageDownloader.h"

@interface ZKImageDownloader ()
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSIndexPath *cellPath;
@property (nonatomic, weak) id <ImageDownloadDelegate> delegate;
@end

@implementation ZKImageDownloader

- (instancetype)initWithUrl:(NSString*)url path:(NSIndexPath*)path callback:(id<ImageDownloadDelegate>)delegate {
    
    self = [super init];
    if (self != nil) {
        self.imageUrl = url;
        self.cellPath = path;
        self.delegate = delegate;
    }
    return self;
}

- (void)main {
    
    if ([self isCancelled])
        return;
    
    @autoreleasepool {
        
        NSURL *url = [NSURL URLWithString:self.imageUrl];
        NSData *imgData = [NSData dataWithContentsOfURL:url];
        UIImage *image = nil;
        if (imgData) image = [UIImage imageWithData:imgData];
        else {
            NSLog(@"Img Download Error: '%@'", self.imageUrl);
        }
        
        if (![self isCancelled] && _delegate != nil && [_delegate conformsToProtocol:@protocol(ImageDownloadDelegate)] && [_delegate respondsToSelector:@selector(imageLoaded:forPath:)])
            [_delegate imageLoaded:image forPath:self.cellPath];
    }
}

@end
