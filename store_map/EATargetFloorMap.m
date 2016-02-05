//
//  EATargetFloorMap.m
//  store_map
//
//  Created by Ethan Arbuckle on 1/27/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import "EATargetFloorMap.h"

@implementation EATargetFloorMap

- (id)initWithSVGKImage:(SVGKImage *)image {
    
    if ((self = [super initWithSVGKImage:image])) {
        
    }
    
    return self;
}

- (void)setItemCoordinates:(NSArray *)items {
    _itemCoordinates = items;
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor purpleColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, [_itemCoordinates[0] CGPointValue].x, [_itemCoordinates[0] CGPointValue].y);
    
    for (int i = 1; i < [_itemCoordinates count]; i++) {

        CGContextAddLineToPoint(context, [_itemCoordinates[i] CGPointValue].x, [_itemCoordinates[i] CGPointValue].y);
    }
    
    CGContextStrokePath(context);
    
}

@end
