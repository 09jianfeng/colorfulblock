//
//  GameKeyValue.m
//  HuaiNanVideoSDK
//
//  Created by ENZO YANG on 13-3-5.
//  Copyright (c) 2013年 HuaiNanVideoSDK Mobile Co. Ltd. All rights reserved.
//

#import "GameKeyValue.h"

static NSString *const kGameKeyValueFileName = @"Game.dict";

@interface GameKeyValue()

@property (nonatomic, retain) NSMutableDictionary *dict;

@end

@implementation GameKeyValue

+ (GameKeyValue *)sharedInstance {
    static GameKeyValue *keyValue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyValue = [GameKeyValue new];
    });
    return keyValue;
}

- (id)init {
    self = [super init];
    if (self) {
        self.dict = (NSMutableDictionary *)[GameKeyValue deserializeObjectAtPath:[self filePath]];
        if (!self.dict) self.dict = [NSMutableDictionary dictionaryWithCapacity:5];
        [self _addObservers];
    }
    return self;
}

- (void)dealloc {
    [self _removeObservers];
    self.dict = nil;
}

- (NSString *)filePath {
    NSString *folder = [[GameKeyValue libraryPath] stringByAppendingPathComponent:@"HNVideoSDK"];
    [GameKeyValue createFolderAtPath:folder];
    return [folder stringByAppendingPathComponent:kGameKeyValueFileName];
}

- (void)_addObservers {
    // 添加观察者，若程序将要退出则保存数据
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_applicationWillTerminate:)
												 name:UIApplicationWillTerminateNotification
											   object:nil];
	
	
    
    // 进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)_removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_applicationWillTerminate:(NSNotification *)notification {
	[GameKeyValue synchronize];
}

- (void)_applicationWillResignActive:(NSNotification *)note {
	[GameKeyValue synchronize];
}


+ (BOOL)existValueOfKey:(NSString *)key {
    return ([self objectForKey:key] != nil);
}

+ (id)objectForKey:(NSString *)key {
    @synchronized(self) {
        return [[self sharedInstance].dict objectForKey:key];
    }
}

+ (NSString *)stringForKey:(NSString *)key {
    NSString *str = [self objectForKey:key];
    if (![str isKindOfClass:[NSString class]]) return nil;
    return str;
}

+ (NSArray *)arrayForKey:(NSString *)key {
    NSArray *arr = [self objectForKey:key];
    if (![arr isKindOfClass:[NSArray class]]) return nil;
    return arr;
}

+ (NSDictionary *)dictionaryForKey:(NSString *)key {
    NSDictionary *dict = [self objectForKey:key];
    if (![dict isKindOfClass:[NSDictionary class]]) return nil;
    return dict;
}

+ (CGFloat)floatForKey:(NSString *)key {
    NSNumber *num = [self objectForKey:key];
    if (![num isKindOfClass:[NSNumber class]]) return 0.0f;
    return [num floatValue];
}

+ (NSInteger)integerForKey:(NSString *)key {
    NSNumber *num = [self objectForKey:key];
    if (![num isKindOfClass:[NSNumber class]]) return 0;
    return [num integerValue];
}

+ (BOOL)boolForKey:(NSString *)key {
    NSNumber *num = [self objectForKey:key];
    if (![num isKindOfClass:[NSNumber class]]) return NO;
    return [num boolValue];
}

+ (void)setObject:(id)object forKey:(NSString *)key {
    if (object == nil) {
        return;
    }
    @synchronized(self) {
        [[self sharedInstance].dict setObject:object forKey:key];
    }
}

+ (void)setString:(NSString *)string forKey:(NSString *)key {
    if (![string isKindOfClass:[NSString class]]) {
        return;
    }
    [self setObject:string forKey:key];
}

+ (void)setArray:(NSArray *)array forKey:(NSString *)key {
    if (![array isKindOfClass:[NSArray class]]) {
        return;
    }
    [self setObject:array forKey:key];
}

+ (void)setDictionary:(NSDictionary *)dictionary forKey:(NSString *)key {
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }
    [self setObject:dictionary forKey:key];
}

+ (void)setFloat:(CGFloat)number forKey:(NSString *)key {
    NSNumber *n = [NSNumber numberWithFloat:number];
    [self setObject:n forKey:key];
}

+ (void)setIntegerForKey:(NSInteger)number forKey:(NSString *)key {
    NSNumber *n = [NSNumber numberWithInteger:number];
    [self setObject:n forKey:key];
}

+ (void)setBoolForKey:(BOOL)number forKey:(NSString *)key {
    NSNumber *n = [NSNumber numberWithBool:number];
    [self setObject:n forKey:key];
}

+ (void)removeObjectForKey:(NSString *)key {
    @synchronized(self) {
        [[self sharedInstance].dict removeObjectForKey:key];
    }
}

+ (void)synchronize {
    @synchronized(self) {
        [GameKeyValue serializeObject:[self sharedInstance].dict toPath:[[self sharedInstance] filePath]];
    }
}

+ (NSObject*)deserializeObjectAtPath:(NSString*)path {
    // 如果文件不存在 则 返回nil
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return nil;
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSObject *obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return obj;
}

+ (NSString*)libraryPath {
    static NSString *path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *pathArray =  nil;
        pathArray = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        path = [pathArray objectAtIndex:0];
    });
    return path;
}

+ (BOOL)createFolderAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        return [fileManager createDirectoryAtPath:path
                      withIntermediateDirectories:YES
                                       attributes:nil
                                            error:NULL];
    }
    return YES;
}

+ (void)serializeObject:(NSObject*)obj toPath:(NSString*)path {
    if (obj == nil) {
        [GameKeyValue deleteFile:path];
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [data writeToFile:path atomically:YES];
}

+ (BOOL)deleteFile:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:path error:nil];
}

@end
