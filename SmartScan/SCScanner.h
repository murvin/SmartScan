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
@property (nonatomic, readonly) UIImage *sampleBufferImage;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (instancetype)initForMetaDataObjectType:(NSArray *)metaDataObjectTypeArray
                     interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                          completionBlock:(void (^)(SCScan *))completion;

+ (NSArray *)allMetaDataObjectTypes;

/**
 *  Will set the device's torch on/off.
 *
 *  @param lightningTorchOn YES when the torch should be on.
 */
- (void)setLightningTorchOn:(BOOL)lightningTorchOn;

/**
 *  Change focus mode from continuous center to the new designated point.
 *
 *  @param point A non translated coordinate point. The SCScanner will translate point in regards to the video preview bounds.
 */
- (void)focusOnPoint:(CGPoint) point;

/**
 *  Sets the video capture orientation to the AV corresponding one.
 *
 *  @param interfaceOrientation The UIInterfaceOrientation the device is rotating to.
 */
- (void)setDeviceCaptureOrientation:(UIInterfaceOrientation)interfaceOrientation;

- (void)startScan;

- (void)stopScan;

@end
