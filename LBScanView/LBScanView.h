//
//  QRView.h
//  test
//
//  Created by 刘彬 on 16/7/25.
//  Copyright © 2016年 刘彬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBScanView : UIView
@property (nonatomic, strong, readonly) AVCaptureSession        *session;
@property (nonatomic, strong, readonly) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong, readonly) AVCaptureOutput         *photoOutput;

@property (nonatomic, strong, readwrite) CALayer *coverLayer;
@property (nonatomic, strong, readwrite) CAShapeLayer *scanBoxBorderLayer;
@property (nonatomic, strong, readwrite) CAShapeLayer *cornersLayer;
@property (nonatomic, strong, readwrite) CAGradientLayer *scanAnimationLayer;

@property (nonatomic, assign) BOOL getImageWhenScanFinished;//扫描成功后需要获取图片

@property (nonatomic, copy, nullable) void(^scanFinishedBlock)(NSString *_Nullable resultString,UIImage *_Nullable image);

- (instancetype)initWithFrame:(CGRect)frame scanBoxFrame:(CGRect)boxFrame failure:(void(^)(NSError *error))failure;

+ (NSString *_Nullable)scanQRImage:(UIImage *)image;

- (void)startScanCompletion:(void (^ __nullable)(void))completion;
- (void)stopScan;
@end
NS_ASSUME_NONNULL_END
