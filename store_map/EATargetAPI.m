//
//  EATargetAPI.m
//  store_map
//
//  Created by Ethan Arbuckle on 1/12/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import "EATargetAPI.h"

@implementation EATargetAPI

- (id)initWithDelegate:(id)delegate {
    
    if ((self = [super init])) {
        
        _delegate = delegate;
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
    
    NSString *queryString = [NSString stringWithFormat:@"%@/%@?searchTerm=%@&limit=%lu", kTargetAPIQueryURL, _targetStoreID, query, limit];
    NSURL *queryURL = [NSURL URLWithString:[queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[[NSURLSession sharedSession] dataTaskWithURL:queryURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //fail if bad request
        targetFailIfError(error);
        
        NSDictionary *parsedResults = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];

        //fail because of bad data
        targetFailIfError(error);
        
        //create managed item for every product and add to mutable array, which will be sent back to delegate
        NSMutableArray *allItems = [[NSMutableArray alloc] initWithCapacity:limit];
        for (NSDictionary *singleProduct in parsedResults[@"products"]) {
            
            EAStoreItem *currentItem = [[EAStoreItem alloc] init];
            [currentItem setProductTitle:singleProduct[@"title"]];
            [currentItem setProductPrice:singleProduct[@"storeInfo"][@"price"][@"currentPrice"]];
            [currentItem setProductID:singleProduct[@"dpci"]];
            [currentItem setProductImageURL:[NSURL URLWithString:singleProduct[@"images"][@"primaryUri"]]];
            
            //locations is an array containing dicts that hold aisle and department. make sure a location exists to prevent out of bounds crash
            if ([singleProduct[@"storeInfo"][@"locations"] count] > 0) {
                
                [currentItem setProductDepartment:singleProduct[@"storeInfo"][@"locations"][0][@"department"]];
                [currentItem setProductAisle:singleProduct[@"storeInfo"][@"locations"][0][@"aisle"]];
            }
            
            //availability code of IN_STOCK means its available in store
            [currentItem setProductIsAvailable: ([singleProduct[@"storeInfo"][@"availabilityCode"] isEqualToString:@"IN_STOCK"]) ? YES : NO];
            
            //add to array
            [allItems addObject:currentItem];
            
        }
        
        //send immutable copy to delegate handler
        [_delegate targetQueryFinishedWithResults:[allItems copy]];
        
        
    }] resume];
}

- (void)fetchStoreMapForStoreID:(NSString *)storeID {
    
    NSString *lookupString = [NSString stringWithFormat:@"%@/%@?devId=%@&apiKey=%@", kTargetAPIMapLookupURL, storeID, kDevID, kAPIKey];
    NSURL *mapLookupURL = [NSURL URLWithString:lookupString];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:mapLookupURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //fail if bad request
        targetFailIfError(error);
        
        NSDictionary *parsedResults = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        //fail because of bad data
        targetFailIfError(error);
        
        //data is an array, make sure not to go out of bounds
        if ([parsedResults[@"data"] count] > 0) {
            
            //make sure we have a zone
            if ([parsedResults[@"data"][0][@"zones"] count] > 0) {
                
                //find default4 zone, it looks the best
                for (NSDictionary *zone in parsedResults[@"data"][0][@"zones"][0][@"zoneImages"]) {

                    if (![zone[@"imageType"] isEqualToString:@"DEFAULT4"] || ![zone[@"mimeType"] isEqualToString:@"image/svg+xml"]) {
                        continue;
                    }
                    
                    //construct dictionary with svg url and base ratio
                    NSDictionary *mapResults = @{ @"svgUrl" : [NSString stringWithFormat:@"%@?devId=%@&apiKey=%@", zone[@"imageUrl"], kDevID, kAPIKey],
                                                  @"baseRatio" :  zone[@"baseRatio"] };

                    [_delegate targetMapLookupFinishedWithResult:mapResults];
                }
            }

        }
        
    }] resume];
    
}

- (void)fetchItemLocationWithProductID:(NSString *)productID {
    
    NSString *lookupString = [NSString stringWithFormat:@"%@/?devId=%@&apiKey=%@&storeId=%@&proximity=UNKNOWN", kTargetItemLookupURL, kDevID, kAPIKey, _targetStoreID];
    NSURL *lookupURL = [NSURL URLWithString:lookupString];
    
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:lookupURL];
    [postRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [postRequest setHTTPMethod:@"POST"];
    
    NSDictionary *postDictionary = @{ @"products" : @[ @{ @"productId" : productID } ] };
    [postRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:postDictionary options:kNilOptions error:nil]];
     
    [[[NSURLSession sharedSession] dataTaskWithRequest:postRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //fail if bad request
        targetFailIfError(error);
        
        NSDictionary *parsedResults = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        //fail because of bad data
        targetFailIfError(error);
        
        //make sure theres results
        if ([parsedResults[@"results"] count] > 0 && [parsedResults[@"results"][0][@"product"][@"locations"] count] > 0) {

            //create dictionary with location results
            NSDictionary *locationResults = @{ @"x" : parsedResults[@"results"][0][@"product"][@"locations"][0][@"x"],
                                               @"y" : parsedResults[@"results"][0][@"product"][@"locations"][0][@"y"],
                                               @"locationType" : parsedResults[@"results"][0][@"product"][@"locations"][0][@"locationType"],
                                               @"aisle" : parsedResults[@"results"][0][@"product"][@"locations"][0][@"ancestry"][1][@"title"],
                                               @"bay" : parsedResults[@"results"][0][@"product"][@"locations"][0][@"ancestry"][0][@"title"],
                                               @"department" : parsedResults[@"results"][0][@"product"][@"locations"][0][@"ancestry"][2][@"title"] };
            
            [_delegate targetLocationLookupFinishedWithResult:locationResults];
        }
        
    }] resume];
}

@end
