//
//  DeviceInfo.h
//  Unity-iPhone
//
//  Created by 傅瑶fotoable on 2019/7/24.
//

#import <Foundation/Foundation.h>
//#import <CoreGraphics/CoreGraphics.h>

typedef NS_ENUM(NSUInteger, DeviceIdType) {
    DeviceIdTypeSN = 2,
    DeviceIdTypeAId = 3
};

typedef struct { // 以G为单位
    float total;
    float used;
    float free;
} DiskInfo;

NS_ASSUME_NONNULL_BEGIN

@interface DeviceInfo : NSObject
+ (CGFloat)deviceDiskCapacity:(NSString *)systemSize;

+ (NSString *)devicePixelDensity;

//横向分辨率
+ (CGFloat)getScreenXInfo;

//纵向分辨率
+ (CGFloat)getScreenYInfo;

+ (DiskInfo)deviceDiskInfo;

+ (NSString *)macAddress;

+ (int64_t)getFreeDiskSpace;

+ (int64_t)getTotalMemory;

+ (CGFloat)getCurrentBatteryLevel ;

+(NSString *)getidfv;
/// 获取当前语言
+ (NSString *)getDeviceLanguage;
/// 获取国家
+ (NSString *)getDeviceCountry;
//运营商
+ (NSString *)getcarrierName;
/// 获取当前可用内存
+ (int64_t)getAvailableMemorySize;

+ (BOOL)isiPhoneDevice;      //是否为手机

+ (BOOL)isiPadDevice;

+ (NSString *)systemVersion;     //获取手机系统版本

+ (NSString *)getAppVersion;     //app版本

+ (NSString *)getAppName;     //APP名称

+ (NSString *)getAppBundle;

+ (UIColor *) colorWithHexString: (NSString *)color;

+ (NSString *)getDeviceVersionInfo;

+ (NSString *)getAId;     //获取设备唯一标识符UUID

+ (DeviceIdType)getDeviceIdType;    // 如果是sn(1) aid(2)

+ (NSString *)getDeviceId;          // sn或者广告id对应的串

+ (NSInteger)platform;// pc(1), iphone(2), ipad(3)
// Karl Make
+ (NSString *)getIPAddress;

+ (NSString *)getIPAddress:(BOOL)preferIPv4;

+ (BOOL)isValidatIP:(NSString *)ipAddress;

+ (NSDictionary *)getIPAddresses;    //ip

+ (NSString*)deviceModel;      //设备型号

+ (NSString*)arc4randomLevel;      //等级数量


@end

NS_ASSUME_NONNULL_END
