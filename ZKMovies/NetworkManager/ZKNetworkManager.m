//
//  ZKNetworkRequest.m
//  ZKMovies
//
//  Created by Zeeshan Khan on 07/04/15.
//  Copyright (c) 2015 Zeeshan. All rights reserved.
//

#import "ZKNetworkManager.h"
#import <UIKit/UIKit.h>
#import "Utils.h"

@interface ZKNetworkManager ()
@property (nonatomic, strong) NSOperationQueue *requestQueue;
@property (nonatomic, strong) NSString *basePath;
@end

@implementation ZKNetworkManager

+ (instancetype)sharedInstance {
    
    static ZKNetworkManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestQueue = [NSOperationQueue new];
        [self.requestQueue setName:@"ZKAwesomeNetworkOperationQueue"];
        self.basePath = @"http://www.myapifilms.com/imdb?token=3962c3d1-e56d-40fd-b392-3b03bc621454";
        self.queueOpened = YES;
    }
    return self;
}

- (void)requestForDataWithParams:(NSDictionary*)param completion:(NetworkRequestCompletionHandler)completionBlock  {
    
    if (self.queueOpened == YES) {
        ZKNetworkRequest *requestOperation = [[ZKNetworkRequest alloc] initWithAddress:self.basePath
                                                                            parameters:param
                                                                            completion:completionBlock];
        requestOperation.timeoutInterval = NETWORK_TIMEOUT_INTERVAL;
        [self.requestQueue addOperation:requestOperation];
        requestOperation = nil;
    }
    else {
        NSLog(@"[HTTPClient Error] Queue is closed.");
    }
}

- (void)cancelAllRequests {
    NSLog(@"[HTTPClient] Cancelling All Request.");
    [self.requestQueue cancelAllOperations];
}

@end

#pragma mark 
#pragma mark Network Request
#pragma mark

@implementation ZKNetworkRequest

static NSInteger RequestTaskCount = 0;
static NSInteger reqCounter;                     // To maintain the number of request fired from this class

- (instancetype)initWithAddress:(NSString*)urlString parameters:(NSDictionary*)parameters
                         completion:(NetworkRequestCompletionHandler)completionBlock  {
    
    self = [super init];
    if (self) {
        
        self.operationCompletionBlock = completionBlock;
        self.operationParameters = parameters;
        
        self.saveDataDispatchGroup = dispatch_group_create();
        self.saveDataDispatchQueue = dispatch_queue_create("com.zeeshan.NetworkRequest", DISPATCH_QUEUE_SERIAL);
        
        NSString *strParam = [Utils validString:[self parameterStringFromDictionary:parameters]];
        if (strParam.length > 0)
            urlString = [NSString stringWithFormat:@"%@&%@", urlString, strParam];
        self.operationURL = [NSURL URLWithString:urlString];
    }
    
    return self;
}

- (void)finish {
    [self.operationConnection cancel];
    self.operationConnection = nil;
    [self decreaseRequestTaskCount];
}

- (NSString*)parameterStringFromDictionary:(NSDictionary*)parameters {

    NSMutableArray *stringParameters = [NSMutableArray arrayWithCapacity:parameters.count];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([obj isKindOfClass:[NSString class]]) {
            [stringParameters addObject:[NSString stringWithFormat:@"%@=%@", key, [obj encodedURLParameterString]]];
        }
        else if([obj isKindOfClass:[NSNumber class]]) {
            [stringParameters addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
        }
        else
            [NSException raise:NSInvalidArgumentException format:@"%@ requests only accept NSString and NSNumber parameters.", self.operationRequest.HTTPMethod];
    }];
    
    return [stringParameters componentsJoinedByString:@"&"];
}

#pragma mark - NSOperation methods

- (void)start {
    
    if (self.isCancelled) {
        [self finish];
        return;
    }
    NSLog(@"[Request Number]: === %@ ===", @(++reqCounter));

    dispatch_async(dispatch_get_main_queue(), ^{
        [self increaseRequestTaskCount];
    });
    
    self.absoluteStartTime = CFAbsoluteTimeGetCurrent();

    [self setupNewNetwork]; //initiateNetworkRequest
}

- (void)cancel {

    if([self isExecuting] == YES) {
        [self finish];
    }
    [super cancel];
}

- (BOOL)isConcurrent {
    return YES;
}

#pragma mark - Network indicator

- (void)increaseRequestTaskCount {
    RequestTaskCount++;
    [self toggleNetworkActivityIndicator];
}

- (void)decreaseRequestTaskCount {
    RequestTaskCount = MAX(0, RequestTaskCount-1);
    [self toggleNetworkActivityIndicator];
}

- (void)toggleNetworkActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(RequestTaskCount > 0)];
    });
}

#pragma mark - New Network

- (void)setupNewNetwork {

    __weak ZKNetworkRequest *weakSelf = self;
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSLog(@"URL: %@", self.operationURL);
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:self.operationURL
            completionHandler:^(NSData *data,
            NSURLResponse *response,
            NSError *error) {
                // handle response
                weakSelf.operationURLResponse = (NSHTTPURLResponse*)response;
                NSLog(@"[Status Code]: %@", @(weakSelf.operationURLResponse.statusCode));
                
                [weakSelf callCompletionBlockWithResponse:data error:error];
            }];
    [dataTask resume];
}

#pragma mark - Connection Delegates

- (void)initiateNetworkRequest {

    self.operationRequest = [[NSMutableURLRequest alloc] initWithURL:self.operationURL];
    [self.operationRequest setHTTPMethod:@"GET"];
    [self.operationRequest setTimeoutInterval:self.timeoutInterval];
    [self.operationRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    
    self.operationConnection = [[NSURLConnection alloc] initWithRequest:self.operationRequest delegate:self startImmediately:NO];
    
    /* Some Points.
     * 1. The connection retains delegate. It releases delegate when the connection finishes loading, fails, or is canceled.
     * 2. If you are performing this on a background thread, the thread is probably exiting before the delegates can be called.
     * 3. As document of START method says: If you don’t schedule the connection in a run loop or an operation queue before calling this method, the connection would be scheduled in the current run loop in the default mode.
     */
    
    NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
    BOOL inBackgroundAndInOperationQueue = (currentQueue != nil && currentQueue != [NSOperationQueue mainQueue]);
    NSRunLoop *targetRunLoop = (inBackgroundAndInOperationQueue) ? [NSRunLoop currentRunLoop] : [NSRunLoop mainRunLoop];
    
    //    NSLog(@"[HTTP]Request Running on: %@", (inBackgroundAndInOperationQueue) ? @"Current Run Loop" : @"Main Run Loop" );
    
    [self.operationConnection scheduleInRunLoop:targetRunLoop forMode:NSDefaultRunLoopMode]; // NSRunLoopCommonModes
    [self.operationConnection start];
    NSLog(@"[HTTPRequest] %@ / %@", self.operationRequest.HTTPMethod, self.operationRequest.URL.absoluteString);
    
    // make NSRunLoop stick around until operation is finished
    if (inBackgroundAndInOperationQueue) {
        self.operationRunLoop = CFRunLoopGetCurrent();
        CFRunLoopRun();
    }

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    self.absoluteResponseTime = CFAbsoluteTimeGetCurrent();
    self.operationURLResponse = (NSHTTPURLResponse*)response;
    NSLog(@"[Status Code]: %@", @(self.operationURLResponse.statusCode));
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // responseData is an instance variable declared elsewhere.
    self.operationData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    dispatch_group_async(self.saveDataDispatchGroup, self.saveDataDispatchQueue, ^{
        [self.operationData appendData:data];
    });
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    dispatch_group_notify(self.saveDataDispatchGroup, self.saveDataDispatchQueue, ^{
        id response = [NSData dataWithData:self.operationData];
        [self callCompletionBlockWithResponse:response error:nil];
    });
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self callCompletionBlockWithResponse:nil error:error];
}

#pragma mark - Final Callback

- (void)callCompletionBlockWithResponse:(id)response error:(NSError *)error {
    
    //CFTimeInterval responseTime = self.absoluteResponseTime - self.absoluteStartTime;
    //CFTimeInterval difference = CFAbsoluteTimeGetCurrent() - self.absoluteStartTime;
    //NSLog(@"[Server Response Finish] Response: %f, TotalTimeTaken: %f", responseTime, difference);
    
    if (self.operationRunLoop)
        CFRunLoopStop(self.operationRunLoop);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSError *serverError = error;
        if (response == nil && (!serverError || self.operationURLResponse.statusCode == 500)) {
            NSDictionary *dicInfo = @{NSLocalizedDescriptionKey: @"Bad Server Response.",
                                      NSURLErrorFailingURLErrorKey: self.operationRequest.URL,
                                      NSURLErrorFailingURLStringErrorKey: self.operationRequest.URL.absoluteString};
            serverError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:dicInfo];
        }
        
        if (self.operationCompletionBlock && !self.isCancelled)
            self.operationCompletionBlock(response, serverError);
        
        [self finish];
    });
}

@end
