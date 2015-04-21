//
//  MovieDetails.m
//  ZKMovies
//
//  Created by Zeeshan Khan on 07/04/15.
//  Copyright (c) 2015 Zeeshan. All rights reserved.
//

#import "MovieDetails.h"
#import "Utils.h"

@interface MovieDetails ()
@property (strong, nonatomic) NSMutableDictionary *dicMovie;
@property (strong, nonatomic) NSMutableArray *arrActors;
@end

@implementation MovieDetails

+ (NSArray*)movieListFromResponse:(id)res {
    NSMutableArray *arr = [@[] mutableCopy];
    NSArray *movies = (NSArray*)res;
    for (NSDictionary *dic in movies) {
        [arr addObject:[[[self class] alloc] initWithMoview:dic]];
    }
    return [NSArray arrayWithArray:arr];
}

- (void)updateResponse:(NSDictionary*)dic {
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        [self.dicMovie addEntriesFromDictionary:dic];
        self.arrActors = [[MovieActor actorListFromResponse:[self.dicMovie objectForKey:@"actors"]] mutableCopy];
    }
}

- (instancetype)initWithMoview:(NSDictionary*)dic {
    self = [super init];
    if (self) {
        self.dicMovie = [dic mutableCopy];
        [self setMovieInfo:dic];
    }
    return self;
}

- (void)setMovieInfo:(NSDictionary*)dicInfo {

    self.title = [Utils validString:[self.dicMovie objectForKey:kAPIKeyTitle]];
    self.movieId = [Utils validString:[self.dicMovie objectForKey:kAPIKeyMovieId]];
    self.year = [Utils validString:[self.dicMovie objectForKey:kAPIKeyYear]];
    self.posterURL = [Utils validString:[self.dicMovie objectForKey:kAPIKeyPosterURL]];
    
    NSArray *arr = [self.dicMovie objectForKey:kAPIKeyGenres];
    self.genres = [Utils validString:[arr componentsJoinedByString:@" / "]];
    
    self.storyline = [Utils validString:[self.dicMovie objectForKey:kAPIKeyStoryline]];

    arr = [self.dicMovie objectForKey:kAPIKeyLanguages];
    self.languages = [Utils validString:[arr componentsJoinedByString:@" / "]];
    
    arr = [self.dicMovie objectForKey:kAPIKeyDirectors];
    NSMutableArray *names = [@[] mutableCopy];
    for (NSDictionary *dic in arr) {
        NSString *name = [Utils validString:[dic objectForKey:@"name"]];
        if (name.length>0) [names addObject:name];
    }
    self.directors = [names componentsJoinedByString:@", "];
    
    arr = [self.dicMovie objectForKey:kAPIKeyWriters];
    NSMutableArray *arrNames = [@[] mutableCopy];
    for (NSDictionary *dic in arr) {
        NSString *name = [Utils validString:[dic objectForKey:@"name"]];
        if (name.length>0) [arrNames addObject:name];
    }
    self.writers = [names componentsJoinedByString:@", "];
    
    arr = [self.dicMovie objectForKey:kAPIKeyRuntime];
    self.runtime = [Utils validString:[arr firstObject]];
    
    NSString *dt = [Utils validString:[self.dicMovie objectForKey:kAPIKeyReleaseDate]];
    if (dt.length > 0) {
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat:@"yyyymmdd"];
        NSDate *d = [df dateFromString:dt];
        [df setDateFormat:@"yyyy/mm/dd"];
        dt = [df stringFromDate:d];
    }
    self.releaseDate = dt;
    
    self.rating = [Utils validString:[self.dicMovie objectForKey:kAPIKeyRating]];
    
    arr = [self.dicMovie objectForKey:kAPIKeyCountries];
    self.countries = [Utils validString:[arr componentsJoinedByString:@" / "]];
    
    arr = [self.dicMovie objectForKey:kAPIKeyFilmingLocations];
    self.filmingLocations = [Utils validString:[arr componentsJoinedByString:@" / "]];
}

#pragma mark - Cast

- (NSArray*)cast {
    return self.arrActors;
}

- (void)setArrActors:(NSMutableArray *)arrActors {
    if (_arrActors == nil) {
        _arrActors = [[NSMutableArray alloc] initWithArray:arrActors];
    }
}

- (NSInteger)castCount {
    if (_arrActors) return _arrActors.count;
    return [[self.dicMovie objectForKey:@"actors"] count];
}

- (void)updateCastWithThumb:(UIImage*)img onIndex:(NSInteger)index {
    MovieActor *ac = [self.arrActors objectAtIndex:index];
    ac.actorThumb = img;
}

@end


@interface MovieActor ()
@property (nonatomic, strong) NSDictionary *dicActor;
@end

@implementation MovieActor

+ (NSArray*)actorListFromResponse:(NSArray*)arr {
    NSMutableArray *arrCast = [@[] mutableCopy];
    for (NSDictionary* actor in arr) {
        [arrCast addObject:[[[self class] alloc] initWithActor:actor]];
    }
    return arrCast;
}

- (instancetype)initWithActor:(NSDictionary*)actor {
    self = [super init];
    if (self) {
        self.dicActor = actor;
    }
    return self;
}

- (NSString*)name {
    return [Utils validString:[self.dicActor objectForKey:@"actorName"]];
}

- (NSString*)character {
    return [Utils validString:[self.dicActor objectForKey:@"character"]];
}

- (NSString*)actorThumbURL {
    NSString *str = [Utils validString:[self.dicActor objectForKey:@"urlPhoto"]];
    if (![str isEqualToString:@""]) {
        NSString *newUrl = [NSString stringWithFormat:@"%@._V1_SY317_CR56,0,214,317_AL_.jpg",[[str componentsSeparatedByString:@"._V1_"] firstObject]];
        return newUrl;
    }
    return str;
}

@end


