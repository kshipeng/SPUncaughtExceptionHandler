//
//  SPUncaughtExceptionHandler.h
//  PageController
//
//  Created by 康世朋 on 16/8/10.
//  Copyright © 2016年 SP. All rights reserved.
//  Demo地址:https://github.com/kshipeng/SPUncaughtExceptionHandler
//

#import <Foundation/Foundation.h>

@interface SPUncaughtExceptionHandler : NSObject

/**
 是否展示错误信息
 */
@property (nonatomic, copy) SPUncaughtExceptionHandler*(^showExceptionInfor)(BOOL yesOrNo);

/**
 自定义Alert的message
 */
@property (nonatomic, copy) SPUncaughtExceptionHandler*(^message)(NSString *message);

/**
 点击Alert后续处理
 */
@property (nonatomic, copy) SPUncaughtExceptionHandler*(^didClick)(void (^click)(NSString *message));

/**
 自定义Alert的title
 */
@property (nonatomic, copy) SPUncaughtExceptionHandler*(^title)(NSString *title);

/**
 是否展示警告框
 */
@property (nonatomic, copy) SPUncaughtExceptionHandler*(^showAlert)(BOOL yesOrNo);

/**
 对日志文件的后续处理
 */
@property (nonatomic, copy) SPUncaughtExceptionHandler*(^logFileHandle)(void(^logHandle)(NSString *exceptionLogFilePath));

/**
 日志文件路径
 */
@property (nonatomic, retain, readonly) NSString *exceptionFilePath;

/**
 创建一个异常捕获类的单例
 */
+ (instancetype)shareInstance;

//void HandleException(NSException *exception);
//void SignalHandler(int signal);
SPUncaughtExceptionHandler* InstallUncaughtExceptionHandler(void);
void ExceptionHandlerFinishNotify();
@end
