//
//  HistoryController.m
//  iscanner_ios
//
//  Created by xdf on 12/16/14.
//  Copyright (c) 2014 xdf. All rights reserved.
//

#import "HistoryController.h"

@interface HistoryController ()

@end

@implementation HistoryController

NSMutableArray *list;

- (void)viewDidLoad {
  [super viewDidLoad];
  [self readNSUserDefaults];
  [self setTable];
}

-(void)readNSUserDefaults {
  NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
  list = [userDefaultes objectForKey:@"list"];
  list = (NSMutableArray *)[[list reverseObjectEnumerator] allObjects];
}

- (void)setTable {
  if (!list) return;
  UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
  tableView.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:tableView];
  tableView.delegate = self;
  tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  NSMutableDictionary *dictionary = [list objectAtIndex:indexPath.section];
  NSArray *tempArray = [dictionary allKeys];
  NSString *tempKey = [tempArray objectAtIndex:0];
  NSMutableArray *array = [dictionary objectForKey:tempKey];
  array = (NSMutableArray *)[[array reverseObjectEnumerator] allObjects];
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[array objectAtIndex:indexPath.row]]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  return list.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  long int count = [list count];
  for (int i = 0 ; i < count; i++) {
    if (section == i) {
      NSMutableDictionary *dictionary = [list objectAtIndex:i];
      NSArray *tempArray = [dictionary allKeys];
      NSString *tempKey = [tempArray objectAtIndex:0];
      NSMutableArray *array = [dictionary objectForKey:tempKey];
      return array.count;
    }
  }
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  UITableViewCell *cell = [[UITableViewCell alloc] init];
  long int count = [list count];
  for (int i = 0 ; i < count; i++) {
    if (indexPath.section == i) {
      NSMutableDictionary *dictionary = [list objectAtIndex:i];
      NSArray *tempArray = [dictionary allKeys];
      NSString *tempKey = [tempArray objectAtIndex:0];
      NSMutableArray *array = [dictionary objectForKey:tempKey];
      array = (NSMutableArray *)[[array reverseObjectEnumerator] allObjects];
      long int c = [array count];
      for (int j=0; j < c; j++) {
        if (indexPath.row == j) {
          cell.textLabel.text = [array objectAtIndex:j];
        }
      }
    }
  }
  return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  NSDictionary *d = [list objectAtIndex: section];
  NSArray *tempArray = [d allKeys];
  NSString *tempKey = [tempArray objectAtIndex:0];
  return tempKey;
}

@end
