//
//  DataManager.m
//  ZKMovies
//
//  Created by Zeeshan Khan on 07/04/15.
//  Copyright (c) 2015 Zeeshan. All rights reserved.
//

#import "DataManager.h"
#import "DBManager.h"
#import "ZKNetworkManager.h"
#import <UIKit/UIKit.h>
#import "Utils.h"
#import "MovieDetails.h"
#import "DBManager.h"

@interface DataManager ()
@property (nonatomic, weak) id <DataManagerDelegate> dataDelegate;
@property (nonatomic, strong) NSString *currentSearch;
@end

@implementation DataManager

#define     kParamKeySearch         @"title"
#define     kParamKeyLimiit           @"limit"
#define     kParamKeyDetailId        @"idIMDB"
#define     kParamKeyDetailActors  @"actors"

- (instancetype)initWithDelegate:(id <DataManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.dataDelegate = delegate;
    }
    return self;
}

#define NETWORK_ERR				@"You are not connected to network, please check your network settings and try again"

- (void)getDataFromServerWithParams:(NSDictionary*)params {

    [[ZKNetworkManager sharedInstance] requestForDataWithParams:params completion:^(id response, NSError *error) {
        
        id jsonObject = nil;
        NSData *respdata = (NSData*)response;
        if (respdata != nil && respdata.length > 0) {
            
            NSString *str = [[NSString alloc] initWithBytes:[(NSData*)response bytes] length:[(NSData*)response length] encoding:NSUTF8StringEncoding];
            NSLog(@"[Server Response] %@", str);
            
            jsonObject = [NSJSONSerialization JSONObjectWithData:respdata options:NSJSONReadingAllowFragments error:&error];
            if(jsonObject == nil) {
                NSLog(@"[Server Response Error] JSON Parsing Error 1: %@", error);
                
                str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                str = [str stringByReplacingOccurrencesOfString:@"”" withString:@"\""];
                str = [str stringByReplacingOccurrencesOfString:@"“" withString:@"\""];
                
                error = nil;
                jsonObject = [NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:[str UTF8String] length:str.length] options:NSJSONReadingAllowFragments error:&error];
                if(jsonObject == nil) {
                    NSLog(@"[Server Response Error] JSON Parsing Error 2: %@", error);
                    [Utils showAlertViewWithTitle:error.domain message:error.localizedDescription];
//                    [self checkErrorOnResponse:nil];
                }
                else
                    [self checkErrorOnResponse:jsonObject];
            }
            else
                [self checkErrorOnResponse:jsonObject];
        }
        else {
            
            NSLog(@"[Server Response Error] %@", error);
            
            switch (error.code) {
                case NSURLErrorNotConnectedToInternet:
                    [Utils showAlertViewWithTitle:@"Network Error!" message:NETWORK_ERR];
                    break;
                case NSURLErrorNetworkConnectionLost:
                    [Utils showAlertViewWithTitle:@"Network Error!" message:error.localizedDescription];
                    break;
                    
                default: {
                    NSString *strDesc = [Utils validString:error.localizedDescription];
                    if (strDesc.length < 5) strDesc = @"Unknown server error.";
                    [Utils showAlertViewWithTitle:@"Error" message:strDesc];
                }
                    break;
            }
            
//            [self checkErrorOnResponse:nil];
        }
       
    }];

}

- (void)checkErrorOnResponse:(id)data {
    if (data && _dataDelegate && [_dataDelegate conformsToProtocol:@protocol(DataManagerDelegate)]) {
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            if ([[(NSDictionary*)data allKeys] count] == 2) {
                NSString* strMsg = [Utils validString:[(NSDictionary*)data objectForKey:@"message"]];
                if (strMsg.length == 0) strMsg = @"Unknow server error.";
                [Utils showAlertViewWithTitle:strMsg message:nil];
                return;
            }
        }
        
        [self dataReceived:data];
    }
}

@end

@implementation MovieListDM

- (void)getMoviesListForString:(NSString*)str {
    self.currentSearch = [Utils validString:str];
    NSDictionary *dicParam =  @{kParamKeySearch: self.currentSearch, kParamKeyLimiit: @"10"};
    [self getDataFromServerWithParams:dicParam];
}

- (void)dataReceived:(id)data {
    if (data && self.dataDelegate && [self.dataDelegate conformsToProtocol:@protocol(DataManagerDelegate)]) {
        [[DBManager new] addSearchItem:self.currentSearch];
        [self.dataDelegate refreshedList:[MovieDetails movieListFromResponse:data]];
    }
}

@end

@implementation MovieDetailDM

- (void)getMovieDetailWithId:(NSString*)movieId {
    NSDictionary *dicParam =  @{kParamKeyDetailId: [Utils validString:movieId], kParamKeyDetailActors: @"S"};
    [self getDataFromServerWithParams:dicParam];
}

- (void)dataReceived:(id)data {
    if (data && self.dataDelegate && [self.dataDelegate conformsToProtocol:@protocol(DataManagerDelegate)]) {
        [self.dataDelegate refreshDetailWithResponse:(NSDictionary*)data];
    }
}

@end
