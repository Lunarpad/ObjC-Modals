//
//  LPModalViewController.m
//  Lunarpad
//
//  Created by Paul Shapiro.
//  Copyright (c) 2014 Lunarpad. All rights reserved.
//

#import "LPModalViewController.h"


////////////////////////////////////////////////////////////////////////////////

NSString *const LPModal_notification_backgroundTapped = @"LPModal_notification_backgroundTapped";


////////////////////////////////////////////////////////////////////////////////

@interface LPModalViewController ()

@property (strong, readwrite, nonatomic) UIImageView *curtainImageView;
@property (strong, readwrite, nonatomic) UIViewController *contentViewController;
@property CGRect initialModalFrame;

@end

@implementation LPModalViewController


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle - Setup

- (id)init
{
    self = [super init];
    if (self) {
        [self _setup];
    }
    return self;
}

- (void)_setup
{
    self.revealTransition = LPModalTransitionFade;
    self.dismissTransition = LPModalTransitionFade;
    [self setupCurtainImageView];
}

- (void)setupCurtainImageView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.accessibilityLabel = [LPAccessibility bzModal_backgroundView_accessibilityLabel];
    imageView.frame = self.view.bounds;
    imageView.backgroundColor = [UIColor colorWithHex:@"2a2625dd"]; // 0.5 opacity on color
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.hidden = YES;
    imageView.userInteractionEnabled = YES;
    self.curtainImageView = imageView;
    [self.view addSubview:imageView];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [imageView addGestureRecognizer:recognizer];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle - Teardown

- (void)dealloc
{
    [self teardown];
}

- (void)teardown
{
    [self stopObserving];

    [self.contentViewController removeFromParentViewController];
    self.contentViewController = nil;
}

- (void)stopObserving
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Imperatives 

- (void)revealWithCompletion:(void (^)(BOOL))completed
{
    [self revealWithTransition:self.revealTransition andCompletion:completed];
}

- (void)revealWithTransition:(LPModalTransition)transition andCompletion:(void(^)(BOOL))completed
{
    BOOL animated = transition != LPModalTransitionNone;
    void (^configure)(void) = [self revealAnimationConfigurationsForTransition:transition];
    void (^animationCompleted)(BOOL) = ^(BOOL finished) {
        [self revealAnimationPostconfigurationsForTransition:transition];
        [(id<LPModalContentViewController>)self.contentViewController modalWasPresented];
        
        completed(finished);
    };
    [self revealPreconfigurationsForTransition:transition]();

    [(id<LPModalContentViewController>)self.contentViewController modalWillBePresented];
    
    if (animated) {
        UIViewAnimationOptions options = [self revealAnimationOptionsForTransition:transition];
        [UIView animateWithDuration:0.4 delay:0 options:options animations:configure completion:animationCompleted];
    } else {
        configure();
        animationCompleted(YES);
    }
}

- (void)dismissWithCompletion:(void(^)(BOOL))completed
{
    [self dismissWithTransition:self.dismissTransition andCompletion:completed];
}

- (void)dismissWithTransition:(LPModalTransition)transition andCompletion:(void(^)(BOOL))completed
{
    BOOL animated = transition != LPModalTransitionNone;
    void (^configure)(void) = [self dismissAnimationConfigurationsForTransition:transition];
    void (^animationCompleted)(BOOL) = ^(BOOL finished) {
        [self dismissAnimationPostconfigurationsForTransition:transition];
        [(id<LPModalContentViewController>)self.contentViewController modalWasDismissed];

        completed(finished);
    };
    [self dismissPreconfigurationsForTransition:transition]();

    [(id<LPModalContentViewController>)self.contentViewController modalWillBeDismissed];
    
    if (animated) {
        UIViewAnimationOptions options = [self dismissAnimationOptionsForTransition:transition];
        [UIView animateWithDuration:0.5 delay:0 options:options animations:configure completion:animationCompleted];
    } else {
        configure();
        animationCompleted(YES);
    }
}

- (void)useContentViewController:(id<LPModalContentViewController>)contentViewController
{
    if (![contentViewController isKindOfClass:[UIViewController class]]) {
        NSLog(@"Error: D'oh! Content view controller needs to be a view controller in order to use it!");
        return;
    }
    UIViewController *viewController = (UIViewController *)contentViewController;
    if (!self.contentViewController) {
        [self.contentViewController.view removeFromSuperview];
        [self.contentViewController removeFromParentViewController];
        self.contentViewController = nil;
    }
    self.contentViewController = viewController;
    viewController.accessibilityLabel = [LPAccessibility bzModal_contentView_accessibilityLabel];
    viewController.view.hidden = YES; // hide till we show it, hide after dismissing too
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors - Reveal

- (UIViewAnimationOptions)revealAnimationOptionsForTransition:(LPModalTransition)transition
{
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    switch (transition) {
        case LPModalTransitionNone:
            // should never actually get here
            break;
            
        case LPModalTransitionFade:
            options |= UIViewAnimationCurveEaseInOut;
            break;
            
        case LPModalTransitionSlideUp:
            options |= UIViewAnimationCurveEaseIn;
            break;
            
        case LPModalTransitionSlideDown:
            options |= UIViewAnimationCurveEaseOut;
            break;
            
        default:
            break;
    }
    
    return options;
}

- (void(^)(void))revealPreconfigurationsForTransition:(LPModalTransition)transition
{
    __block LPModalTransition transition__block = transition;
    return ^{
        self.initialModalFrame = self.contentViewController.view.frame;
        
        switch (transition__block) {
            case LPModalTransitionNone:
                break;

            case LPModalTransitionFade:
                self.curtainImageView.alpha = 0;
                self.contentViewController.view.alpha = 0;
                break;
                
            case LPModalTransitionSlideUp:
                self.curtainImageView.alpha = 0;
                self.contentViewController.view.alpha = 1;
                self.contentViewController.view.frame = CGRectMake(self.contentViewController.view.frame.origin.x, self.view.frame.size.height + self.contentViewController.view.frame.size.height, self.contentViewController.view.frame.size.width, self.contentViewController.view.frame.size.height);
                break;
                
            case LPModalTransitionSlideDown:
                self.curtainImageView.alpha = 0;
                self.contentViewController.view.alpha = 1;
                self.contentViewController.view.frame = CGRectMake(self.contentViewController.view.frame.origin.x, -self.contentViewController.view.frame.size.height, self.contentViewController.view.frame.size.width, self.contentViewController.view.frame.size.height);
                break;
                
            default:
                break;
        }
        
        self.curtainImageView.hidden = NO;
        self.contentViewController.view.hidden = NO;
    };
}

- (void(^)(void))revealAnimationConfigurationsForTransition:(LPModalTransition)transition
{
    __block LPModalTransition transition__block = transition;
    return ^{
        switch (transition__block) {
            case LPModalTransitionNone:
                break;

            case LPModalTransitionFade:
                self.curtainImageView.alpha = 1;
                self.contentViewController.view.alpha = 1;
                break;
                
            case LPModalTransitionSlideUp:
                self.curtainImageView.alpha = 1;
                self.contentViewController.view.frame = self.initialModalFrame;
                break;
                
            case LPModalTransitionSlideDown:
                self.curtainImageView.alpha = 1;
                self.contentViewController.view.frame = self.initialModalFrame;
                break;
                
            default:
                break;
        }
    };
}

- (void(^)(void))revealAnimationPostconfigurationsForTransition:(LPModalTransition)transition
{
    __block LPModalTransition transition__block = transition;
    return ^{
        switch (transition__block) {
            case LPModalTransitionNone:
                break;
                
            case LPModalTransitionFade:
                break;
                
            case LPModalTransitionSlideUp:
                break;
                
            case LPModalTransitionSlideDown:
                break;
                
            default:
                break;
        }
    };
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors - Dismiss

- (UIViewAnimationOptions)dismissAnimationOptionsForTransition:(LPModalTransition)transition
{
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    switch (transition) {
        case LPModalTransitionNone:
            // should never actually get here
            break;
            
        case LPModalTransitionFade:
            options |= UIViewAnimationCurveEaseInOut;
            break;
            
        case LPModalTransitionSlideUp:
            options |= UIViewAnimationCurveEaseOut;
            break;
            
        case LPModalTransitionSlideDown:
            options |= UIViewAnimationCurveEaseIn;
            break;
            
        default:
            break;
    }
    
    return options;
}

- (void(^)(void))dismissPreconfigurationsForTransition:(LPModalTransition)transition
{
    __block LPModalTransition transition__block = transition;
    return ^{
        switch (transition__block) {
            case LPModalTransitionNone:
                break;
                
            case LPModalTransitionFade:
                break;
                
            case LPModalTransitionSlideUp:
                break;
                
            case LPModalTransitionSlideDown:
                break;
                
            default:
                break;
        }
    };
}

- (void(^)(void))dismissAnimationConfigurationsForTransition:(LPModalTransition)transition
{
    __block LPModalTransition transition__block = transition;
    return ^{
        switch (transition__block) {
            case LPModalTransitionNone:
                break;
                
            case LPModalTransitionFade:
                self.curtainImageView.alpha = 0;
                self.contentViewController.view.alpha = 0;
                break;
                
            case LPModalTransitionSlideUp:
                self.curtainImageView.alpha = 0;
                self.contentViewController.view.frame = CGRectMake(self.contentViewController.view.frame.origin.x, -self.contentViewController.view.frame.size.height*2, self.contentViewController.view.frame.size.width, self.contentViewController.view.frame.size.height);
                break;
                
            case LPModalTransitionSlideDown:
                self.curtainImageView.alpha = 0;
                self.contentViewController.view.frame = CGRectMake(self.contentViewController.view.frame.origin.x, self.view.frame.size.height + self.contentViewController.view.frame.size.height, self.contentViewController.view.frame.size.width, self.contentViewController.view.frame.size.height);
                break;
                
            default:
                break;
        }
    };
}

- (void(^)(void))dismissAnimationPostconfigurationsForTransition:(LPModalTransition)transition
{
    __block LPModalTransition transition__block = transition;
    return ^{
        self.curtainImageView.hidden = YES;
        self.contentViewController.view.hidden = YES;
        
        switch (transition__block) {
            case LPModalTransitionNone:
                break;
                
            case LPModalTransitionFade:
                break;
                
            case LPModalTransitionSlideUp:
                break;
                
            case LPModalTransitionSlideDown:
                break;
                
            default:
                break;
        }
    };
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delegation

- (void)backgroundTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    //If it's within the bounds of where you'd expect the left and right buttons of the modal to be
    CGFloat recognizableWidth = 90;
    CGFloat recognizableHeight = 75;
    CGPoint tappedLocation = [gestureRecognizer locationInView:nil];
    
    LPModalBackgroundQuadrant quadrant;
    
    if (tappedLocation.y < recognizableHeight) {
        if (tappedLocation.x < recognizableWidth) {
            quadrant = LPModalBackgroundQuadrantUL;
        } else {
            quadrant = LPModalBackgroundQuadrantUR;
        }
    } else {
        if (tappedLocation.x < self.view.frame.size.width - recognizableWidth) {
            quadrant = LPModalBackgroundQuadrantLL;
        } else {
            quadrant = LPModalBackgroundQuadrantLR;
        }
    }
    
    [(id<LPModalContentViewController>)self.contentViewController backgroundTappedInQuadrant:quadrant];
    LPNotificationCenterPost(LPModal_notification_backgroundTapped);
}

@end
