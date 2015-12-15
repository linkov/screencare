//
//  SDWScreenShotService.m
//  Screenr
//
//  Created by alex on 6/28/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//
#import "SDWScreenShotOverlayVC.h"
#import "ScreenCare.h"

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

#pragma mark - Utils

- (void)setupService {

    progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];

    // uncomment to test in Simulator
    //[self performSelector:@selector(startOverlay) withObject:nil afterDelay:1.3];

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

    UIViewController *controllerToPresentOnTopOff;

    if ([UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController) {

        controllerToPresentOnTopOff = [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController;
    } else {
        controllerToPresentOnTopOff = [UIApplication sharedApplication].keyWindow.rootViewController;
    }


    appStatusbarHidden = [UIApplication sharedApplication].isStatusBarHidden;

    UIGraphicsBeginImageContextWithOptions(controllerToPresentOnTopOff.view.bounds.size, NO, 1);
    [controllerToPresentOnTopOff.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UIImageView *imageView = [[UIImageView alloc] initWithImage:viewImage];
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
    [controllerToPresentOnTopOff presentViewController:screenCaptureNav animated:NO completion:nil];
}

- (NSString *)prepareNotes:(NSDictionary *)notes {

    __block NSString *notesStr = @"";

    [notes enumerateKeysAndObjectsUsingBlock:^(id number, id text, BOOL *stop) {

        notesStr = [notesStr stringByAppendingString:[NSString stringWithFormat:@"\n %i - %@ ", [(NSNumber *)number intValue], (NSString *)text]];
    }];

    return notesStr;
}

#pragma mark - Network

- (void)uploadImage:(UIImage *)image withNotes:(NSDictionary *)notes {

    [self uploadcareUploadImage:image withNotes:notes];
}

- (void)uploadcareUploadImage:(UIImage *)image withNotes:(NSDictionary *)notes {

    progressView.hidden = NO;
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://upload.uploadcare.com/base/"]];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = [self boundaryString];
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];

    NSData *fileData = imageData;
    NSData *data = [self createBodyWithBoundary:boundary username:@"rob" password:@"password" data:fileData filename:@"pic.jpg"];

    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (error) {
            [self showErrorAlert];
        } else {

            NSString *notesString;

            if (notes.count > 0) {

                notesString = [self prepareNotes:notes];
            }


            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:nil];

            NSString *fileName = json[@"file"];

            NSString *textString = [NSString stringWithFormat:@"%@ from %@ [iOS%@] <http://www.ucarecdn.com/%@/pic.jpg>", userID ?:@"",[UIDevice currentDevice].name,[UIDevice currentDevice].systemVersion, fileName];

            if (notesString) {

                textString = [textString stringByAppendingString:notesString];
            }

            progressView.hidden = YES;
            [self slackUploadDataWithNotes:textString];
        }


    }];
    [task resume];

}

- (NSString *)boundaryString {

    CFUUIDRef  uuid;
    NSString  *uuidStr;

    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);

    uuidStr = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
    assert(uuidStr != NULL);

    CFRelease(uuid);

    return [NSString stringWithFormat:@"Boundary-%@", uuidStr];
}


- (NSData *) createBodyWithBoundary:(NSString *)boundary username:(NSString*)username password:(NSString*)password data:(NSData*)data filename:(NSString *)filename {
    NSMutableData *body = [NSMutableData data];

    if (data) {
        //only send these methods when transferring data as well as username and password
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", @"image/jpeg"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:data];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"UPLOADCARE_PUB_KEY\"\r\n\r\n%@\r\n", ucKey] dataUsingEncoding:NSUTF8StringEncoding]];

    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"UPLOADCARE_STORE\"\r\n\r\n%@\r\n", @"1"] dataUsingEncoding:NSUTF8StringEncoding]];

    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    return body;
}

- (void)slackUploadDataWithNotes:(NSString *)textString {

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

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    
    progressView.progress = (float)totalBytesSent / (float)totalBytesExpectedToSend;
}

@end
