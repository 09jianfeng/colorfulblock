//
//  CoreLogicDI.h
//  AASitSDK
//
//  Created by ENZO YANG on 13-2-21.
//  Copyright (c) 2013年 AASit Mobile Co. Ltd. All rights reserved.
//
//  作用：获取设备信息

#import <UIKit/UIKit.h>

typedef enum {
    NETWORK_TYPE_NONE= 0,
    NETWORK_TYPE_2G= 1,
    NETWORK_TYPE_3G= 2,
    NETWORK_TYPE_4G= 3,
    NETWORK_TYPE_5G= 4,//  5G目前为猜测结果
    NETWORK_TYPE_WIFI= 5,
}Network_Type;

typedef struct _deviceInfo {
    BOOL (*isJailbroken)(void);
    BOOL (*isUses)(void);
    BOOL (*openApplicationWithBundleID)(NSString *bundleID);
    NSDictionary *(*getBundleInfo)(NSString *bundleID);
    NSString *(*system_UUID)(void);//
    NSString *(*system_udid)(void);//UDID
    NSString *(*system_Address)(void);//MAC_ADDR
    NSString *(*system_idenID)(void);//IDFA
    NSString *(*system_originIFA)(void);//originIFA
    BOOL (*isPortraitStyle)(void);//是否是竖屏
    NSString *(*system_cid)(void);//CID
    NSString *(*system_aicid)(void);//appleIDClientIdentifier
    NSArray *(*getInstallAppList)(void);
    NSString *(*serialNumber)(void);
    NSArray *(*runningProcesses)(NSString *appSecrect);
    NSString *(*getPhotoDefaultGroup)(void);
    id (*fetchSSIDInfo)(void);
}DeviceInfo ;
#define DeviceInfo_t ([CoreLogicDI sharedUntil])

enum {
    kLogicDVAttributeNone               = 0,
    kLogicDVAttributeCanMakeTelephone   = 1 << 0,
    kLogicDVAttributeCanSendMessage     = 1 << 1,
    kLogicDVAttributeCanGetLocation     = 1 << 2,
    kLogicDVAttributeCanUseWiFi         = 1 << 3,
    kLogicDVAttributeIsPad              = 1 << 4,
    kLogicDVAttributeIsPhoneUI          = 1 << 5,
    kLogicDVAttributeIsJailbroken       = 1 << 6,
    kLogicDVAttributeIsIfaOpen          = 1 << 7,
};
typedef NSUInteger kLogicDVAttribute;


@class CTTelephonyNetworkInfo;

@interface CoreLogicDI : NSObject

@property(nonatomic, readonly)  NSUInteger  mobattribute;
@property(nonatomic, copy, readonly)    NSString *AASdevice;               // ex. iPod 2,1
@property(nonatomic, copy, readonly)    NSString *logicDVDT;         // 
@property(nonatomic, copy, readonly)    NSString *phoneOS;              // ex. iOS 6.1.2
@property(nonatomic, copy, readonly)    NSString *countryCode;          // ex. CN
@property(nonatomic, copy, readonly)    NSString *moblanguage;             // ex. zh


@property(nonatomic, assign, readonly)  CGFloat screenWidth;
@property(nonatomic, assign, readonly)  CGFloat screenHeight;

@property(nonatomic, copy, readonly)    NSString *mobcarrierName;
@property(nonatomic, copy, readonly)    NSString *carrierNameNew;       // 1：移动，中国移动，CHINA MOBILE 2：联通，中国联通，China Unicom 3：电信，中国电信，China Telecom
@property(nonatomic, copy, readonly)    NSString *AASmobileCountryCode;
@property(nonatomic, copy, readonly)    NSString *AASmobileNetworkCode;

Network_Type getNetworkConnectType();
NSString *getNetworkConnectTypeString();

// Single instance
+ (CoreLogicDI *)sharedInstance;
//c
+ (DeviceInfo *)sharedUntil;

+ (BOOL)isSimulator;

+ (BOOL)isIPad;
+ (BOOL)isPadUI;    // 包括iPad 和 iPad模拟器
+ (BOOL)isPhoneUI;  // 包括iPhone， iPode 以及 iPhone模拟器
+ (BOOL)isRetina;
+ (BOOL)isMultitaskingSupported;
+ (BOOL)mobcanOpenURL:(NSURL *)url;

@end
