//
//  SDWScreenShotOverlayVC.h
//  Screenr
//
//  Created by alex on 6/28/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SDWScreenshotCompletionBlock)(UIImage *image, NSDictionary *notes);

@interface SDWScreenShotOverlayVC : UIViewController

- (id)initWithScreenGrab:(UIImageView *)screen statusBarHidden:(BOOL)isHidden completion:(SDWScreenshotCompletionBlock)block;
- (void)closeWidget;

@end
