//
//  EAProcessedListController.h
//  store_map
//
//  Created by Ethan Arbuckle on 1/31/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAStoreItem.h"
#import "EATargetFloorViewController.h"

@interface EAProcessedListController : UITableViewController

@property (nonatomic, retain) NSArray <EAStoreItem *> *processedItems;
@property (nonatomic, retain) EATargetFloorViewController *floorMapController;

- (void)createRoute;

@end
