//
//  ViewController.m
//  DKOpenGLTest
//
//  Created by dingkan on 2019/11/13.
//  Copyright © 2019年 dingkan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) NSArray *temp;
@end

@implementation ViewController

-(void)viewDidLoad{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config.plist" ofType:nil];
    self.temp = [NSArray arrayWithContentsOfFile:path];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"test"];
    [self.tableView reloadData];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.temp.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"test"];
    cell.textLabel.text = self.temp[indexPath.row];
    cell.textLabel.textColor = [UIColor blackColor];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *clasName = self.temp[indexPath.row];
    Class class = NSClassFromString(clasName);
    UIViewController *vc= [[class alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
