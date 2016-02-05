//
//  EAStoreItem.m
//  store_map
//
//  Created by Ethan Arbuckle on 1/12/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import "EAStoreItem.h"

@implementation EAStoreItem

- (NSString *)description {
    
    //dynamically pull and print any ivars on this class for printing to console
    
    NSMutableString *description = [[NSMutableString alloc] initWithString:@"\n["];
    
    uint total = 0;
    Ivar *ivarsBuffer = class_copyIvarList([self class], &total);
    for (int i = 0; i < total; i++) {
        
        [description appendFormat:@"\t\"%s\" == \"%@\"\n", ivar_getName(ivarsBuffer[i]), [self valueForKey:[NSString stringWithCString:ivar_getName(ivarsBuffer[i]) encoding:NSUTF8StringEncoding]]];
    }
    
    [description appendString:@"]\n"];
    
    return description;
}

@end

