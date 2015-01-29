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
@property (nonatomic, strong) ZXCapture *capture;
@property (nonatomic) BOOL startScan;
@property (nonatomic, strong) NSString *distUrl;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self initView];
}

- (void)initView {
  [self setNavigationBar];
  [self setCopyRight];
  [self setCapture];
}

- (void)setCapture {
  self.capture = nil;
  self.capture = [[ZXCapture alloc] init];
  self.capture.camera = self.capture.back;
  self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
  self.capture.rotation = 90.0f;
  self.capture.layer.cornerRadius = 5.0f;
  CGRect frame = CGRectMake(20, 80, self.view.frame.size.width - 40, self.view.frame.size.width + 40);
  self.capture.layer.frame = frame;
  [self.view.layer addSublayer: self.capture.layer];
  [self setBackground];
  self.startScan = YES;
}

- (void)setBackground {
  float length = 20.0;
  float width = 80.0;
  float total = length + width;
  UIImageView *canvasView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - total) / 2, (self.view.frame.size.width - total) / 2 + 100, total, total)];
  [self.view addSubview:canvasView];
  UIGraphicsBeginImageContext(canvasView.frame.size);
  [canvasView.image drawInRect:CGRectMake(0, 0, canvasView.frame.size.width, canvasView.frame.size.height)];
  CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
  CGContextRef line = UIGraphicsGetCurrentContext();
  CGContextSetStrokeColorWithColor(line, [UIColor blackColor].CGColor);
  CGContextSetAlpha(line, 0.5);
  
  CGContextMoveToPoint(line, 0.0, 0.0);
  CGContextAddLineToPoint(line, length, 0.0);
  CGContextMoveToPoint(line, 0.0, 0.0);
  CGContextAddLineToPoint(line, 0.0, length);
  
  CGContextMoveToPoint(line, width, 0.0);
  CGContextAddLineToPoint(line, total, 0.0);
  CGContextMoveToPoint(line, total, 0.0);
  CGContextAddLineToPoint(line, total, length);
  
  CGContextMoveToPoint(line, 0.0, total);
  CGContextAddLineToPoint(line, length, total);
  CGContextMoveToPoint(line, 0.0, width);
  CGContextAddLineToPoint(line, 0.0, total);
  
  CGContextMoveToPoint(line, width, total);
  CGContextAddLineToPoint(line, total, total);
  CGContextMoveToPoint(line, total, width);
  CGContextAddLineToPoint(line, total, total);
  
  CGContextStrokePath(line);
  CGContextSetStrokeColorWithColor(line, [UIColor redColor].CGColor);
  CGContextSetAlpha(line, 0.5);
  CGContextMoveToPoint(line, 0.0, total / 2);
  CGContextAddLineToPoint(line, total, total / 2);
  
  CGContextStrokePath(line);
  canvasView.image = UIGraphicsGetImageFromCurrentImageContext();
}

- (void)setNavigationBar {
  self.navigationItem.title = @"EasyScanner";
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
  self.capture.delegate = self;
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
  if (!self.view.window || !self.startScan || !result) return;
  
  NSString *formatString = [self barcodeFormatToString:result.barcodeFormat];
  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
  self.startScan = NO;
  self.distUrl = result.text;
  self.distUrl = [self.distUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:formatString message: self.distUrl delegate:self cancelButtonTitle:@"continue" otherButtonTitles:@"ok", nil];
  [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
  if (buttonIndex == 1) {
    [self saveNSUserDefaults];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.distUrl]];
  }
  self.startScan = YES;
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
      [array addObject: self.distUrl];
      NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];
      [newDictionary setObject:array forKey:dateString];
      [list replaceObjectAtIndex:list.count - 1 withObject:newDictionary];
      NSLog(@"%@", list);
      [userDefaults setObject:list forKey:@"list"];
    } else {
      if (list.count == 3) {
        [list removeObjectAtIndex:0];
      }
      NSMutableArray *childlist = [[NSMutableArray alloc] init];
      [childlist addObject: self.distUrl];
      NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
      [dictionary setObject:childlist forKey:dateString];
      [list addObject:dictionary];
      [userDefaults setObject:list forKey:@"list"];
    }
  } else {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSMutableArray *childlist = [[NSMutableArray alloc] init];
    [childlist addObject: self.distUrl];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:childlist forKey:dateString];
    [list addObject:dictionary];
    [userDefaults setObject:list forKey:@"list"];
  }
}

@end
