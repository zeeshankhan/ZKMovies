//
//  ZKCoreDataManager.m
//  ZKMovies
//
//  Created by Zeeshan Khan on 07/04/15.
//  Copyright (c) 2015 Zeeshan. All rights reserved.
//

#import "DBManager.h"
#import "CoreDataStack.h"
#import "Movie.h"
#import "Recent.h"

@implementation DBManager

- (NSArray*)getSearchList {
    return [self getSearchListWithSearchItem:nil];
}

- (NSArray*)getSearchListWithSearchItem:(NSString*)searchString {

    NSManagedObjectContext *context = [CoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Recent class]) inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    //    [fetchRequest setResultType:NSDictionaryResultType];
    
    if (searchString) {
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"search == %@", [searchString lowercaseString]];
        [fetchRequest setPredicate:pre];
    }
    
    NSError *error = nil;
    NSArray *arrResult = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) NSLog(@"[DB Error] GET list: %@", error.debugDescription);
    return arrResult;
}


- (void)addSearchItem:(NSString*)searchString {
    
    if (searchString.length == 0) {
        NSLog(@"[DB Error] Search String is nil."); return;
    }
    
    NSArray *arr = nil;
    // Print all items name
//    arr = [self getSearchListWithSearchItem:nil];
//    for (Recent* r in arr) {
//        NSLog(@"%@", r.search);
//    }

    arr = [self getSearchListWithSearchItem:searchString];
    if (arr.count > 0) {
        NSLog(@"[DB Error] Search item already exist.: %@", searchString); return;
    }

    NSManagedObjectContext *context = [CoreDataStack sharedInstance].managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Recent class]) inManagedObjectContext:context];
    Recent *row = (Recent*)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    if (row) {
        row.search = [searchString lowercaseString];
        row.dt = [NSDate date];
    }
    
    [[CoreDataStack sharedInstance] saveContext];
}

- (void)deleteSearchObject:(Recent*)searchItem {
    if (searchItem) {
        [[CoreDataStack sharedInstance].managedObjectContext deleteObject:searchItem];
        [[CoreDataStack sharedInstance] saveContext];
    }
}

@end
