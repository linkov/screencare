//
//  UIView+StatusBarRef.m
//  ScreenCare
//
//  Created by alex on 7/11/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//
#import "SDWRSwizzleHelper.h"
#import <UIKit/UIKit.h>

static UIView *statusBarInstance = nil;

#import "UIView+StatusBarRef.h"

@implementation UIView (StatusBarRef)

+ (UIView *)statusBarInstance_Screencare
{
    return statusBarInstance;
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class statusBarClass = NSClassFromString(@"UIStatusBar");
        [SDWRSwizzleHelper swizzClass:statusBarClass
                                                        selector:@selector(setFrame:)
                                                        selector:@selector(setFrame_ComSDWRScreencareHelper:)];
        [SDWRSwizzleHelper swizzClass:statusBarClass
                                                        selector:NSSelectorFromString(@"dealloc")
                                                        selector:@selector(dealloc_ComSDWRScreencareHelper)];
    });
}

- (void)setFrame_ComSDWRScreencareHelper:(CGRect)frame
{
    [self setFrame_ComSDWRScreencareHelper:frame];
    statusBarInstance = self;
}

- (void)dealloc_ComSDWRScreencareHelper
{
    statusBarInstance = nil;
    [self dealloc_ComSDWRScreencareHelper];
}

@end
