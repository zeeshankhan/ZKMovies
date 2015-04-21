//
//  MovieDetails.h
//  ZKMovies
//
//  Created by Zeeshan Khan on 07/04/15.
//  Copyright (c) 2015 Zeeshan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define     kImgPlaceholder             @"poster-dark.png"

#define           kAPIKeyTitle                    @"title"
#define           kAPIKeyMovieId                @"idIMDB"
#define           kAPIKeyYear                     @"year"
#define           kAPIKeyPosterURL                @"urlPoster"
#define           kAPIKeyDetailsURL                @""
#define           kAPIKeyGenres                @"genres"
#define           kAPIKeyStoryline                @"simplePlot"
#define           kAPIKeyLanguages                @"languages"
#define           kAPIKeyDirectors                @"directors"
#define           kAPIKeyWriters                @"writers"
#define           kAPIKeyRuntime                @"runtime"
#define           kAPIKeyReleaseDate                @"releaseDate"
#define           kAPIKeyRating                @"rating"
#define           kAPIKeyCountries                @"countries"
#define           kAPIKeyFilmingLocations       @"filmingLocations"

@interface MovieDetails : NSObject

@property (strong, nonatomic) UIImage *poster;

+ (NSArray*)movieListFromResponse:(id)res;
- (void)updateResponse:(NSDictionary*)dic;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *movieId;
@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *posterURL;
@property (nonatomic, strong) NSString *detailsURL;
@property (nonatomic, strong) NSString *genres;
@property (nonatomic, strong) NSString *storyline;

@property (nonatomic, strong) NSString *languages;
@property (nonatomic, strong) NSString *directors;
@property (nonatomic, strong) NSString *writers;
@property (nonatomic, strong) NSString *runtime;
@property (nonatomic, strong) NSString *releaseDate;
@property (nonatomic, strong) NSString *rating;
@property (nonatomic, strong) NSString *countries;
@property (nonatomic, strong) NSString *filmingLocations;

- (NSInteger)castCount;
- (NSArray*)cast;
- (void)updateCastWithThumb:(UIImage*)img onIndex:(NSInteger)index;

@end

@interface MovieActor : MovieDetails
@property (strong, nonatomic) UIImage *actorThumb;

+ (NSArray*)actorListFromResponse:(NSArray*)arr;
- (NSString*)name;
- (NSString*)character;
- (NSString*)actorThumbURL;

@end