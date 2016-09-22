//
//  ViewController.m
//  SPUncaughtExceptionHandler
//
//  Created by 康世朋 on 16/8/10.
//  Copyright © 2016年 SP. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 160, 130, 60);
    [btn setTitle:@"点我试试😀" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(100, 240, 130, 60);
    [btn1 setTitle:@"点我试试😀" forState:UIControlStateNormal];
    btn1.backgroundColor = [UIColor greenColor];
    [btn1 addTarget:self action:@selector(btn1Action:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)btn1Action:(UIButton *)btn {
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       
    }];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"这是正常的" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:alertAction];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
