//
//  ViewController.m
//  ZKMovies
//
//  Created by Zeeshan Khan on 07/04/15.
//  Copyright (c) 2015 Zeeshan. All rights reserved.
//

#import "ViewController.h"
#import "MoviesListCell.h"
#import "DataManager.h"
#import "Utils.h"
#import "ZKImageDownloader.h"
#import "MovieDetails.h"
#import "DetailVC.h"

@interface ViewController () <DataManagerDelegate, UISearchBarDelegate, ImageDownloadDelegate>

@property (strong, nonatomic) NSMutableArray *arrList;
@property (strong, nonatomic) MovieListDM *dm;
@property (nonatomic, strong) NSOperationQueue     *imageDownloadQueue;
@property (nonatomic, strong) UISearchBar *searchBar;
@end

@implementation ViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setSeparatorColor:[UIColor seperatorColor]];
    self.clearsSelectionOnViewWillAppear = YES;
    
    self.dm = [[MovieListDM alloc] initWithDelegate:self];
    
    self.imageDownloadQueue = [[NSOperationQueue alloc] init];
    self.imageDownloadQueue.name = @"ZKSearchListingQueue";
    [self.imageDownloadQueue setMaxConcurrentOperationCount:10];

    [self intializeSearchBar];
    
    // Pre run service
    self.searchBar.text = @"X men";
    [self.dm getMoviesListForString:self.searchBar.text];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.searchBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.searchBar removeFromSuperview];
    [self.imageDownloadQueue cancelAllOperations];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [self.imageDownloadQueue cancelAllOperations];
    [super didReceiveMemoryWarning];
}

#pragma mark - UISearchBarDelegate

- (void)intializeSearchBar {
    CGSize sc = self.navigationController.navigationBar.frame.size;
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(10, 0, sc.width-20, sc.height)];
    self.searchBar.placeholder = @"Search";
    self.searchBar.showsCancelButton=YES;
    self.searchBar.delegate = self;
    self.searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    self.searchBar.barStyle = UIBarStyleBlack;
    self.searchBar.translucent = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length > 0) {
        [self.dm getMoviesListForString:searchBar.text];
        [searchBar resignFirstResponder];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - DataManagerDelegate

- (void)refreshedList:(NSArray*)arrItems {
    if (arrItems) {
        self.arrList = [arrItems mutableCopy];
        [self.tableView reloadData];
    }
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrList.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MoviesListCell *cell = (MoviesListCell *)[tableView dequeueReusableCellWithIdentifier:@"MoviesListCell"];

    UIView *bgColorView = [UIView new];
    bgColorView.backgroundColor = [UIColor rowSeletionColor];
    bgColorView.layer.masksToBounds = YES;
    cell.selectedBackgroundView = bgColorView;
    
    MovieDetails *m = [self.arrList objectAtIndex:indexPath.row];
    NSString *text = [NSString stringWithFormat:@"%@\n%@",m.title, m.year];

    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:text];
    [attText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:[text rangeOfString:m.title]];
    [attText addAttribute:NSForegroundColorAttributeName value:[UIColor lightBlue] range:[text rangeOfString:m.year]];
    cell.lblName.attributedText = attText;

    UIImage *img = m.poster;
    if (img != nil) {
        cell.imgVThumb.image = img;
    }
    else {
        
        cell.imgVThumb.image = [UIImage imageNamed:kImgPlaceholder];
        if (tableView.dragging == NO && tableView.decelerating == NO) {
            [self startIconDownloadForUrl:m.posterURL forIndexPath:indexPath];
        }
    }
    return cell;
}

#pragma mark - Image Download Delegate callback

- (void)imageLoaded:( UIImage*)img forPath:(NSIndexPath*)path {
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        __block UIImage *image = img;
        if (image == nil) image = [UIImage imageNamed:kImgPlaceholder];
        MovieDetails *m = [self.arrList objectAtIndex:path.row];
        m.poster = image;
        [self.arrList replaceObjectAtIndex:path.row withObject:m];
        
        MoviesListCell *oldcell = (MoviesListCell*)[self.tableView cellForRowAtIndexPath:path];
        oldcell.imgVThumb.image = image;
    });

}

#pragma mark - Table Image Download

- (void)startIconDownloadForUrl:(NSString*)strUrl forIndexPath:(NSIndexPath *)indexPath {
    [self.imageDownloadQueue addOperation:[[ZKImageDownloader alloc] initWithUrl:strUrl path:indexPath callback:self]];
}

- (void)loadImagesForOnscreenRows {

    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths) {
        MovieDetails* m = [self.arrList objectAtIndex:indexPath.row];
        if (m.poster == nil)
            [self startIconDownloadForUrl:m.posterURL forIndexPath:indexPath];
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

// Try hiding nav bar and tab bor on scroll up
- (void)topBottomBarHide:(BOOL)yesNo {
    self.navigationController.navigationBarHidden = yesNo; //!self.navigationController.navigationBarHidden;
    self.tabBarController.tabBar.hidden = yesNo; //!self.tabBarController.tabBar.hidden;
}

#pragma mark - Push Detail VC

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"MovieDetails"]) {
        DetailVC* dvcObj = [segue destinationViewController];
        dvcObj.md = [self.arrList objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    }

}

@end
