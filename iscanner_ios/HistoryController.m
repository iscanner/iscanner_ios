//
//  HistoryController.m
//  iscanner_ios
//
//  Created by xdf on 12/16/14.
//  Copyright (c) 2014 xdf. All rights reserved.
//

#import "HistoryController.h"
#import "SwipeableCell.h"

@interface HistoryController () <SwipeableCellDelegate, SwipeableCellDataSource, UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) NSMutableArray *isEditing;
@property (strong) UIView *maskView;
@end

static NSString * const cellIdentifier = @"swipetablecell";

@implementation HistoryController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self readNSUserDefaults];
  [self initView];
}

- (void)initView {
  if (!self.list) return;
  [self.tableView registerClass:[SwipeableCell class] forCellReuseIdentifier:cellIdentifier];
  self.isEditing = [NSMutableArray array];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  return YES;
}

-(void)readNSUserDefaults {
  NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
  self.list = [userDefaultes objectForKey:@"list"];
  self.list = (NSMutableArray *)[[self.list reverseObjectEnumerator] allObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 60.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  long int count = [self.list count];
  for (int i = 0 ; i < count; i++) {
    if (section == i) {
      NSMutableDictionary *dictionary = [self.list objectAtIndex:i];
      NSArray *tempArray = [dictionary allKeys];
      NSString *tempKey = [tempArray objectAtIndex:0];
      NSMutableArray *array = [dictionary objectForKey:tempKey];
      return array.count;
    }
  }
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  SwipeableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
  long int count = [self.list count];
  for (int i = 0 ; i < count; i++) {
    if (indexPath.section == i) {
      NSMutableDictionary *dictionary = [self.list objectAtIndex:i];
      NSArray *tempArray = [dictionary allKeys];
      NSString *tempKey = [tempArray objectAtIndex:0];
      NSMutableArray *array = [dictionary objectForKey:tempKey];
      array = (NSMutableArray *)[[array reverseObjectEnumerator] allObjects];
      long int c = [array count];
      for (int j=0; j < c; j++) {
        if (indexPath.row == j) {
          cell.customLabel.text = [array objectAtIndex:j];
        }
      }
    }
  }
  cell.dataSource = self;
  cell.delegate = self;
  [cell setNeedsUpdateConstraints];
  if ([self.isEditing containsObject:indexPath]) {
    [cell openCell:NO];
  }
  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSURL *res = [self getListData: indexPath];
  [[UIApplication sharedApplication] openURL: res];
}

- (NSURL *)getListData:(NSIndexPath *)indexPath {
  NSMutableDictionary *dictionary = [self.list objectAtIndex:indexPath.section];
  NSArray *tempArray = [dictionary allKeys];
  NSString *tempKey = [tempArray objectAtIndex:0];
  NSMutableArray *array = [dictionary objectForKey:tempKey];
  array = (NSMutableArray *)[[array reverseObjectEnumerator] allObjects];
  return [NSURL URLWithString:[array objectAtIndex:indexPath.row]];
}

- (NSInteger)numberOfButtonsInSwipeableCell:(SwipeableCell *)cell {
  return 2;
}

- (NSString *)swipeableCell:(SwipeableCell *)cell titleForButtonAtIndex:(NSInteger)index {
  NSString *res;
  if (index ==0) {
    res = @"copy";
  } else {
    res = @"create";
  }
  return res;
}

- (UIImage *)swipeableCell:(SwipeableCell *)cell imageForButtonAtIndex:(NSInteger)index {
  return [UIImage imageNamed:@"user"];
}

- (UIColor *)swipeableCell:(SwipeableCell *)cell backgroundColorForButtonAtIndex:(NSInteger)index {
  UIColor *res;
  if (index ==0) {
    res = [UIColor grayColor];
  } else {
    res = [UIColor lightGrayColor];
  }
  return res;
}

- (UIColor *)swipeableCell:(SwipeableCell *)cell tintColorForButtonAtIndex:(NSInteger)index {
  return [UIColor whiteColor];
}

- (void)swipeableCell:(SwipeableCell *)cell didSelectButtonAtIndex:(NSInteger)index {
  if (index == 0) {
    [self copyToClipboard: cell.customLabel.text];
  } else {
    [self createQrcode: cell.customLabel.text];
  }
}

- (void)copyToClipboard:(NSString*)string {
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  pasteboard.string = string;
  UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"" message:@"Copy to clipboard" delegate:nil cancelButtonTitle:@"I got it" otherButtonTitles:nil];
  [alter show];
}

- (void)createQrcode:(NSString*)string {
  CGFloat width = 300;
  CGFloat height = 300;
  CGFloat infoWidth = 180;
  NSError *error = nil;
  ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
  ZXBitMatrix* result = [writer encode: string format: kBarcodeFormatQRCode width: width height: height error:&error];
  if (result) {
    self.navigationController.navigationBar.hidden = YES;
    CGImageRef image = [[ZXImage imageWithMatrix:result] cgimage];
    UIImage *subImag = [UIImage imageWithCGImage:image];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - width) / 2, (self.view.frame.size.height - height) / 2, width, height)];
    imageView.image = subImag;
    self.maskView = [[UIView alloc] initWithFrame: self.view.bounds];
    self.maskView.backgroundColor = [UIColor blackColor];
    [self.maskView addSubview: imageView];
    UILabel *tipInfo = [[UILabel alloc]initWithFrame: CGRectMake((self.view.frame.size.width - infoWidth) / 2, (self.view.frame.size.height - height) / 2 + height + 20, infoWidth, 30)];
    tipInfo.text = @"tap to close or screenshot";
    tipInfo.textColor = [UIColor whiteColor];
    tipInfo.font = [tipInfo.font fontWithSize:14];
    [self.maskView addSubview: tipInfo];
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapHandle:)];
    [self.maskView addGestureRecognizer:singleTap];
    singleTap.delegate = self;
    singleTap.cancelsTouchesInView = NO;
    [self.view addSubview: self.maskView];
  } else {
    NSString *errorMessage = [error localizedDescription];
    NSLog(@"%@", errorMessage);
  }
}

-(void)onTapHandle:(UITapGestureRecognizer *)sender{
  self.navigationController.navigationBar.hidden = NO;
  [self.maskView removeFromSuperview];
}

- (void)swipeableCellDidOpen:(SwipeableCell *)cell {
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:cell.center];
  [self.isEditing addObject:indexPath];
}

- (void)swipeableCellDidClose:(SwipeableCell *)cell {
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:cell.center];
  [self.isEditing removeObject:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  NSDictionary *d = [self.list objectAtIndex: section];
  NSArray *tempArray = [d allKeys];
  NSString *tempKey = [tempArray objectAtIndex:0];
  return tempKey;
}

@end