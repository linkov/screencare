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
#import "OTScreenshotHelper.h"

@implementation ScreenCare {

	NSString *ucKey;
	NSString *slackKey;
	NSString *screenCareKey;
    NSString *userID;
	UIProgressView *progressView;
	BOOL appStatusbarHidden;
    SDWScreenShotOverlayVC *overlayVC;
}

- (instancetype)initWithScreencareKey:(NSString *)token {
	return [self initWithUploadCareKey:token slackHookUrl:nil userID:nil];
}

- (instancetype)initWithUploadCareKey:(NSString *)uck slackHookUrl:(NSString *)slackUrl; {
    return [self initWithUploadCareKey:uck slackHookUrl:slackUrl userID:nil];
}

- (instancetype)initWithUploadCareKey:(NSString *)uck slackHookUrl:(NSString *)slackUrl userID:(NSString *)uID {

    self = [super init];
	if (self) {
		ucKey = uck ? : @"";
		slackKey = slackUrl ? : @"";
        userID = uID;
		[self setupService];
		self.view.userInteractionEnabled = NO;
	}
	return self;

}

- (void)setupService {

	progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];

	[self performSelector:@selector(startOverlay) withObject:nil afterDelay:1.3];

	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
	    [self startOverlay];
	}];
}

- (NSString *)buildNumber {

	return [NSString stringWithFormat:@"Build %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
}

- (void) dismissAlerts {
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        for (UIView* view in window.subviews) {
            BOOL action = [view isKindOfClass:[UIActionSheet class]];
            if (action)
                [(UIActionSheet *)view dismissWithClickedButtonIndex:0 animated:NO];
        }
    }
}

- (void)startOverlay {

	appStatusbarHidden = [UIApplication sharedApplication].isStatusBarHidden;

	UIImageView *imageView = [[UIImageView alloc] initWithImage:[OTScreenshotHelper screenshotWithStatusBar:YES]];
	[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [self dismissAlerts];

	overlayVC = [[SDWScreenShotOverlayVC alloc]initWithScreenGrab:imageView statusBarHidden:appStatusbarHidden completion:^(UIImage *image, NSDictionary *notes) {

	    [self uploadImage:image withNotes:notes];
	}];

	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	UINavigationController *screenCaptureNav = [[UINavigationController alloc]initWithRootViewController:overlayVC];
	[screenCaptureNav.navigationBar addSubview:progressView];
	progressView.frame = CGRectMake(0, screenCaptureNav.navigationBar.frame.size.height, screenCaptureNav.navigationBar.frame.size.width, 2);
	progressView.hidden = YES;
	[self presentViewController:screenCaptureNav animated:NO completion:nil];
}

- (NSString *)prepareNotes:(NSDictionary *)notes {

	__block NSString *notesStr = @"";

	[notes enumerateKeysAndObjectsUsingBlock:^(id number, id text, BOOL *stop) {

	    notesStr = [notesStr stringByAppendingString:[NSString stringWithFormat:@"\n %i - %@ ", [(NSNumber *)number intValue], (NSString *)text]];
	}];

	return notesStr;
}

- (void)uploadImage:(UIImage *)image withNotes:(NSDictionary *)notes {

    [self uploadcareUploadImage:image withNotes:notes];
}

- (void)uploadcareUploadImage:(UIImage *)image withNotes:(NSDictionary *)notes {

	NSString *notesString;

	if (notes.count > 0) {

		notesString = [self prepareNotes:notes];
	}

	AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:@"https://upload.uploadcare.com/"]];
	[client setDefaultHeader:@"Accept" value:@"application/json"];
	client.parameterEncoding = AFJSONParameterEncoding;
	[client registerHTTPOperationClass:[AFJSONRequestOperation class]];

	progressView.hidden = NO;

	NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
	NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST"path:@"base/"
	                                                           parameters:@{ @"UPLOADCARE_PUB_KEY": ucKey, @"UPLOADCARE_STORE":@YES }
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
	    NSLog(@"dict - %@", dict);


	    NSString *pURL = [[[[[[operation responseString] stringByReplacingOccurrencesOfString:@"photo\": \"" withString:@""] stringByReplacingOccurrencesOfString:@"{" withString:@""] stringByReplacingOccurrencesOfString:@"}" withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	    //
	    //
	    NSString *textString = [NSString stringWithFormat:@"%@ from %@ [iOS%@] <http://www.ucarecdn.com/%@/pic.jpg>", userID ?:@"",[UIDevice currentDevice].name,[UIDevice currentDevice].systemVersion, pURL];

	    if (notesString) {

	        textString = [textString stringByAppendingString:notesString];
		}

	    NSDictionary *payloadDict = @{ @"text":textString };
	    id JSONData = [NSJSONSerialization dataWithJSONObject:payloadDict options:NSJSONWritingPrettyPrinted error:nil];

	    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:slackKey]];

        [urlRequest setHTTPMethod:@"POST"];
	    [urlRequest setHTTPBody:JSONData];

	    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	    [urlRequest setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"content-type"];

	    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
	    //
	    NSURLSession *session = [NSURLSession sessionWithConfiguration:conf];
	    NSURLSessionDataTask *task =  [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

            if(!error) {

                [self closeWidget];
            }
            else  {

                [self showErrorAlert];
            }
		}];
	    [task resume];

	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        [self showErrorAlert];
	}];

	[client enqueueHTTPRequestOperation:operation];
}

- (void)closeWidget {

    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:appStatusbarHidden withAnimation:UIStatusBarAnimationSlide];
    }];
}

- (void)showErrorAlert {

   UIAlertView *alert =  [[UIAlertView alloc]initWithTitle:@"Screencare"
                              message:@"Connection error occured, stay calm and try again"
                             delegate:nil
                    cancelButtonTitle:@"Ok"
                    otherButtonTitles:nil, nil];

    [alert show];

}

@end
