//
//  SCScanner.m
//  SmartScanner
//
//  Created by Murvin Bhantooa (O581573) on 05/04/2014.
//  Copyright (c) 2014 Murvin Bhantooa. All rights reserved.
//

#import "SCScanner.h"
#import "SCScan.h"

@interface SCScanner ()<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureMetadataOutput *metaDataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, weak) AVCaptureConnection *captureConnection;
@property (nonatomic, copy) void (^completion)(SCScan *);
@property (nonatomic, readwrite) UIImage *sampleBufferImage;

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


            // Create a VideoDataOutput and add it to the session to capture screen snap shots
            AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
            [_session addOutput:videoDataOutput];
            [videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];

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

+ (NSArray *)allMetaDataObjectTypes
{
    return @[AVMetadataObjectTypeQRCode,
             AVMetadataObjectTypeAztecCode,
             AVMetadataObjectTypeCode128Code,
             AVMetadataObjectTypeCode39Code,
             AVMetadataObjectTypeCode39Mod43Code,
             AVMetadataObjectTypeEAN13Code,
             AVMetadataObjectTypeEAN8Code,
             AVMetadataObjectTypeEAN13Code,
             AVMetadataObjectTypePDF417Code,
             AVMetadataObjectTypeUPCECode,
             ];
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

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);

    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);

    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);

    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);

    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];

    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
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


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate Delegate Method

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{

    // Create a UIImage from the sample buffer data
    self.sampleBufferImage = [self imageFromSampleBuffer:sampleBuffer];
}

@end
