//
//  AboutController.m
//  iscanner_ios
//
//  Created by xdf on 12/16/14.
//  Copyright (c) 2014 xdf. All rights reserved.
//

#import "AboutController.h"
#import "ViewController.h"
#import "UIView+Toast.h"

@interface AboutController ()
@property (strong) NSString *versionString;
@property (strong) UIImageView *iconIimageView;
@property (strong) UITextView *versionView;
@property (strong) UIButton *updateView;
@property (strong, nonatomic) NSString *API;
@end

@implementation AboutController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.API = @"http://iscanner.github.io/api/latest.json";
  [self initView];
}

- (void)initView {
  NSInteger updateViewHeight = 50;
  self.versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  self.iconIimageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 220) / 2, 100, 220, 220)];
  self.iconIimageView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"icon.png"]];
  self.iconIimageView.alpha = 0.1;
  self.iconIimageView.layer.masksToBounds = YES;
  [self.view addSubview: self.iconIimageView];
  self.versionView = [[UITextView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - updateViewHeight - 20, self.view.frame.size.width, 100)];
  self.versionView.backgroundColor = [UIColor clearColor];
  self.versionView.text = [NSString stringWithFormat:@"%@%@",@"iScanner v", self.versionString];
  self.versionView.font = [UIFont systemFontOfSize: 20.0];
  self.versionView.textAlignment = NSTextAlignmentCenter;
  self.versionView.textColor = [UIColor grayColor];
  [self.view addSubview: self.versionView];
  self.updateView = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - updateViewHeight, self.view.frame.size.width, updateViewHeight)];
  self.updateView.backgroundColor = [UIColor clearColor];
  [self.updateView setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
  [self.updateView setTitle:@"update?" forState:UIControlStateNormal];
  [self.updateView addTarget:self action:@selector(checkForUpdate) forControlEvents:UIControlEventTouchDown];
  [self.view addSubview: self.updateView];
}

- (void)checkForUpdate {
  NSError *error;
  NSURL *url = [NSURL URLWithString: self.API];
  NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
  NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
  NSDictionary *djson = [json objectForKey:@"ios"];
  NSString *latestVersion = [djson objectForKey: @"version"];
  NSString *latestVersionStr = [@"update iscanner to version " stringByAppendingString: latestVersion];
  if ([latestVersion compare:self.versionString options:NSNumericSearch] == NSOrderedDescending) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message: latestVersionStr delegate:self cancelButtonTitle:@"next time" otherButtonTitles:@"update", nil];
    [alert show];
  } else {
    [self.view makeToast: @"iscanner is up to date"
                duration: 1.0
                position: CSToastPositionCenter];
  }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
  if (buttonIndex == 1) {
    NSURL *url=[NSURL URLWithString:@"http://iscanner.github.io"];
    [[UIApplication sharedApplication] openURL: url];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
