//
//  RecentVC.m
//  ZKMovies
//
//  Created by Zeeshan Khan on 11/04/15.
//  Copyright (c) 2015 Zeeshan. All rights reserved.
//

#import "RecentVC.h"
#import "DBManager.h"
#import "Recent.h"
#import "Utils.h"

@interface RecentVC ()
@property (nonatomic, strong) NSMutableArray *arrRecent;
@property (nonatomic, strong) NSDateFormatter *df;
@end

@implementation RecentVC

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
     self.clearsSelectionOnViewWillAppear = YES;
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.df = [NSDateFormatter new];
    [self.df setDateStyle:NSDateFormatterShortStyle];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.arrRecent = [[[DBManager new] getSearchList] mutableCopy];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrRecent.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Subtitle"];
    Recent *rec = [self.arrRecent objectAtIndex:indexPath.row];
    cell.textLabel.text = rec.search;
    cell.detailTextLabel.text = [self.df stringFromDate:rec.dt];
    
    UIView *bgColorView = [UIView new];
    bgColorView.backgroundColor = [UIColor rowSeletionColor];
    bgColorView.layer.masksToBounds = YES;
    cell.selectedBackgroundView = bgColorView;

    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Recent *rec = [self.arrRecent objectAtIndex:indexPath.row];
        [[DBManager new] deleteSearchObject:rec];
        [self.arrRecent removeObject:rec];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

/*
#pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
