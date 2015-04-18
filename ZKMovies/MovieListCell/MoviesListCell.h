//
//  ZKMoviesListCell.h
//  ZKMovies
//
//  Created by Zeeshan Khan on 07/04/15.
//  Copyright (c) 2015 Zeeshan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoviesListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgVThumb;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@end



@interface MoviesDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgVThumb;
@property (weak, nonatomic) IBOutlet UIImageView *imgVBG;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@end
