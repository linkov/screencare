//
//  SDWMasterViewController.m
//  Screenr
//
//  Created by alex on 6/26/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//

#import "SDWMasterViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SDWDetailViewController.h"
#import "SDWSimpleDetailVC.h"

@interface SDWMasterViewController () <UIAlertViewDelegate> {
	NSMutableArray *_objects;
	NSMutableArray *photoArray;
	NSMutableArray *assets;
}

@end

@implementation SDWMasterViewController

+ (ALAssetsLibrary *)defaultAssetsLibrary {
	static dispatch_once_t pred = 0;
	static ALAssetsLibrary *library = nil;
	dispatch_once(&pred, ^{
	    library = [[ALAssetsLibrary alloc] init];
	});
	return library;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
	self.navigationItem.rightBarButtonItem = addButton;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
	[self loadPhotos];
}

- (void)loadPhotos {

	assets = [[NSMutableArray alloc] init];
	[[SDWMasterViewController defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAll

	                                                              usingBlock:^(ALAssetsGroup *group, BOOL *stop)
	{
	    [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop)
	    {
	        if (asset) {

	            float width = asset.defaultRepresentation.dimensions.width;
	            float height = asset.defaultRepresentation.dimensions.height;

	            if (height == 1136 && width == 640) {

	                [assets addObject:asset];
				}

	            [self.tableView reloadData];
			}
		}

	    ];
	}

	failureBlock:^(NSError *error)
    {
	    // User did not allow access to library
	    // .. handle error
	}

	];

}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return assets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

	ALAsset *asset = assets[indexPath.row];

	cell.imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[_objects removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
		// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    SDWSimpleDetailVC *detail = [SDWSimpleDetailVC new];
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}


@end
