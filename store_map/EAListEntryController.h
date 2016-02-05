//
//  EAListEntryController.h
//  store_map
//
//  Created by Ethan Arbuckle on 1/31/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EATargetAPI.h"
#import "EAProcessedListController.h"

@interface EAListEntryController : UIViewController <UITextViewDelegate, EATargetDelegate>

@property (nonatomic, retain) UITextView *itemEntryView;
@property (nonatomic, retain) UIButton *processButton;
@property (nonatomic, retain) EATargetAPI *targetAPI;
@property (nonatomic, retain) NSMutableArray *processedListItems;
@property (nonatomic) NSInteger expectedResults;
@property (nonatomic) NSInteger retrievedResults;

- (void)dismissKeyboard;
- (void)processList;
- (void)finishedProcessing;

@end
