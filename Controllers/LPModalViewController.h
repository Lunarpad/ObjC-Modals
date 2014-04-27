//
//  LPModalViewController.h
//  Lunarpad
//
//  Created by Paul Shapiro.
//  Copyright (c) 2014 Lunarpad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPModalContentViewController.h"


////////////////////////////////////////////////////////////////////////////////

typedef enum {
    LPModalTransitionFade,
    LPModalTransitionNone,
    LPModalTransitionSlideUp,
    LPModalTransitionSlideDown
} LPModalTransition;


extern NSString *const LPModal_notification_backgroundTapped;


////////////////////////////////////////////////////////////////////////////////

@interface LPModalViewController : UIViewController

- (void)teardown; // call super if overridden
- (void)stopObserving;

@property (strong, readonly, nonatomic) UIImageView *curtainImageView;
@property (strong, readonly, nonatomic) UIViewController *contentViewController;

@property LPModalTransition revealTransition;
@property LPModalTransition dismissTransition;

- (void)useContentViewController:(id<LPModalContentViewController>)contentViewController;

- (void)revealWithCompletion:(void(^)(BOOL))completed; // will default to self.revealTransition
- (void)revealWithTransition:(LPModalTransition)transition andCompletion:(void(^)(BOOL))completed;
- (void)dismissWithCompletion:(void(^)(BOOL))completed; // will default to self.dismissTransition
- (void)dismissWithTransition:(LPModalTransition)transition andCompletion:(void(^)(BOOL))completed;

@end
