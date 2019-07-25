//
//  DeviceInfo.m
//  Unity-iPhone
//
//  Created by 傅瑶fotoable on 2019/7/24.
//

#import "DeviceInfo.h"
#import <UIKit/UIKit.h>
#import <sys/sysctl.h>
#import <sys/socket.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <sys/utsname.h>
#import <sys/mount.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <objc/runtime.h>
#import <AdSupport/AdSupport.h>

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import <sys/types.h>
#import <sys/sysctl.h>
#import <mach/host_info.h>
#import <mach/mach_host.h>
#import <mach/task_info.h>
#import <mach/task.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

#define DOCUMENT_PATH ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject])
#define DEVICE_ID_FILE_PATH ([[DOCUMENT_PATH stringByAppendingPathComponent:@"deviceId"] stringByAppendingPathExtension:@"plist"])
#define SEED_FILE_PATH ([DOCUMENT_PATH stringByAppendingPathComponent:@"seed"])
#define SEED_BAK_FILE_PATH ([DOCUMENT_PATH stringByAppendingPathComponent:@"seed_bak"])



@implementation DeviceInfo
+ (NSString *)getAppName{
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    return  [infoDictionary objectForKey:@"CFBundleDisplayName"];
    
}
+ (NSString *)getAppVersion{
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return  [infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getAppBundle{
    
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}


// 系统总内存空间
+ (int64_t)getTotalMemory {
    int64_t totalMemory = [[NSProcessInfo processInfo] physicalMemory];
    if (totalMemory < -1) totalMemory = -1;
    return totalMemory;
}
//运营商
+ (NSString *)getcarrierName{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    //    DLog(@"运营商:%@", carrier.carrierName);
    return [carrier carrierName] ? [carrier carrierName] : @"unknow";
}


+ (NSString*)arc4randomLevel{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FAT_LevelNum"]) {
        int x = arc4random() % 10;
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",x] forKey:@"FAT_LevelNum"];
    }
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"FAT_LevelNum"];
}




+ (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // 判断前缀
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    // 从六位数值中找到RGB对应的位数并转换
    NSRange range;
    range.location = 0;
    range.length = 2;
    //R、G、B
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}


// 获取未使用的磁盘空间
+ (int64_t)getFreeDiskSpace {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space =  [[attrs objectForKey:NSFileSystemFreeSize] longLongValue];
    if (space < 0) space = -1;
    return space;
}
/// 获取当前可用内存
+ (int64_t)getAvailableMemorySize {
    
    vm_statistics_data_t vmStats;
    
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    
    if (kernReturn != KERN_SUCCESS)
    {
        
        return NSNotFound;
    }
    return ((vm_page_size * vmStats.free_count + vm_page_size * vmStats.inactive_count));
}

/// 获取当前语言
+ (NSString *)getDeviceLanguage {
    
    /*zh-Hans*/
    NSString *language = [[NSBundle mainBundle] preferredLocalizations][0];
    
    if (language.length == 0) {
        return @"";
    }
    
    NSString *languageCode = [language substringToIndex:2];
    return languageCode;
}

/// 获取国家

+ (NSString *)getDeviceCountry {
    
    NSLocale *locale = [NSLocale currentLocale];
    if (@available(iOS 10.0, *)) {
        
        return [locale countryCode];
    } else {
        // Fallback on earlier versions
        
        return [locale objectForKey:NSLocaleCountryCode];
    }
    
}

/// 获取精准电池电量

+ (CGFloat)getCurrentBatteryLevel {
    
    UIApplication *app = [UIApplication sharedApplication];
    
    if (app.applicationState == UIApplicationStateActive||app.applicationState==UIApplicationStateInactive) {
        
        Ivar ivar=  class_getInstanceVariable([app class],"_statusBar");
        
        id status  = object_getIvar(app, ivar);
        
        for (id aview in [status subviews]) {
            
            int batteryLevel = 0;
            
            for (id bview in [aview subviews]) {
                
                if ([NSStringFromClass([bview class]) caseInsensitiveCompare:@"UIStatusBarBatteryItemView"] == NSOrderedSame&&[[[UIDevice currentDevice] systemVersion] floatValue] >=6.0) {
                    Ivar ivar=  class_getInstanceVariable([bview class],"_capacity");
                    if(ivar) {
                        batteryLevel = ((int (*)(id, Ivar))object_getIvar)(bview, ivar);
                        if (batteryLevel > 0 && batteryLevel <= 100) {
                            return batteryLevel;
                        } else {
                            return 0;
                        }
                    }
                }
            }
        }
    }
    return 0;
    
}


// 获取mac地址 iOS 7 以后就是固定值
+ (NSString *)macAddress {
#if TARGET_IPHONE_SIMULATOR
    return @"12:23:56:79";
#endif
    int mib[6];
    size_t len;
    char  *buf;
    unsigned char  *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        return nil;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        return nil;
    }
    
    if ((buf = malloc(len)) == NULL) {
        return nil;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        free(buf);
        return nil;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return [outstring uppercaseString]; // to upper
}

/**
 FOUNDATION_EXPORT NSString * const NSFileSystemSize;
 FOUNDATION_EXPORT NSString * const NSFileSystemFreeSize;
 FOUNDATION_EXPORT NSString * const NSFileSystemNodes;
 FOUNDATION_EXPORT NSString * const NSFileSystemFreeNodes;
 */

+ (CGFloat)deviceDiskCapacity:(NSString *)systemSize {
    CGFloat totalSpace = 0.0f;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary  objectForKey:systemSize];
        totalSpace = [fileSystemSizeInBytes floatValue];
    } else {
        // 获取到磁盘信息失败
    }
    return totalSpace;
}

// 现在使用的方法
+ (DiskInfo)deviceDiskInfo {
    DiskInfo diskInfo = {.0f,.0f};
    CGFloat totalSize = [self deviceDiskCapacity:NSFileSystemSize]/(1024 * 1024 * 1024);
    CGFloat freeSize = [self deviceDiskCapacity:NSFileSystemFreeSize]/(1024 * 1024 * 1024);
    
    diskInfo.total = totalSize;
    
    CGFloat offset = 0.2;
    if (freeSize < .2) {
        offset = .1;
    } else if (freeSize < .05){
        offset = 0;
    }
    diskInfo.used = totalSize - freeSize;
    // why 什么意思
    if (freeSize > offset) {
        freeSize = freeSize - offset;
    } else {
        freeSize = 0;
    }
    
    diskInfo.free = freeSize;
    return diskInfo;
}

// 仅仅有两个字段 ProcessID和ProcessName
+ (NSArray *)runningProcesses {
    
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t miblen = 4;
    
    size_t size;
    int st = sysctl(mib, (u_int)miblen, NULL, &size, NULL, 0);
    
    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;
    
    do {
        size += size / 10;
        newprocess = realloc(process, size);
        if (!newprocess){
            if (process){
                free(process);
            }
            return nil;
        }
        process = newprocess;
        st = sysctl(mib, (u_int)miblen, process, &size, NULL, 0);
        
    } while (st == -1 && errno == ENOMEM);
    
    if (st == 0){
        
        if (size % sizeof(struct kinfo_proc) == 0){
            int nprocess = (int)size / sizeof(struct kinfo_proc);
            
            if (nprocess){
                
                NSMutableArray * array = [[NSMutableArray alloc] init];
                
                for (int i = nprocess - 1; i >= 0; i--){
                    
                    NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                    NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                    
                    NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:processID, processName, nil]
                                                                        forKeys:[NSArray arrayWithObjects:@"ProcessID", @"ProcessName", nil]];
                    
                    [array addObject:dict];
                }
                free(process);
                return array.copy;
            }
        }
    }
    
    return nil;
}

+ (BOOL)isiPhoneDevice {
    UIDevice *device = [UIDevice currentDevice];
    NSString *model = [device.model lowercaseString];
    BOOL result = [model hasPrefix:@"iphone"] || [model hasPrefix:@"ipod"];     // iphone和ipod类型一样  但是与ipad不同
    return result;
}

+ (BOOL)isiPadDevice {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}


+ (NSString *)getDeviceVersionInfo {
    struct utsname systemInfo;  // 导入<sys/utsname.h>
    uname(&systemInfo);
    NSString *platform = [NSString stringWithFormat:@"%s", systemInfo.machine];
    
    return platform;
}
//广告位标识符idfa,idfa没取到就返回idfv
+ (NSString *)getAId {
    
    if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
        return [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
    }
    return [UIDevice currentDevice].identifierForVendor.UUIDString;
    
}

+(NSString *)getidfv{
    
    return  [UIDevice currentDevice].identifierForVendor.UUIDString;
}

+ (DeviceIdType)getDeviceIdType {
    // 如果是sn(2) aid(3)
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:DEVICE_ID_FILE_PATH]) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:DEVICE_ID_FILE_PATH];
        if (dict[@"sn"]) { // 如果存在sn的话 就优先使用sn
            return DeviceIdTypeSN;
        } else {
            return DeviceIdTypeAId;
        }
    } else {
        // 这是没有授权的情况 将aid写入文件 ，同时返回aid；
        NSDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:[self getAId] forKey:@"aid"];
        [dict writeToFile:DEVICE_ID_FILE_PATH atomically:YES];
        
        return DeviceIdTypeAId;
    }
}

+ (NSString *)getDeviceId {
    // sn或者广告id对应的串
    if ([self getDeviceIdType] == DeviceIdTypeSN) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:DEVICE_ID_FILE_PATH];
        return dict[@"sn"];
    } else {
        return [self getAId];
    }
}


+ (NSInteger)platform {
    if ([self isiPadDevice]) {
        return 0x10000003;
    } else {
        return 0x10010002;
    }
}
//系统版本
+ (NSString *)systemVersion {
    return [UIDevice currentDevice].systemVersion;
}

#pragma mark - 获取设备当前网络IP地址WIFI和4G都可以获取ip
+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         //筛选出IP地址格式
         if([self isValidatIP:address]) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

+ (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result=[ipAddress substringWithRange:resultRange];
            return YES;
        }
    }
    return NO;
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

// wifi下获取ip
+ (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}


+ (NSString *)deviceModel{
    
    //        需要导入头文件：#import <sys/utsname.h>
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if([platform isEqualToString:@"iPhone1,1"])  return @"iPhone 2G";
    
    if([platform isEqualToString:@"iPhone1,2"])  return @"iPhone 3G";
    
    if([platform isEqualToString:@"iPhone2,1"])  return @"iPhone 3GS";
    
    if([platform isEqualToString:@"iPhone3,1"])  return @"iPhone 4";
    
    if([platform isEqualToString:@"iPhone3,2"])  return @"iPhone 4";
    
    if([platform isEqualToString:@"iPhone3,3"])  return @"iPhone 4";
    
    if([platform isEqualToString:@"iPhone4,1"])  return @"iPhone 4S";
    
    if([platform isEqualToString:@"iPhone5,1"])  return @"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,2"])  return @"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,3"])  return @"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone5,4"])  return @"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone6,1"])  return @"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone6,2"])  return @"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone7,1"])  return @"iPhone 6 Plus";
    
    if([platform isEqualToString:@"iPhone7,2"])  return @"iPhone 6";
    
    if([platform isEqualToString:@"iPhone8,1"])  return @"iPhone 6s";
    
    if([platform isEqualToString:@"iPhone8,2"])  return @"iPhone 6s Plus";
    
    if([platform isEqualToString:@"iPhone8,4"])  return @"iPhone SE";
    
    if([platform isEqualToString:@"iPhone9,1"])  return @"iPhone 7";
    
    if([platform isEqualToString:@"iPhone9,3"])  return @"iPhone 7";
    
    if([platform isEqualToString:@"iPhone9,2"])  return @"iPhone 7 Plus";
    
    if([platform isEqualToString:@"iPhone9,4"])  return @"iPhone 7 Plus";
    
    if([platform isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,3"]) return @"iPhone X";
    
    if([platform isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    
    if([platform isEqualToString:@"iPhone10,8"]) return @"iPhone XR";
    
    if([platform isEqualToString:@"iPhone10,2"]) return @"iPhone XS";
    
    if([platform isEqualToString:@"iPhone10,4"]) return @"iPhone XS Max";
    
    if([platform isEqualToString:@"iPhone10,6"]) return @"iPhone XS Max";
    
    if([platform isEqualToString:@"iPod1,1"])  return @"iPod Touch 1G";
    
    if([platform isEqualToString:@"iPod2,1"])  return @"iPod Touch 2G";
    
    if([platform isEqualToString:@"iPod3,1"])  return @"iPod Touch 3G";
    
    if([platform isEqualToString:@"iPod4,1"])  return @"iPod Touch 4G";
    
    if([platform isEqualToString:@"iPod5,1"])  return @"iPod Touch 5G";
    
    if([platform isEqualToString:@"iPad1,1"])  return @"iPad 1G";
    
    if([platform isEqualToString:@"iPad2,1"])  return @"iPad 2";
    
    if([platform isEqualToString:@"iPad2,2"])  return @"iPad 2";
    
    if([platform isEqualToString:@"iPad2,3"])  return @"iPad 2";
    
    if([platform isEqualToString:@"iPad2,4"])  return @"iPad 2";
    
    if([platform isEqualToString:@"iPad2,5"])  return @"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad2,6"])  return @"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad2,7"])  return @"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad3,1"])  return @"iPad 3";
    
    if([platform isEqualToString:@"iPad3,2"])  return @"iPad 3";
    
    if([platform isEqualToString:@"iPad3,3"])  return @"iPad 3";
    
    if([platform isEqualToString:@"iPad3,4"])  return @"iPad 4";
    
    if([platform isEqualToString:@"iPad3,5"])  return @"iPad 4";
    
    if([platform isEqualToString:@"iPad3,6"])  return @"iPad 4";
    
    if([platform isEqualToString:@"iPad4,1"])  return @"iPad Air";
    
    if([platform isEqualToString:@"iPad4,2"])  return @"iPad Air";
    
    if([platform isEqualToString:@"iPad4,3"])  return @"iPad Air";
    
    if([platform isEqualToString:@"iPad4,4"])  return @"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,5"])  return @"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,6"])  return @"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,7"])  return @"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad4,8"])  return @"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad4,9"])  return @"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad5,1"])  return @"iPad Mini 4";
    
    if([platform isEqualToString:@"iPad5,2"])  return @"iPad Mini 4";
    
    if([platform isEqualToString:@"iPad5,3"])  return @"iPad Air 2";
    
    if([platform isEqualToString:@"iPad5,4"])  return @"iPad Air 2";
    
    if([platform isEqualToString:@"iPad6,3"])  return @"iPad Pro 9.7";
    
    if([platform isEqualToString:@"iPad6,4"])  return @"iPad Pro 9.7";
    
    if([platform isEqualToString:@"iPad6,7"])  return @"iPad Pro 12.9";
    
    if([platform isEqualToString:@"iPad6,8"])  return @"iPad Pro 12.9";
    
    if([platform isEqualToString:@"i386"])  return @"iPhone Simulator";
    
    if([platform isEqualToString:@"x86_64"])  return @"iPhone Simulator";
    
    return platform;
}

+ (NSString *)devicePixelDensity{
    
    NSString *platform = [self deviceModel];
    
    if([platform isEqualToString:@"iPhone 2G"])  return@"163ppi";
    if([platform isEqualToString:@"iPhone 3G"])  return@"163ppi";
    if([platform isEqualToString:@"iPhone 3GS"])  return@"163ppi";
    if([platform isEqualToString:@"iPhone 4"])  return@"163ppi";
    
    if([platform isEqualToString:@"iPhone 4S"])  return@"326ppi";
    if([platform isEqualToString:@"iPhone 5"])  return@"326ppi";
    if([platform isEqualToString:@"iPhone 5c"])  return@"326ppi";
    if([platform isEqualToString:@"iPhone 5s"])  return@"326ppi";
    
    if([platform isEqualToString:@"iPhone 6 Plus"])  return@"401ppi";
    if([platform isEqualToString:@"iPhone 6"])  return@"401ppi";
    if([platform isEqualToString:@"iPhone 6s"])  return@"401ppi";
    if([platform isEqualToString:@"iPhone 6s Plus"])  return@"401ppi";
    if([platform isEqualToString:@"iPhone SE"])  return@"401ppi";
    if([platform isEqualToString:@"iPhone 7"])  return@"401ppi";
    if([platform isEqualToString:@"iPhone 7 Plus"])  return@"401ppi";
    if([platform isEqualToString:@"iPhone 8"])  return@"401ppi";
    if([platform isEqualToString:@"iPhone 8 Plus"])  return@"401ppi";
    
    if([platform isEqualToString:@"iPhone X"])  return@"458ppi";
    if([platform isEqualToString:@"iPhone XR"])  return@"326ppi";
    if([platform isEqualToString:@"iPhone XS"])  return@"458ppi";
    if([platform isEqualToString:@"iPhone XS Max"])  return@"458ppi";
    
    if([platform isEqualToString:@"iPod Touch 1G"])  return@"163ppi";
    if([platform isEqualToString:@"iPod Touch 2G"])  return@"163ppi";
    if([platform isEqualToString:@"iPod Touch 3G"])  return@"163ppi";
    if([platform isEqualToString:@"iPod Touch 4G"])  return@"163ppi";
    if([platform isEqualToString:@"iPod Touch 5G"])  return@"163ppi";
    
    if([platform isEqualToString:@"iPad 1G"])  return@"163ppi";
    if([platform isEqualToString:@"iPad 2"])  return@"163ppi";
    if([platform isEqualToString:@"iPad 3"])  return@"264ppi";
    if([platform isEqualToString:@"iPad 4"])  return@"264ppi";
    
    if([platform isEqualToString:@"iPad Mini 1G"])  return@"163ppi";
    if([platform isEqualToString:@"iPad Mini 2G"])  return@"163ppi";
    if([platform isEqualToString:@"iPad Mini 3"])  return@"326ppi";
    if([platform isEqualToString:@"iPad Mini 4"])  return@"326ppi";
    
    if([platform isEqualToString:@"iPad Air"])  return@"264ppi";
    if([platform isEqualToString:@"iPad Air 2"])  return@"264ppi";
    if([platform isEqualToString:@"iPad Pro 9.7"])  return@"264ppi";
    if([platform isEqualToString:@"iPad Pro 12.9"])  return@"264ppi";
    
    if([platform isEqualToString:@"iPhone Simulator"])  return@"0";
    
    
    return platform;
}


//横向分辨率
+ (CGFloat)getScreenXInfo{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenRect.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat screenY = screenSize.height * scale;
    return screenY;
    
}

//纵向分辨率
+ (CGFloat)getScreenYInfo{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenRect.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat screenX = screenSize.width * scale;
    return screenX;
    
}


//格式化时间
+ (double)getNowDateFromatAnDate:(NSString *)anyDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    //df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
    df.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss z";
    df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSDate *date1 = [df dateFromString:anyDate];
    
    
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithName:@"GMT"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:date1];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:date1];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:date1];
    
    NSTimeInterval a = [destinationDateNow timeIntervalSince1970];
    
    return a - destinationGMTOffset;
}



@end
