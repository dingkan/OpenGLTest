//
//  DKShaderComplier.m
//  DKOpenGLTest
//
//  Created by dingkan on 2019/11/13.
//  Copyright © 2019年 dingkan. All rights reserved.
//

#import "DKShaderComplier.h"

@interface DKShaderComplier()
@property (nonatomic, assign) GLuint program;
@property (nonatomic, weak) id<DKShaderComplierDelegate> delegate;
@end

@implementation DKShaderComplier

-(instancetype)initWithVertexShader:(NSString *)vertexFileName fragmentShader:(NSString *)fragmentFileName delegate:(id<DKShaderComplierDelegate>)delegate{
    if (self = [super init]) {
        self.delegate = delegate;
        
        GLuint vertexShader = [self createShaderWIthType:GL_VERTEX_SHADER fileName:vertexFileName];
        GLuint fragmentShader = [self createShaderWIthType:GL_FRAGMENT_SHADER fileName:fragmentFileName];
        
        self.program = [self createProgmentVertexShader:vertexShader fragmentShader:fragmentShader];
        
    }
    return self;
}

-(GLuint)createProgmentVertexShader:(GLuint)vertexShader fragmentShader:(GLuint)fragmentShader{
    GLuint progment = glCreateProgram();
    
    if (progment == 0) {
        if ([self.delegate respondsToSelector:@selector(DKShaderComplierDidFailedWithError:)]) {
            NSError *nError = [NSError errorWithDomain:@"com.dingkan.shaderComplier" code:-2220000 userInfo:@{NSLocalizedDescriptionKey:@"failed to create progment"}];
            [self.delegate DKShaderComplierDidFailedWithError:nError];
        }
        return 0;
    }
    
    glAttachShader(progment, vertexShader);
    glAttachShader(progment, fragmentShader);
    
    glLinkProgram(progment);
    
    GLint link;
    glGetProgramiv(progment, GL_LINK_STATUS, &link);
    
    if (link == 0) {
        GLchar message[256];
        glGetProgramInfoLog(progment, sizeof(message), NULL, &message[0]);
        NSString *errorStr = [NSString stringWithUTF8String:message];
        NSError *nError = [NSError errorWithDomain:@"com.dingkan.shaderComplier" code:-2220000 userInfo:@{NSLocalizedDescriptionKey:errorStr}];
        if ([self.delegate respondsToSelector:@selector(DKShaderComplierDidFailedWithError:)]) {
            [self.delegate DKShaderComplierDidFailedWithError:nError];
        }
        return 0;
    }
    
    glUseProgram(progment);
    NSLog(@"success to link program");
    return progment;
}

-(GLuint)createShaderWIthType:(GLenum)type fileName:(NSString *)fileName{
    GLuint shader = glCreateShader(type);
    
    if (shader == 0) {
        if ([self.delegate respondsToSelector:@selector(DKShaderComplierDidFailedWithError:)]) {
            NSError *nError = [NSError errorWithDomain:@"com.dingkan.shaderComplier" code:-2220000 userInfo:@{NSLocalizedDescriptionKey:@"failed to create shader"}];
            [self.delegate DKShaderComplierDidFailedWithError:nError];
        }
        return 0;
    }
    
    NSError *error = nil;
    NSString *sourceString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:nil] encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        if ([self.delegate respondsToSelector:@selector(DKShaderComplierDidFailedWithError:)]) {
            [self.delegate DKShaderComplierDidFailedWithError:error];
        }
    }
    const GLchar *data = [sourceString UTF8String];
    glShaderSource(shader, 1, &data, NULL);
    
    glCompileShader(shader);
    
    GLint compile;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compile);
    
    if (compile == 0) {
        GLchar message[256];
        glGetShaderInfoLog(shader, sizeof(message), NULL, &message[0]);
        NSString *errorStr = [NSString stringWithUTF8String:message];
        NSError *nError = [NSError errorWithDomain:@"com.dingkan.shaderComplier" code:-2220000 userInfo:@{NSLocalizedDescriptionKey:errorStr}];
        if ([self.delegate respondsToSelector:@selector(DKShaderComplierDidFailedWithError:)]) {
            [self.delegate DKShaderComplierDidFailedWithError:nError];
        }
        return 0;
    }
    
    
    NSLog(@"success to compile shader");
    return shader;
}

-(void)prepareToDraw{
    glUseProgram(_program);
}

-(GLuint)uniformIndex:(NSString *)uniformName{
    return glGetUniformLocation(_program, [uniformName UTF8String]);
}

-(GLuint)attributeIndex:(NSString *)attributeName{
    return glGetAttribLocation(_program, [attributeName UTF8String]);
}
@end
