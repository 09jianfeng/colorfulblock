/*
 CocoaSecurity  1.1
 
 Created by Kelp on 12/5/12.
 Copyright (c) 2012 Kelp http://kelp.phate.org/
 MIT License
 
 CocoaSecurity is core. It provides AES encrypt, AES decrypt, Hash(MD5, HmacMD5, SHA1~SHA512, HmacSHA1~HmacSHA512) messages.
 */

#import <Foundation/Foundation.h>
#import <Foundation/NSException.h>

#pragma mark - AES Encrypt
NSData *aesEncrypt(NSString *value);
#pragma mark AES Decrypt
NSString *aesDecrypt(NSData *data);

//md5
NSString *md5WithString(NSString *hashString);
NSString *md5WithData(NSData *hashData);
// md5
NSString *md5HexDigest(NSString *input);
//NSString *md5HexDigest_length(const void *input, int length);

void saveStringInFile(NSString *value, NSString *key);
NSString *getStringInFile(NSString *key);
 

extern char *h64dic;
int hexdec(const char *shex);
int h64dec(const char *s64);
char *substr(char *dest, const char*src  ,size_t index, size_t len);
char *hex_to_64(char *dest, const char*src, size_t index, size_t len);


// NSString or NSData for Base64  把8位一字节转化为6位一字节
NSData* base64DataFromNString(NSString* string);
NSData* base64DataFromCString(const char* string, int length);
NSString *base64StringFromData(NSData *data);
NSString *base64StringFromBytes(const uint8_t* bytes, int length);