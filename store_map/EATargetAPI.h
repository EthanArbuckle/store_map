//
//  EATargetAPI.h
//  store_map
//
//  Created by Ethan Arbuckle on 1/12/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EAStoreItem.h"

#define kTargetAPIQueryURL @"https://www.tgtappdata.com/v1/products/search/inside/"
#define kTargetAPIMapLookupURL @"https://api-target.pointinside.com/feeds/maps/v1.4/venues"
#define kTargetItemLookupURL @"https://api-target.pointinside.com/search/v1.4/product/lookup"

//i stole these from the target app, we probably cant use them
#define kDevID @"129B6468-12B1-43E6-B68F-09BDADF2614C"
#define kAPIKey @"9a25323c2103248b67e50ccfd0dc13ec"

//boilerplate
#define targetFailIfError(error) if (error) { [_delegate targetQueryDidReceiveError:error]; return; }

@protocol EATargetDelegate <NSObject>

- (void)targetQueryFinishedWithResults:(NSArray *)results;
- (void)targetMapLookupFinishedWithResult:(NSDictionary *)store;
- (void)targetQueryDidReceiveError:(NSError *)error;
- (void)targetLocationLookupFinishedWithResult:(NSDictionary *)location;

@end

@interface EATargetAPI : NSObject

@property (nonatomic, weak) id <EATargetDelegate> delegate;
@property (nonatomic, assign) NSString *targetStoreID;

- (id)initWithDelegate:(id)delegate;
- (void)searchWithQuery:(NSString *)query maximumResults:(NSInteger)limit;
- (void)fetchStoreMapForStoreID:(NSString *)storeID;
- (void)fetchItemLocationWithProductID:(NSString *)productID;

@end
