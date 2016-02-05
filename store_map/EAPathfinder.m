//
//  EAPathfinder.m
//  store_map
//
//  Created by Ethan Arbuckle on 2/4/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import "EAPathfinder.h"

@implementation EAPathfinder

+ (NSArray *)sortedPathFromArrayOfPoints:(NSArray *)sortedPoints {
    
    NSMutableArray <NSValue *> *allCoordinates = [[NSMutableArray alloc] init];
    for (NSArray *singleSet in sortedPoints) {

        [allCoordinates addObject:[NSValue valueWithCGPoint:CGPointMake([singleSet[0] floatValue], [singleSet[1] floatValue])]];
    }
    
#define addToRemoveFrom(a, b, c, d) [b addObject:[NSValue valueWithCGPoint:a]]; [d removeObject:[NSValue valueWithCGPoint:c]];
    
    NSMutableArray *orderedPoints = [[NSMutableArray alloc] initWithCapacity:[allCoordinates count]];
    
    CGPoint startingPoint = [allCoordinates[0] CGPointValue];
    addToRemoveFrom(startingPoint, orderedPoints, [allCoordinates[0] CGPointValue], allCoordinates);
    
    while ([allCoordinates count] > 0) {
        
        CGFloat distance = INT_MAX;
        CGPoint shortest = CGPointZero;
        for (int cycle = 0; cycle < [allCoordinates count]; cycle++) {
            
            CGPoint currentPoint = [allCoordinates[cycle] CGPointValue];
            if (CGPointEqualToPoint(startingPoint, currentPoint))
                continue;
            
            CGFloat positionDistance = sqrt(pow((startingPoint.x - currentPoint.x), 2) + pow((startingPoint.y - currentPoint.y), 2));
            if (positionDistance < distance) {
                distance = positionDistance;
                shortest = currentPoint;
            }
            
        }
        
        addToRemoveFrom(shortest, orderedPoints, shortest, allCoordinates);
        startingPoint = shortest;
    }
    
    return orderedPoints;
}

@end
