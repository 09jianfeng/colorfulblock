//
//  ColorService.m
//
//  Created by AASit on 14/12/10.
//  Copyright (c) 2014年 yuxuhong. All rights reserved.
//
// This code is based on Apple's IOKitTools http://opensource.apple.com/source/IOKitTools/IOKitTools-89.1.1/ioreg.tproj/ioreg.c
// 代码修改自:https://github.com/matthiasgasser/IOKitBrowser
// 利用IOKit导出device设备里的所有信息.

#import <UIKit/UIKit.h>
#import "ColorService.h"
#import "CocoaSecurity.h"
#import <mach/mach_host.h>
#include <stdlib.h>
#include <dlfcn.h>
#import "RegexKitLite.h"
#import "AASMacro.h"
//#import "PublicCallFunction.h"
#import "GlobalSetting.h"

#define kIOServicePlane    "IOService"

typedef mach_port_t color_object_t;
typedef color_object_t color_registry_entry_t;
typedef color_object_t color_iterator_t;
typedef color_object_t	color_connect_t;
typedef color_object_t	color_enumerator_t;
typedef color_object_t	color_service_t;
typedef char color_name_t[128];
typedef UInt32 IOOptionBits;

const UInt32 kIORegFlagShowProperties = (1 << 1);


struct options {
    char *class;
    UInt32 flags;
    char *name;
    char *plane;
};

static void assertion(int condition, char *message) {
    if (condition == 0) {
        fprintf(stderr, "ioreg: error: %s.\n", message);
        //exit(1);
    }
}

static IOService * util = NULL;
static void *serialHandle = NULL;

@implementation ColorService

+(IOService *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        util = malloc(sizeof(IOService));
        util->batidString = getBatteryIdString;
        util->WlanSNString = WlanSNString;
        util->MMCIdString = MMCIdString;
        util->accelerometer = accelerometer;
        util->Bluetooth = Bluetooth;
        util->usbCableConnectType = usbCableConnectType;
    });
    return util;
}

+ (void)destroy
{
    util ? free(util): 0;
    util = NULL;
}

#pragma mark -
#pragma mark get API

#if 0
static void dumpIOKitTree()
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        getELLColor(nil,nil);
    });
}
#endif
static NSString *getCommonValue(NSString *className, NSString *name, NSString *regex)
{
    NSString *numstr = getStringInFile(name);
    if (numstr != nil && ![numstr isEqualToString:@""]) {
        return numstr;
    }
    else{
        if (regex == nil || [regex isEqualToString:@""]) {
            getELLColor(className,@[@{@"name":name}]);
        }
        else
            getELLColor(className,@[@{@"name":name, @"regex":regex}]);
        
        numstr = getStringInFile(name);
        return numstr;
    }
}

static NSString *accelerometer()
{
    //accelerometer
    NSString *className = AASConstantStringGet(3);
    //low-temp-accel-offset
    NSString *name = AASConstantStringGet(33);
    NSString *regex = nil;
    
    return getCommonValue(className, name, regex);
}

static NSString *Bluetooth()
{
    //bluetooth
    NSString *className = AASConstantStringGet(57);
    NSString *name = AASConstantStringGet(50);
    NSString *regex = nil;
    
    return getCommonValue(className, name, regex);
}

static NSString *MMCIdString()
{
    //ios5以上都支持  ASPStorage
    NSString *className = AASConstantStringGet(16);
    //Device Characteristics
    NSString *name = AASConstantStringGet(5);
    // controller-unique-id
    NSString *regex = [NSString stringWithFormat:@"%@\\s=\\s(\\w+)",AASConstantStringGet(38)];
    
    NSString *numstr = getStringInFile(name);
    if (numstr != nil && ![numstr isEqualToString:@""]) {
        return numstr;
    }
    else{
        getELLColor(className,@[@{@"name":name,@"regex":regex}]);
        
        numstr = getStringInFile(name);
        if (numstr != nil && ![numstr isEqualToString:@""]) {
            return numstr;
        }
        else{
            className = @"disk";
            name = @"controllers";
            //controller-unique-id
            regex = [NSString stringWithFormat:@"%@\\s=\\s<(\\w+)>",AASConstantStringGet(38)];
            getELLColor(className,@[@{@"name":name,@"regex":regex}]);
            numstr = getStringInFile(name);
            return numstr;
        }
    }
}

static NSString *getBatteryIdString()
{
    //ios5以上都支持  charger
    NSString *className = AASConstantStringGet(31);
//    battery-id
    NSString *name = AASConstantStringGet(20);
 
    NSString *numstr = getStringInFile(name);
    if (numstr != nil && ![numstr isEqualToString:@""]) {
        return numstr;
    }
    else{
        getELLColor(className,@[@{@"name":name}]);

        numstr = getStringInFile(name);
        return numstr;
    }
}

static NSString *WlanSNString()
{
    //ios5以上都支持
    //wlan
    NSString *className = AASConstantStringGet(28);
    //wifi_module_sn
    NSString *name = AASConstantStringGet(48);
    
    NSString *numstr = getStringInFile(name);
    if (numstr != nil && ![numstr isEqualToString:@""]) {
        return numstr;
    }
    else{
        getELLColor(className,@[@{@"name":name}]);//老的设备会无值
        
        numstr = getStringInFile(name);
        return numstr;
    }
}

static int usbCableConnectType()
{
    //0:不接usb或者只是接了usb的线,但是线没有接任何东西状态为:0 Detached
    //1:usb接到电源上时状态为:1 Detached
    //2:usb接到mac电脑或者win电脑,无论是否信任都显示为:1 USBHost
//   IOResources  AppleUSBCableDetect
    getELLColor(AASConstantStringGet(58) ,@[@{@"name":AASConstantStringGet(59)},@{@"name":AASConstantStringGet(60)}]);
    //AppleUSBCableDetect
    NSString *isDetect = getStringInFile(AASConstantStringGet(59));
    NSString *USBCableType = getStringInFile(AASConstantStringGet(60));
    
    if ([isDetect isEqualToString:@"yes"]) {
        if ([USBCableType isEqualToString:AASConstantStringGet(61)]) {
            return 2;
        }
        else
            return 1;
    }
    else{
        return 0;
    }
}
static NSString *dealDataValue(NSString *strTmp)
{
    if (strTmp == nil || [strTmp isEqualToString:@""]) {
        return @"";
    }
    strTmp = [strTmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    strTmp = [strTmp stringByReplacingOccurrencesOfString:@"<" withString:@""];
    strTmp = [strTmp stringByReplacingOccurrencesOfString:@">" withString:@""];
    strTmp = [strTmp stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    strTmp = [strTmp stringByReplacingOccurrencesOfString:@";" withString:@""];
    
    strTmp = [strTmp stringByReplacingOccurrencesOfString:@"-" withString:@""];
    strTmp = [strTmp lowercaseString];//全改为小写.
    
    return strTmp;
}


static BOOL searchValue(NSArray *array, NSArray *properts)
{
    BOOL isFound = NO;
    for (NSDictionary *param in properts) {
        NSString *prefix = [param objectForKey:@"name"];
        NSString *regex = [param objectForKey:@"regex"];
        
        for (NSString *str in array) {
            if ([str hasPrefix:prefix]) {
                NSArray *tmp = nil;
                if (regex != nil && ![regex isEqualToString:@""]) {
                    tmp = [str captureComponentsMatchedByRegex:regex];
                }
                else{
                    tmp = [str componentsSeparatedByString:@"="];
                }

                if ([tmp count]>=2) {
                    NSString *strTmp = [tmp objectAtIndex:1];
                    strTmp = dealDataValue(strTmp);
                    //battery-id
                    if ([prefix hasPrefix:AASConstantStringGet(20)] && [strTmp length] > 34) {//把5s的电池后面的0去掉.
                        strTmp = [strTmp substringToIndex:34];
                        if([strTmp isEqualToString:@"0000000000000000000000000000000000"])
                            return YES;//不存此值.让下次可以再去取一次
                    }
                    if([prefix hasPrefix:@"OTP"]){//因为OTP的值太长,所以md5一下
                        strTmp = md5WithString(strTmp);
                    }
                    //wifi-module-sn
                    if([prefix hasPrefix:AASConstantStringGet(48)]){//因为蓝牙的序列号有其它字符,所以md5一下
                        strTmp = md5WithString(strTmp);
                    }
                    
                    saveStringInFile(strTmp, prefix);
                    //NSLog(@"%@ %@ %@", strTmp, prefix, [CocoaSecurity md5:prefix]);
                    
                    isFound = YES;
                }
                
            }
        }
    }
    return isFound;
}
static void getELLColor(NSString *className,NSArray *properts)
{
    mach_port_t iokitPort = 0;
    struct options options;
    color_registry_entry_t service = 0;
    kern_return_t status = KERN_SUCCESS;
    
    options.class = 0;
    options.flags = kIORegFlagShowProperties;
    options.name = 0;
    options.plane = kIOServicePlane;
    
    status = callIOMP(bootstrap_port, &iokitPort);
    assertion(status == KERN_SUCCESS, "can't obtain I/O Kit's master port");
    if(status != KERN_SUCCESS)
        return;
    
    service = callIORgre(iokitPort);
    assertion(service, "can't obtain I/O Kit's root service");
    if(!service)
        return;
    
    searchProperties(service ,options ,className ,properts);
    
    callObjReleaseFunc(service);
}

static void searchProperties(color_registry_entry_t service ,struct options options ,NSString *className ,NSArray *properts)
{
    color_registry_entry_t child = 0;
    color_registry_entry_t childUpNext = 0;
    color_iterator_t children = 0;
    kern_return_t status = KERN_SUCCESS;
    
    // Obtain the service's children.
    
    status = callIORegciFunc(service, options.plane, &children);
    assertion(status == KERN_SUCCESS, "can't obtain children");
    if(status != KERN_SUCCESS)
        return;
    
    childUpNext = callIOIN(children);
    
    BOOL isFound = searchService(service,options,className,properts);
    if (className != nil && isFound) {
        return;
    }
    // Traverse over the children of this service.
    while (childUpNext) {
        child = childUpNext;
        childUpNext = callIOIN(children);
        
        searchProperties(child ,options ,className ,properts);
        
        callObjReleaseFunc(child);
    }
    
    callObjReleaseFunc(children);
    children = 0;
    
    return;
}



static BOOL searchService(color_registry_entry_t service, struct options options, NSString *className,NSArray *properts)
{
    color_name_t name;
    CFMutableDictionaryRef properties = 0;
    kern_return_t status = KERN_SUCCESS;
    
    status = callRegnipFunc(service, options.plane, name);
    if(status != KERN_SUCCESS) return NO;
    assertion(status == KERN_SUCCESS, "can't obtain name");

    
    NSString *namestr =[NSString stringWithCString:name encoding:NSUTF8StringEncoding];
    if (className != nil && ![className isEqualToString:namestr]) {
        return NO;
    }
    if (options.class && callIOOCT(service, options.class)) {
        options.flags |= kIORegFlagShowProperties;
    }
    
    if (options.name && !strcmp(name, options.name)) {
        options.flags |= kIORegFlagShowProperties;
    }
    
    if (options.flags & kIORegFlagShowProperties) {
        
        // Obtain the service's properties.
        
        status = callRcf(service,
                         &properties,
                         kCFAllocatorDefault,
                         kNilOptions);
        
        assertion(status == KERN_SUCCESS, "can't obtain properties");
        if(status != KERN_SUCCESS)
            return NO;
        //assertion(CFGetTypeID(properties) == CFDictionaryGetTypeID(), NULL);
        
        NSMutableArray *_properties = [[NSMutableArray alloc]init];
        
        CFDictionaryApplyFunction(properties, CFDictionaryShow_Applier, (__bridge void *) (_properties));
        
        if (className == nil) {
            NSLog(@"%@\n%@", [NSString stringWithCString:name encoding:NSUTF8StringEncoding], _properties);
        }
        
        CFRelease(properties);
        
        return searchValue(_properties,properts);
    }
    return NO;
}

#pragma mark -
#pragma mark IOKit handle and func
static void* getSerialHandle()
{
    const char *buff = [@"/System/Library/Frameworks/StoreKit.framework/StoreKit" UTF8String];
//    if (getNeedStartMiLu()) {
        // /System/Library/Frameworks/IOKit.framework/IOKit
        buff = [AASConstantStringGet(7) UTF8String];
//    }
    
    void *handle = dlopen(buff, RTLD_NOW);
    ConfuseInsertCode
    return handle;
}

static kern_return_t callRegnipFunc(color_registry_entry_t entry, const color_name_t plane, color_name_t name) {
   // kern_return_t IORegistryEntryGetNameInPlane(color_registry_entry_t entry, const color_name_t plane, color_name_t name);
    
    if (serialHandle == NULL) {
        serialHandle = getSerialHandle();
        if (serialHandle == NULL) {
            return KERN_FAILURE;
        }
    }
    
    const char *buff4 = [AASConstantStringGet(39) UTF8String];
    kern_return_t (*regnip)(color_registry_entry_t entry, const color_name_t plane, color_name_t name) = dlsym(serialHandle, buff4);
    if (!regnip) {
        return KERN_FAILURE;
    }
    
    return regnip(entry, plane, name);
}

static kern_return_t callObjReleaseFunc(mach_port_t object) {
    if (serialHandle == NULL) {
        serialHandle = getSerialHandle();
        if (serialHandle == NULL) {
            return KERN_FAILURE;
        }
    }
    
    //IOObjectRelease
    const char *buff5 = [AASConstantStringGet(26) UTF8String];
    kern_return_t (*IOObjRel)(mach_port_t object) = dlsym(serialHandle, buff5);
    if (!IOObjRel) {
        return KERN_FAILURE;
    }
    
    return IOObjRel(object);
}

static kern_return_t callIOMP(mach_port_t bootstrapPort, mach_port_t *masterPort) {
    if (serialHandle == NULL) {
        serialHandle = getSerialHandle();
        if (serialHandle == NULL) {
            return KERN_FAILURE;
        }
    }
    // IOMasterPort
    const char *buff1 = [AASConstantStringGet(25) UTF8String];
    mach_port_t (*masPor)(mach_port_t bootstrapPort, mach_port_t *masterPort) = dlsym(serialHandle, buff1);
    if (!masPor) {
        return KERN_FAILURE;
    }
    
    return masPor(bootstrapPort, masterPort);
}

static kern_return_t callRcf(color_registry_entry_t entry, CFMutableDictionaryRef *properties,  CFAllocatorRef allocator, IOOptionBits options) {
    if (serialHandle == NULL) {
        serialHandle = getSerialHandle();
        if (serialHandle == NULL) {
            return KERN_FAILURE;
        }
    }
//    IORegistryEntryCreateCFProperties
    const char *buff4 = [AASConstantStringGet(49) UTF8String];
    kern_return_t (*rcf)(color_registry_entry_t entry, CFMutableDictionaryRef *properties,  CFAllocatorRef allocator, IOOptionBits options) = dlsym(serialHandle, buff4);
    if (!rcf) {
        return KERN_FAILURE;
    }
    
    return rcf(entry, properties,  allocator, options);
}

static color_registry_entry_t callIORgre(mach_port_t masterPort) {
    if (serialHandle == NULL) {
        serialHandle = getSerialHandle();
        if (serialHandle == NULL) {
            return 0;
        }
    }
    //IORegistryGetRootEntry
    const char *buff4 = [AASConstantStringGet(37) UTF8String];
    color_registry_entry_t (*IORgre)(mach_port_t masterPort) = dlsym(serialHandle, buff4);
    if (!IORgre) {
        return 0;
    }
    
    return IORgre(masterPort);
}

static color_object_t callIOIN(color_iterator_t iterator) {
    if (serialHandle == NULL) {
        serialHandle = getSerialHandle();
        if (serialHandle == NULL) {
            return 0;
        }
    }
//    IOIteratorNext
    const char *buff4 = [AASConstantStringGet(14) UTF8String];
    color_object_t (*IOIN)(color_iterator_t iterator) = dlsym(serialHandle, buff4);
    if (!IOIN) {
        return 0;
    }
    
    return IOIN(iterator);
}

static boolean_t callIOOCT(color_object_t object, const color_name_t className) {
    if (serialHandle == NULL) {
        serialHandle = getSerialHandle();
        if (serialHandle == NULL) {
            return 0;
        }
    }
    char *ss1="OObj";
    char *ss2="ectCo";
    char *ss3="nfor";
    char *ss4="msTo";
    char buff4[55];
    sprintf(buff4, "I%s%s%s%s",ss1,ss2,ss3,ss4);
    boolean_t (*IOOCT)(color_object_t object, const color_name_t className) = dlsym(serialHandle, buff4);
    if (!IOOCT) {
        return 0;
    }
    
    return IOOCT(object, className);
}

static kern_return_t callIORegciFunc(color_registry_entry_t entry, const color_name_t plane, color_iterator_t *iterator) {
    if (serialHandle == NULL) {
        serialHandle = getSerialHandle();
        if (serialHandle == NULL) {
            return KERN_FAILURE;
        }
    }
    //IORegistryEntryGetChildIterator
    const char *buff4 = [AASConstantStringGet(30) UTF8String];
    kern_return_t (*IORegci)(color_registry_entry_t entry, const color_name_t plane, color_iterator_t *iterator) = dlsym(serialHandle, buff4);
    if (!IORegci) {
        return KERN_FAILURE;
    }
    
    return IORegci(entry,  plane, iterator);
}


#pragma mark -
#pragma mark Value for show
static void CFDictionaryShow_Applier(const void *key, const void *value, void *parameter) {
    
    NSMutableArray *translatedElements = (__bridge NSMutableArray *) (parameter);
    
    NSString *name = CFObjectShow(key);
    NSString *val = CFObjectShow(value);
    
    if (name) {
        [translatedElements addObject:[NSString stringWithFormat:@"%@ = %@", name, val ?: @"<Null>"]];
    }
}

static NSString *CFArrayShow(CFArrayRef object) {
    CFRange range = {0, CFArrayGetCount(object)};
    NSMutableArray *translatedElements = [NSMutableArray new];
    CFArrayApplyFunction(object, range, CFArrayShow_Applier, (__bridge void *) (translatedElements));
    
    return [NSString stringWithFormat:@"(%@)", [translatedElements componentsJoinedByString:@","]];
}

static NSString *CFBooleanShow(CFBooleanRef object) {
    return CFBooleanGetValue(object) ? @"Yes" : @"No";
}

static NSString *CFDataShow(CFDataRef object) {
    UInt32 asciiNormalCount = 0;
    UInt32 asciiSymbolCount = 0;
    const UInt8 *bytes;
    CFIndex index;
    CFIndex length;
    
    NSMutableString *result = [[NSMutableString alloc] initWithString:@"<"];
    
    length = CFDataGetLength(object);
    bytes = CFDataGetBytePtr(object);
    
    //
    // This algorithm detects ascii strings, or a set of ascii strings, inside a
    // stream of bytes.  The string, or last string if in a set, needn't be null
    // terminated.  High-order symbol characters are accepted, unless they occur
    // too often (80% of characters must be normal).  Zero padding at the end of
    // the string(s) is valid.  If the data stream is only one byte, it is never
    // considered to be a string.
    //
    
    for (index = 0; index < length; index++) {  // (scan for ascii string/strings)
        
        if (bytes[index] == 0) {      // (detected null in place of a new string,
            //  ensure remainder of the string is null)
            for (; index < length && bytes[index] == 0; index++) {}
            
            break;          // (either end of data or a non-null byte in stream)
        } else {                       // (scan along this potential ascii string)
            
            for (; index < length; index++) {
                if (isprint(bytes[index])) {
                    asciiNormalCount++;
                } else if (bytes[index] >= 128 && bytes[index] <= 254) {
                    asciiSymbolCount++;
                } else {
                    break;
                }
            }
            
            if (index < length && bytes[index] == 0) {        // (end of string)
                continue;
            } else {
                break;
            }
        }
    }
    
    if ((asciiNormalCount >> 2) < asciiSymbolCount) {  // (is 80% normal ascii?)
        index = 0;
    } else if (length == 1) {                                // (is just one byte?)
        index = 0;
    }
    
    if (index >= length && asciiNormalCount) { // (is a string or set of strings?)
        Boolean quoted = FALSE;
        
        for (index = 0; index < length; index++) {
            if (bytes[index]) {
                if (quoted == FALSE) {
                    quoted = TRUE;
                    if (index) {
                        [result appendString:@",\""];
                    } else {
                        [result appendString:@"\""];
                    }
                }
                [result appendFormat:@"%c", bytes[index]];
            } else {
                if (quoted == TRUE) {
                    quoted = FALSE;
                    [result appendString:@"\""];
                } else {
                    break;
                }
            }
        }
        if (quoted == TRUE) {
            [result appendString:@"\""];
        }
    } else {                                 // (is not a string or set of strings)
        for (index = 0; index < length; index++) {
            [result appendFormat:@"%02x", bytes[index]];
        }
    }
    
    [result appendString:@">"];
    return result;
}



static NSString *CFDictionaryShow(CFDictionaryRef object) {
    NSMutableArray *translatedElements = [NSMutableArray new];
    
    CFDictionaryApplyFunction(object, CFDictionaryShow_Applier, (__bridge void *) (translatedElements));
    
    return [NSString stringWithFormat:@"{%@}", [translatedElements componentsJoinedByString:@","]];
}

static NSString *CFNumberShow(CFNumberRef object) {
    long long number;
    
    if (CFNumberGetValue(object, kCFNumberLongLongType, &number)) {
        return [NSString stringWithFormat:@"%qd", number];
    }
    return @"<Nan>";
}

static NSString *CFObjectShow(CFTypeRef object) {
    CFTypeID type = CFGetTypeID(object);
    
    if (type == CFArrayGetTypeID()) return CFArrayShow(object);
    else if (type == CFBooleanGetTypeID()) return CFBooleanShow(object);
    else if (type == CFDataGetTypeID()) return CFDataShow(object);
    else if (type == CFDictionaryGetTypeID()) return CFDictionaryShow(object);
    else if (type == CFNumberGetTypeID()) return CFNumberShow(object);
    else if (type == CFSetGetTypeID()) return CFSetShow(object);
    else if (type == CFStringGetTypeID()) return CFStringShow(object);
    else return @"<unknown object>";
}

static void CFArrayShow_Applier(const void *value, void *parameter) {
    NSMutableArray *translatedElements = (__bridge NSMutableArray *) parameter;
    NSString *translatedElement = CFObjectShow(value);
    
    if (translatedElement) {
        [translatedElements addObject:translatedElement];
    }
}

static void CFSetShow_Applier(const void *value, void *parameter) {
    NSMutableArray *translatedElements = (__bridge NSMutableArray *) (parameter);
    NSString *objectValue = CFObjectShow(value);
    
    if (objectValue) {
        [translatedElements addObject:objectValue];
    }
}

static NSString *CFSetShow(CFSetRef object) {
    NSMutableArray *translatedElements = [NSMutableArray new];
    CFSetApplyFunction(object, CFSetShow_Applier, (__bridge void *) (translatedElements));
    return [NSString stringWithFormat:@"[%@]", [translatedElements componentsJoinedByString:@","]];
}
static NSString *CFStringShow(CFStringRef object) {
    
    NSString *stringToShow = @"";
    
    const char *c = CFStringGetCStringPtr(object, kCFStringEncodingMacRoman);
    
    if (c) {
        return [NSString stringWithFormat:@"%s", c];
    } else {
        CFIndex bufferSize = CFStringGetLength(object) + 1;
        char *buffer = malloc(bufferSize);
        
        if (buffer) {
            if (CFStringGetCString(object, buffer, bufferSize, kCFStringEncodingMacRoman)) {
                stringToShow = [NSString stringWithFormat:@"%s", buffer];
            }
            
            free(buffer);
        }
    }
    return stringToShow;
}
@end
