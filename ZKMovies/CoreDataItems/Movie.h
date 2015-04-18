//
//  Movie.h
//  ZKMovies
//
//  Created by Zeeshan Khan on 07/04/15.
//  Copyright (c) 2015 Zeeshan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Movie : NSManagedObject

@property (nonatomic, retain) NSData * details;
@property (nonatomic, retain) NSString * movieId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * pageNo;

@end
