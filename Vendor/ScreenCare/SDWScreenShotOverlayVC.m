//
//  SDWScreenShotOverlayVC.m
//  Screenr
//
//  Created by alex on 6/28/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//
#import "SDWDrawingView.h"
#import "SDWScreenShotOverlayVC.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"

@interface SDWScreenShotOverlayVC () <UIScrollViewDelegate,NSURLConnectionDelegate> {

    UIImageView *imageView;
    UIScrollView *scrollZoom;
    UIBarButtonItem *addButton;
}

@property (nonatomic, retain) SDWDrawingView *drawScreen;

@end

@implementation SDWScreenShotOverlayVC


- (id)initWithScreenGrab:(UIImageView *)screen {

    self = [super init];
    if (self) {

        imageView = screen;

    }
    return self;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {

    return imageView;
}

- (void)viewDidDisappear:(BOOL)animated {

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"checkers"]];
    scrollZoom = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    scrollZoom.minimumZoomScale=0.6;
    scrollZoom.maximumZoomScale=6.0;
    scrollZoom.contentSize=CGSizeMake(1280, 960);
    scrollZoom.delegate = self;
    scrollZoom.userInteractionEnabled = NO;
    [scrollZoom addSubview:imageView];

    [self.view addSubview:scrollZoom];

    //[self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];


    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:0.9 options:UIViewAnimationOptionTransitionNone animations:^{

        [scrollZoom setZoomScale:0.85];

    } completion:nil];

    UIBarButtonItem *clearFromLibButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close)];
	self.navigationItem.leftBarButtonItem = clearFromLibButton;

	addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = addButton;


    UIButton *uploadButton =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 29, 35)];
    [uploadButton setImage:[[UIImage imageNamed:@"upload"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [uploadButton addTarget:self action:@selector(afUpload) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.titleView =uploadButton;

    self.drawScreen = [[SDWDrawingView alloc]initWithFrame:CGRectMake(0, 44, 320, [[UIScreen mainScreen] bounds].size.height-44)];

    self.drawScreen.brush = [UIColor redColor];
    self.drawScreen.userInteractionEnabled = NO;

    [self.view addSubview:self.drawScreen];

}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{

    // center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = scrollView.bounds.size;
    CGRect frameToCenter = imageView.frame;

    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
    {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    } else {
        frameToCenter.origin.x = 0;
    }

    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
    {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 5;
    } else {
        frameToCenter.origin.y = 0;
    }

    imageView.frame = frameToCenter;

}

-(void)close {

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)buildNumber {

    return [NSString stringWithFormat:@"Build %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
}

- (UIImage *)prepareImage {

    UIView *snapShotView = self.view;

    UIImageView *logoView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"upload"]];
    logoView.frame = CGRectMake(320/2-35/2, 10, 29, 35);
    [snapShotView addSubview:logoView];

    UILabel *buildVersionLabel = [[UILabel alloc]initWithFrame:CGRectMake(logoView.frame.origin.x+30, 20, 100, 22)];
    buildVersionLabel.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:18];
    buildVersionLabel.textAlignment = NSTextAlignmentLeft;
    buildVersionLabel.textColor = [UIColor blackColor];
    buildVersionLabel.text =[self buildNumber];

    [snapShotView addSubview:buildVersionLabel];

	CGRect rect = self.view.bounds;
	UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0f);
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToRect(context, rect);
	[snapShotView.layer renderInContext:context];
	UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

    return capturedImage;
}


- (void)afUpload {

    UIImage *viewSnap = [self prepareImage];

    AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:@"https://upload.uploadcare.com/"]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    client.parameterEncoding = AFJSONParameterEncoding;
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];



    NSData *imageData = UIImageJPEGRepresentation(viewSnap, 1.0);
	NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST"path:@"base/"
                                                               parameters:@{@"UPLOADCARE_PUB_KEY": @"47723df3799764bc67fb",@"UPLOADCARE_STORE":@YES}
                                                constructingBodyWithBlock:^(id <AFMultipartFormData> formData)
                                    {
                                        [formData appendPartWithFileData:imageData name:@"photo" fileName:@"pic.jpg" mimeType:@"image/jpeg"];
                                    }];


	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

	[operation setUploadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {

	    if (totalBytesExpectedToRead > 0) {

	        [SVProgressHUD showProgress:(float)totalBytesRead / (float)totalBytesExpectedToRead];

	        if ((float)totalBytesRead == (float)totalBytesExpectedToRead) {

	            [SVProgressHUD dismiss];
			}
		}
	}];

	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        //        NSString *pURL = [[[[[[operation responseString] stringByReplacingOccurrencesOfString:@"photo\": \"" withString:@""] stringByReplacingOccurrencesOfString:@"{" withString:@""] stringByReplacingOccurrencesOfString:@"}" withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //
        //
        //        NSString *textString = [NSString stringWithFormat:@"%@ <http://www.ucarecdn.com/%@/pic.jpg>",[self buildNumber], pURL];
        //        NSDictionary *payloadDict = @{@"text":textString};
        //
        //
        //        id JSONData = [NSJSONSerialization dataWithJSONObject:payloadDict  options:NSJSONReadingAllowFragments error:nil];
        //
        //         NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://riders.slack.com/services/hooks/incoming-webhook?token=zOoXaDmovLPqMJXPw9dkbaV0"]];
        //       // NSString * params =[NSString stringWithFormat:@"{'text':'%@'}",textString];
        //        [urlRequest setHTTPMethod:@"POST"];
        //        [urlRequest setHTTPBody:JSONData];
        //
        //
        //        [urlRequest setValue: @"application/json" forHTTPHeaderField: @"Accept"];
        //        [urlRequest setValue: @"application/json; charset=utf-8" forHTTPHeaderField: @"content-type"];
        //
        //        NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
        //
        //        NSURLSession *session = [NSURLSession sessionWithConfiguration:conf];
        //        NSURLSessionDataTask *task =  [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //
        //          DLog(@"%@\n" , [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
        //             DLog(@"%@\n" , [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        //             DLog(@"%@\n" , error.localizedDescription);
        //
        //        }];
        //        [task resume];

	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        [SVProgressHUD showErrorWithStatus:error.localizedDescription];

	}];

	[client enqueueHTTPRequestOperation:operation];
}


-(void)save:(UIBarButtonItem *)item {

    if (addButton.tintColor == [UIColor redColor]) {

        //  scrollZoom.userInteractionEnabled = YES;
        self.drawScreen.userInteractionEnabled = NO;
        addButton.tintColor = [UIWindow appearance].tintColor;
    }
    
    else if (addButton.tintColor == [UIWindow appearance].tintColor ) {
        
        //  scrollZoom.userInteractionEnabled = NO;
        self.drawScreen.userInteractionEnabled = YES;
        addButton.tintColor = [UIColor redColor];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
