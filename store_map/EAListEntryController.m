//
//  EAListEntryController.m
//  store_map
//
//  Created by Ethan Arbuckle on 1/31/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import "EAListEntryController.h"

@implementation EAListEntryController

- (id)init {
    
    if ((self = [super init])) {
     
        [[self view] setBackgroundColor:[UIColor lightGrayColor]];
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
        [self setTitle:@"items"];
        
        _targetAPI = [[EATargetAPI alloc] initWithDelegate:self];
        [_targetAPI setTargetStoreID:@"2425"];
        
        //create list text view
        _itemEntryView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10 + /*nav bar height*/ 64, [[UIScreen mainScreen] bounds].size.width - 20, [[UIScreen mainScreen] bounds].size.height - 160)];
        [_itemEntryView setTextAlignment:NSTextAlignmentLeft];
        [_itemEntryView setDelegate:self];
        [_itemEntryView setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        [[self view] addSubview:_itemEntryView];
        
        //gesture to dismiss keyboard
        UISwipeGestureRecognizer *swipeDismiss = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
        [swipeDismiss setDirection:UISwipeGestureRecognizerDirectionDown];
        [_itemEntryView addGestureRecognizer:swipeDismiss];
        
        //create button to process list
        _processButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_processButton setFrame:CGRectMake(10, [_itemEntryView frame].size.height + [_itemEntryView frame].origin.y + 10, [[UIScreen mainScreen] bounds].size.width - 20, [[UIScreen mainScreen] bounds].size.height - ([_itemEntryView frame].size.height + [_itemEntryView frame].origin.y + 20))];
        [_processButton setBackgroundColor:[UIColor blueColor]];
        [_processButton setTitle:@"process" forState:UIControlStateNormal];
        [_processButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_processButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [_processButton setEnabled:NO];
        [_processButton addTarget:self action:@selector(processList) forControlEvents:UIControlEventTouchUpInside];
        [[self view] addSubview:_processButton];
        
    }
    
    return self;
}

- (void)dismissKeyboard {

    //swiped down on textview, dismiss keyboard
    [_itemEntryView resignFirstResponder];
    
    //remove done button
    [[self navigationItem] setRightBarButtonItem:nil animated:YES];
}

- (void)processList {
    
    if ([[_itemEntryView text] length] > 0) {
        
        [_processButton setEnabled:NO];
        
        //get array of search items
        NSArray *queries = [[_itemEntryView text] componentsSeparatedByString:@"\n"];
        
        //create array to hold finished results
        _processedListItems = [[NSMutableArray alloc] initWithCapacity:[queries count]];
        _expectedResults = [queries count];
        _retrievedResults = 0;
        
        for (NSString *search in queries) {
            
            //do a single item search
            [_targetAPI searchWithQuery:search maximumResults:1];
        }
    }
    
}

- (void)finishedProcessing {
    
    if ([_processedListItems count] > 0) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [_processButton setEnabled:YES];
            
            //create processed list controller and push to it
            EAProcessedListController *processedController = [[EAProcessedListController alloc] init];
            [processedController setProcessedItems:_processedListItems];
            [[self navigationController] pushViewController:processedController animated:YES];

        });
        
    }
    else {
        
        NSLog(@"no items returned");
    }
    
}

#pragma mark UITextView delegates
- (void)targetQueryFinishedWithResults:(NSArray *)results {
    
    //should only have a single result
    if ([results count] >= 1) {
        
        //add it to array
        [_processedListItems addObject:[results objectAtIndex:0]];
    }
    
    //keep track of when we finish loading everything
    if (++_retrievedResults >= _expectedResults) {
        
        [self finishedProcessing];
    }
}

- (void)targetQueryDidReceiveError:(NSError *)error {
    
    NSLog(@"listentry receieved error %@", error);
    //keep track of when we finish loading everything
    
    if (++_retrievedResults >= _expectedResults) {
        
        [self finishedProcessing];
    }
    
}

#pragma mark UITextView delegates
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    //show done button to dismiss keyboard
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard)];
    [[self navigationItem] setRightBarButtonItem:doneButton animated:YES];
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    //only enable proceed button if there is text
    [_processButton setEnabled:(([[_itemEntryView text] length] > 0) ? YES : NO)];
    
}

@end
