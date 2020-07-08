# LBScanView
集成系统扫描，支持二维码和条形码，同时返回扫描成功图片；以及图片二维码扫描（目前苹果自带API不支持图片扫描条形码），界面完全自定义。
```objc
LBScanView *scanView = [[LBScanView alloc] initWithFrame:self.view.bounds scanBoxFrame:CGRectMake((CGRectGetWidth(self.view.frame)-250)/2, (CGRectGetHeight(self.view.frame)-250)/2, 250, 250) failure:^(NSError * _Nonnull error) {
        NSLog(@"%@",error.localizedDescription);
    }];
//scanView.coverLayer = ;
//scanView.scanBoxBorderLayer = ;
//scanView.scanAnimationLayer = ;
[self.view addSubview:scanView];
```

![](https://github.com/A1129434577/LBScanView/blob/master/LBScanView.jpeg?raw=true)
