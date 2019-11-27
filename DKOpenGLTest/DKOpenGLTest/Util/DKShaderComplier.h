//
//  DKShaderComplier.h
//  DKOpenGLTest
//
//  Created by dingkan on 2019/11/13.
//  Copyright © 2019年 dingkan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DKShaderComplierDelegate <NSObject>
-(void)DKShaderComplierDidFailedWithError:(NSError *)error;
@end

@interface DKShaderComplier : NSObject

-(instancetype)initWithVertexShader:(NSString *)vertexFileName fragmentShader:(NSString *)fragmentFileName delegate:(id<DKShaderComplierDelegate>)delegate;

-(void)prepareToDraw;

-(GLuint)uniformIndex:(NSString *)uniformName;

-(GLuint)attributeIndex:(NSString *)attributeName;

@end

NS_ASSUME_NONNULL_END
