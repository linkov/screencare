//
//  SDWScreenShotService.m
//  Screenr
//
//  Created by alex on 6/28/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//
#import "SDWScreenShotOverlayVC.h"
#import "SDWScreenShotService.h"

@implementation SDWScreenShotService

+(instancetype)sharedInstance {

    static dispatch_once_t pred = 0;
	static SDWScreenShotService *service = nil;
	dispatch_once(&pred, ^{
	    service = [[SDWScreenShotService alloc] init];
        [service setupService];

	});
	return service;
}

- (void)setupService {

    //    [self performSelector:@selector(startOverlay) withObject:nil afterDelay:1.3];

    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {


        [self startOverlay];

    }];

}


- (void)startOverlay {

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[self takeScreenshot]];
    SDWScreenShotOverlayVC *overlayVC = [[SDWScreenShotOverlayVC alloc]initWithScreenGrab:imageView];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    UINavigationController *screenCaptureNav = [[UINavigationController alloc]initWithRootViewController:overlayVC];
    [self presentViewController:screenCaptureNav animated:NO completion:nil];
}

- (BOOL)appHasStatusBar {

    return  ![UIApplication sharedApplication].isStatusBarHidden;
}

- (UIImage *)takeScreenshot {

    UIImage *statusBar;
    UIImageView *imageView;

    if ([self appHasStatusBar]) {

        if ([UIApplication sharedApplication].statusBarStyle != UIStatusBarStyleLightContent) {

            statusBar = [UIImage imageNamed:@"statusBarBlack"];
        }
        else {

            statusBar = [UIImage imageNamed:@"statusBarWhite"];
        }


        imageView = [[UIImageView alloc]initWithImage:statusBar];
        imageView.frame = CGRectMake(320/2-imageView.frame.size.width/2, 4, imageView.frame.size.width, imageView.frame.size.height);

    }



    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);

    CGContextRef context = UIGraphicsGetCurrentContext();

    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);



            //            [statusBar drawInRect:CGRectMake(0, 0, statusBar.size.width, statusBar.size.height)];

            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            if ([self appHasStatusBar]) {

                [statusBar drawInRect:imageView.frame];
            }
            //     CGContextDrawImage(context, imageView.frame, statusBar.CGImage);
            //     [imageView.layer renderInContext:context];

            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *imageForEmail = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageForEmail;
}



@end
