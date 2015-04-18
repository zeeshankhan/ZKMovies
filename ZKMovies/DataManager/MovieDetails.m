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
    }
    return self;
}

#pragma mark - Movie Info

- (NSString*)movieId {
    return [Utils validString:[self.dicMovie objectForKey:@"idIMDB"]];
}

- (NSString*)title {
    return [Utils validString:[self.dicMovie objectForKey:@"title"]];
}

- (NSString*)year {
    return [Utils validString:[self.dicMovie objectForKey:@"year"]];
}

- (NSString*)strURLThumb {
    return [Utils validString:[self.dicMovie objectForKey:@"urlPoster"]];
}

- (NSString*)strURLDetail {
    NSDictionary *posters = [self.dicMovie objectForKey:@"links"];
    return [Utils validString:[posters objectForKey:@"self"]];
}

- (NSString*)genres {
    NSArray *arr = [self.dicMovie objectForKey:kDetailKeyGenres];
    return [Utils validString:[arr componentsJoinedByString:@" / "]];
}

- (NSString*)storyline {
    return [Utils validString:[self.dicMovie objectForKey:@"simplePlot"]];
}

- (NSString*)rating {
    return [Utils validString:[self.dicMovie objectForKey:@"rating"]];
}

- (NSString*)languages {
    NSArray *arr = [self.dicMovie objectForKey:@"languages"];
    return [Utils validString:[arr componentsJoinedByString:@" / "]];
}

- (NSString*)countries {
    NSArray *arr = [self.dicMovie objectForKey:@"countries"];
    return [Utils validString:[arr componentsJoinedByString:@" / "]];
}

- (NSString*)filmingLocations {
    NSArray *arr = [self.dicMovie objectForKey:@"filmingLocations"];
    return [Utils validString:[arr componentsJoinedByString:@" / "]];
}

- (NSString*)runtime {
    NSArray *arr = [self.dicMovie objectForKey:@"runtime"];
    return [Utils validString:[arr firstObject]];
}

- (NSString*)directors {
    NSArray *arr = [self.dicMovie objectForKey:@"directors"];
    NSMutableArray *names = [@[] mutableCopy];
    for (NSDictionary *dic in arr) {
        NSString *name = [Utils validString:[dic objectForKey:@"name"]];
        if (name.length>0) [names addObject:name];
    }
    return [names componentsJoinedByString:@", "];
}

- (NSString*)writers {
    NSArray *arr = [self.dicMovie objectForKey:@"writers"];
    NSMutableArray *names = [@[] mutableCopy];
    for (NSDictionary *dic in arr) {
        NSString *name = [Utils validString:[dic objectForKey:@"name"]];
        if (name.length>0) [names addObject:name];
    }
    return [names componentsJoinedByString:@", "];
}

- (NSString*)releaseDate {
    NSString *dt = [Utils validString:[self.dicMovie objectForKey:@"releaseDate"]];
    if (dt.length > 0) {
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat:@"yyyymmdd"];
        NSDate *d = [df dateFromString:dt];
        [df setDateFormat:@"yyyy/mm/dd"];
        dt = [df stringFromDate:d];
    }
    return dt;
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
    return [[self.dicMovie objectForKey:@"actors"] count];
}

- (void)updateCastWithThumb:(UIImage*)img onIndex:(NSInteger)index {
    MovieActor *ac = [self.arrActors objectAtIndex:index];
    ac.thumb = img;
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

- (NSString*)strURLThumb {
    NSString *str = [Utils validString:[self.dicActor objectForKey:@"urlPhoto"]];
    NSString *newUrl = [NSString stringWithFormat:@"%@._V1_SY317_CR56,0,214,317_AL_.jpg",[[str componentsSeparatedByString:@"._V1_"] firstObject]];
    return newUrl;
}

@end


