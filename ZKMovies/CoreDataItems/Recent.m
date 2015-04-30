//
//  Recent.m
//  ZKMovies
//
//  Created by Zeeshan Khan on 11/04/15.
//  Copyright (c) 2015 Zeeshan. All rights reserved.
//

#import "Recent.h"


@implementation Recent

@dynamic dt;
@dynamic search;

- (NSString*)description {
    return [NSString stringWithFormat:@"Recent Search: '%@' on '%@'", self.search, self.dt];
}

@end
