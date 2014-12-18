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
  UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 220) / 2, 100, 220, 220)];
  imageView1.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"icon.png"]];
  imageView1.alpha = 0.1;
  imageView1.layer.masksToBounds = YES;
  [self.view addSubview:imageView1];
  UITextView *text1 = [[UITextView alloc] initWithFrame:CGRectMake(0, 400, self.view.frame.size.width, 100)];
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
