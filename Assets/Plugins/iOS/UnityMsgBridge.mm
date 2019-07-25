//
//  UnityMsgBridge.m
//  fotoabl_test
//
//  Created by fotoabl on 2018/7/17.
//  Copyright © 2018年 fotoabl. All rights reserved.
//

#import "UnityMsgBridge.h"

//固定代码
#if defined(__cplusplus)
extern "C"{
#endif
        extern void UnitySendMessage(const char *, const char *, const char *);
        extern NSString* _CreateNSString (const char* string);
#if defined(__cplusplus)
}
#endif


#if defined(__cplusplus)
extern "C"{
#endif
    
    
    //供u3d调用的c函数 ( 因测试的sdk调用初始化为不传参方法，如果调用的sdk需要传参调用，此处应相应修改为含参数方法)    SDK初始化
    // 获取设备信息
    void GetDeviceAllInfo(){
        NSLog(@"拿设备信息");
        [[UnityMsgBridge shared] GetDeviceInfo];
    }
    
    
#if defined(__cplusplus)
}
#endif


#import "DeviceInfo.h"


@implementation UnityMsgBridge


+ (instancetype)shared {
    static UnityMsgBridge *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)GetDeviceInfo {
    
    NSDictionary *deviceInfo = @{
                                 @"appname":[DeviceInfo getAppName],
                                 @"packagename":[DeviceInfo getAppBundle],
                                 @"appver":[DeviceInfo getAppVersion],
                                 @"userid":[DeviceInfo getAId],//idfa 没有取到就传idfv
                                 @"idfv":[DeviceInfo getidfv],
                                 @"devicecountry":[DeviceInfo getDeviceCountry],
                                 @"carriername":[DeviceInfo getcarrierName],
                                 @"syslanguage":[DeviceInfo getDeviceLanguage],
                                 @"sysver":[DeviceInfo systemVersion],
                                 @"devicemodel":[DeviceInfo deviceModel],
                                 @"timezone":[NSTimeZone localTimeZone].name
                                 };
    
    UnitySendMessage(UNITY_SENDMESSAGE_CALLBACK, UNITY_DEVICE_CALLBACK,  [[self getJsonStringFromDictionary:deviceInfo] UTF8String]);
}


- (NSString *) getJsonStringFromDictionary:(NSDictionary *)dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (jsonData && error == nil) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}







@end
