//
//  QImagePickerController.m
//  QunariPhone
//
//  Created by Zhuo on 14-1-17.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "QImagePickerController.h"

static QImagePickerController *shared = nil;

@implementation QImagePickerController

+ (QImagePickerController *)sharedPickerController {
	@synchronized(self)
	{
		if (shared == nil)
		{
			// allocate the shared instance, because it hasn't been done yet
			shared = [[self alloc] init];
		}
	}
	return shared;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (shared == nil) {
			shared = [super allocWithZone:zone];
			// assignment and return on first allocation
			return shared;
		}
	}
	// on subsequent allocation attempts return nil
	return nil;
}

@end
