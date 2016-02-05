//
//  EATargetFloorViewController.m
//  store_map
//
//  Created by Ethan Arbuckle on 1/12/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import "EATargetFloorViewController.h"

@implementation EATargetFloorViewController

- (id)initWithStoreItems:(NSArray <EAStoreItem *> *)storeItems {
    
    if ((self = [super init])) {
        
        [[self view] setBackgroundColor:[UIColor whiteColor]];
        
        _cachedFloorImageDownsizeScale = 0.2;
        _targetStoreID = @"2425";
        
        _storeItems = storeItems;
        
        _itemCoordinates = [[NSMutableArray alloc] init];
        
        //create scroll view to contain floor layout, so it can pan and zoom
        _targetFloorScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        [_targetFloorScrollView setDelegate:self];
        [_targetFloorScrollView setMaximumZoomScale:2];
        [_targetFloorScrollView setBackgroundColor:[UIColor blackColor]];
        [[self view] addSubview:_targetFloorScrollView];
        
        //create api, with self as delegate
        _targetAPI = [[EATargetAPI alloc] initWithDelegate:self];
        [_targetAPI setTargetStoreID:_targetStoreID];
        
        //load up an initial floor
        [self updateFloorLayoutWithStoreID:_targetStoreID];
        
    }
    
    return self;
}

- (void)updateFloorLayoutWithStoreID:(NSString *)storeID {
    
    //query api for store map
    _targetStoreID = storeID;
    [_targetAPI setTargetStoreID:_targetStoreID];
    [_targetAPI fetchStoreMapForStoreID:_targetStoreID];
}

#pragma mark EATargetAPI delegate methods

- (void)targetQueryFinishedWithResults:(NSArray *)results {
    
    //cycle all results and grab their location
    for (EAStoreItem *item in results) {
        
        [_targetAPI fetchItemLocationWithProductID:[item productID]];

    }
}

- (void)targetQueryDidReceiveError:(NSError *)error {
    
    NSLog(@"targetQueryDidReceiveError: %@", error);
}

- (void)targetMapLookupFinishedWithResult:(NSDictionary *)store {
    
    //update our map size ratio
    _targetFloorRatio = [store[@"baseRatio"] floatValue];
    
    //fetch the actual svg image
    [SVGKImage imageWithSource:[SVGKSourceURL sourceFromURL:[NSURL URLWithString:store[@"svgUrl"]]] onCompletion:^(SVGKImage *loadedImage, SVGKParseResult *parseResult) {
    
        _cachedFloorImage = loadedImage;

        //downscale it
        [_cachedFloorImage setSize:CGSizeMake(_cachedFloorImageDownsizeScale * [_cachedFloorImage size].width, _cachedFloorImageDownsizeScale * [_cachedFloorImage size].height)];
        
        //hop back on main thread
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            //create optimized image view
            _targetFloorImageView = [[EATargetFloorMap alloc] initWithSVGKImage:_cachedFloorImage];
            [_targetFloorImageView setDisableAutoRedrawAtHighestResolution:YES];
            
            //update scroll view
            [[_targetFloorScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [_targetFloorScrollView setContentSize:[_cachedFloorImage size]];
            [_targetFloorScrollView setMinimumZoomScale:[[UIScreen mainScreen] bounds].size.width / [_cachedFloorImage size].width];
            [_targetFloorScrollView setZoomScale:[_targetFloorScrollView minimumZoomScale]];
            [_targetFloorScrollView addSubview:_targetFloorImageView];
            
            //enumerate items and perfom lookup
            for (EAStoreItem *item in _storeItems) {
                
                [_targetAPI fetchItemLocationWithProductID:[item productID]];
            }

        });
        
    }];
}

- (void)targetLocationLookupFinishedWithResult:(NSDictionary *)location {
    
    //hop back on main thread
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        //get adjusted coords to draw marker at
        CGPoint markerPoint = CGPointMake((_targetFloorRatio * _cachedFloorImageDownsizeScale) * [location[@"x"] floatValue], (_targetFloorRatio * _cachedFloorImageDownsizeScale) * [location[@"y"] floatValue]);
        
        //create marker
        UIView *marker = [[UIView alloc] initWithFrame:CGRectMake(markerPoint.x, markerPoint.y, 8, 8)];
        [marker setBackgroundColor:[UIColor purpleColor]];
        
        //add it to map layout image
        [_targetFloorImageView addSubview:marker];
        
        [self addCoordinateSet:@[@((_targetFloorRatio * _cachedFloorImageDownsizeScale) * [location[@"x"] floatValue]), @((_targetFloorRatio * _cachedFloorImageDownsizeScale) * [location[@"y"] floatValue])]];
        
    });
    
}

- (void)addCoordinateSet:(NSArray *)coordinates {
    
    //add set to item coords
    [_itemCoordinates addObject:coordinates];
    
    if ([_itemCoordinates count] == [_storeItems count]) {
        
        [_targetFloorImageView setItemCoordinates:[EAPathfinder sortedPathFromArrayOfPoints:[_itemCoordinates copy]]];
        [_targetFloorImageView setNeedsDisplay];
    }
}

#pragma mark UIScrollView delegate methods
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _targetFloorImageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
}

@end
