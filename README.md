# SPUncaughtExceptionHandler

APP闪退时，由用户决定是否继续。宝宝再也不用担心APP闪退了

1.导入头文件  #import "SPUncaughtExceptionHandler.h"

2.在Appdelegate里面只需调用捕捉异常类的一个方法如下:

-(BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    InstallUncaughtExceptionHandler();

    return YES; 
}

3.采用“链式编程”实现Alert的一些自定义，详情请查看demo。

4.现已添加cocoapods支持: pod search SPUncaughtExceptionHandler

5.将日志存储在本地Documents文件夹下，并提供了获取日志文件路径的方法

只要整个程序有任何地方崩溃，它都能够捕捉到：（然后你在任何一个文件中写一个会导致程序崩溃的方法，比如给一个Button添加方法，但是并没有实现方法）

⚠️注：不要在debug环境下（会出现只拦截一次的情况）测试。因为系统的debug会优先去拦截。要运行一次后，关闭debug状态（不连接Xcode）。即直接点击我们在模拟器或真机上build的app去运行。

            😊如果对您还有所帮助，记得给颗星哦😊
