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

@interface SDWMasterViewController () <UIAlertViewDelegate> {
	NSMutableArray *_objects;
	NSMutableArray *photoArray;
	NSMutableArray *assets;
}
@end

@implementation SDWMasterViewController

- (void)awakeFromNib {
	[super awakeFromNib];
}

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
	// Do any additional setup after loading the view, typically from a nib.

    UIBarButtonItem *clearFromLibButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(clearFromLib:)];
	self.navigationItem.leftBarButtonItem = clearFromLibButton;

	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
	self.navigationItem.rightBarButtonItem = addButton;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)clearFromLib:(id)sender {



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


//
//    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
//
//    if([ALAssetsLibrary authorizationStatus])
//    {
//        [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//            if(group)
//            {
//                //Filter photos
//                photoArray = [self getContentFrom:group withAssetFilter:[ALAssetsFilter allPhotos]];
//                //Enumerate through the group to get access to the photos.
//
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"assetread" object:nil];
//
//            }
//        } failureBlock:^(NSError *error) {
//            NSLog(@"Error Description %@",[error description]);
//        }];
//    }
//    else{
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission Denied" message:@"Please allow the application to access your photo and videos in settings panel of your device" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//        [alertView show];
//    }
}

//-(NSMutableArray *) getContentFrom:(ALAssetsGroup *) group withAssetFilter:(ALAssetsFilter *)filter
//{
//    NSMutableArray *contentArray = [NSMutableArray array];
//    [group setAssetsFilter:filter];
//
//    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
//
//        //ALAssetRepresentation holds all the information about the asset being accessed.
//        if(result)
//        {
//
//            ALAssetRepresentation *representation = [result defaultRepresentation];
//
//            //Stores releavant information required from the library
//            NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
//            //Get the url and timestamp of the images in the ASSET LIBRARY.
//            NSString *imageUrl = [representation UTI];
//            NSDictionary *metaDataDictonary = [representation metadata];
//            NSString *dateString = [result valueForProperty:ALAssetPropertyDate];
//
//            //            NSLog(@"imageUrl %@",imageUrl);
//            //            NSLog(@"metadictionary: %@",metaDataDictonary);
//
//            //Check for the date that is applied to the image
//            // In case its earlier than the last sync date then skip it. ##TODO##
//
//            NSString *imageKey = @"ImageUrl";
//            NSString *metaKey = @"MetaData";
//            NSString *dateKey = @"CreatedDate";
//
//            [tempDictionary setObject:imageUrl forKey:imageKey];
//            [tempDictionary setObject:metaDataDictonary forKey:metaKey];
//            [tempDictionary setObject:dateString forKey:dateKey];
//
//            //Add the values to photos array.
//            [contentArray addObject:tempDictionary];
//        }
//    }];
//    return contentArray;
//}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return assets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

	//NSURL *url = [representation url];
	//NSLog(@"url: %@", [url absoluteString]);

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

/*
   // Override to support rearranging the table view.
   - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
   {
   }
 */

/*
   // Override to support conditional rearranging of the table view.
   - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
   {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
   }
 */

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"showDetail"]) {
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		NSDate *object = _objects[indexPath.row];
		[[segue destinationViewController] setDetailItem:object];
	}
}

@end
