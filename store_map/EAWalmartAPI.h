//
//  EAWalmartAPI.h
//  store_map
//
//  Created by Ethan Arbuckle on 1/12/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EAStoreItem.h"

#define kWalmartAPISearchURL @"http://search.mobile.walmart.com/search"
#define kWalmartStoreLocatorURL @"https://mobile.walmart.com/m/j"

//boilerplate
#define walmartFailIfError(error) if (error) { [_delegate walmart:self queryDidReceiveError:error]; return; }

@class EAWalmartAPI;
@protocol EAWalmartAPIDelegate <NSObject>

- (void)walmart:(EAWalmartAPI *)api queryFinishedWithResults:(NSArray *)results;
- (void)walmart:(EAWalmartAPI *)api storeLocatorFoundStores:(NSArray *)stores;
- (void)walmart:(EAWalmartAPI *)api queryDidReceiveError:(NSError *)error;

@end

@interface EAWalmartAPI : NSObject

@property (nonatomic, weak) id <EAWalmartAPIDelegate> delegate;
@property (nonatomic, assign) NSString *walmartStoreID;

- (id)initWithDelegate:(id)delegate;
- (void)searchWithQuery:(NSString *)query maximumResults:(NSInteger)limit;
- (void)fetchStoredNearLocationWithLatitude:(float)latitude longitude:(float)longitude;

@end
