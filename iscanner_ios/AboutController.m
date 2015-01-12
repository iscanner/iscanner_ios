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
  [self initView];
}

- (void)initView {
  NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  UIImageView *iconIimageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 220) / 2, 100, 220, 220)];
  iconIimageView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"icon.png"]];
  iconIimageView.alpha = 0.1;
  iconIimageView.layer.masksToBounds = YES;
  [self.view addSubview: iconIimageView];
  UITextView *versionView = [[UITextView alloc] initWithFrame:CGRectMake(0, 400, self.view.frame.size.width, 100)];
  versionView.backgroundColor = [UIColor clearColor];
  versionView.text = [NSString stringWithFormat:@"%@%@%@",@"iScanner v", versionString, @"\nby xdf"];
  versionView.font = [UIFont systemFontOfSize: 20.0];
  versionView.textAlignment = NSTextAlignmentCenter;
  versionView.textColor = [UIColor grayColor];
  [self.view addSubview: versionView];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
