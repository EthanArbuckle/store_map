//
//  EATargetFloorViewController.h
//  store_map
//
//  Created by Ethan Arbuckle on 1/12/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EATargetAPI.h"
#import "EATargetFloorMap.h"
#import "EAPathfinder.h"
#import <SVGKit/SVGKit.h>

@interface EATargetFloorViewController : UIViewController <UIScrollViewDelegate, EATargetDelegate>

@property (nonatomic, retain) SVGKImage *cachedFloorImage;
@property (nonatomic, retain) EATargetFloorMap *targetFloorImageView;
@property (nonatomic, retain) EATargetAPI *targetAPI;
@property (nonatomic, retain) NSArray <EAStoreItem *> *storeItems;
@property (nonatomic, retain) UIScrollView *targetFloorScrollView;
@property (nonatomic, retain) NSString *targetStoreID;
@property (nonatomic, retain) NSMutableArray *itemCoordinates;
@property (nonatomic) CGFloat cachedFloorImageDownsizeScale;
@property (nonatomic) CGFloat targetFloorRatio;

- (id)initWithStoreItems:(NSArray <EAStoreItem *> *)storeItems;
- (void)updateFloorLayoutWithStoreID:(NSString *)storeID;
- (void)addCoordinateSet:(NSArray *)coordinates;

@end

