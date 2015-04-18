//
//  DataManager.h
//  ZKMovies
//
//  Created by Zeeshan Khan on 07/04/15.
//  Copyright (c) 2015 Zeeshan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataManagerDelegate <NSObject>
@optional
- (void)refreshedList:(NSArray*)arrItems;
- (void)refreshDetailWithResponse:(NSDictionary*)response;
@end

@protocol DMCallBack <NSObject>
@optional
- (void)dataReceived:(id)data;
@end


@interface DataManager : NSObject <DMCallBack>
- (instancetype)initWithDelegate:(id <DataManagerDelegate>)delegate;
@end


@interface MovieListDM : DataManager 
- (void)getMoviesListForString:(NSString*)str;
@end

@interface MovieDetailDM : DataManager
- (void)getMovieDetailWithId:(NSString*)movieId;
@end
