//
//  AboutController.m
//  iscanner_ios
//
//  Created by xdf on 12/16/14.
//  Copyright (c) 2014 xdf. All rights reserved.
//

#import "AboutController.h"
#import "ViewController.h"

@interface AboutController ()

@end

@implementation AboutController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setAbout];
}

- (void)setAbout {
  UITextView *text1 = [[UITextView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height - 100)];
  text1.text = @"iScanner v1.0\nby xdf";
  text1.font = [UIFont systemFontOfSize: 20.0];
  text1.textAlignment = NSTextAlignmentCenter;
  text1.textColor = [UIColor grayColor];
  [self.view addSubview:text1];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
