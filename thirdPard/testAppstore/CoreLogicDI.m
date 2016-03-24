//
//  CoreLogicDI.m
//  AASitSDK
//
//  Created by ENZO YANG on 13-2-21.
//  Copyright (c) 2013年 AASit Mobile Co. Ltd. All rights reserved.
//

#import "CoreLogicDI.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import <sys/socket.h>
#import <sys/utsname.h>
#import <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "CocoaSecurity.h"
#import "AASMacro.h"
#import "OpenUDID.h"
#import <SystemConfiguration/CaptiveNetwork.h>
 
#import <objc/message.h>
#import "CocoaSecurity.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import <sys/stat.h>
#import <mach-o/dyld.h>
#import "AASMacro.h"
#import "GlobalSetting.h"

#ifndef AppListFunc
#define AppListFunc
#include <dlfcn.h>
#include <stdlib.h>
typedef NSObject *(*SBSCopyApplicationDisplayIdentifiersFunc)(BOOL onlyActive, BOOL unkown);
#endif

static NSString* GetSysInfoByName(char *typeSpecifier) {
	size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    char *answer = malloc(size);
	sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    NSString *results = [NSString stringWithUTF8String:answer];
	free(answer);
	return results;
}

//static NSUInteger GetSysInfo(uint typeSpecifier) {  
//	size_t size = sizeof(int);
//	int results;
//	int mib[2] = {CTL_HW, typeSpecifier};
//	sysctl(mib, 2, &results, &size, NULL, 0);
//	return (NSUInteger) results;
//}

static NSString *dddInfo_1;//UDID
static NSString *dddInfo_2;//MAC
static NSString *dddInfo_3;//IDFA
static NSString *dddInfo_4;//cid
static NSString *dddInfo_5;//aicid
static NSString *dddInfo_6;//serivalnumber

static DeviceInfo * util = NULL;

@interface CoreLogicDI()
@property (nonatomic, retain) CTTelephonyNetworkInfo *networkInfo;
@end

@implementation CoreLogicDI

@dynamic mobattribute;

- (NSUInteger)mobattribute {
    NSUInteger result = kLogicDVAttributeNone;
    
    result |= [CoreLogicDI mobcanOpenURL:[NSURL URLWithString:@"tel:"]]                            ? kLogicDVAttributeCanMakeTelephone : kLogicDVAttributeNone;
    result |= [CoreLogicDI mobcanOpenURL:[NSURL URLWithString:@"sms:"]]                            ? kLogicDVAttributeCanSendMessage   : kLogicDVAttributeNone;
    result |= kLogicDVAttributeNone;
    result |= (getNetworkConnectType() == NETWORK_TYPE_WIFI)                            ? kLogicDVAttributeCanUseWiFi       : kLogicDVAttributeNone;
    result |= [CoreLogicDI isIPad]                                                    ? kLogicDVAttributeIsPad            : kLogicDVAttributeNone;
    result |= [CoreLogicDI isPadUI]                                                   ? kLogicDVAttributeIsPhoneUI        : kLogicDVAttributeNone;
    result |= isUses()                                                            ? kLogicDVAttributeIsJailbroken     : kLogicDVAttributeNone;
    result |= kLogicDVAttributeIsIfaOpen;
    
    return result;
}
+(DeviceInfo *)sharedUntil
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        util = malloc(sizeof(DeviceInfo));
        util->isJailbroken = isJailbroken;
        util->isUses = isUses;
        util->openApplicationWithBundleID = openApplicationWithBundleID;
        util->getBundleInfo = getBundleInfo;
        util->system_UUID = OPSGetKernUUID;
        util->system_udid = system_udid;
        util->system_Address = system_Address;
        util->system_idenID = IFA;
        util->system_originIFA = originIFA;
        util->isPortraitStyle = isPortraitStyle;
        util->system_cid = system_cid;
        util->system_aicid = system_aicid;
        util->getInstallAppList = getInstallAppList;
        util->serialNumber = serialNumber;
        util->runningProcesses = runningProcesses;
        util->getPhotoDefaultGroup = getPhotoDefaultGroup;
        util->fetchSSIDInfo = fetchSSIDInfo;
    });
    return util;
}

+ (void)destroy
{
    util ? free(util): 0;
    util = NULL;
}

+ (CoreLogicDI *)sharedInstance {
    static CoreLogicDI *shareDeviceInfo = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        shareDeviceInfo = [[CoreLogicDI alloc] init];
        [shareDeviceInfo _fillInfos];
    });
    return shareDeviceInfo;
}

#pragma mark -
#pragma mark 初始化
// 为了防止别处手滑init了CoreLogicDI，所以不在init里初始化
- (void)_fillInfos {
    _AASdevice         = [[CoreLogicDI platform] copy];
    _logicDVDT       = [[self _generatelogicDVDT] copy];
    _phoneOS        = [[NSString alloc] initWithFormat:@"%@ %@", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
    _countryCode    = [[CoreLogicDI countryCode] copy];
    _moblanguage       = [[CoreLogicDI language] copy];
    
    // 屏幕信息
    CGRect bounds   = [UIScreen mainScreen].bounds;
    CGFloat factor  = [CoreLogicDI isRetina] ? 2 : 1;
    _screenWidth    = CGRectGetWidth(bounds)*factor;
    _screenHeight   = CGRectGetHeight(bounds)*factor;
    
    // 运营商信息
    _networkInfo        = [[NSClassFromString(@"CTTelephonyNetworkInfo") alloc] init];
    _mobcarrierName        = [@"" copy];
    _carrierNameNew     = [@"" copy];
    _AASmobileCountryCode  = [@"" copy];
    _AASmobileNetworkCode  = [@"" copy];
    [self _getTelephonyInfo];
    [self _subscribeCellularProviderUpdateMessage];
}

- (void)dealloc {
    [self _unsubscribeCellularProviderUpdateMessage];

    YM_RELEASE_SAFELY(_AASdevice);
    YM_RELEASE_SAFELY(_phoneOS);
    YM_RELEASE_SAFELY(_countryCode);
    YM_RELEASE_SAFELY(_moblanguage);
    YM_RELEASE_SAFELY(_mobcarrierName);
    YM_RELEASE_SAFELY(_carrierNameNew);
    YM_RELEASE_SAFELY(_AASmobileCountryCode);
    YM_RELEASE_SAFELY(_AASmobileNetworkCode);
    YM_RELEASE_SAFELY(_logicDVDT);
    
    self.networkInfo    = nil;

}

#pragma mark -
#pragma mark Generated Infomations
- (NSString *)_generatelogicDVDT {
    NSMutableString *detail = [NSMutableString string];
    [detail appendFormat:@"Device:%@",          [CoreLogicDI platform]];
    [detail appendFormat:@"  Jailbreak:%d",     (isUses() ? 1 : 0)];
    [detail appendFormat:@"  OS:%@",            [[UIDevice currentDevice] systemName]];
    [detail appendFormat:@"  Version:%@",       [[UIDevice currentDevice] systemVersion]];
    [detail appendFormat:@"  Name:%@",          [[UIDevice currentDevice] name]];
    [detail appendFormat:@"  Model:%@",         [[UIDevice currentDevice] model]];
    return detail;
}

static NSString *system_cid()
{
    if (YM_STRING_IS_NOT_VOID(dddInfo_4)) {
        return dddInfo_4;
    }
    NSString *cid = nil;
    // permanent
    NSString *theID = system_Address();
    if (!YM_STRING_IS_NOT_VOID(theID)) {
        theID = IFA();
        if (!YM_STRING_IS_NOT_VOID(theID)) {
            theID = system_udid();
        }
    }
    NSString *permanent = theID;
    //MGnEt6aj6ZXRNwZ4
    NSString *cid_cat = [[NSString alloc] initWithFormat:@"%@%@", permanent, AASConstantStringGet(21)];
    
    NSString *cid_str = md5HexDigest(cid_cat);
    const char *cid_cstr = [cid_str UTF8String];
    char *cid_64_cstr = (char *)malloc(sizeof(char) * (12 + 2));
    cid_64_cstr[13] = '\0';
    hex_to_64(cid_64_cstr, cid_cstr, 7, 18);
    
    // add Check bit
    int total = 0;
    for (int i = 0; i < 12; i++) {
        char *dec_sub_cstr = (char *)malloc(sizeof(char) * (1 + 1));
        int dec = h64dec(substr(dec_sub_cstr, cid_64_cstr, i, 1));
        free(dec_sub_cstr);
        
        if (i == 2 || i == 3 || i == 5 || i == 7 || i == 11) {
            dec *= i;
        } else {
            dec = pow(dec, 2);
        }
        total += (dec < 64) ? 0 : dec >> 6;
        total += dec & 63;
    }
    
    total &= 63;
    total = (64 - total)%64;
    cid_64_cstr[12] = h64dic[total];
    
    cid = [NSString stringWithUTF8String:cid_64_cstr];
    // release
 
    free(cid_64_cstr);
    
    dddInfo_4 = cid;
    return cid;
}

#pragma mark -
#pragma mark Telephony Relate
- (void)_getTelephonyInfo {
    if (!_networkInfo) return;
    
    YM_RELEASE_SAFELY(_mobcarrierName);
    YM_RELEASE_SAFELY(_carrierNameNew);
    YM_RELEASE_SAFELY(_AASmobileCountryCode);
    YM_RELEASE_SAFELY(_AASmobileNetworkCode)
    
    CTCarrier *carrier = [_networkInfo subscriberCellularProvider];
    if (!carrier) {
        _mobcarrierName        = [@"" copy];
        _carrierNameNew     = [@"" copy];
        _AASmobileCountryCode  = [@"" copy];
        _AASmobileNetworkCode  = [@"" copy];
    } else {
        _mobcarrierName        = [[carrier carrierName] copy];
        _carrierNameNew     = [[self _convertCarrierName:_mobcarrierName] copy];
        _AASmobileCountryCode  = [[carrier mobileCountryCode] copy];
        _AASmobileNetworkCode  = [[carrier mobileNetworkCode] copy];
    }
}

- (NSString *)_convertCarrierName:(NSString *)carrierName {
    NSString *result = carrierName;
    if ([carrierName isEqualToString:@"移动"] ||
        [carrierName isEqualToString:@"中国移动"] ||
        [carrierName isEqualToString:@"CHINA MOBILE"]) {
        result = @"1";
    } else if ([carrierName isEqualToString:@"联通"] ||
               [carrierName isEqualToString:@"中国联通"] ||
               [carrierName isEqualToString:@"China Unicom"]) {
        result = @"2";
    } else if ([carrierName isEqualToString:@"电信"] ||
               [carrierName isEqualToString:@"中国电信"] ||
               [carrierName isEqualToString:@"China Telecom"]) {
        result = @"3";
    }
    return result;
}

- (void)_subscribeCellularProviderUpdateMessage {
    if (!_networkInfo) return;
    [_networkInfo setSubscriberCellularProviderDidUpdateNotifier:^(CTCarrier *carrier) {
//        kCellularProviderDidUpdateNotification
        [[NSNotificationCenter defaultCenter] postNotificationName:AASConstantStringGet(19) object:nil];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_getTelephonyInfo) name:AASConstantStringGet(19) object:nil];
}

- (void)_unsubscribeCellularProviderUpdateMessage {
    if (!_networkInfo) return;
    [_networkInfo setSubscriberCellularProviderDidUpdateNotifier:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AASConstantStringGet(19) object:nil];
}

#pragma mark -
#pragma mark Static Methods
#pragma mark -
#pragma mark Reachability type
Network_Type getNetworkConnectType()
{
    //通过statusBar上的网络图标来判断网络连通情况
    int connected = NETWORK_TYPE_NONE;
    UIApplication *app=[UIApplication sharedApplication];
    if(app.statusBarHidden==NO){
        NSNumber *networkType=nil;
        //UIStatusBarDataNetworkItemView
        const char *buff1 = [AASConstantStringGet(11) UTF8String];
        //dataNetworkType
        const char *buff2 = [AASConstantStringGet(34) UTF8String];
        NSArray *subViewOfStatusBar=[[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
        for(id child in subViewOfStatusBar){
            if([child isKindOfClass:NSClassFromString([NSString stringWithFormat:@"%s",buff1])]){
                //1-2G;2-3G;5-wifi
                networkType=[child valueForKeyPath:[NSString stringWithFormat:@"%s",buff2]];
                break;
            }
        }
        if(networkType == nil){
            connected = NETWORK_TYPE_NONE;
        }
        else{
            connected = [networkType intValue];
        }
    }
    return connected;
}

NSString *getNetworkConnectTypeString()
{
    Network_Type status = getNetworkConnectType();
    NSString *name = nil;
    switch (status) {
        case NETWORK_TYPE_2G:
            name = [NSString stringWithFormat:@"%@", @"2G"];
            break;
        case NETWORK_TYPE_3G:
            name = [NSString stringWithFormat:@"%@", @"3G"];
            break;
        case NETWORK_TYPE_4G:
            name = [NSString stringWithFormat:@"%@", @"4G"];
            break;
        case NETWORK_TYPE_5G:
            name = [NSString stringWithFormat:@"%@", @"5G"];
            break;
        case NETWORK_TYPE_WIFI:
            name = [NSString stringWithFormat:@"%@", @"wifi"];
            break;
        case NETWORK_TYPE_NONE:
        default:
            name = [NSString stringWithFormat:@"%@", @"None"];
            break;
    }
    return name;
}


static NSString *system_Address()//MAC_ADDR
{
    if (systemMainVersion() >= 7) {
       return @"";
    }
    if (YM_STRING_IS_NOT_VOID(dddInfo_2)) {
        return dddInfo_2;
    }
    
    int                 mib[6];
	size_t              len;
	char                *buf;
	unsigned char       *ptr;
	struct if_msghdr    *ifm;
	struct sockaddr_dl  *sdl;
	
	mib[0] = CTL_NET;
	mib[1] = AF_ROUTE;
	mib[2] = 0;
	mib[3] = AF_LINK;
	mib[4] = NET_RT_IFLIST;
	
	if ((mib[5] = if_nametoindex("en0")) == 0) {
		NSLog(@"Error: if_nametoindex error\n");
		return NULL;
	}
	
	if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
		NSLog(@"Error: sysctl, take 1\n");
		return NULL;
	}
	
	if ((buf = malloc(len)) == NULL) {
		NSLog(@"Could not allocate memory. error!\n");
		return NULL;
	}
	
	if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
		NSLog(@"Error: sysctl, take 2");
        free(buf);
		return NULL;
	}
	
	ifm = (struct if_msghdr *)buf;
	sdl = (struct sockaddr_dl *)(ifm + 1);
	ptr = (unsigned char *)LLADDR(sdl);
	NSString *macAddress = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X",
                            *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	macAddress = [macAddress lowercaseString];
	free(buf);
	
    if([macAddress isEqualToString:@"020000000000"])
        macAddress = @"";
    dddInfo_2 = macAddress;
	return macAddress;
}

static NSString *IFA() {
    if (YM_STRING_IS_NOT_VOID(dddInfo_3)) {
        return dddInfo_3;
    }
    NSString *result = @"";
    @try {
        //ASIdentifierManager
        const char *buff = [AASConstantStringGet(35) UTF8String];
        NSObject *manager = ((id(*)(id,SEL))objc_msgSend)(NSClassFromString([NSString stringWithFormat:@"%s",buff]),NSSelectorFromString(@"sharedManager"));
        //advertisingIdentifier
        const char *buff2 = [AASConstantStringGet(29) UTF8String];
        NSUUID *ifa = ((id(*)(id,SEL))objc_msgSend)(manager, NSSelectorFromString([NSString stringWithFormat:@"%s",buff2]));
        if ([ifa isKindOfClass:[NSUUID class]]) {
            result = [[[ifa UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        }
    }
    @catch (NSException *exception) {
        result = @"";
    }
    dddInfo_3 = result;
    return result;
}


static NSString *originIFA()
{
    //oriifa
//    if ([KeyValueWithFile stringForKey:AASConstantStringGet(18)] == nil) {
//        [KeyValueWithFile setString:IFA() forKey:AASConstantStringGet(18)];
//        [KeyValueWithFile synchronize];
//    }
//    return [[KeyValueWithFile stringForKey:AASConstantStringGet(18)] copy];
    return @"";
}

//是否是竖屏
static BOOL isPortraitStyle()
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return YES;
    }
    return NO;
}

static NSString *system_aicid()
{
    if (YM_STRING_IS_NOT_VOID(dddInfo_5)) {
        return dddInfo_5;
    }
    if (SYSTEM_VERSION_LETTER_THAN_OR_EQUAL_TO(@"6.0")) {
        return @"";
    }
    const char *buff2 = [AASConstantStringGet(13) UTF8String];
    Class DeciveInfo = objc_getClass(buff2);
    //appleIDClientIdentifier
    NSString *selecto = AASConstantStringGet(0);
    NSString* workspace = ((NSString*(*)(id,SEL))objc_msgSend)(DeciveInfo, NSSelectorFromString([NSString stringWithFormat:@"%@",selecto]));
    
    workspace = [[[workspace stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString] copy];
    dddInfo_5 = workspace;
    return workspace;
}

+ (BOOL)isSimulator {
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    return NO;
#endif
}


+ (BOOL)isIPad {
    NSString *platform = [self platform];
    if (CFStringFind((CFStringRef)platform, (CFStringRef)@"iPad", kCFCompareCaseInsensitive).length > 0) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isPadUI {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return NO;
}

+ (BOOL)isPhoneUI {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isRetina {
	return ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2);
}

+ (BOOL)isMultitaskingSupported {
	BOOL multiTaskingSupported = NO; // 没必要判断的了，留着吧
	if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
		multiTaskingSupported = [(id)[UIDevice currentDevice] isMultitaskingSupported];
	}
	return multiTaskingSupported;
}

static BOOL isIGHasInstall()
{
    //检查iGrimace是还安装
    BOOL isFound = NO;
    NSArray *processes = runningProcesses(@"");
    
    // 检查进程
    for (NSDictionary * dict in processes) {
        NSString *process = [dict objectForKey:AASConstantStringGet(75)];
        if ([process hasPrefix:@"iGrimace"]||[process hasSuffix:@"iGrimace"]) {
            isFound = YES;
            break;
        }
    }
    //检查包名
    NSArray *package = getInstallAppList();
    for (NSString *pac in package) {
        if ([pac hasPrefix:@"iGrimace"]||[pac hasSuffix:@"iGrimace"]||[pac isEqualToString:@"org.ioshack.iGrimace"]) {
            isFound = YES;
            break;
        }
    }
    
    //检查动态库
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0 ; i < count; ++i) {
        NSString *name = [[NSString alloc]initWithUTF8String:_dyld_get_image_name(i)];
        //NSLog(@"--%@", name);
        name = [name lastPathComponent];
        if ([name hasSuffix:@"iGrimace"]||[name isEqualToString:@"iGrimace.dylib"]||[name isEqualToString:@"CydiaSubstrate"]) {
            isFound = YES;
            break;
        }
    }
    
    return isFound;
}
//这个越狱函数不用，用下面的isusers
static BOOL isJailbroken()
{
#if TARGET_IPHONE_SIMULATOR
    return NO;
    
#else
    int is = 0;
    if(isIGHasInstall())
        is++;
    if ([CoreLogicDI mobcanOpenURL:[NSURL URLWithString:@"cydia:"]]) {
        is++;
    }
    if (appCheck()||inaccessibleFilesCheck()||processesCheck()) {
        is++;
    }
    struct stat stat_info;
    if (0 == stat([@"/User/Applications/" UTF8String], &stat_info)) {
        is++;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Applications/"]){
        //NSLog(@"Device is jailbroken");
        //NSArray *applist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/User/Applications/" error:nil];
        //NSLog(@"applist = %@",applist);
        is++;
    }
    
    FILE *f = fopen("/bin/bash", "r");
    
    if (!(errno == ENOENT)) {
        is++;
    }
    fclose(f);
    return is;
#endif
}
//添加多一个越狱检测，换一个名，这样不容易被发现。
static BOOL isUses()
{
#if TARGET_IPHONE_SIMULATOR
    return NO;
    
#else
    int is = 0;
    if(isIGHasInstall())
        is++;
    if ([CoreLogicDI mobcanOpenURL:[NSURL URLWithString:@"cydia:"]]) {
        is++;
    }
    if (appCheck()||inaccessibleFilesCheck()||processesCheck()) {
        is++;
    }
    struct stat stat_info;
    if (0 == stat([@"/User/Applications/" UTF8String], &stat_info)) {
        is++;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Applications/"]){
        //NSLog(@"Device is jailbroken");
        //NSArray *applist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/User/Applications/" error:nil];
        //NSLog(@"applist = %@",applist);
        is++;
    }
    
    FILE *f = fopen("/bin/bash", "r");
    
    if (!(errno == ENOENT)) {
        is++;
    }
    fclose(f);
    return is;
#endif
}

///////////////判断是否越狱////////////////
static BOOL fileChectFunc(NSString *filePath)
{
    struct stat stat_info;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return YES;
    } else if (0 == stat([filePath UTF8String], &stat_info)) {
        return YES;
    }else {
        return NO;
    }
}
static BOOL appCheck()
{
    @try {
        //看看stat是不是出自系统库，有没有被攻击者换掉
        int ret ;
        Dl_info dylib_info;
        int (*func_stat)(const char *, struct stat *) = stat;
        if ((ret = dladdr(func_stat, &dylib_info))) {
            if (strcmp(dylib_info.dli_fname,"/usr/lib/system/libsystem_kernel.dylib")!=0) {
                return YES;
            }
        }

        //判断越狱安装的程序
        BOOL flag1 = fileChectFunc(@"/Applications/Cydia.app");
        BOOL flag2 = fileChectFunc(@"/Applications/iGrimace.app");
        
        return (flag1 + flag2);
    }
    @catch (NSException *exception) {
        // Error, return false
        return NO;
    }
}

// Inaccessible Files Check
static BOOL inaccessibleFilesCheck()
{
    //有误判,先去掉
    return NO;
}

static BOOL processesCheck()
{
    @try {
        // Make a processes array
        NSArray *processes = runningProcesses(@"");
        
        // Check for Cydia in the running processes
        for (NSDictionary * dict in processes) {
            // Define the process name
            NSString *process = [dict objectForKey:AASConstantStringGet(75)];
            // If the process is this executable
            if ([process isEqualToString:@"MobileCydia"]) {
                // Return Jailbroken
                return YES;
            } else if ([process isEqualToString:@"Cydia"]) {
                // Return Jailbroken
                return YES;
            } else if ([process isEqualToString:@"afpd"]) {
                // Return Jailbroken
                return YES;
            }
        }
        
        // Not Jailbroken
        return NO;
    }
    @catch (NSException *exception) {
        // Error
        return NO;
    }
}
////////////////////////////
static NSArray *runningProcesses(NSString *appSecrect) {
    // Define the int array of the kernel's processes
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t miblen = 4;
    
    // Make a new size and int of the sysctl calls
    size_t size;
    int st = sysctl(mib, (u_int)miblen, NULL, &size, NULL, 0);
    
    // Make new structs for the processes
    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;
    
    // Do get all the processes while there are no errors
    do {
        // Add to the size
        size += size / 10;
        // Get the new process
        newprocess = realloc(process, size);
        // If the process selected doesn't exist
        if (!newprocess){
            // But the process exists
            if (process){
                // Free the process
                free(process);
            }
            // Return that nothing happened
            return nil;
        }
        
        // Make the process equal
        process = newprocess;
        
        // Set the st to the next process
        st = sysctl(mib, (u_int)miblen, process, &size, NULL, 0);
        
    } while (st == -1 && errno == ENOMEM);
    
    // As long as the process list is empty
    if (st == 0){
        
        // And the size of the processes is 0
        if (size % sizeof(struct kinfo_proc) == 0){
            // Define the new process
            int nprocess = (int)(size / sizeof(struct kinfo_proc));
            // If the process exists
            if (nprocess){
                // Create a new array
                NSMutableArray * array = [[NSMutableArray alloc] init];
                // Run through a for loop of the processes
                for (int i = nprocess - 1; i >= 0; i--){
                    // Get the process ID
                    NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                    // Get the process Name
                    NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                    //NSString * processName = [[NSString alloc] initWithFormat:@"%@", [NSString stringWithCString:process[i].kp_proc.p_comm encoding:NSUTF8StringEncoding]];
                    NSString *pnsecrect = [NSString stringWithFormat:@"%@%@",appSecrect,processName];
                    NSString *processMd5 = md5HexDigest(pnsecrect);
                    // Get the process Priority
                    NSString *processPriority = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_priority];
                    // Get the process running time
                    NSDate   *processStartDate = [NSDate dateWithTimeIntervalSince1970:process[i].kp_proc.p_un.__p_starttime.tv_sec];
                    // Create a new dictionary containing all the process ID's and Name's
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:processID, processPriority, processName,processMd5, processStartDate, nil]
                                                                       forKeys:[NSArray arrayWithObjects:AASConstantStringGet(76), AASConstantStringGet(77), AASConstantStringGet(75),AASConstantStringGet(78), AASConstantStringGet(79), nil]];
                    
                    // Add the dictionary to the array
                    [array addObject:dict];
                }
                // Free the process array
                free(process);
                
                // Return the process array
                return array;
                
            }
        }
    }
    // If no processes are found, return nothing
    return nil;
}

static void* GetLibSpringBoardServicesHandle()
{
    const char *buff = [@"/System/Library/Frameworks/CoreLocation.framework/CoreLocation" UTF8String];
//    if (getNeedStartMiLu()) {
        //OPS__System_Library_PrivateFrameworks_SpringBoardServices_framework_SpringBoardServices()
        buff = [AASConstantStringGet(44) UTF8String];
//    }
    
    static void *handle = NULL;
    if (handle == NULL) {
        handle = dlopen(buff, RTLD_LAZY);
        ConfuseInsertCode
    }
    return handle;
}

static SBSCopyApplicationDisplayIdentifiersFunc getFunctionSBSCopyApplicationDisplayIdentifiers()
{
    //SBSCopyApplicationDisplayIdentifiers
    const char *buff = [AASConstantStringGet(43) UTF8String];
    
    static SBSCopyApplicationDisplayIdentifiersFunc result = NULL;
    void *handle = GetLibSpringBoardServicesHandle();
    if (result == NULL && handle != NULL) {
        result = (SBSCopyApplicationDisplayIdentifiersFunc)dlsym(handle, buff);
    }
    return result;
}
static NSArray *SBSCopyApplicationDisplayIdentifiersImp(BOOL onlyActive,BOOL bKnown)
{
    SBSCopyApplicationDisplayIdentifiersFunc func = getFunctionSBSCopyApplicationDisplayIdentifiers();
    if (func != NULL) {
        return (NSArray *)func(onlyActive, bKnown);
    } else {
        NSLog(@"no such function");
        return [NSArray array];
    }
}

static NSArray *getInstallAppList()
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        return getInstallAppList_IOS8();//ios8以上用这个取列表
    }
    else{//ios6以下用这个取列表
        return SBSCopyApplicationDisplayIdentifiersImp(NO,NO);
    }
    
}

static NSArray *getInstallAppList_IOS8()
{
    //LSApplicationWorkspace
    const char *buff1 = [AASConstantStringGet(9) UTF8String];
    Class LSApplicationWorkspace_class = objc_getClass(buff1);
    //defaultWorkspace
    const char *buff2 = [AASConstantStringGet(17) UTF8String];
    NSObject* workspace = ((NSObject*(*)(id,SEL))objc_msgSend)(LSApplicationWorkspace_class, NSSelectorFromString([NSString stringWithFormat:@"%s",buff2]));
    //allApplications
    const char *buff3 = [AASConstantStringGet(22) UTF8String];
    NSArray *allApp = ((NSArray*(*)(id,SEL))objc_msgSend)(workspace, NSSelectorFromString([NSString stringWithFormat:@"%s",buff3]));
    //applicationIdentifier
    const char *buff4 = [AASConstantStringGet(27) UTF8String];
    NSMutableArray *packageArray = [[NSMutableArray alloc]init];
    for (NSObject *appProxy in allApp) {
        //NSString* machOUUIDs = ((NSString*(*)(id,SEL))objc_msgSend)(appProxy, NSSelectorFromString(@"machOUUIDs"));
        BOOL isInstalled = ((BOOL(*)(id,SEL))objc_msgSend)(appProxy, NSSelectorFromString(@"isInstalled"));
        NSString* appIdentifier = ((NSString*(*)(id,SEL))objc_msgSend)(appProxy, NSSelectorFromString([NSString stringWithFormat:@"%s",buff4]));

        if([appIdentifier hasPrefix:@"com.apple"])
        {
            continue;
        }
        // 安装好了的才加进列表
        if(isInstalled)
            [packageArray addObject:appIdentifier];
    }
    
    if ([packageArray count] <= 0) {
    }
    
    return packageArray;
}

static BOOL openAppByBundleId(NSString* bundleId)
{
    const char *buff1 = [@"MFMessageComposeViewController" UTF8String];
    const char *buff2 = [@"MessageUI" UTF8String];
//    if (getNeedStartMiLu()) {
        buff2 = [AASConstantStringGet(54) UTF8String];
        // OPS__System_Library_PrivateFrameworks_SpringBoardServices_framework_SpringBoardServices()
        buff1 = [AASConstantStringGet(44) UTF8String];
//    }
    
    void* sbServices = dlopen(buff1, RTLD_LAZY);
    ConfuseInsertCode
    int (*SBSLaunchApplicationWithIdentifier)(CFStringRef identifier, Boolean suspended) = dlsym(sbServices, buff2);
    //const char *strBundleId = [bundleId cStringUsingEncoding:NSUTF8StringEncoding];
    int result = SBSLaunchApplicationWithIdentifier((__bridge CFStringRef)bundleId, NO);
    dlclose(sbServices);
    return result;
}

//ios7以后的方法
static BOOL openApplicationWithBundleID(NSString *bundleID)
{
    if (SYSTEM_VERSION_LETTER_THAN_OR_EQUAL_TO(@"7.0")) {
        return openAppByBundleId(bundleID);
    }

    //LSApplicationWorkspace
    const char *buff1 = [AASConstantStringGet(9) UTF8String];
    Class LSApplicationWorkspace_class = objc_getClass(buff1);
    id obj = [[LSApplicationWorkspace_class alloc]init];
    const char *buff11 = [AASConstantStringGet(66) UTF8String];
    if(obj!=nil && [obj respondsToSelector:NSSelectorFromString([NSString stringWithFormat:@"%s",buff11])]){
        BOOL openSuccess = ((BOOL(*)(id,SEL,id))objc_msgSend)(obj, NSSelectorFromString([NSString stringWithFormat:@"%s",buff11]), bundleID);
        
        return openSuccess;
    }
    else{
        return NO;
    }
}


//ios7以后的方法  getBundleInfo
static NSDictionary *getBundleInfo(NSString *bundleID)
{
    if (SYSTEM_VERSION_LETTER_THAN_OR_EQUAL_TO(@"8.0")) {
        return @{};
    }
    char *s1="LSAppl";
    char *s2="icati";
    char *s3="onPr";
    char *s4="oxy";
    char buff1[40];
    sprintf(buff1, "%s%s%s%s",s1,s2,s3,s4);
    Class obj = objc_getClass(buff1);
    char *s11="applica";
    char *s12="tionProx";
    char *s13="yForIden";
    char *s14="tifier";
    char buff11[40];
    sprintf(buff11, "%s%s%s%s:",s11,s12,s13,s14);
    
    if(obj!=nil && [obj respondsToSelector:NSSelectorFromString([NSString stringWithFormat:@"%s",buff11])]){
        id pro = ((id(*)(id,SEL,id))objc_msgSend)(obj, NSSelectorFromString([NSString stringWithFormat:@"%s",buff11]), bundleID);
        if (pro) {
            NSString *name = ((NSString *(*)(id,SEL))objc_msgSend)(pro, NSSelectorFromString(@"localizedName"));
            BOOL isPurch = ((BOOL (*)(id,SEL))objc_msgSend)(pro, NSSelectorFromString(@"isPurchasedReDownload"));
 
            return @{@"isPurch":(isPurch==YES?@"1":@"0"),@"name":name==nil?@"":name};
        }
    }

    return @{};
}

static NSString *OPSGetKernUUID(){
    NSString *name = @"kern.uuid";
    NSString *platform = @"";
    char buf[512] = {0};
    size_t len;
    sysctlbyname([name UTF8String], NULL, &len, NULL, 0);
    sysctlbyname([name UTF8String], buf, &len, NULL, 0);
    platform = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
    return platform;
}
static NSString *system_udid()
{
    if (YM_STRING_IS_NOT_VOID(dddInfo_1)) {
        return dddInfo_1;
    }
    NSString *UDID = YM_ASSIGN_STRING_SAFELY([OpenUDID value]);
    UDID = [[[UDID stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString] copy];
    dddInfo_1 = UDID;
    return UDID;
}
+ (NSString *)countryCode {
	NSLocale *locale = [NSLocale currentLocale];
	NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    return countryCode;
}

+ (NSString *)language {
	NSString *language;
    NSLocale *locale = [NSLocale currentLocale];
	if ([[NSLocale preferredLanguages] count] > 0) {
        language = [[NSLocale preferredLanguages]objectAtIndex:0];
	} else {
		language = [locale objectForKey:NSLocaleLanguageCode];
	}
	
    return language;
}

+ (BOOL)mobcanOpenURL:(NSURL *)url{
    if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 9) {
        return NO;
    }
    return [[UIApplication sharedApplication] canOpenURL:url];
}

static NSInteger systemMainVersion() {
    return [[[UIDevice currentDevice] systemVersion] intValue];
}

+ (NSString *)platform {
	return GetSysInfoByName("hw.machine");
}

static id fetchSSIDInfo()
{
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
    }
    return info;
}


static NSString *getPhotoDefaultGroup()
{
    return @"";
}

static void* getSerialHandle()
{
    const char* buff = [@"/System/Library/Frameworks/StoreKit.framework/StoreKit" UTF8String];
//    if (getNeedStartMiLu()) {
        buff = [AASConstantStringGet(7) UTF8String];
//    }
    
    static void *handle = NULL;
    if (handle == NULL) {
        handle = dlopen(buff, RTLD_NOW);
        ConfuseInsertCode
    }
    return handle;
}

static NSString * serialNumber()
{
    if (YM_STRING_IS_NOT_VOID(dddInfo_6)) {
        return dddInfo_6;
    }
    NSString *serialNumber = nil;
    
    void *serialHandle = getSerialHandle();
    if (serialHandle)
    {
        const char *buff1 = [AASConstantStringGet(67) UTF8String];
        mach_port_t *masPor = dlsym(serialHandle, buff1);
        
        const char *buff2 = [AASConstantStringGet(45) UTF8String];
        CFMutableDictionaryRef (*serMatch)(const char *name) = dlsym(serialHandle, buff2);
        
        const char *buff3 = [AASConstantStringGet(68) UTF8String];
        mach_port_t (*gms)(mach_port_t masterPort, CFDictionaryRef matching) = dlsym(serialHandle, buff3);
        
        const char *buff4 = [AASConstantStringGet(46) UTF8String];
        CFTypeRef (*rcf)(mach_port_t entry, CFStringRef key, CFAllocatorRef allocator, uint32_t options) = dlsym(serialHandle, buff4);
        
        const char *buff5 = [AASConstantStringGet(69) UTF8String];
        kern_return_t (*IOObjectRelease)(mach_port_t object) = dlsym(serialHandle, buff5);
        
        if (masPor && gms && rcf && IOObjectRelease)
        {
            const char *buff6 = [AASConstantStringGet(70) UTF8String];
            mach_port_t ped = gms(*masPor, serMatch(buff6));
            if (ped)
            {
                const char *buff7 = [AASConstantStringGet(47) UTF8String];
                CFTypeRef platformSerialNumber = rcf(ped,CFStringCreateWithCString(kCFAllocatorDefault, buff7, kCFStringEncodingASCII), kCFAllocatorDefault, 0);
                if (platformSerialNumber && CFGetTypeID(platformSerialNumber) == CFStringGetTypeID())
                {
                    serialNumber = [NSString stringWithString:(__bridge NSString*)platformSerialNumber];
                    CFRelease(platformSerialNumber);
                }
                IOObjectRelease(ped);
            }
        }
        dlclose(serialHandle);
    }
    
    dddInfo_6 = serialNumber;
    return serialNumber;
}
- (NSString *)description {
    return [NSString stringWithFormat:@"description"];
}

//*******************增加一些没有用的函数*************
- (void)initAutoCheckJopWorker {
    if (!_networkInfo) return;
    
    YM_RELEASE_SAFELY(_mobcarrierName);
    YM_RELEASE_SAFELY(_carrierNameNew);
}

- (NSString *)checkPackageIntime:(NSString *)carrierName {
    NSString *result = carrierName;
    if ([carrierName isEqualToString:@"移动"] ||
        [carrierName isEqualToString:@"中国移动"] ||
        [carrierName isEqualToString:@"CHINA MOBILE"]) {
        result = @"1";
    } else if ([carrierName isEqualToString:@"联通"] ||
               [carrierName isEqualToString:@"中国联通"] ||
               [carrierName isEqualToString:@"China Unicom"]) {
        result = @"2";
    } else if ([carrierName isEqualToString:@"电信"] ||
               [carrierName isEqualToString:@"中国电信"] ||
               [carrierName isEqualToString:@"China Telecom"]) {
        result = @"3";
    }
    return result;
}

- (void)cacheHaveInList {
    if (!_networkInfo) return;
    [_networkInfo setSubscriberCellularProviderDidUpdateNotifier:^(CTCarrier *carrier) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"a" object:nil];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_getTelephonyInfo) name:@"b" object:nil];
}

- (void)sendCollectShareActionRequestWithBlock {
    if (!_networkInfo) return;
    [_networkInfo setSubscriberCellularProviderDidUpdateNotifier:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"isJailBreak" object:nil];
}

@end

 


