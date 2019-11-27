//
//  DKTestView.h
//  DKOpenGLTest
//
//  Created by dingkan on 2019/11/14.
//  Copyright © 2019年 dingkan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DKTestViewDelegate <NSObject>
-(void)DKTestViewDidFailedWithError:(NSError *)error;
@end

NS_ASSUME_NONNULL_BEGIN

@interface DKTestView : UIView
@property (nonatomic, strong) UIImage *image;

@end

NS_ASSUME_NONNULL_END
