//
//  SCScan.h
//  SmartScan
//
//  Created by Murvin Bhantooa (O581573) on 09/04/2014.
//  Copyright (c) 2014 Murvin Bhantooa. All rights reserved.
//

@import Foundation;
@import AVFoundation;

@interface SCScan : NSObject

/**
 *  A concrete implementation of this class is returned in a scan.
 */
@property(nonatomic, readonly) AVMetadataObject *metaDataObject;

/**
 *  Returns the receiver’s errorCorrectedData decoded into a human-readable string.
 *  The value of this property is an NSString created by decoding the binary payload according to the format of the machine
 *  readable code.  Returns nil if a string representation cannot be created from the payload.
 */
@property(nonatomic, readonly, copy) NSString *stringValue;

- (instancetype)initWithMetaDataObject:(AVMetadataObject *)metaDataObject readableStringValue:(NSString *)stringValue;


/**
 *  Transforms meta data object's coordinates to screen coordinates of the preview layer.
 *
 *  @param videoPreviewLayer The running video preview layer
 *
 *  @return A CGRect representing the frame of the found meta data item.
 */
- (CGRect)transformedBoundsForPreviewLayer:(AVCaptureVideoPreviewLayer *)videoPreviewLayer;

- (NSDate*)captureDate;
@end
