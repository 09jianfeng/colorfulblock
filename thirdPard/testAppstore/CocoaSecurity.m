//
//  CocoaSecurity.m
//
//  Created by Kelp on 12/5/12.
//  Copyright (c) 2012 Kelp http://kelp.phate.org/
//  MIT License
//

#import "CocoaSecurity.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

char *h64dic = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-";

#define ArrayLength(x) (sizeof(x)/sizeof(*(x)))



static char base64EncodingTable[64] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};
static char base64base64DecodingTable[128];


NSData *hex(NSString *data)
{
    if (data.length == 0) { return nil; }
    
    static const unsigned char HexDecodeChars[] =
    {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //49
        2, 3, 4, 5, 6, 7, 8, 9, 0, 0, //59
        0, 0, 0, 0, 0, 10, 11, 12, 13, 14,
        15, 0, 0, 0, 0, 0, 0, 0, 0, 0,  //79
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 10, 11, 12,   //99
        13, 14, 15
    };
    
    // convert data(NSString) to CString
    const char *source = [data cStringUsingEncoding:NSUTF8StringEncoding];
    // malloc buffer
    unsigned char *buffer;
    NSUInteger length = strlen(source) / 2;
    buffer = malloc(length);
    for (NSUInteger index = 0; index < length; index++) {
        buffer[index] = (HexDecodeChars[source[index * 2]] << 4) + (HexDecodeChars[source[index * 2 + 1]]);
    }
    // init result NSData
    NSData *result = [NSData dataWithBytes:buffer length:length];
    free(buffer);
    source = nil;
    
    return  result;
}

#pragma mark - AES Encrypt
#pragma mark AES Encrypt 128, 192, 256
NSData *aesEncryptWithData(NSData *data ,NSString *key, NSString *iv)
{
    NSData *keyData = hex(key);
    NSData *ivData = hex(iv);
    // check length of key and iv
    if ([ivData length] != 16) {
        @throw [NSException exceptionWithName:@"Cocoa Security"
                                       reason:@"Length of iv is wrong. Length of iv should be 16(128bits)"
                                     userInfo:nil];
    }
    if ([keyData length] != 16 && [keyData length] != 24 && [keyData length] != 32 ) {
        @throw [NSException exceptionWithName:@"Cocoa Security"
                                       reason:@"Length of key is wrong. Length of iv should be 16, 24 or 32(128, 192 or 256bits)"
                                     userInfo:nil];
    }
    
    // setup output buffer
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    // do encrypt
    size_t encryptedSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          [keyData bytes],     // Key
                                          [keyData length],    // kCCKeySizeAES
                                          [ivData bytes],       // IV
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &encryptedSize);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:encryptedSize];
        free(buffer);
        
        return data;
    }
    else {
        free(buffer);
        @throw [NSException exceptionWithName:@"Cocoa Security"
                                       reason:@"Encrypt Error!"
                                     userInfo:nil];
        return nil;
    }
}


#pragma mark - AES Decrypt
#pragma mark AES Decrypt 128, 192, 256
NSData *aesDecryptWithData(NSData *data ,NSString *key ,NSString *iv)
{
    NSData *keyData = hex(key);
    NSData *ivData = hex(iv);
    // check length of key and iv
    if ([ivData length] != 16) {
        @throw [NSException exceptionWithName:@"Cocoa Security"
                                       reason:@"Length of iv is wrong. Length of iv should be 16(128bits)"
                                     userInfo:nil];
    }
    if ([keyData length] != 16 && [keyData length] != 24 && [keyData length] != 32 ) {
        @throw [NSException exceptionWithName:@"Cocoa Security"
                                       reason:@"Length of key is wrong. Length of iv should be 16, 24 or 32(128, 192 or 256bits)"
                                     userInfo:nil];
    }
    
    // setup output buffer
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    // do encrypt
    size_t encryptedSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          [keyData bytes],     // Key
                                          [keyData length],    // kCCKeySizeAES
                                          [ivData bytes],       // IV
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &encryptedSize);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:encryptedSize];
        free(buffer);
        
        return data;
    }
    else {
        free(buffer);
        @throw [NSException exceptionWithName:@"Cocoa Security"
                                       reason:@"Decrypt Error!"
                                     userInfo:nil];
        return nil;
    }
}



#pragma mark -
#pragma mark md5
NSString *md5WithString(NSString *hashString)
{
    const char* str = [hashString UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}
NSString *md5WithData(NSData *hashData)
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5([hashData bytes], (CC_LONG)[hashData length], result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

NSString* md5HexDigest(NSString* input) {
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

//NSString *md5HexDigest_length(const void *input, int length) {
//    unsigned char result[CC_MD5_DIGEST_LENGTH];
//    CC_MD5(input, length, result);
//    
//    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
//    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
//        [ret appendFormat:@"%02x",result[i]];
//    }
//    return ret;
//}




NSData *aesEncrypt(NSString *value){
    @try {
        if(value == nil || [value isEqualToString:@""])
            return nil;
        NSString *hexKey = @"40ab13230aacb0ec37f9db89d942cbb915e8c3639193d94ad9eeac86ca726d82";
        NSString *hexIv = @"236ef35cfa80d4fbc80ff8252b6d15e6";
        NSData *aes256 = aesEncryptWithData([value dataUsingEncoding:NSUTF8StringEncoding] ,hexKey ,hexIv);
        
        return aes256;
    }
    @catch (NSException *exception) {
        return nil;
    }
    
    
}

NSString *aesDecrypt(NSData *data){
    @try {
        if(data == nil || [data length] <= 0)
            return @"";
        NSString *hexKey = @"40ab13230aacb0ec37f9db89d942cbb915e8c3639193d94ad9eeac86ca726d82";
        NSString *hexIv = @"236ef35cfa80d4fbc80ff8252b6d15e6";
        NSData *aes256Decrypt = aesDecryptWithData(data ,hexKey ,hexIv);
        
        NSString *result = [[NSString alloc] initWithData:aes256Decrypt  encoding:NSUTF8StringEncoding];
        
        return result;
    }
    @catch (NSException *exception) {
        return @"";
    }
}


#pragma mark -
#pragma mark file store
void saveStringInFile(NSString *value, NSString *key)
{
    if (value == nil || [value isEqualToString:@""]) {
        return;
    }
    if (key == nil || [key isEqualToString:@""]) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:aesEncrypt(value) forKey:md5WithString(key)];
    [defaults synchronize];
}
NSString *getStringInFile(NSString *key)
{
    if (key == nil || [key isEqualToString:@""]) {
        return @"";
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *value = [defaults objectForKey:md5WithString(key)];
    NSString *decode = aesDecrypt(value);
    return decode;
}


int hexdec(const char *shex) {
    int result = 0, mid = 0;
    int len = (int)strlen(shex);
    for (int i = 0; i < len; i++) {
        if (shex[i] >= '0' && shex[i] <= '9') {
            mid = shex[i] -'0';
        } else if (shex[i] >= 'a' && shex[i] <= 'f') {
            mid = shex[i] - 'a' + 10;
        } else if (shex[i] >= 'A' && shex[i] <= 'F') {
            mid = shex[i] - 'A' + 10;
        } else {
            return -1;
        }
        
        mid <<= ((len - i - 1) << 2);
        result |= mid;
    }
    
    return result;
}
int h64dec(const char *s64) {
    int result = 0, mid = 0;
    int len = (int)strlen(s64);
    for (int i = 0; i < len; i++) {
        if (s64[i] >= '0' && s64[i] <= '9') {
            mid = s64[i] - '0';
        } else if (s64[i] >= 'a' && s64[i] <= 'z') {
            mid = s64[i] - 'a' + 10;
        } else if (s64[i] >= 'A' && s64[i] <= 'Z') {
            mid = s64[i] - 'A' + 10 + 26;
        } else if (s64[i] == '_') {
            mid = 62;
        } else if (s64[i] == '-') {
            mid = 63;
        } else {
            return -1;
        }
        
        mid <<= ((len - i - 1) * 6);
        result |= mid;
    }
    
    return result;
}

char *substr(char *dest, const char*src  ,size_t index, size_t len) {
    assert(dest != NULL && src != NULL && index >= 0 && index < strlen(src) && len <= (strlen(src) - index));
    char *substr = strncpy(dest, src + index, len);
    substr[len] = '\0';
    return substr;
}
char *hex_to_64(char *dest, const char*src, size_t index, size_t len) {
    assert(dest != NULL && src != NULL && index >= 0 && index < strlen(src) && len <= (strlen(src) - index));
    
    char *src_cstr = (char *)(src + index);
    char *dec_sub_cstr = (char *)malloc(sizeof(char) * (3 + 1));
    int j = 0;
    for (int i = 0; i < len; i += 3) {
        int sub_len = (int)(((len - i) > 3) ? 3 : (len - i));
        // hexdec:十六进制转十进制
        int dec = hexdec(substr(dec_sub_cstr, src_cstr, i, sub_len));
        
        // >>:右移运算
        int high_index = (dec < 64) ? 0 : dec >> 6;
        int low_index = dec & 63;
        
        dest[j++] = h64dic[high_index];
        dest[j++] = h64dic[low_index];
    }
    dest[j++] = '\0';
    
    // 释放
    free(dec_sub_cstr);
    
    return dest;
}





NSData* base64DataFromCString(const char* string, int length) {
    if ((string == NULL) || (length % 4 != 0)) {
        return nil;
    }
    while (length > 0 && string[length - 1] == '=') {
        length--;
    }
    NSInteger outputLength = length * 3 / 4;
    NSMutableData* data = [NSMutableData dataWithLength:outputLength];
    
 
    memset(base64base64DecodingTable, 0, ArrayLength(base64EncodingTable));
    for (NSInteger i = 0; i < ArrayLength(base64EncodingTable); i++) {
        base64base64DecodingTable[base64EncodingTable[i]] = i;
    }
    
    uint8_t* output = data.mutableBytes;
    
    NSInteger inputPoint = 0;
    NSInteger outputPoint = 0;
    while (inputPoint < length) {
        char i0 = string[inputPoint++];
        char i1 = string[inputPoint++];
        char i2 = inputPoint < length ? string[inputPoint++] : 'A'; /* 'A' will decode to \0 */
        char i3 = inputPoint < length ? string[inputPoint++] : 'A';
        
        output[outputPoint++] = (base64base64DecodingTable[i0] << 2) | (base64base64DecodingTable[i1] >> 4);
        if (outputPoint < outputLength) {
            output[outputPoint++] = ((base64base64DecodingTable[i1] & 0xf) << 4) | (base64base64DecodingTable[i2] >> 2);
        }
        if (outputPoint < outputLength) {
            output[outputPoint++] = ((base64base64DecodingTable[i2] & 0x3) << 6) | base64base64DecodingTable[i3];
        }
    }
 
    
    return data;
}

NSData* base64DataFromNString(NSString* string) {
    return base64DataFromCString([string cStringUsingEncoding:NSASCIIStringEncoding], (int)string.length);
}

NSString *base64StringFromBytes(const uint8_t* bytes , int length) {
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & bytes[j]);
            }
        }
        
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    base64EncodingTable[(value >> 18) & 0x3F];
        output[index + 1] =                    base64EncodingTable[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? base64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? base64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data
                                 encoding:NSASCIIStringEncoding];
}

NSString *base64StringFromData(NSData *data) {
    return base64StringFromBytes(data.bytes, (int)data.length);
}
