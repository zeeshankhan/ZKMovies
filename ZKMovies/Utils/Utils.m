//
//  Utils.m
//  ZKMovies
//
//  Created by Zeeshan Khan on 07/04/15.
//  Copyright (c) 2015 Zeeshan. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (CGRect)screenFrame {
    static CGRect scFr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scFr = [[UIScreen mainScreen] bounds];
    });
    return scFr;
}

+ (NSString*)validString:(NSString*)str {
    
    if ([str isKindOfClass:[NSNumber class]] ) {
        return [NSString stringWithFormat:@"%@", str];
    }

    else if (![str isKindOfClass:[NSString class]] ) {
        return @"";
    }
    
    else if(str && ![@"(null)" isEqualToString:str] && ![@"null" isEqualToString:str] && ![@"<null>" isEqualToString:str] && ![str isKindOfClass:[NSNull class]]  && [str length] > 0) {
        str = [str stringByReplacingOccurrencesOfString:@"" withString:@""];
        str = [str stringByReplacingOccurrencesOfString:@" " withString:@" "];
        return str;
    }
    
    return @"";
}

+ (void)showAlertViewWithTitle:(NSString*)title message:(NSString*)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    alert = nil;
}

@end

@implementation UIColor (AppColors)

+ (UIColor*)bgColor {
    return [UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:246.0f/255.0f alpha:1];
}

+ (UIColor*)lightBlue {
    return [UIColor colorWithRed:100.0f/255.0f green:205.0f/255.0f blue:251.0f/255.0f alpha:1];
}

+ (UIColor*)seperatorColor {
    return [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1];
}

+ (UIColor*)rowSeletionColor {
    return [UIColor colorWithRed:(76.0/255.0) green:(161.0/255.0) blue:(255.0/255.0) alpha:1.0];
}

@end

@implementation NSString (NetworkRequest)

- (NSString*)encodedURLParameterString {
    NSString *result = (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                            (__bridge CFStringRef)self,
                                                                                            NULL,
                                                                                            CFSTR(":/=,!$&'()*+;[]@#?^%\"`<>{}\\|~ "),
                                                                                            kCFStringEncodingUTF8);
    return result;
}

@end
