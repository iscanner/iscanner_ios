//
//  ViewController.m
//  iscanner_ios
//
//  Created by xdf on 12/16/14.
//  Copyright (c) 2014 xdf. All rights reserved.
//

#import "ViewController.h"
#import "AboutController.h"
#import "HistoryController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController ()
@end

@implementation ViewController

ZXCapture *capture;
BOOL startScan;
NSString *distUrl;

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setNavigationBar];
  [self setCopyRight];
  [self setCapture];
}

- (void)setCapture {
  capture = nil;
  capture = [[ZXCapture alloc] init];
  capture.camera = capture.back;
  capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
  capture.rotation = 90.0f;
  capture.layer.cornerRadius = 5.0f;
  CGRect frame = CGRectMake(20, 80, self.view.frame.size.width - 40, self.view.frame.size.width + 40);
  capture.layer.frame = frame;
  [self.view.layer addSublayer:capture.layer];
  [self setBackground];
  startScan = YES;
}

- (void)setBackground {
  UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(80, 100, 48, 48)];
  imageView1.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"qrcode.png"]];
  imageView1.layer.masksToBounds = YES;
  imageView1.layer.cornerRadius = 5.0f;
  [self.view addSubview:imageView1];
  UITextView *text1 = [[UITextView alloc] initWithFrame:CGRectMake(80, 140, 48, 30)];
  text1.text = @"qrcode";
  text1.backgroundColor = [UIColor clearColor];
  text1.alpha = 0.3;
  text1.textColor = [UIColor whiteColor];
  [self.view addSubview:text1];
  UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 120, 100, 48, 48)];
  imageView2.layer.masksToBounds = YES;
  imageView2.layer.cornerRadius = 5.0f;
  imageView2.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"barcode.png"]];
  [self.view addSubview:imageView2];
  UITextView *text2 = [[UITextView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 124, 140, 54, 30)];
  text2.text = @"barcode";
  text2.backgroundColor = [UIColor clearColor];
  text2.alpha = 0.3;
  text2.textColor = [UIColor whiteColor];
  [self.view addSubview:text2];
}
- (void)setNavigationBar {
  self.navigationItem.title = @"iScanner";
  UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"History" style:UIBarButtonItemStylePlain target:self action:@selector(gotoHistory)];
  self.navigationItem.rightBarButtonItems=@[rightButton];
}

- (void)setCopyRight {
  CGRect frame = CGRectMake((self.view.frame.size.width - 200) / 2, self.view.frame.size.height - 50, 200, 50);
  UIButton *copyrightBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  copyrightBtn.backgroundColor = [UIColor clearColor];
  [copyrightBtn setTitle:@"Copyright by xdf" forState:UIControlStateNormal];
  copyrightBtn.frame = frame;
  [copyrightBtn addTarget:self action:@selector(gotoAbout) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:copyrightBtn];
}

- (void)gotoHistory {
  HistoryController *historyView=[[HistoryController alloc]init];
  historyView.navigationItem.title = @"History";
  [self.navigationController pushViewController:historyView animated:YES];
}

- (void)gotoAbout {
  AboutController *aboutView = [[AboutController alloc] init];
  aboutView.navigationItem.title = @"About";
  [self.navigationController pushViewController:aboutView animated:YES];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  capture.delegate = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}


- (NSString *)barcodeFormatToString:(ZXBarcodeFormat)format {
  switch (format) {
    case kBarcodeFormatAztec:
      return @"Aztec";
    case kBarcodeFormatCodabar:
      return @"CODABAR";
    case kBarcodeFormatCode39:
      return @"Code 39";
    case kBarcodeFormatCode93:
      return @"Code 93";
    case kBarcodeFormatCode128:
      return @"Code 128";
    case kBarcodeFormatDataMatrix:
      return @"Data Matrix";
    case kBarcodeFormatEan8:
      return @"EAN-8";
    case kBarcodeFormatEan13:
      return @"EAN-13";
    case kBarcodeFormatITF:
      return @"ITF";
    case kBarcodeFormatPDF417:
      return @"PDF417";
    case kBarcodeFormatQRCode:
      return @"QR Code";
    case kBarcodeFormatRSS14:
      return @"RSS 14";
    case kBarcodeFormatRSSExpanded:
      return @"RSS Expanded";
    case kBarcodeFormatUPCA:
      return @"UPCA";
    case kBarcodeFormatUPCE:
      return @"UPCE";
    case kBarcodeFormatUPCEANExtension:
      return @"UPC/EAN extension";
    default:
      return @"Unknown";
  }
}


- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result {
  if (!self.view.window || !startScan || !result) return;
  
  NSString *formatString = [self barcodeFormatToString:result.barcodeFormat];
  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
  startScan = NO;
  distUrl = result.text;
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:formatString message:result.text delegate:self cancelButtonTitle:@"continue" otherButtonTitles:@"ok", nil];
  [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
  if (buttonIndex == 1) {
    [self saveNSUserDefaults];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:distUrl]];
  }
  startScan = YES;
}

- (void)saveNSUserDefaults {
  NSDateFormatter *dateFormtter=[[NSDateFormatter alloc] init];
  [dateFormtter setDateFormat:@"yyyy-MM-dd"];
  NSString *dateString=[dateFormtter stringFromDate:[NSDate date]];
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *list = [[userDefaults objectForKey:@"list"] mutableCopy];
  if (list) {
    NSLog(@"%@", list);
    NSMutableDictionary *dictionary = [list objectAtIndex:list.count - 1];
    NSArray *tempArray = [dictionary allKeys];
    NSString *tempKey = [tempArray objectAtIndex:0];
    if([tempKey isEqualToString:dateString]) {
      NSMutableArray *array = [[dictionary objectForKey:tempKey] mutableCopy];
      [array addObject:distUrl];
      NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];
      [newDictionary setObject:array forKey:dateString];
      [list replaceObjectAtIndex:2 withObject:newDictionary];
      NSLog(@"%@", list);
      [userDefaults setObject:list forKey:@"list"];
    } else {
      if (list.count == 3) {
        [list removeObjectAtIndex:0];
      }
      NSMutableArray *childlist = [[NSMutableArray alloc] init];
      [childlist addObject:distUrl];
      NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
      [dictionary setObject:childlist forKey:dateString];
      [list addObject:dictionary];
      [userDefaults setObject:list forKey:@"list"];
    }
  } else {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSMutableArray *childlist = [[NSMutableArray alloc] init];
    [childlist addObject:distUrl];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:childlist forKey:dateString];
    [list addObject:dictionary];
    [userDefaults setObject:list forKey:@"list"];
  }
}

@end
