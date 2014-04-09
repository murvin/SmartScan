//
//  SCScanner.h
//  SmartScanner
//
//  Created by Murvin Bhantooa (O581573) on 05/04/2014.
//  Copyright (c) 2014 Murvin Bhantooa. All rights reserved.
//

@import Foundation;
@import AVFoundation;

@class SCScan;

@interface SCScanner : NSObject

@property (nonatomic, readonly, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, assign, getter = isLightningTorchOn) BOOL lightningTorchOn;
@property (nonatomic, readonly, getter = isDeviceCameraAvailable) BOOL deviceCameraAvailable;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (instancetype)initForMetaDataObjectType:(NSArray *)metaDataObjectTypeArray
                 captureDeviceOrientation:(AVCaptureVideoOrientation)captureOrientation
                          completionBlock:(void (^)(SCScan *))completion;

- (void)startScan;

- (void)stopScan;

- (void)setDeviceCaptureOrientation:(AVCaptureVideoOrientation)captureOrientation;

@end
