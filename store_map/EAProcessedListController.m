//
//  EAProcessedListController.m
//  store_map
//
//  Created by Ethan Arbuckle on 1/31/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import "EAProcessedListController.h"

@implementation EAProcessedListController

- (id)init {
    
    if ((self = [super init])) {
        
        [self setTitle:@"processed items"];
        
        //create route button
        UIBarButtonItem *createRouteButton = [[UIBarButtonItem alloc] initWithTitle:@"Route" style:UIBarButtonItemStyleDone target:self action:@selector(createRoute)];
        [[self navigationItem] setRightBarButtonItem:createRouteButton];
        
    }
    
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_processedItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //create cell
    UITableViewCell *itemCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"com.ethanarbuckle.store"];
    [[itemCell textLabel] setText:[_processedItems[[indexPath row]] productTitle]];
    
    return itemCell;
}

- (void)createRoute {
    
    //create controller if needed. its a property so it only needs to be made once
    if (!_floorMapController) {
        
        _floorMapController = [[EATargetFloorViewController alloc] initWithStoreItems:_processedItems];
    }
    
    //push to it
    [[self navigationController] pushViewController:_floorMapController animated:YES];
}

@end
