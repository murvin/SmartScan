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
        }
    }
    return self;
}

- (instancetype)initForMetaDataObjectType:(NSArray *)metaDataObjectTypeArray
                 captureDeviceOrientation:(AVCaptureVideoOrientation)captureOrientation
                          completionBlock:(void (^)(SCScan *))completion
{
    NSParameterAssert([metaDataObjectTypeArray count]);
    NSParameterAssert(completion);

    self = [self init];
    if (self)
    {
        _completion = completion;
        [self initVideoPreviewLayerForMetaDataObjectType:metaDataObjectTypeArray
                                captureDeviceOrientation:captureOrientation];
    }
    return self;
}

- (void)setLightningTorchOn:(BOOL)lightningTorchOn
{
    if ([_device lockForConfiguration:nil])
    {

        if ([_device hasTorch])
        {
            [_device setTorchMode:lightningTorchOn ? AVCaptureTorchModeOn: AVCaptureTorchModeOff];
        }

        [_device unlockForConfiguration];
    }
}

- (BOOL)isDeviceCameraAvailable
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (void)startScan
{
    [_session startRunning];
}

- (void)stopScan
{
    if ([_session isRunning])
    {
        [_session stopRunning];
    }
}

- (void)setDeviceCaptureOrientation:(AVCaptureVideoOrientation)captureOrientation
{
    [_captureConnection setVideoOrientation:captureOrientation];
}

#pragma mark - Private Helper Methods

- (void)initVideoPreviewLayerForMetaDataObjectType:(NSArray *)metaDataObjectTypeArray
                          captureDeviceOrientation:(AVCaptureVideoOrientation)captureOrientation
{
    _metaDataOutput.metadataObjectTypes = metaDataObjectTypeArray;
    _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    _captureConnection = [_videoPreviewLayer connection];
    [_captureConnection setVideoOrientation:captureOrientation];

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
