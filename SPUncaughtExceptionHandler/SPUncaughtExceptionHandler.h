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
@property (nonatomic, copy) SPUncaughtExceptionHandler*(^showExceptionInfor)(BOOL yesOrNo);
@property (nonatomic, copy) SPUncaughtExceptionHandler*(^message)(NSString *message);
@property (nonatomic, copy) SPUncaughtExceptionHandler*(^didClick)(void (^click)(NSString *message));
@property (nonatomic, copy) SPUncaughtExceptionHandler*(^title)(NSString *title);
void HandleException(NSException *exception);
void SignalHandler(int signal);
SPUncaughtExceptionHandler* InstallUncaughtExceptionHandler(void);
+ (instancetype)shareInstance;
@end
