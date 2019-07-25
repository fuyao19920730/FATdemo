//
//  UnityMsgBridge.h
//  fotoabl_test
//
//  Created by fotoabl on 2018/7/17.
//  Copyright © 2018年 fotoabl. All rights reserved.
//

#import <Foundation/Foundation.h>

static const char * UNITY_DEVICE_CALLBACK = "DeviceInfoCallback";
static const char * UNITY_SENDMESSAGE_CALLBACK = "NativeMsgReceiver";

@interface UnityMsgBridge : NSObject

+ (instancetype)shared;
- (void)GetDeviceInfo;
@end
