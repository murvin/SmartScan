//
//  SCScanner.m
//  SmartScanner
//
//  Created by Murvin Bhantooa (O581573) on 05/04/2014.
//  Copyright (c) 2014 Murvin Bhantooa. All rights reserved.
//

#import "SCScanner.h"
#import "SCScan.h"

@interface SCScanner ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureMetadataOutput *metaDataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, weak) AVCaptureConnection *captureConnection;
@property (nonatomic, copy) void (^completion)(SCScan *);

@end

@implementation SCScanner

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
        if (error)
        {
            return nil;
        }
        else
        {
            _session = [AVCaptureSession new];
            _metaDataOutput = [AVCaptureMetadataOutput new];
            [_session addOutput:_metaDataOutput];
            [_session addInput:_deviceInput];
            [_metaDataOutput setMetadataObjectsDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];

            // Continuously auto focus on screen center;
            [self applyFocusMode:AVCaptureFocusModeContinuousAutoFocus withPoint:CGPointMake(0.5f, 0.5f)];
        }
    }
    return self;
}

- (instancetype)initForMetaDataObjectType:(NSArray *)metaDataObjectTypeArray
                     interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                          completionBlock:(void (^)(SCScan *))completion
{
    NSParameterAssert([metaDataObjectTypeArray count]);
    NSParameterAssert(completion);

    self = [self init];
    if (self)
    {
        _completion = completion;
        [self initVideoPreviewLayerForMetaDataObjectType:metaDataObjectTypeArray
                                captureDeviceOrientation:[self avCaptureVideoDeviceOrientationForInterfaceOrientation:interfaceOrientation]];
    }
    return self;
}

- (void)setLightningTorchOn:(BOOL)lightningTorchOn
{
    if ([_device lockForConfiguration:nil])
    {
        AVCaptureTorchMode torchMode = lightningTorchOn ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
        if ([_device hasTorch] && [_device isTorchModeSupported:torchMode])
        {
            [_device setTorchMode:torchMode];
        }

        [_device unlockForConfiguration];
    }
}

- (void)focusOnPoint:(CGPoint)point
{
    CGRect videoPreviewLayerBounds = _videoPreviewLayer.bounds;
    CGFloat translatedX = point.x / CGRectGetWidth(videoPreviewLayerBounds);
    CGFloat translatedY = point.y / CGRectGetHeight(videoPreviewLayerBounds);
    CGPoint translatedPoint = CGPointMake(translatedX, translatedY);

    [self applyFocusMode:AVCaptureFocusModeContinuousAutoFocus withPoint:translatedPoint];
}

- (void)setDeviceCaptureOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([_captureConnection isVideoOrientationSupported])
    {
        AVCaptureVideoOrientation avCaptureVideoOrientation = [self avCaptureVideoDeviceOrientationForInterfaceOrientation:interfaceOrientation];
        [_captureConnection setVideoOrientation:avCaptureVideoOrientation];
    }
}

- (BOOL)isDeviceCameraAvailable
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (void)startScan
{
    if (![_session isRunning])
    {
        [_session startRunning];
    }
}

- (void)stopScan
{
    if ([_session isRunning])
    {
        [_session stopRunning];
    }
}

#pragma mark - Private Helper Methods

- (AVCaptureVideoOrientation)avCaptureVideoDeviceOrientationForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
        case UIInterfaceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
    }
}

- (void)initVideoPreviewLayerForMetaDataObjectType:(NSArray *)metaDataObjectTypeArray
                          captureDeviceOrientation:(AVCaptureVideoOrientation)captureOrientation
{
    _metaDataOutput.metadataObjectTypes = metaDataObjectTypeArray;
    _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    _captureConnection = [_videoPreviewLayer connection];
    [_captureConnection setVideoOrientation:captureOrientation];

}

- (void)applyFocusMode:(AVCaptureFocusMode)focusMode withPoint:(CGPoint)point
{
    if ([_device isFocusModeSupported:focusMode] && [_device lockForConfiguration:nil])
    {
        [_device setFocusMode:focusMode];
        if ([_device isFocusPointOfInterestSupported])
        {
            [_device setFocusPointOfInterest:point];
        }
        [_device unlockForConfiguration];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate Delegate Method

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *current in metadataObjects)
    {
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]])
        {
            _completion([[SCScan alloc] initWithMetaDataObject:current readableStringValue:[((AVMetadataMachineReadableCodeObject *)current)stringValue]]);
        }
    }
}

@end
