//
//  EAWalmartAPI.m
//  store_map
//
//  Created by Ethan Arbuckle on 1/12/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import "EAWalmartAPI.h"

@implementation EAWalmartAPI

- (id)initWithDelegate:(id)delegate {
    
    if ((self = [super init])) {
        
        _delegate = delegate;
        
        //this will work as one, but obviously wont be your store
        _walmartStoreID = @"1";
        
    }
    
    return self;
}

//we will always need a delegate
- (id)init {
    
    NSLog(@"call initWithDelegate instead");
    return NULL;
}

- (void)searchWithQuery:(NSString *)query maximumResults:(NSInteger)limit {
    
    //fail if nothing will get the results
    if (!_delegate) {
        NSLog(@"no delegate");
        return;
    }

    NSString *queryString = [NSString stringWithFormat:@"%@?store=%@&query=%@&size=%lu", kWalmartAPISearchURL, _walmartStoreID, query, limit];
    NSURL *queryURL = [NSURL URLWithString:queryString];
    [[[NSURLSession sharedSession] dataTaskWithURL:queryURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //fail if bad request
        walmartFailIfError(error);
        
        NSDictionary *parsedResults = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        //fail because of bad data
        walmartFailIfError(error);
       
        //create managed item for every product and add to mutable array, which will be sent back to delegate
        NSMutableArray *allItems = [[NSMutableArray alloc] initWithCapacity:limit];
        for (NSDictionary *singleProduct in parsedResults[@"results"]) {
            
            EAStoreItem *currentItem = [[EAStoreItem alloc] init];
            [currentItem setProductTitle:singleProduct[@"name"]];
            
            //price can only be pulled in cents, so convert to float to precisely divide by 100, and then go back to string
            [currentItem setProductPrice:[NSString stringWithFormat:@"%.2f", (float)[singleProduct[@"price"][@"priceInCents"] integerValue] / 100]];
            
            [currentItem setProductID:singleProduct[@"productId"][@"productId"]];
            [currentItem setProductImageURL:[NSURL URLWithString:singleProduct[@"images"][@"largeUrl"]]];
            [currentItem setProductDepartment:singleProduct[@"department"][@"name"]];
            
            //aisle is stored in array 'aisle', do bounds check before trying to access
            if ([singleProduct[@"location"][@"aisle"] count] > 0) {
                
                [currentItem setProductAisle:singleProduct[@"location"][@"aisle"][0]];
            }
            
            [currentItem setProductIsAvailable: ([singleProduct[@"inventory"][@"status"] isEqualToString:@"In Stock"]) ? YES : NO];
            
            //add to array
            [allItems addObject:currentItem];
            
        }
        
        //send immutable copy to delegate handler
        [_delegate walmart:self queryFinishedWithResults:[allItems copy]];
        

    }] resume];
}

- (void)fetchStoredNearLocationWithLatitude:(float)latitude longitude:(float)longitude {

    //create url with location params
    NSString *queryString = [NSString stringWithFormat:@"%@?service=StoreLocator&method=locate&p1=%f&p2=%f&p3=100&p4=0&p5=0", kWalmartStoreLocatorURL, latitude, longitude];
    NSURL *queryURL = [NSURL URLWithString:queryString];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:queryURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //fail if bad request
        walmartFailIfError(error);
        
        NSDictionary *parsedResults = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        //fail because of bad data
        walmartFailIfError(error);
        
        //cycle all the stores, and create a dict containing their name (value) and storenumber (key), and put it in allstores
        NSMutableArray *allStores = [[NSMutableArray alloc] init];
        for (NSDictionary *currentStore in parsedResults) {
            
            NSDictionary *limitedStoreInfo = @{ currentStore[@"storeNumber"] : currentStore[@"address"][@"street1"] };
            [allStores addObject:limitedStoreInfo];
        }
        
        //send to delegate
        [_delegate walmart:self storeLocatorFoundStores:[allStores copy]];
        
    }] resume];

}

@end
