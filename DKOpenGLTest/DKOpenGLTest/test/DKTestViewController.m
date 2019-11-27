//
//  DKTestViewController.m
//  DKOpenGLTest
//
//  Created by dingkan on 2019/11/13.
//  Copyright © 2019年 dingkan. All rights reserved.
//

#import "DKTestViewController.h"
#import "DKTestView.h"
@interface DKTestViewController ()
@property (nonatomic, strong) DKTestView *mainView;
@end

@implementation DKTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:({
        _mainView = [[DKTestView alloc]initWithFrame:self.view.bounds];
    })];
}



@end
