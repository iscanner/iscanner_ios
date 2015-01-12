//
//  SwipeableCell.m
//  iscanner_ios
//
//  Created by xdf on 1/10/15.
//  Copyright (c) 2015 xdf. All rights reserved.
//

#import "SwipeableCell.h"

@interface SwipeableCell() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingRightLayoutConstraintConstant;
@property (nonatomic, strong) NSLayoutConstraint *contentViewRightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *contentViewLeftConstraint;
@end

@implementation SwipeableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.buttons = [NSMutableArray array];
        self.containerView = [[UIView alloc] init];
        self.containerView.userInteractionEnabled = YES;
        self.containerView.clipsToBounds = YES;
        self.containerView.backgroundColor = [UIColor whiteColor];
        self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.containerView];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
        panRecognizer.delegate = self;
        [self.containerView addGestureRecognizer:panRecognizer];
        [self layoutIfNeeded];
        CGRect rect = [ UIScreen mainScreen ].applicationFrame;
        CGFloat offsetLeft = 15;
        self.customLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetLeft, 0, rect.size.width - offsetLeft * 2, 60.0f)];
        self.customLabel.numberOfLines = 0;
        [self.containerView addSubview: self.customLabel];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    if (!self.contentViewLeftConstraint) {
        NSDictionary *views = @{ @"containerView" : self.containerView };
        NSArray *verticalConstraints = [NSLayoutConstraint
                                        constraintsWithVisualFormat:@"V:|[containerView]|"
                                        options:0
                                        metrics:nil
                                        views:views];
        [self.contentView addConstraints:verticalConstraints];
        NSArray *horizontalConstraints = [NSLayoutConstraint
                                          constraintsWithVisualFormat:@"H:|[containerView]|"
                                          options:0
                                          metrics:0
                                          views:views];
        self.contentViewLeftConstraint = horizontalConstraints[0];
        self.contentViewRightConstraint = horizontalConstraints[1];
        
        [self.contentView addConstraints:horizontalConstraints];
    }
}

- (void)configureButtons {
    CGFloat previousMinX = CGRectGetWidth(self.frame);
    NSInteger buttons = [self.dataSource numberOfButtonsInSwipeableCell:self];
    for (NSInteger i = 0; i < buttons; i++) {
        UIButton *button = [self buttonForIndex:i previousButtonMinX:previousMinX];
        [self.buttons addObject:button];
        previousMinX -= CGRectGetWidth(button.frame);
        [self.contentView addSubview:button];
    }
    
    [self.contentView bringSubviewToFront:self.containerView];
}

- (void)configureButtonsIfNeeded {
    if (self.buttons.count == 0) {
        [self configureButtons];
    }
}

- (UIButton *)buttonForIndex:(NSInteger)index previousButtonMinX:(CGFloat)previousMinX {
    UIButton *button = nil;
    if ([self.dataSource respondsToSelector:@selector(swipeableCell:buttonForIndex:)]) {
        
        button = [self.dataSource swipeableCell:self buttonForIndex:index];
    } else {
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if ([self.dataSource respondsToSelector:@selector(swipeableCell:titleForButtonAtIndex:)]) {
            [button setTitle:[self.dataSource swipeableCell:self titleForButtonAtIndex:index] forState:UIControlStateNormal];
        } else {
            [button setTitle:@"" forState:UIControlStateNormal];
        }
        
        if ([self.dataSource respondsToSelector:@selector(swipeableCell:imageForButtonAtIndex:)]) {
            UIImage *iconImage = [self.dataSource swipeableCell:self imageForButtonAtIndex:index];
            if (iconImage) {
                [button setImage:[iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            }
        }
        
        if ([self.dataSource respondsToSelector:@selector(swipeableCell:tintColorForButtonAtIndex:)]) {
            button.tintColor = [self.dataSource swipeableCell:self tintColorForButtonAtIndex:index];
        } else {
            button.tintColor = [UIColor whiteColor];
        }
        [button setContentEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
        
        if ([self.dataSource respondsToSelector:@selector(swipeableCell:fontForButtonAtIndex:)]) {
            button.titleLabel.font = [self.dataSource swipeableCell:self fontForButtonAtIndex:index];
        }
        [button sizeToFit];
        
        CGFloat appleRecommendedMinimumTouchPointWidth = 44.0f;
        if (button.frame.size.width < appleRecommendedMinimumTouchPointWidth) {
            CGRect frame = button.frame;
            frame.size.width = appleRecommendedMinimumTouchPointWidth;
            button.frame = frame;
        }
        
        if ([self.dataSource respondsToSelector:@selector(swipeableCell:backgroundColorForButtonAtIndex:)]) {
            button.backgroundColor = [self.dataSource swipeableCell:self  backgroundColorForButtonAtIndex:index];
        } else {
            if (index == 0) {
                button.backgroundColor = [UIColor lightGrayColor];
            } else {
                button.backgroundColor = [UIColor lightGrayColor];
            }
        }
    }
    
    CGFloat xOrigin = previousMinX - CGRectGetWidth(button.frame);
    button.frame = CGRectMake(xOrigin, 0, CGRectGetWidth(button.frame), CGRectGetHeight(self.frame));
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (IBAction)buttonClicked:(id)sender {
    NSInteger index = [self.buttons indexOfObject:sender];
    if (index != NSNotFound) {
        [self.delegate swipeableCell:self didSelectButtonAtIndex:index];
    }
}

- (CGFloat)halfOfFirstButtonWidth {
    UIButton *firstButton = [self.buttons firstObject];
    return (CGRectGetWidth(firstButton.frame) / 2);
}

- (CGFloat)halfOfLastButtonXPosition {
    UIButton *lastButton = [self.buttons lastObject];
    CGFloat halfOfLastButton = CGRectGetWidth(lastButton.frame) / 2;
    return [self buttonTotalWidth] - halfOfLastButton;
}

- (CGFloat)buttonTotalWidth {
    CGFloat buttonWidth = 0;
    for (UIButton *button in self.buttons) {
        buttonWidth += CGRectGetWidth(button.frame);
    }
    return buttonWidth;
}

- (void)openCell:(BOOL)animated {
    [self configureButtonsIfNeeded];
    [self setConstraintsToShowAllButtons:animated notifyDelegateDidOpen:NO];
}

- (void)closeCell:(BOOL)animated {
    [self configureButtonsIfNeeded];
    [self resetConstraintContstantsToZero:animated notifyDelegateDidClose:NO];
}

- (void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate {
    if (notifyDelegate) {
        [self.delegate swipeableCellDidOpen:self];
    }
    
    CGFloat buttonTotalWidth = [self buttonTotalWidth];
    if (self.startingRightLayoutConstraintConstant == buttonTotalWidth && self.contentViewRightConstraint.constant == buttonTotalWidth) {
        return;
    }
    
    self.contentViewLeftConstraint.constant = -buttonTotalWidth;
    self.contentViewRightConstraint.constant = buttonTotalWidth;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
    }];
}

- (void)resetConstraintContstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)notifyDelegate {
    if (notifyDelegate) {
        [self.delegate swipeableCellDidClose:self];
    }
    if (self.startingRightLayoutConstraintConstant == 0 && self.contentViewRightConstraint.constant == 0) {
        return;
    }
    
    self.contentViewRightConstraint.constant = 0;
    self.contentViewLeftConstraint.constant = 0;
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
    }];
}

- (void)updateConstraintsIfNeeded:(BOOL)animated completion:(void (^)(BOOL finished))completion; {
    float duration = 0;
    if (animated) {
        duration = 0.4;
    }
    
    [UIView animateWithDuration:duration
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self layoutIfNeeded];
                     } completion:completion];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint velocity = [panGesture velocityInView:self.containerView];
        if (velocity.x > 0) {
            return YES;
        } else if (fabsf(velocity.x) > fabsf(velocity.y)) {
            return NO;
        }
    }
    
    return YES;
}

- (void)panThisCell:(UIPanGestureRecognizer *)recognizer {
    CGPoint currentPoint = [recognizer translationInView:self.containerView];
    BOOL movingHorizontally = fabsf(self.panStartPoint.y) < fabsf(self.panStartPoint.x);
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self configureButtonsIfNeeded];
            self.panStartPoint = currentPoint;
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
            break;
        case UIGestureRecognizerStateChanged: {
            if(movingHorizontally) {
                CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
                BOOL panningLeft = NO;
                if (currentPoint.x < self.panStartPoint.x) {
                    panningLeft = YES;
                }
                
                CGFloat adjustment = self.startingRightLayoutConstraintConstant - deltaX;
                if (panningLeft) {
                    CGFloat constant = MIN(adjustment, [self buttonTotalWidth]);
                    if (constant == [self buttonTotalWidth]) {
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                    } else {
                        self.contentViewRightConstraint.constant = constant;
                    }
                } else {
                    CGFloat constant = MAX(adjustment, 0);
                    if (constant == 0) {
                        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                    } else {
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
                
                self.contentViewLeftConstraint.constant = -self.contentViewRightConstraint.constant;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
            if(movingHorizontally) {
                if (self.startingRightLayoutConstraintConstant == 0) {
                    CGFloat halfWidth = [self halfOfFirstButtonWidth];
                    if (halfWidth != 0 && self.contentViewRightConstraint.constant >= halfWidth) {
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                    } else {
                        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                    }
                } else {
                    if (self.contentViewRightConstraint.constant >= [self halfOfLastButtonXPosition]) {
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                    } else {
                        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                    }
                }
            }
            break;
        case UIGestureRecognizerStateCancelled:
            if(movingHorizontally) {
                if (self.startingRightLayoutConstraintConstant == 0) {
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                } else {
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                }
            }
            break;
            
        default:
            break;
    }
}

@end
