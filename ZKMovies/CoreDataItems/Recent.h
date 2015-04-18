//
//  Recent.h
//  ZKMovies
//
//  Created by Zeeshan Khan on 11/04/15.
//  Copyright (c) 2015 Zeeshan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Recent : NSManagedObject

@property (nonatomic, retain) NSDate * dt;
@property (nonatomic, retain) NSString * search;

@end
