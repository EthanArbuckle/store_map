//
//  EATargetFloorMap.h
//  store_map
//
//  Created by Ethan Arbuckle on 1/27/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import <SVGKit/SVGKit.h>

@interface EATargetFloorMap : SVGKFastImageView

@property (nonatomic, retain) NSArray <NSValue *> *itemCoordinates;

- (id)initWithSVGKImage:(SVGKImage *)image;
- (void)setItemCoordinates:(NSArray *)items;

@end
