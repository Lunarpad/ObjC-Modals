//
//  LPModalContentViewController.h
//  Lunarpad
//
//  Created by Paul Shapiro.
//  Copyright (c) 2014 Lunarpad. All rights reserved.
//

#import <Foundation/Foundation.h>


////////////////////////////////////////////////////////////////////////////////

typedef enum {
    LPModalBackgroundQuadrantUL,
    LPModalBackgroundQuadrantUR,
    LPModalBackgroundQuadrantLL,
    LPModalBackgroundQuadrantLR
} LPModalBackgroundQuadrant;

////////////////////////////////////////////////////////////////////////////////

@protocol LPModalContentViewController <NSObject>

- (void)modalWillBePresented;
- (void)modalWillBeDismissed;
- (void)modalWasPresented;
- (void)modalWasDismissed;

- (void)backgroundTappedInQuadrant:(LPModalBackgroundQuadrant)quadrant;

@end
