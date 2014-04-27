# Modals

## Description

A view controller module for displaying floating modal views within your iOS app.

## Installation

Simply plop this repo into your project, and you should be good to go.

## Sample usage

    UIViewController *customContentViewController = [[UIViewController alloc] init];
    customContentViewController.view.frame = CGRectMake(10, 20, 300, 200); // set intended 'visible' frame
    customContentViewController.view.backgroundColor = [UIColor white];
    customContentViewController.view.layer.masksToBounds = YES;
    customContentViewController.view.layer.cornerRadius = 6;

    LPModalViewController *modalViewController = [[BZModalViewController alloc] init];
    [modalViewController useContentViewController:myModalContentViewController];

    modalViewController.revealTransition = LPModalTransitionSlideUp;
    modalViewController.dismissTransition = LPModalTransitionSlideDown;

    [modalViewController revealWithCompletion:^(BOOL finished) {}];

    …
    
    [modalViewController dismissWithCompletion:^(BOOL finished) {}];
    

### Transitions

    typedef enum {
        LPModalTransitionFade,
        LPModalTransitionNone,
        LPModalTransitionSlideUp,
        LPModalTransitionSlideDown
    } LPModalTransition;


### Subclassing

`LPModalViewController` is subclassable! Subclassing is great for customizing modal transitions and subview appearance.