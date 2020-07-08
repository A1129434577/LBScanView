//
//  ViewController.m
//  LBScanViewExample
//
//  Created by 刘彬 on 2020/7/8.
//  Copyright © 2020 刘彬. All rights reserved.
//

#import "ViewController.h"
#import "LBScanView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    LBScanView *scanView = [[LBScanView alloc] initWithFrame:self.view.bounds scanBoxFrame:CGRectMake((CGRectGetWidth(self.view.frame)-250)/2, (CGRectGetHeight(self.view.frame)-250)/2, 250, 250) failure:^(NSError * _Nonnull error) {
        NSLog(@"%@",error.localizedDescription);
    }];
//    scanView.coverLayer = ;
//    scanView.scanBoxBorderLayer = ;
//    scanView.scanAnimationLayer = ;
    [self.view addSubview:scanView];
}


@end
