//
//  ZKCoreDataManager.h
//  ZKMovies
//
//  Created by Zeeshan Khan on 07/04/15.
//  Copyright (c) 2015 Zeeshan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Recent;
@interface DBManager : NSObject

- (NSArray*)getSearchList;
- (void)addSearchItem:(NSString*)searchString;
- (void)deleteSearchObject:(Recent*)searchItem;

@end
