//
//  WSCoachMarksView.m
//  Version 0.2
//
//  Created by Dimitry Bentsionov on 4/1/13.
//  Copyright (c) 2013 Workshirt, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WSCoachMarksView.h"

static const CGFloat kAnimationDuration = 0.3f;
static const CGFloat kCutoutRadius = 2.0f; // カットアウトの角丸半径
static const CGFloat kMaxLblWidth = 230.0f; //文字のラベル（横）
static const CGFloat kLblSpacing = 35.0f; //文字のラベル（縦）
// 最初のコーチマークでユーザを誘導するために、デフォルトで"Tap to continue"ラベルをポップアップで表示する
static const BOOL kEnableContinueLabel = YES;


@implementation WSCoachMarksView {
    CAShapeLayer *mask;
    NSUInteger markIndex;
    UILabel *lblContinue;
}

#pragma mark - Properties

@synthesize delegate;
@synthesize coachMarks;
@synthesize lblCaption;
@synthesize maskColor = _maskColor;
@synthesize animationDuration;
@synthesize cutoutRadius;
@synthesize maxLblWidth;
@synthesize lblSpacing;
@synthesize enableContinueLabel;

#pragma mark - Methods

- (id)initWithFrame:(CGRect)frame coachMarks:(NSArray *)marks {
    self = [super initWithFrame:frame];
    if (self) {
        // Save the coach marks
        self.coachMarks = marks;

        // Setup
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Setup
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Setup
        [self setup];
    }
    return self;
}

- (void)setup {
    // Default
    self.animationDuration = kAnimationDuration;
    self.cutoutRadius = kCutoutRadius;
    self.maxLblWidth = kMaxLblWidth;
    self.lblSpacing = kLblSpacing;
    self.enableContinueLabel = kEnableContinueLabel;
    

    // Shape layer mask
    mask = [CAShapeLayer layer];
    [mask setFillRule:kCAFillRuleEvenOdd];
    [mask setFillColor:[[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:0.9f] CGColor]];
    [self.layer addSublayer:mask];

    // Capture touches
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];

    
   

    
    
    // Captions
    self.lblCaption = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {self.maxLblWidth, 0.0f}}];
    self.lblCaption.backgroundColor = [UIColor clearColor];
    self.lblCaption.textColor = [UIColor whiteColor];
    self.lblCaption.font = [UIFont systemFontOfSize:20.0f];
    self.lblCaption.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblCaption.numberOfLines = 0;
    self.lblCaption.textAlignment = NSTextAlignmentCenter;
    self.lblCaption.alpha = 0.0f;
    [self addSubview:self.lblCaption];

    // Hide until unvoked
    self.hidden = YES;
}

#pragma mark - Cutout modify

- (void)setCutoutToRect:(CGRect)rect {
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cutoutRadius];
    [maskPath appendPath:cutoutPath];
    
    
    // Set the new path
    mask.path = maskPath.CGPath;
}

- (void)animateCutoutToRect:(CGRect)rect {
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cutoutRadius];
    [maskPath appendPath:cutoutPath];

    // Animate it
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.delegate = self;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.duration = self.animationDuration;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.fromValue = (__bridge id)(mask.path);
    anim.toValue = (__bridge id)(maskPath.CGPath);
    [mask addAnimation:anim forKey:@"path"];
    mask.path = maskPath.CGPath;
}

#pragma mark - Mask color

- (void)setMaskColor:(UIColor *)maskColor {
    _maskColor = maskColor;
    [mask setFillColor:[maskColor CGColor]];
}

#pragma mark - Touch handler

- (void)userDidTap:(UITapGestureRecognizer *)recognizer {
    // Go to the next coach mark
    [self goToCoachMarkIndexed:(markIndex+1)];
    
    NSLog(@"タッチ");
    NSLog(@"%d回",markIndex);
    
    
}

#pragma mark - Navigation

- (void)start {
    // Fade in self
    self.alpha = 0.0f;
    self.hidden = NO;
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         // Go to the first coach mark
                         [self goToCoachMarkIndexed:0];
                     }];
}

- (void)goToCoachMarkIndexed:(NSUInteger)index {
    // Out of bounds
    if (index >= self.coachMarks.count) {
        [self cleanup];
        return;
    }

   
    // Current index
    markIndex = index;

    // Coach mark definition
    NSDictionary *markDef = [self.coachMarks objectAtIndex:index];
    NSString *markCaption = [markDef objectForKey:@"caption"];
    CGRect markRect = [[markDef objectForKey:@"rect"] CGRectValue];

    // Delegate (coachMarksView:willNavigateTo:atIndex:)
    if ([self.delegate respondsToSelector:@selector(coachMarksView:willNavigateToIndex:)]) {
        [self.delegate coachMarksView:self willNavigateToIndex:markIndex];
    }

    
    //CGRect{{x,y},{width,height}}
    if(markIndex == 0){
        self.lblCaption.frame = (CGRect){{50, 100}, {200, 70}};
    }
    else if(markIndex  == 1){
        self.lblCaption.frame = (CGRect){{50, 170}, {200, 90}};
    }
    else if(markIndex  == 2){
        self.lblCaption.frame = (CGRect){{50, 200}, {200, 90}};
    }
    else if(markIndex  == 3){
        self.lblCaption.frame = (CGRect){{50, 200}, {200, 90}};
    }


    
    // Calculate the caption position and size
    self.lblCaption.alpha = 0.0f;
    
    self.lblCaption.text = markCaption;
    [self.lblCaption sizeToFit];
    //CGFloat y = markRect.origin.y + markRect.size.height + self.lblSpacing;
    //CGFloat bottomY = y + self.lblCaption.frame.size.height + self.lblSpacing;
    //if (bottomY > self.bounds.size.height) {
   //     y = markRect.origin.y - self.lblSpacing - self.lblCaption.frame.size.height;
    //}
    //CGFloat x = floorf((self.bounds.size.width - self.lblCaption.frame.size.width) / 2.0f);

    // Animate the caption label
   // self.lblCaption.frame = (CGRect){{x, y}, self.lblCaption.frame.size};
    [UIView animateWithDuration:0.3f animations:^{
        self.lblCaption.alpha = 1.0f;
    }];

    // If first mark, set the cutout to the center of first mark
    if (markIndex == 0) {
        CGPoint center = CGPointMake(floorf(markRect.origin.x + (markRect.size.width / 2.0f)), floorf(markRect.origin.y + (markRect.size.height / 2.0f)));
        CGRect centerZero = (CGRect){center, CGSizeZero};
        [self setCutoutToRect:centerZero];
    }

    // Animate the cutout
    [self animateCutoutToRect:markRect];

}
#pragma mark - Cleanup

- (void)cleanup {
    // Delegate (coachMarksViewWillCleanup:)
    if ([self.delegate respondsToSelector:@selector(coachMarksViewWillCleanup:)]) {
        [self.delegate coachMarksViewWillCleanup:self];
    }

    // Fade out self
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         // Remove self
                         [self removeFromSuperview];

                         // Delegate (coachMarksViewDidCleanup:)
                         if ([self.delegate respondsToSelector:@selector(coachMarksViewDidCleanup:)]) {
                             [self.delegate coachMarksViewDidCleanup:self];
                         }
                     }];
}

#pragma mark - Animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    // Delegate (coachMarksView:didNavigateTo:atIndex:)
    if ([self.delegate respondsToSelector:@selector(coachMarksView:didNavigateToIndex:)]) {
        [self.delegate coachMarksView:self didNavigateToIndex:markIndex];
    }
}

@end
