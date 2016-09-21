# SPUncaughtExceptionHandler

APP闪退时，由用户决定是否继续。宝宝再也不用担心APP闪退了

1.导入头文件  #import "SPUncaughtExceptionHandler.h"

2.在Appdelegate里面只需调用捕捉异常类的一个方法如下。

-(BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    InstallUncaughtExceptionHandler();

    return YES; 
}

只要整个程序有任何地方崩溃，它都能够捕捉到：（然后你在任何一个文件中写一个会导致程序崩溃的方法，比如给一个Button添加方法，但是并没有实现方法）

现已添加cocoapods支持: pod 'SPUncaughtExceptionHandler', '~> 0.0.1'
