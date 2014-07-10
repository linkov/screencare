//
//  SDWSimpleDetailVC.m
//  Screenr
//
//  Created by alex on 7/1/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//

#import "SDWSimpleDetailVC.h"

@interface SDWSimpleDetailVC () <UIViewControllerRestoration>

@property (strong) UILabel *label;
@property (nonatomic) BOOL restoringState;

@end

@implementation SDWSimpleDetailVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.restorationClass = [SDWSimpleDetailVC class];
    self.restorationIdentifier = @"com.sdwr.restorationID.SDWSimpleDetailVC";
    self.view.restorationIdentifier =  @"com.sdwr.restorationID.SDWSimpleDetailVC.view";
    self.view.backgroundColor = [UIColor whiteColor];

    self.label = [[UILabel alloc]initWithFrame:CGRectMake(150, 150, 60, 30)];
    self.label.text = @"test";
    [self.view addSubview:self.label];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.restoringState)
    {

        NSLog(@"state restore");
        self.restoringState = NO;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    UIViewController *viewController = [[SDWSimpleDetailVC alloc] init];
    viewController.restorationIdentifier = [identifierComponents lastObject];
    viewController.restorationClass = [SDWSimpleDetailVC class];
    return viewController;
}

-(void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeObject:self.label.text forKey:@"UnsavedText"];

}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    self.label.text = [coder decodeObjectForKey:@"UnsavedText"];
    self.restoringState = YES;
}

@end
