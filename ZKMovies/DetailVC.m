//
//  DetailVC.m
//  ZKMovies
//
//  Created by Zeeshan Khan on 08/04/15.
//  Copyright (c) 2015 Zeeshan. All rights reserved.
//

#import "DetailVC.h"
#import "MovieDetails.h"
#import "MoviesListCell.h"
#import "DataManager.h"
#import "Utils.h"
#import "ZKImageDownloader.h"
#import "UIImageEffects.h"

@interface DetailVC () <DataManagerDelegate, ImageDownloadDelegate>
@property (nonatomic, strong) NSArray *arrDetail;
@property (nonatomic, strong) NSOperationQueue     *imageDownloadQueue;
@end

@implementation DetailVC

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.md.title;
    [self.tableView setSeparatorColor:[UIColor seperatorColor]];

    if (self.md.poster == nil)
        [self downloadThumb];
    else
        [self setTableBackground];
    
    self.imageDownloadQueue = [[NSOperationQueue alloc] init];
    self.imageDownloadQueue.name = @"ZKActorListingQueue";
    [self.imageDownloadQueue setMaxConcurrentOperationCount:10];

    self.arrDetail = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DetailScreen" ofType:@"plist"]];
    MovieDetailDM *dm = [[MovieDetailDM alloc] initWithDelegate:self];
    [dm getMovieDetailWithId:self.md.movieId];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.imageDownloadQueue cancelAllOperations];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [self.imageDownloadQueue cancelAllOperations];
    [super didReceiveMemoryWarning];
}

#pragma mark - VC logic

- (void)setTableBackground {

    UIImage *img = [UIImageEffects imageByApplyingDarkEffectToImage:self.md.poster];
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:img];
    [tempImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = tempImageView;
}

- (void)downloadThumb {

    __weak DetailVC *weakSelf = self;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^(void) {
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:weakSelf.md.posterURL]];
        if (imageData) {

            UIImage* image = [UIImage imageWithData:imageData];
            if (image) {

                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.md.poster = image;
                    [weakSelf setTableBackground];
                    [weakSelf.tableView reloadData];
                });
            }
            else { NSLog(@"UIImage is nil."); }
        }  else { NSLog(@"Image NSData is nil."); }
    });

}

- (void)addCastRowsWithCount:(NSInteger)castCount {

    NSArray *arrDetail = self.arrDetail;
    NSMutableArray *arrNew = [NSMutableArray arrayWithArray:arrDetail];
    
    NSDictionary *dicCastRow = nil;
    for (int a=0; a<arrDetail.count; a++) {

        NSMutableDictionary *sec = [NSMutableDictionary dictionaryWithDictionary:[arrDetail objectAtIndex:a]];

        NSString *title = [sec objectForKey:@"SectionTitle"];
        if ([title isEqualToString:@"Cast"]) {
        
            dicCastRow = [[sec objectForKey:@"Rows"] firstObject];
            
            NSMutableArray *arrNewCast = [@[] mutableCopy];
            for (int x=0; x<castCount; x++) {
                [arrNewCast addObject:[NSDictionary dictionaryWithDictionary:dicCastRow]];
            }

            sec[@"Rows"] = arrNewCast;
            [arrNew replaceObjectAtIndex:a withObject:sec];
            break;
        }
    }
    
    self.arrDetail = [NSArray arrayWithArray:arrNew];
}

#pragma mark - DataManagerDelegate

- (void)refreshDetailWithResponse:(NSDictionary*)response {
    if (response) {
        [self.md updateResponse:response];
        [self addCastRowsWithCount:self.md.castCount];
        [self.tableView reloadData];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arrDetail.count;
}

#define kHeaderHeight 25

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *secTitle = [Utils validString:[[self.arrDetail objectAtIndex:section] objectForKey:@"SectionTitle"]];
    if (![secTitle isEqualToString:@""]) return kHeaderHeight;
    return 0;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    
    CGSize scSz = [Utils screenFrame].size;
    UIView *vHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scSz.width, kHeaderHeight)];
    vHeader.backgroundColor = [UIColor clearColor];

    UIView *vTransparent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scSz.width, kHeaderHeight)];
    vTransparent.backgroundColor = [UIColor blackColor];
    vTransparent.alpha = 0.4;
    [vHeader addSubview:vTransparent];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, scSz.width-20, kHeaderHeight)];
    lblTitle.textColor = [UIColor lightBlue];
    lblTitle.font = [UIFont boldSystemFontOfSize:13];
    [vHeader addSubview:lblTitle];
    
    NSString *secTitle = [Utils validString:[[self.arrDetail objectAtIndex:section] objectForKey:@"SectionTitle"]];
    if (![secTitle isEqualToString:@""]) {
        lblTitle.text = secTitle;
    }
    else
        vHeader = nil;
    
    return vHeader;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.arrDetail objectAtIndex:section] objectForKey:@"Rows"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat val = [[[[[self.arrDetail objectAtIndex:indexPath.section] objectForKey:@"Rows"] objectAtIndex:indexPath.row] objectForKey:@"Height"] floatValue];
    if (val == 0) val = UITableViewAutomaticDimension;
    return val;
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewAutomaticDimension;
//}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *row = [[[self.arrDetail objectAtIndex:indexPath.section] objectForKey:@"Rows"] objectAtIndex:indexPath.row];
    NSString *iden = [row objectForKey:@"CellId"];
    NSString *key = [Utils validString:[row objectForKey:@"Key"]];
    
    NSString *value = @"";
    if (key.length > 0) {
        SEL selector = NSSelectorFromString(key);
//        value = (NSString*)[self.md performSelector:selector]; // http://stackoverflow.com/a/20058585/559017
        
        IMP imp = [self.md methodForSelector:selector];
        NSString* (*func)(id, SEL) = (void *)imp;
        value = func(self.md, selector);
    }

    if ([iden isEqualToString:@"MoviesDetailCell"]) {
        
        MoviesDetailCell *cell = (MoviesDetailCell *)[tableView dequeueReusableCellWithIdentifier:iden forIndexPath:indexPath];
        
        NSString *text = [NSString stringWithFormat:@"%@\n%@\n%@",self.md.title, self.md.genres, self.md.year];
        NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:text];
        [attText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:22] range:[text rangeOfString:_md.title]];
        [attText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:[text rangeOfString:_md.year]];
        [attText addAttribute:NSForegroundColorAttributeName value:[UIColor lightBlue] range:[text rangeOfString:_md.year]];
        [attText addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:[text rangeOfString:_md.genres]];
        cell.lblName.attributedText = attText;
        cell.imgVThumb.image = self.md.poster;
        
        return cell;
    }
    
    else if ([iden isEqualToString:@"MoviesListCell"]) {

        MoviesListCell *cell = (MoviesListCell *)[tableView dequeueReusableCellWithIdentifier:iden forIndexPath:indexPath];
        
        NSArray *arrCast = self.md.cast;
        if (arrCast.count > 0) {
            MovieActor *ma = [arrCast objectAtIndex:indexPath.row];
            NSString *text = [NSString stringWithFormat:@"%@\nas %@", ma.name, ma.character];
            NSString *chara = [NSString stringWithFormat:@"as %@", ma.character];
            NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:text];
            [attText setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor grayColor]} range:[text rangeOfString:chara]];
            cell.lblName.attributedText = attText;
            
            UIImage *img = ma.actorThumb;
            if (img != nil) {
                cell.imgVThumb.image = img;
            }
            else {
                
                cell.imgVThumb.image = [UIImage imageNamed:kImgPlaceholder];
                if (tableView.dragging == NO && tableView.decelerating == NO) {
                    [self startIconDownloadForUrl:ma.actorThumbURL forIndexPath:indexPath];
                }
            }
            
            // Make rounded image for characters
            UIImageView *imageView = cell.imgVThumb;
            [imageView setClipsToBounds:YES];
            [imageView.layer setBorderColor:[UIColor clearColor].CGColor];
            [imageView.layer setBorderWidth:2.0];
            [imageView.layer setCornerRadius:imageView.frame.size.width/2.0];
            
        }
        return cell;
    }
    
    else if ([iden isEqualToString:@"Basic"]) {
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:iden forIndexPath:indexPath];

        if ([key isEqualToString:@"directors"]) {
            NSString *header = @"Directed by:";
            NSString *text = [NSString stringWithFormat:@"%@ %@", header, value];
            NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:text];
            [attText setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:13], NSForegroundColorAttributeName: [UIColor lightBlue]} range:[text rangeOfString:header]];
            [attText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:[text rangeOfString:value]];
            cell.textLabel.attributedText = attText;
        }
        else
            cell.textLabel.text = value;
        return cell;
    }

    else if ([iden isEqualToString:@"RightDetail"]) {
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:iden forIndexPath:indexPath];
        cell.textLabel.text = [row objectForKey:@"LeftTitle"];
        cell.detailTextLabel.text = value;
        return cell;
    }

    else {
        NSLog(@"Cell Identifier is missing...");
        return nil;
    }
}

#pragma mark - Image Download Delegate callback

- (void)imageLoaded:( UIImage*)img forPath:(NSIndexPath*)path {
    
    __weak DetailVC *weakSelf = self;

    dispatch_sync(dispatch_get_main_queue(), ^{
        if (weakSelf) {
            __block UIImage *image = img;
            if (image == nil) image = [UIImage imageNamed:kImgPlaceholder];
            [weakSelf.md updateCastWithThumb:image onIndex:path.row];
            
            MoviesListCell *oldcell = (MoviesListCell*)[weakSelf.tableView cellForRowAtIndexPath:path];
            oldcell.imgVThumb.image = image;
        }
    });
    
}

#pragma mark - Table Image Download

- (void)startIconDownloadForUrl:(NSString*)strUrl forIndexPath:(NSIndexPath *)indexPath {
    [self.imageDownloadQueue addOperation:[[ZKImageDownloader alloc] initWithUrl:strUrl path:indexPath callback:self]];
}

- (void)loadImagesForOnscreenRows {
    
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths) {
        NSDictionary *dicSec = [self.arrDetail objectAtIndex:indexPath.section];
        NSString *secTitle = [dicSec objectForKey:@"SectionTitle"];
        if ([secTitle isEqualToString:@"Cast"] && self.md.cast.count > indexPath.row) {
            MovieActor* m = [self.md.cast objectAtIndex:indexPath.row];
            if (m.actorThumb == nil)
                [self startIconDownloadForUrl:m.actorThumbURL forIndexPath:indexPath];
        }
    }
}

#pragma mark - Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImagesForOnscreenRows];
}


@end
