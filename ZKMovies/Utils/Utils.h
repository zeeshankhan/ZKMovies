//
//  Utils.h
//  ZKMovies
//
//  Created by Zeeshan Khan on 07/04/15.
//  Copyright (c) 2015 Zeeshan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject

+ (CGRect)screenFrame;

#pragma mark - Categories
+ (NSString*)validString:(NSString*)str;
+ (void)showAlertViewWithTitle:(NSString*)title message:(NSString*)message;

@end

@interface UIColor (AppColors)
+ (UIColor*)bgColor;
+ (UIColor*)lightBlue;
+ (UIColor*)seperatorColor;
+ (UIColor*)rowSeletionColor;
@end

@interface NSString (NetworkRequest)
- (NSString*)encodedURLParameterString;
@end


