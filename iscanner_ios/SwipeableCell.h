//
//  SwipeableCell.h
//  iscanner_ios
//
//  Created by xdf on 1/10/15.
//  Copyright (c) 2015 xdf. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwipeableCell;

@protocol SwipeableCellDataSource <NSObject>

@required
- (NSInteger)numberOfButtonsInSwipeableCell:(SwipeableCell *)cell;
@optional
- (UIButton *)swipeableCell:(SwipeableCell *)cell buttonForIndex:(NSInteger)index;
- (NSString *)swipeableCell:(SwipeableCell *)cell titleForButtonAtIndex:(NSInteger)index;
- (UIColor *)swipeableCell:(SwipeableCell *)cell backgroundColorForButtonAtIndex:(NSInteger)index;
- (UIColor *)swipeableCell:(SwipeableCell *)cell tintColorForButtonAtIndex:(NSInteger)index;
- (UIImage *)swipeableCell:(SwipeableCell *)cell imageForButtonAtIndex:(NSInteger)index;
- (UIFont *)swipeableCell:(SwipeableCell *)cell fontForButtonAtIndex:(NSInteger)index;
@end

@protocol SwipeableCellDelegate <NSObject>
- (void)swipeableCell:(SwipeableCell *)cell didSelectButtonAtIndex:(NSInteger)index;
- (void)swipeableCellDidOpen:(SwipeableCell *)cell;
- (void)swipeableCellDidClose:(SwipeableCell *)cell;
@end

@interface SwipeableCell : UITableViewCell
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, weak) id <SwipeableCellDelegate> delegate;
@property (nonatomic, weak) id <SwipeableCellDataSource> dataSource;
@property (nonatomic, strong) UILabel *customLabel;
- (void)openCell:(BOOL)animated;
- (void)closeCell:(BOOL)animated;
@end
