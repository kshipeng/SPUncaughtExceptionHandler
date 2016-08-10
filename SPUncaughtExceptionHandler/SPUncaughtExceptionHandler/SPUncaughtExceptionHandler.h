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
void HandleException(NSException *exception);
void SignalHandler(int signal);
void InstallUncaughtExceptionHandler(void);

@end
