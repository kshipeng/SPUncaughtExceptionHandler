//
//  SPUncaughtExceptionHandler.h
//  PageController
//
//  Created by 康世朋 on 16/8/10.
//  Copyright © 2016年 SP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPUncaughtExceptionHandler : NSObject
{
    BOOL dismissed;
}

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
void HandleException(NSException *exception);
void SignalHandler(int signal);
SPUncaughtExceptionHandler* InstallUncaughtExceptionHandler(void);

@end
