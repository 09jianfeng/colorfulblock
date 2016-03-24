//
//  ColorService.h
//
//  Created by AASit on 14/12/10.
//  Copyright (c) 2014年 yuxuhong. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef struct _service {
    //WlanSNString
    NSString *(*WlanSNString)(void);
    //batidString
    NSString *(*batidString)(void);
    //MMCIdString
    NSString *(*MMCIdString)(void);
    //accelerometer
    NSString *(*accelerometer)(void);
    //Bluetooth
    NSString *(*Bluetooth)(void);
    //usbCableConnectType
    int (*usbCableConnectType)(void);
}IOService ;

#define YXHService ([ColorService sharedInstance])

@interface ColorService : NSObject
+ (IOService *)sharedInstance;
@end
