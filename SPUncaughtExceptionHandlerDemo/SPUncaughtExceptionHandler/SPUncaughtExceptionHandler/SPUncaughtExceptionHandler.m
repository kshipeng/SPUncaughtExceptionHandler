//
//  SPUncaughtExceptionHandler.m
//  PageController
//
//  Created by 康世朋 on 16/8/10.
//  Copyright © 2016年 SP. All rights reserved.
//  Demo地址:https://github.com/kshipeng/SPUncaughtExceptionHandler
//

#import "SPUncaughtExceptionHandler.h"
#import <UIKit/UIKit.h>
#include <libkern/OSAtomic.h>
#include <execinfo.h>

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";
volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;
const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

@interface SPUncaughtExceptionHandler ()
{
    BOOL dismissed;
    NSString *_message_my;
    NSString *_message_alert;
    NSString *_message_exception;
    NSString *_title_alert;
    void (^action)(NSString *msg);
    void (^handleBlock)(NSString *path);
}
@property (nonatomic, assign) BOOL showInfor;
@property (nonatomic, assign) BOOL show_alert;
@property (nonatomic, retain) NSString *logFilePath;
@end

BOOL finish;

@implementation SPUncaughtExceptionHandler
+ (instancetype)shareInstance {
    static SPUncaughtExceptionHandler *single = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        single = [[self alloc]init];
        single.showInfor = YES;
        single.show_alert = YES;
        // 1.获取Documents路径
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        // 2.创建文件路径
        NSString *filePath = [docPath stringByAppendingPathComponent:@"ExceptionLog_sp.txt"];
        // 3.使用文件管理对象创建文件
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:filePath]) {
            [fileManager createFileAtPath:filePath contents:[@">>>>>>>程序异常日志<<<<<<<<\n" dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
        }
        single.logFilePath = filePath;
    });
    return single;
}

+ (NSArray *)backtrace {
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = UncaughtExceptionHandlerSkipAddressCount; i < UncaughtExceptionHandlerSkipAddressCount + UncaughtExceptionHandlerReportAddressCount; i++) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    return backtrace;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
// 被夹在这中间的代码针对于此警告都会无视并且不显示出来
- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex {
    if (anIndex == 0) {
        dismissed = YES;
    }else if (anIndex==1) {
        //继续
        if (action) {
            action(_message_exception);
        }
    }
}
- (void)validateAndSaveCriticalApplicationData:(NSException *)exception {
    NSString *exceptionMessage = [NSString stringWithFormat:NSLocalizedString(@"\n********** %@ 异常原因如下: **********\n%@\n%@\n========== End ==========\n", nil), [self currentTimeString], [exception reason], [[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]];
    // 4.创建文件对接对象,文件对象此时针对文件，可读可写
    NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:_logFilePath];
    [handle seekToEndOfFile];
    [handle writeData:[exceptionMessage dataUsingEncoding:NSUTF8StringEncoding]];
    [handle closeFile];
    //NSLog(@"%@", filePath);
    if (handleBlock) {
        handleBlock(_logFilePath);
    }
}
- (void)handleException:(NSException *)exception {
    [self validateAndSaveCriticalApplicationData:exception];
    if (_showInfor) {
        _message_alert = [NSString stringWithFormat:NSLocalizedString(@"如果点击继续，程序有可能会出现其他的问题，建议您还是点击退出按钮并重新打开\n\n" @"异常原因如下:\n%@\n%@", nil), [exception reason], [[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]];
    }else {
        _message_alert = [NSString stringWithFormat:NSLocalizedString(@"\n如果点击继续，程序有可能会出现其他的问题，建议您还是点击退出按钮并重新打开\n", nil)];
        if (_message_my) {
            _message_alert = _message_my;
        }
    }
    NSString *titleStr = nil;
    if (_title_alert) {
        titleStr = _title_alert;
    }else {
        titleStr = NSLocalizedString(@"抱歉，程序出现了异常", nil);
    }
    _message_exception = [NSString stringWithFormat:NSLocalizedString(@"异常原因如下:\n%@\n%@", nil), [exception reason], [[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleStr message:_message_alert delegate:self cancelButtonTitle:NSLocalizedString(@"退出", nil) otherButtonTitles:NSLocalizedString(@"继续", nil), nil];
    //UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"抱歉，程序出现了异常" message:[NSString stringWithFormat:@"如果点击继续，程序有可能会出现其他的问题，建议您还是点击退出按钮并重新打开\n\n" @"异常原因如下:\n%@\n%@", [exception reason], [[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]] delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"继续", nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_show_alert) {
            [alert show];
        }else {
            if (finish) {
                dismissed = YES;
            }
        }
    });
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    while (!dismissed){
        for (NSString *mode in (__bridge NSArray *)allModes) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    CFRelease(allModes);
#pragma clang diagnostic pop
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName]) {
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
    }else{
        [exception raise];
    }
}
- (SPUncaughtExceptionHandler *(^)(BOOL yesOrNo))showExceptionInfor {
    return ^(BOOL yesOrNo) {
        _showInfor = yesOrNo;
        return [SPUncaughtExceptionHandler shareInstance];
    };
}
- (void)setShowExceptionInfor:(SPUncaughtExceptionHandler *(^)(BOOL))showExceptionInfor {}

- (SPUncaughtExceptionHandler *(^)(NSString *message))message {
    return ^(NSString *message) {
        _message_my = message;
        return [SPUncaughtExceptionHandler shareInstance];
    };
}

- (void)setMessage:(SPUncaughtExceptionHandler *(^)(NSString *))message {}

- (SPUncaughtExceptionHandler *(^)(void (^click)(NSString *message)))didClick {
    return ^(void (^click)(NSString *message)) {
        action = click;
        return [SPUncaughtExceptionHandler shareInstance];
    };
}

- (void)setDidClick:(SPUncaughtExceptionHandler *(^)(void (^)(NSString *)))didClick {}

- (SPUncaughtExceptionHandler *(^)(NSString *title))title {
    return ^(NSString *title){
        _title_alert = title;
        return [SPUncaughtExceptionHandler shareInstance];
    };
}
- (void)setTitle:(SPUncaughtExceptionHandler *(^)(NSString *))title{}

- (SPUncaughtExceptionHandler *(^)(void (^)(NSString *exceptionLogFilePath)))logFileHandle {
    return ^(void (^logFileHandle)(NSString *exceptionLogFilePath)) {
        handleBlock = logFileHandle;
        return [SPUncaughtExceptionHandler shareInstance];
    };
}
- (void)setLogFileHandle:(SPUncaughtExceptionHandler *(^)(void (^)(NSString *)))logFileHandle {};

- (SPUncaughtExceptionHandler *(^)(BOOL yesOrNo))showAlert {
    return ^(BOOL yesOrNo) {
        _show_alert = yesOrNo;
        return [SPUncaughtExceptionHandler shareInstance];
    };
}
- (void)setShowAlert:(SPUncaughtExceptionHandler *(^)(BOOL))showAlert {};

- (NSString *)exceptionFilePath {
    return _logFilePath;
}
- (NSString *)currentTimeString {
    //时间格式化
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    return currentDateStr;
}

@end
void HandleException(NSException *exception) {
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    NSArray *callStack = [SPUncaughtExceptionHandler backtrace];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    [[SPUncaughtExceptionHandler shareInstance] performSelectorOnMainThread:@selector(handleException:) withObject: [NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:userInfo] waitUntilDone:YES];
}
void SignalHandler(int signal) {
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];
    NSArray *callStack = [SPUncaughtExceptionHandler backtrace];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    [[SPUncaughtExceptionHandler shareInstance] performSelectorOnMainThread:@selector(handleException:) withObject: [NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName reason: [NSString stringWithFormat: NSLocalizedString(@"Signal %d was raised.", nil), signal] userInfo: [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey]] waitUntilDone:YES];
}
SPUncaughtExceptionHandler* InstallUncaughtExceptionHandler(void) {
    NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGABRT, SignalHandler);
    signal(SIGILL, SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
    return [SPUncaughtExceptionHandler shareInstance];
}

void ExceptionHandlerFinishNotify() {
    finish =YES;
}
