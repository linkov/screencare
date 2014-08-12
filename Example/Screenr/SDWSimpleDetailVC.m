//
//  SDWSimpleDetailVC.m
//  Screenr
//
//  Created by alex on 7/1/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//

#import "SDWSimpleDetailVC.h"

@interface SDWSimpleDetailVC () <UIViewControllerRestoration>

@property (strong) UITextView *label;
@property (nonatomic) BOOL restoringState;

@property (nonatomic, strong) NSString *selectedRecordId;

@end

@implementation SDWSimpleDetailVC

- (id)initWitRecordID:(NSString *)recID
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.selectedRecordId = recID;
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

    self.label = [[UITextView alloc]initWithFrame:CGRectMake(100, 150, 160, 44)];
    self.label.backgroundColor = [UIColor redColor];
  //  self.label.text = @"test";
    [self.view addSubview:self.label];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];


    self.title = self.selectedRecordId;

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
    [coder encodeObject:self.selectedRecordId forKey:@"SelectedRecord"];

}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    self.label.text = [coder decodeObjectForKey:@"UnsavedText"];
    self.selectedRecordId = [coder decodeObjectForKey:@"SelectedRecord"];
    self.restoringState = YES;
}

@end
