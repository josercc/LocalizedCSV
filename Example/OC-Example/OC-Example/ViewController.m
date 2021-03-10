//
//  ViewController.m
//  OC-Example
//
//  Created by 张行 on 2021/3/9.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /// 下面是已经准备好国际化的例子
    NSString *name = NSLocalizedString(@"my_name", @"joser");
    NSString *age = NSLocalizedString(@"my_age", @"30");
}


@end
