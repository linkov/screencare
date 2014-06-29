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



 //   [self performSelector:@selector(startOverlay) withObject:nil afterDelay:1.3];

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {


            [self startOverlay];

        }];

}

- (NSString *)buildNumber {

    return [NSString stringWithFormat:@"Build %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
}


- (void)startOverlay {

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[self takeScreenshot]];
    SDWScreenShotOverlayVC *overlayVC = [[SDWScreenShotOverlayVC alloc]initWithScreenGrab:imageView completion:^(UIImage *image, NSDictionary *notes) {

        [self uploadImage:image withNotes:notes];

    }];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    UINavigationController *screenCaptureNav = [[UINavigationController alloc]initWithRootViewController:overlayVC];
    [screenCaptureNav.navigationBar addSubview:progressView];
    progressView.frame = CGRectMake(0, screenCaptureNav.navigationBar.frame.size.height, 320, 2);
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

    AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:@"https://upload.uploadcare.com/"]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    client.parameterEncoding = AFJSONParameterEncoding;
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];

    progressView.hidden = NO;

    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
	NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST"path:@"base/"
                                                               parameters:@{@"UPLOADCARE_PUB_KEY": ucKey,@"UPLOADCARE_STORE":@YES}
                                                constructingBodyWithBlock:^(id <AFMultipartFormData> formData)
                                    {
                                        [formData appendPartWithFileData:imageData name:@"photo" fileName:@"pic.jpg" mimeType:@"image/jpeg"];
                                    }];


	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

	[operation setUploadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {

	    if (totalBytesExpectedToRead > 0) {

            progressView.progress = (float)totalBytesRead / (float)totalBytesExpectedToRead;

	        if ((float)totalBytesRead == (float)totalBytesExpectedToRead) {

			}
		}
	}];

	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        progressView.hidden = YES;

        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[operation responseData] options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"dict - %@",dict);


                NSString *pURL = [[[[[[operation responseString] stringByReplacingOccurrencesOfString:@"photo\": \"" withString:@""] stringByReplacingOccurrencesOfString:@"{" withString:@""] stringByReplacingOccurrencesOfString:@"}" withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //
        //
                NSString *textString = [NSString stringWithFormat:@"%@ <http://www.ucarecdn.com/%@/pic.jpg>",[self buildNumber], pURL];

        if (notesString) {

           textString = [textString stringByAppendingString:notesString];
        }

                NSDictionary *payloadDict = @{@"text":textString};
        //
        //
                id JSONData = [NSJSONSerialization dataWithJSONObject:payloadDict  options:NSJSONWritingPrettyPrinted error:nil];
        //
                 NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:slackKey]];
               // NSString * params =[NSString stringWithFormat:@"{'text':'%@'}",textString];
                [urlRequest setHTTPMethod:@"POST"];
                [urlRequest setHTTPBody:JSONData];
        //
        //
                [urlRequest setValue: @"application/json" forHTTPHeaderField: @"Accept"];
                [urlRequest setValue: @"application/json; charset=utf-8" forHTTPHeaderField: @"content-type"];

                NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
        //
                NSURLSession *session = [NSURLSession sessionWithConfiguration:conf];
                NSURLSessionDataTask *task =  [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //
        //          DLog(@"%@\n" , [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
        //             DLog(@"%@\n" , [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        //             DLog(@"%@\n" , error.localizedDescription);
        //
                }];
                [task resume];

	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {


	}];

	[client enqueueHTTPRequestOperation:operation];


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
