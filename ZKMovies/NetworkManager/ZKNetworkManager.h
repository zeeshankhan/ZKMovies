//
//  ZKNetworkRequest.h
//  ZKMovies
//
//  Created by Zeeshan Khan on 07/04/15.
//  Copyright (c) 2015 Zeeshan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^NetworkRequestCompletionHandler)(id response, NSError *error);

#define     NETWORK_TIMEOUT_INTERVAL			 300.0

@interface ZKNetworkManager : NSObject

@property (nonatomic) BOOL queueOpened;

+ (instancetype)sharedInstance;
- (void)requestForDataWithParams:(NSDictionary*)params completion:(NetworkRequestCompletionHandler)completionBlock;
- (void)cancelAllRequests;

@end


@interface ZKNetworkRequest : NSOperation

@property (nonatomic) CFTimeInterval absoluteStartTime;
@property (nonatomic) CFTimeInterval absoluteResponseTime;

@property (nonatomic, strong) NSURL                         *operationURL;
@property (nonatomic, strong) NSMutableURLRequest  *operationRequest;
@property (nonatomic, strong) NSMutableData             *operationData;
@property (nonatomic, strong) NSURLConnection          *operationConnection;
@property (nonatomic, strong) NSDictionary                 *operationParameters;

@property (nonatomic, assign) CFRunLoopRef operationRunLoop;

@property (nonatomic, strong) dispatch_queue_t saveDataDispatchQueue;
@property (nonatomic, strong) dispatch_group_t saveDataDispatchGroup;

@property (nonatomic, strong) NSHTTPURLResponse *operationURLResponse;
@property (nonatomic, copy) NetworkRequestCompletionHandler operationCompletionBlock;

@property (nonatomic, readwrite) NSUInteger timeoutInterval;

- (instancetype)initWithAddress:(NSString*)urlString
                         parameters:(NSObject*)parameters
                         completion:(NetworkRequestCompletionHandler)completionBlock;

@end
