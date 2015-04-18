//
//  MovieDetails.h
//  ZKMovies
//
//  Created by Zeeshan Khan on 07/04/15.
//  Copyright (c) 2015 Zeeshan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define     kDetailKeyGenres          @"genres"
#define     kDetailKeyDirectors          @"directors"
#define     kImgPlaceholder             @"poster-dark.png"

@interface MovieDetails : NSObject

@property (strong, nonatomic) UIImage *thumb;

+ (NSArray*)movieListFromResponse:(id)res;
- (void)updateResponse:(NSDictionary*)dic;

- (NSString*)title;
- (NSString*)movieId;
- (NSString*)year;
- (NSString*)strURLThumb;
- (NSString*)strURLDetail;
- (NSString*)genres;
- (NSString*)storyline;

- (NSString*)languages;
- (NSString*)directors;
- (NSString*)writers;
- (NSString*)runtime;
- (NSString*)releaseDate;
- (NSString*)rating;
- (NSString*)countries;
- (NSString*)filmingLocations;

- (NSInteger)castCount;
- (NSArray*)cast;
- (void)updateCastWithThumb:(UIImage*)img onIndex:(NSInteger)index;

@end

@interface MovieActor : MovieDetails
@property (strong, nonatomic) UIImage *thumb;

+ (NSArray*)actorListFromResponse:(NSArray*)arr;
- (NSString*)name;
- (NSString*)character;
- (NSString*)strURLThumb;

@end