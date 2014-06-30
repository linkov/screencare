//
//  SDWScreenShotService.m
//  Screenr
//
//  Created by alex on 6/28/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//
#import "SDWScreenShotOverlayVC.h"
#import "ScreenCare.h"
#import "AFNetworking.h"

@implementation ScreenCare {

    NSString *ucKey;
    NSString *slackKey;
    UIProgressView *progressView;
    BOOL appStatusbarHidden;
}

+(instancetype)sharedInstance {

    static dispatch_once_t pred = 0;
	static ScreenCare *service = nil;
	dispatch_once(&pred, ^{
	    service = [[ScreenCare alloc] init];
        [service setupService];

	});
	return service;
}

-(id)initWithUploadCareKey:(NSString *)uck slackHookUrl:(NSString *)slackUrl; {

    self = [super init];
    if (self) {

        ucKey = uck ?: @"";
        slackKey = slackUrl ?: @"";
        [self setupService];
        self.view.userInteractionEnabled = NO;

    }
    return self;
}

- (void)setupService {

    progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    //    progressView.center = self.view.center;



//    [self performSelector:@selector(startOverlay) withObject:nil afterDelay:1.3];

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {


            [self startOverlay];

        }];

}


- (NSString *)buildNumber {

    return [NSString stringWithFormat:@"Build %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
}


- (void)startOverlay {

    appStatusbarHidden = [UIApplication sharedApplication].isStatusBarHidden;

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[self screenshot]];
    SDWScreenShotOverlayVC *overlayVC = [[SDWScreenShotOverlayVC alloc]initWithScreenGrab:imageView statusBarHidden:appStatusbarHidden completion:^(UIImage *image, NSDictionary *notes) {

        [self uploadImage:image withNotes:notes];

    }];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    UINavigationController *screenCaptureNav = [[UINavigationController alloc]initWithRootViewController:overlayVC];
    [screenCaptureNav.navigationBar addSubview:progressView];
    progressView.frame = CGRectMake(0, screenCaptureNav.navigationBar.frame.size.height, [UIScreen mainScreen].bounds.size.height, 2);
    progressView.hidden = YES;
    [self presentViewController:screenCaptureNav animated:NO completion:nil];
}

-(NSString *)prepareNotes:(NSDictionary *)notes {

      __block  NSString *notesStr = @"";

    [notes enumerateKeysAndObjectsUsingBlock:^(id number,id text, BOOL *stop) {

     notesStr = [notesStr stringByAppendingString:[NSString stringWithFormat:@"\n %i - %@ ",[(NSNumber *)number intValue],(NSString*)text]];

    }];

    return notesStr;
}

- (void)uploadImage:(UIImage *)image withNotes:(NSDictionary *)notes {

    NSString *notesString;

    if (notes.count>0) {

     notesString = [self prepareNotes:notes];
    }

    NSLog(@"note strings = %@",notesString);

//    AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:@"https://upload.uploadcare.com/"]];
//    [client setDefaultHeader:@"Accept" value:@"application/json"];
//    client.parameterEncoding = AFJSONParameterEncoding;
//    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
//
//    progressView.hidden = NO;
//
//    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
//	NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST"path:@"base/"
//                                                               parameters:@{@"UPLOADCARE_PUB_KEY": ucKey,@"UPLOADCARE_STORE":@YES}
//                                                constructingBodyWithBlock:^(id <AFMultipartFormData> formData)
//                                    {
//                                        [formData appendPartWithFileData:imageData name:@"photo" fileName:@"pic.jpg" mimeType:@"image/jpeg"];
//                                    }];
//
//
//	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//
//	[operation setUploadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//
//	    if (totalBytesExpectedToRead > 0) {
//
//            progressView.progress = (float)totalBytesRead / (float)totalBytesExpectedToRead;
//
//	        if ((float)totalBytesRead == (float)totalBytesExpectedToRead) {
//
//			}
//		}
//	}];
//
//	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//
//        progressView.hidden = YES;
//
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[operation responseData] options:NSJSONReadingMutableContainers error:nil];
//        NSLog(@"dict - %@",dict);
//
//
//                NSString *pURL = [[[[[[operation responseString] stringByReplacingOccurrencesOfString:@"photo\": \"" withString:@""] stringByReplacingOccurrencesOfString:@"{" withString:@""] stringByReplacingOccurrencesOfString:@"}" withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        //
//        //
//                NSString *textString = [NSString stringWithFormat:@"%@ <http://www.ucarecdn.com/%@/pic.jpg>",[self buildNumber], pURL];
//
//        if (notesString) {
//
//           textString = [textString stringByAppendingString:notesString];
//        }
//
//                NSDictionary *payloadDict = @{@"text":textString};
//        //
//        //
//                id JSONData = [NSJSONSerialization dataWithJSONObject:payloadDict  options:NSJSONWritingPrettyPrinted error:nil];
//        //
//                 NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:slackKey]];
//               // NSString * params =[NSString stringWithFormat:@"{'text':'%@'}",textString];
//                [urlRequest setHTTPMethod:@"POST"];
//                [urlRequest setHTTPBody:JSONData];
//        //
//        //
//                [urlRequest setValue: @"application/json" forHTTPHeaderField: @"Accept"];
//                [urlRequest setValue: @"application/json; charset=utf-8" forHTTPHeaderField: @"content-type"];
//
//                NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
//        //
//                NSURLSession *session = [NSURLSession sessionWithConfiguration:conf];
//                NSURLSessionDataTask *task =  [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        //
//        //          DLog(@"%@\n" , [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
//        //             DLog(@"%@\n" , [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//        //             DLog(@"%@\n" , error.localizedDescription);
//        //
//                }];
//                [task resume];
//
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//
//
//	}];
//
//	[client enqueueHTTPRequestOperation:operation];


}

- (UIImage *)screenshot
{


    UIImage *statusBar;
    UIImageView *imageView;

    if (!appStatusbarHidden) {

        if ([UIApplication sharedApplication].statusBarStyle != UIStatusBarStyleLightContent) {

            statusBar = [UIImage imageNamed:@"statusBarBlack"];
        }
        else {

            statusBar = [UIImage imageNamed:@"statusBarWhite"];
        }


        imageView = [[UIImageView alloc]initWithImage:statusBar];
        imageView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-imageView.frame.size.width/2, 4, imageView.frame.size.width, imageView.frame.size.height);
        
    }

    CGSize imageSize = CGSizeZero;

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }

    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }

        if (!appStatusbarHidden) {

            [statusBar drawInRect:imageView.frame];
        }

        CGContextRestoreGState(context);
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}




@end
