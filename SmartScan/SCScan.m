//
//  SCScan.m
//  SmartScan
//
//  Created by Murvin Bhantooa (O581573) on 09/04/2014.
//  Copyright (c) 2014 Murvin Bhantooa. All rights reserved.
//

#import "SCScan.h"

@implementation SCScan

- (instancetype)initWithMetaDataObject:(AVMetadataObject *)metaDataObject readableStringValue:(NSString *)stringValue
{
    NSParameterAssert(metaDataObject != nil);

    self = [super init];
    if (self)
    {
        _metaDataObject = [metaDataObject copy];
        _stringValue = [stringValue copy];
    }

    return self;
}

@end
