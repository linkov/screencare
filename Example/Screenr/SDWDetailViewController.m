//
//  SDWDetailViewController.m
//  Screenr
//
//  Created by alex on 6/26/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//

#import "SDWDetailViewController.h"

@interface SDWDetailViewController () <UIViewControllerTransitionCoordinator> {

    UITextView *myLabel;
}
- (void)configureView;
@end

@implementation SDWDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (BOOL)animateAlongsideTransition:(void (^)(id<UIViewControllerTransitionCoordinatorContext>))animation completion:(void (^)(id<UIViewControllerTransitionCoordinatorContext>))completion {

    return YES;
}

- (void)configureView
{
    // Update the user interface for the detail item.
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];

    }

    myLabel = [[UITextView alloc]initWithFrame:CGRectMake(100, 60, 200, 100)];
    myLabel.text = @"Test";
    myLabel.backgroundColor = [UIColor greenColor];
    [self.view addSubview:myLabel];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {

        NSLog(@"context - %@",context);

        self.navigationController.navigationBar.backgroundColor = [UIColor redColor];
        myLabel.frame = CGRectMake(100, 160, 200, 100);

    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if ( [context initiallyInteractive] ) return;
        [self _onTransitionEnd:context];
    }];
    [self.transitionCoordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self _onTransitionEnd:context];
    }];
}

- (void)_onTransitionEnd:(id<UIViewControllerTransitionCoordinatorContext>)context
{
    if ( [context isCancelled] ) {

        self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
        myLabel.frame = CGRectMake(100, 60, 200, 100);
    }
    else {

        myLabel.frame = CGRectMake(100, 160, 200, 100);
        self.navigationController.navigationBar.backgroundColor = [UIColor redColor];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.restorationIdentifier = @"com.sdwr.restorationID.MasterVC";
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
