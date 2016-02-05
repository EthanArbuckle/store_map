//
//  EAStoreItem.h
//  store_map
//
//  Created by Ethan Arbuckle on 1/12/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface EAStoreItem : NSObject

@property (nonatomic, retain) NSString *productTitle;
@property (nonatomic, retain) NSString *productID;
@property (nonatomic, retain) NSString *productDepartment;
@property (nonatomic, retain) NSString *productAisle;
@property (nonatomic, retain) NSString *productPrice;
@property (nonatomic, retain) NSURL *productImageURL;
@property (nonatomic) BOOL productIsAvailable;

@end
