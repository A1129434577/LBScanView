//
//  QRView.m
//  test
//
//  Created by 刘彬 on 16/7/25.
//  Copyright © 2016年 刘彬. All rights reserved.
//

#import "LBScanView.h"

@interface LBScanView ()<AVCaptureMetadataOutputObjectsDelegate,AVCapturePhotoCaptureDelegate>
@property (nonatomic, strong) NSString *scanResultString;
@end


@implementation LBScanView
- (instancetype)initWithFrame:(CGRect)frame scanBoxFrame:(CGRect)boxFrame failure:(void(^)(NSError *))failure
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        // 实例化拍摄设备
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        // 添加拍摄会话
        // 实例化拍摄会话
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetHigh;
        
        // 设置输入设备
        NSError *inputError = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&inputError];
        
        if (inputError) {
            failure?
            failure(inputError):NULL;
        }else{
            // 添加会话输入
            if ([_session canAddInput:input]) {
                [_session addInput:input];
            }
            
            // 设置元数据输出
            // 实例化拍摄元数据输出
            _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
            //设置扫描区域
            //output.rectOfInterest = ;
            // 设置输出数据代理
            [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
            
            // 添加会话输出
            if ([_session canAddOutput:_metadataOutput]) {
                [_session addOutput:_metadataOutput];
                
                // 设置输出数据类型，需要将元数据输出添加到会话后，才能指定元数据类型，否则会报错
                [_metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeEAN13Code,
                                                          AVMetadataObjectTypeEAN8Code,
                                                          AVMetadataObjectTypeUPCECode,
                                                          AVMetadataObjectTypeCode39Code,
                                                          AVMetadataObjectTypeCode39Mod43Code,
                                                          AVMetadataObjectTypeCode93Code,
                                                          AVMetadataObjectTypeCode128Code,
                                                          AVMetadataObjectTypePDF417Code,
                                                          AVMetadataObjectTypeQRCode]];
            }
        }
        
        
        // 视频预览图层
        // 实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
        AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        preview.frame = self.bounds;
        // 将图层插入当前视图
        [self.layer addSublayer:preview];
        
        
        //绘制图层*******************************************
        {
            if (self.scanBoxBorderLayer == nil) {
                CAShapeLayer *scanBoxBorderLayer = [[CAShapeLayer alloc] init];
                scanBoxBorderLayer.frame = boxFrame;
                scanBoxBorderLayer.lineWidth = 2;
                scanBoxBorderLayer.fillColor = [UIColor clearColor].CGColor;
                scanBoxBorderLayer.strokeColor = self.tintColor.CGColor;
                
                CGRect borderPathRect = CGRectMake(scanBoxBorderLayer.lineWidth/2, scanBoxBorderLayer.lineWidth/2, CGRectGetWidth(boxFrame)-scanBoxBorderLayer.lineWidth, CGRectGetHeight(boxFrame)-scanBoxBorderLayer.lineWidth);
                UIBezierPath *scanBoxBorderLayerPath = [UIBezierPath bezierPathWithRect:borderPathRect];
                scanBoxBorderLayer.path = scanBoxBorderLayerPath.CGPath;
                
                
                CAShapeLayer *cornersLayer = [[CAShapeLayer alloc] init];
                cornersLayer.frame = scanBoxBorderLayer.bounds;
                cornersLayer.lineWidth = scanBoxBorderLayer.lineWidth*2;
                cornersLayer.fillColor = scanBoxBorderLayer.fillColor;
                cornersLayer.strokeColor = scanBoxBorderLayer.strokeColor;
                
                CGRect cornersPathRect = CGRectMake(cornersLayer.lineWidth/2, cornersLayer.lineWidth/2, CGRectGetWidth(boxFrame)-cornersLayer.lineWidth, CGRectGetHeight(boxFrame)-cornersLayer.lineWidth);
                
                UIBezierPath *cornersPath = [UIBezierPath bezierPath];
                [cornersPath moveToPoint:CGPointMake(CGRectGetMinX(cornersPathRect), CGRectGetMinY(cornersPathRect)+25)];
                [cornersPath addLineToPoint:CGPointMake(CGRectGetMinX(cornersPathRect), CGRectGetMinY(cornersPathRect))];
                [cornersPath addLineToPoint:CGPointMake(CGRectGetMinX(cornersPathRect)+25, CGRectGetMinY(cornersPathRect))];
                
                [cornersPath moveToPoint:CGPointMake(CGRectGetMaxX(cornersPathRect)-25, CGRectGetMinY(cornersPathRect))];
                [cornersPath addLineToPoint:CGPointMake(CGRectGetMaxX(cornersPathRect), CGRectGetMinY(cornersPathRect))];
                [cornersPath addLineToPoint:CGPointMake(CGRectGetMaxX(cornersPathRect), CGRectGetMinY(cornersPathRect)+25)];
                
                [cornersPath moveToPoint:CGPointMake(CGRectGetMaxX(cornersPathRect), CGRectGetMaxY(cornersPathRect)-25)];
                [cornersPath addLineToPoint:CGPointMake(CGRectGetMaxX(cornersPathRect), CGRectGetMaxY(cornersPathRect))];
                [cornersPath addLineToPoint:CGPointMake(CGRectGetMaxX(cornersPathRect)-25, CGRectGetMaxY(cornersPathRect))];
                
                [cornersPath moveToPoint:CGPointMake(CGRectGetMinX(cornersPathRect)+25, CGRectGetMaxY(cornersPathRect))];
                [cornersPath addLineToPoint:CGPointMake(CGRectGetMinX(cornersPathRect), CGRectGetMaxY(cornersPathRect))];
                [cornersPath addLineToPoint:CGPointMake(CGRectGetMinX(cornersPathRect), CGRectGetMaxY(cornersPathRect)-25)];
                cornersLayer.path = cornersPath.CGPath;
                
                [scanBoxBorderLayer addSublayer:cornersLayer];
                self.scanBoxBorderLayer = scanBoxBorderLayer;
            }
            [self.layer addSublayer:self.scanBoxBorderLayer];
            
            
            if (self.coverLayer == nil) {
                UIBezierPath *boxPath = [UIBezierPath bezierPathWithRect:self.bounds];
                [boxPath appendPath:[[UIBezierPath bezierPathWithRect:boxFrame] bezierPathByReversingPath]];
                CAShapeLayer *shapeLayer = [CAShapeLayer layer];
                shapeLayer.path = boxPath.CGPath;
                
                CALayer *coverLayer = [[CALayer alloc] init];
                coverLayer.frame = self.bounds;
                coverLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
                coverLayer.mask = shapeLayer;
                self.coverLayer = coverLayer;
            }
            [self.layer addSublayer:self.coverLayer];
            
            if (self.scanAnimationLayer == nil) {
                CAGradientLayer *scanAnimationLayer = [CAGradientLayer new];
                scanAnimationLayer.frame = CGRectMake(CGRectGetMinX(boxFrame), CGRectGetMinY(boxFrame), CGRectGetWidth(boxFrame), 3);
                scanAnimationLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,(__bridge id)self.tintColor.CGColor,(__bridge id)self.tintColor.CGColor,(__bridge id)[UIColor clearColor].CGColor];
                scanAnimationLayer.startPoint = CGPointMake(0, 1);
                scanAnimationLayer.endPoint = CGPointMake(1, 1);
                self.scanAnimationLayer = scanAnimationLayer;
            }
            [self.layer addSublayer:self.scanAnimationLayer];
            
            CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];//变化模式
            basicAnimation.fromValue = [NSNumber numberWithFloat:0];//开始
            basicAnimation.toValue = [NSNumber numberWithFloat:CGRectGetHeight(boxFrame)];//结束
            basicAnimation.duration = 1.5;//变化时间
            basicAnimation.autoreverses = YES;
            basicAnimation.repeatCount = NSUIntegerMax;//重复次数
            basicAnimation.removedOnCompletion = NO;
            [self.scanAnimationLayer addAnimation:basicAnimation forKey:@"labelAnimateLayer"];//可以通过KEY去找它究竟是它哪一个动画
        }
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    
    __weak typeof(self) weakSelf = self;
    if (self.session.isRunning == NO) {
        dispatch_queue_t queue = dispatch_queue_create("LBScanViewQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_async(queue, ^{
            // 启动会话
            [weakSelf.session startRunning];
        });
    }
}

-(void)setGetImageWhenScanFinished:(BOOL)getImageWhenScanFinished{
    _getImageWhenScanFinished = getImageWhenScanFinished;
    if (getImageWhenScanFinished) {
        //添加拍照留底的输出
        if (@available(iOS 10,*)) {
            _photoOutput = [[AVCapturePhotoOutput alloc] init];
        }else{
            _photoOutput = [[AVCaptureStillImageOutput alloc] init];
            ((AVCaptureStillImageOutput *)_photoOutput).outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
        }
        if ([_session canAddOutput:_photoOutput]){
            [_session addOutput:_photoOutput];
        }
    }else{
        if ([_session.outputs containsObject:_photoOutput]) {
            [_session removeOutput:_photoOutput];
            _photoOutput = nil;
        }
    }
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    
    
    //取出二维码/条形码信息
    AVMetadataMachineReadableCodeObject *object = [metadataObjects firstObject];
    if ([object isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
        _scanResultString = object.stringValue;
    }
    
    __weak typeof(self) weakSelf = self;
    
    if (_getImageWhenScanFinished == NO) {
        [_session stopRunning];
        
        _scanFinishedBlock?
        _scanFinishedBlock(weakSelf.scanResultString,nil):NULL;
    }else{
        [_session removeOutput:_metadataOutput];//因为还有可能要拍照，session不能及时stop，所以只能暂时移出以使其不重复扫描
        
        if (@available(iOS 10,*)) {
            [(AVCapturePhotoOutput *)_photoOutput capturePhotoWithSettings:[AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey:AVVideoCodecJPEG}] delegate:self];
        }else{
            AVCaptureStillImageOutput *imageOutput = (AVCaptureStillImageOutput *)_photoOutput;
            
            AVCaptureConnection * videoConnection = [imageOutput connectionWithMediaType:AVMediaTypeVideo];
            if (!videoConnection) {
                _scanFinishedBlock?
                _scanFinishedBlock(weakSelf.scanResultString,nil):NULL;
                
                [_session stopRunning];
                return;
            }
            [imageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                UIImage *image = nil;
                if (imageDataSampleBuffer != NULL) {
                    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                    image = [UIImage imageWithData:imageData];
                }
                weakSelf.scanFinishedBlock?
                weakSelf.scanFinishedBlock(weakSelf.scanResultString,image):NULL;
                
                [weakSelf.session stopRunning];
            }];
        }
        
    }
}

#pragma mark AVCapturePhotoCaptureDelegate

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error API_AVAILABLE(ios(11.0)){
    UIImage *image = [UIImage imageWithData:photo.fileDataRepresentation];
    __weak typeof(self) weakSelf = self;
    self.scanFinishedBlock?
    self.scanFinishedBlock(weakSelf.scanResultString,image):NULL;
    [self.session stopRunning];
}
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error API_AVAILABLE(ios(10.0)) {
    UIImage *image = nil;
    if (photoSampleBuffer != NULL) {
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:photoSampleBuffer];
        image = [UIImage imageWithData:imageData];
    }
    
    __weak typeof(self) weakSelf = self;
    self.scanFinishedBlock?
    self.scanFinishedBlock(weakSelf.scanResultString,image):NULL;
    [self.session stopRunning];
}
#pragma mark private
- (void)startScanCompletion:(void (^ __nullable)(void))completion {
    _scanResultString = nil;
    if ([self.session canAddOutput:self.metadataOutput]) {
        [self.session addOutput:self.metadataOutput];
    }
    
    if (self.session.isRunning == NO) {
        dispatch_queue_t queue = dispatch_queue_create("LBScanViewQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(queue, ^{
            // 6. 启动会话
            [self.session startRunning];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion?
                completion():NULL;
            });
        });
    }else{
        completion?
        completion():NULL;
    }
    
}
-(void)stopScan{
    if (self.session.isRunning == YES) {
        [self.session startRunning];
    }
}
+(NSString *)scanQRImage:(UIImage *)image{
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:nil];
    NSArray<CIFeature *> *metadataObjects = [detector featuresInImage:[CIImage imageWithCGImage:[image CGImage]]];
    
    CIQRCodeFeature *object = (CIQRCodeFeature *)[metadataObjects firstObject];
    
    if ([object isKindOfClass:[CIQRCodeFeature class]]){
        return object.messageString;
    }
    return nil;
}
-(void)running{};


-(void)applicationDidBecomeActiveNotification{
    if (self.session.isRunning == NO) {
        [self startScanCompletion:nil];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

