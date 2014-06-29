//
//  SDWScreenShotOverlayVC.m
//  Screenr
//
//  Created by alex on 6/28/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//
#import "SDWDrawingView.h"
#import "SDWMarkerView.h"
#import "SDWScreenShotOverlayVC.h"

#import "SDWTextView.h"
#import "SDWCircle.h"

@interface SDWScreenShotOverlayVC () <UIScrollViewDelegate,NSURLConnectionDelegate,SDWViewDelegate> {

    UIImageView *imageView;
    UIScrollView *scrollZoom;
    UIBarButtonItem *addButton;
    UIButton *uploadButton;
    NSMutableDictionary *notes;
    CGPoint activeCirclePoint;
}

@property (nonatomic, retain) SDWDrawingView *drawScreen;
@property (nonatomic, retain) SDWMarkerView *markerScreen;
@property (copy) SDWScreenshotCompletionBlock block;

@end

@implementation SDWScreenShotOverlayVC


- (id)initWithScreenGrab:(UIImageView *)screen completion:(SDWScreenshotCompletionBlock)block; {

    self = [super init];
    if (self) {

        imageView = screen;
        self.block = block;

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

    notes = [NSMutableDictionary dictionary];
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

    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
	self.navigationItem.leftBarButtonItem = cancel;

	addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(toggleDrawing:)];
	self.navigationItem.rightBarButtonItem = addButton;


    uploadButton =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 29, 35)];
    [uploadButton setImage:[[UIImage imageNamed:@"upload"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [uploadButton addTarget:self action:@selector(afUpload) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.titleView =uploadButton;

    self.drawScreen = [[SDWDrawingView alloc]initWithFrame:CGRectMake(0, 44, 320, [[UIScreen mainScreen] bounds].size.height-44)];

    self.drawScreen.brush = [UIColor redColor];
    self.drawScreen.userInteractionEnabled = NO;

    [self.view addSubview:self.drawScreen];

    self.markerScreen = [[SDWMarkerView alloc]initWithFrame:CGRectInset(self.view.bounds, 0, 44) delegate:self];
    [self.view addSubview:self.markerScreen];

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

- (UIImage *)prepareImageFromView:(UIView *)view {

    UIView *snapShotView = view;

    UIImageView *logoView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"upload"]];
    logoView.frame = CGRectMake(320/2-35/2, 10, 29, 35);
    [snapShotView addSubview:logoView];

    UILabel *buildVersionLabel = [[UILabel alloc]initWithFrame:CGRectMake(logoView.frame.origin.x+30, 20, 100, 22)];
    buildVersionLabel.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:18];
    buildVersionLabel.textAlignment = NSTextAlignmentLeft;
    buildVersionLabel.textColor = [UIColor blackColor];
    buildVersionLabel.text =[self buildNumber];

    [snapShotView addSubview:buildVersionLabel];

	CGRect rect = view.bounds;
	UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0f);
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToRect(context, rect);
	[snapShotView.layer renderInContext:context];
	UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

    return capturedImage;
}


- (void)afUpload {

    UIView *view = self.view;

    [uploadButton setEnabled:NO];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        UIImage *snapShot = [self prepareImageFromView:view];

        dispatch_async(dispatch_get_main_queue(), ^{

            self.block(snapShot,nil);
            [uploadButton setEnabled:YES];


        });
    });


 }


-(void)toggleDrawing:(UIBarButtonItem *)item {

    if (addButton.tintColor == [UIColor redColor]) {

        //  scrollZoom.userInteractionEnabled = YES;
        self.drawScreen.userInteractionEnabled = NO;
        self.markerScreen.userInteractionEnabled = YES;
        addButton.tintColor = [UIWindow appearance].tintColor;
    }
    
    else if (addButton.tintColor == [UIWindow appearance].tintColor ) {
        
        //  scrollZoom.userInteractionEnabled = NO;
        self.drawScreen.userInteractionEnabled = YES;
        self.markerScreen.userInteractionEnabled = NO;
        addButton.tintColor = [UIColor redColor];
    }
}

#pragma mark - SDWViewDelegate

- (void)view:(SDWBaseView *)view didProvideMarkerPoint:(CGPoint)point {

    activeCirclePoint = point;
    CGPoint circlePoint = [self.view convertPoint:point fromView:view];


    SDWTextView *noteText = [[SDWTextView alloc]initWithFrame:CGRectMake(circlePoint.x, circlePoint.y, 40, 40) delegate:self];
    noteText.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];
    [self.view addSubview:noteText];


    SDWCircle *circle = [self.markerScreen circleAtPoint:activeCirclePoint];
    if (notes[[NSNumber numberWithInteger:circle.hash]] ) {

        noteText.note = notes[[NSNumber numberWithInteger:circle.hash]];

    }

    [UIView animateWithDuration:.2 animations:^{

        noteText.frame = self.view.bounds;
        noteText.backgroundColor = [UIColor greenColor];

    }];

}

-(void)viewDidCancelText:(SDWBaseView *)view {

    [UIView animateWithDuration:.2 animations:^{

        view.frame = CGRectMake(activeCirclePoint.x, activeCirclePoint.y,40,40);
        view.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];

    } completion:^(BOOL finished) {
        view.alpha = 0;

        SDWCircle *circle = [self.markerScreen circleAtPoint:activeCirclePoint];

        if (!notes[[NSNumber numberWithInteger:circle.hash]] ) {

            [self.markerScreen removeCircleAtPoint:activeCirclePoint];
            
        }




    }];
}

-(void)view:(SDWBaseView *)view didProvideTextForNote:(NSString *)text {


    SDWCircle *circle = [self.markerScreen circleAtPoint:activeCirclePoint];
    circle.number = notes.count+1;

    notes[[NSNumber numberWithInteger:circle.hash] ] = text;

    [UIView animateWithDuration:.2 animations:^{

        view.frame = CGRectMake(activeCirclePoint.x, activeCirclePoint.y,40,40);
        view.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];

    } completion:^(BOOL finished) {
        view.alpha = 0;
    }];
}


@end
