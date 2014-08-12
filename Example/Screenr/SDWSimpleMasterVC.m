//
//  SDWSimpleMasterVC.m
//  Screenr
//
//  Created by alex on 7/1/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//
#import "SDWSimpleDetailVC.h"
#import "SDWSimpleMasterVC.h"

@interface SDWSimpleMasterVC () <UIViewControllerRestoration>

@end

@implementation SDWSimpleMasterVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if(self)
    {
        self.restorationIdentifier = @"master";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Master";
    self.tableView.restorationIdentifier = @"masterView";
    self.restorationClass = [self class];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Section %d", section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *recID = [NSString stringWithFormat:@"Section:%d, Row:%d", indexPath.section,  indexPath.row];
    SDWSimpleDetailVC *vc = [[SDWSimpleDetailVC alloc]initWitRecordID:recID];
    [self.navigationController pushViewController:vc animated:YES];
}



+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    UIViewController *viewController = [[SDWSimpleMasterVC alloc] init];
    viewController.restorationIdentifier = [identifierComponents lastObject];
    viewController.restorationClass = [SDWSimpleMasterVC class];
    return viewController;
}

-(void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];

}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
}
@end
