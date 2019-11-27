//
//  DKTestView.m
//  DKOpenGLTest
//
//  Created by dingkan on 2019/11/14.
//  Copyright © 2019年 dingkan. All rights reserved.
//

#import "DKTestView.h"
#import <OpenGLES/ES2/glext.h>
#import "DKShaderComplier.h"
#import <AVFoundation/AVFoundation.h>

@interface DKTestView()<DKShaderComplierDelegate>
@property (nonatomic, weak) id<DKTestViewDelegate> delegate;

@property (nonatomic, strong) CAEAGLLayer *mLayer;
@property (nonatomic, strong) EAGLContext *mContext;

@property (nonatomic, assign) GLuint renderBuffer;
@property (nonatomic, assign) GLuint frameBuffer;

@property (nonatomic, assign) GLint width;
@property (nonatomic, assign) GLint height;

@property (nonatomic, assign) GLuint originalTextureID;

@property (nonatomic, assign) GLuint brightnessFrameBuffer;
@property (nonatomic, assign) GLuint brightnessTextureID;

@property (nonatomic, assign) GLuint saturationFrameBuffer;
@property (nonatomic, assign) GLuint saturationTextureID;

@property (nonatomic, strong) DKShaderComplier *renderShader;
@property (nonatomic, assign) GLuint renderPositionSlot;
@property (nonatomic, assign) GLuint renderTextureSlot;
@property (nonatomic, assign) GLuint renderTextureCoordSlot;

@property (nonatomic, strong) DKShaderComplier *brightnessShader;
@property (nonatomic, assign) GLuint brightnessPositionSlot;
@property (nonatomic, assign) GLuint birghtnessTextureSlot;
@property (nonatomic, assign) GLuint brightnessTextureCoordSlot;
@property (nonatomic, assign) GLuint brightness;

@property (nonatomic, strong) DKShaderComplier *saturationShader;
@property (nonatomic, assign) GLuint saturaionPositionSlot;
@property (nonatomic, assign) GLuint saturationTextureSlot;
@property (nonatomic, assign) GLuint saturationTextureCoordSlot;
@property (nonatomic, assign) GLuint saturation;

@end

@implementation DKTestView

+(Class)layerClass{
    return [CAEAGLLayer class];
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupContext];
        
        self.image = [UIImage imageNamed:@"wuyanzu.jpg"];
        
        [self setupLayer];
        [self clearRenderAndFrameBuffer];
        [self setupRenderAndFrameBuffer];
        [self createBeightnessFrameBuffer:self.image];
        [self createSaturationFrameBuffer:self.image];
        [self setupRenderScreenViewPort];
        [self setupRenderShader];
        [self setupBrightnessShader];
        [self setupSaturationShader];
        [self renderToScreenWithTexture:self.originalTextureID];
    }
    return self;
}

-(void)renderToScreenWithTexture:(GLuint)texture{
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    [self setupRenderScreenViewPort];
    [_renderShader prepareToDraw];
    
    UIImage *img = self.image;
    CGRect realRect = AVMakeRectWithAspectRatioInsideRect(img.size, self.bounds);
    CGFloat widthRatio = realRect.size.width / self.bounds.size.width;
    CGFloat heightRatio = realRect.size.height / self.bounds.size.height;
    
    const CGFloat vertices[] = {
        -widthRatio, - heightRatio,0,
        widthRatio, - heightRatio, 0,
        -widthRatio, heightRatio, 0,
        widthRatio, heightRatio, 0
    };
    
    glEnableVertexAttribArray(_renderPositionSlot);
    glVertexAttribPointer(_renderPositionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    
    static const CGFloat coords[] = {
        0,0,
        1,0,
        0,1,
        1,1
    };
    glEnableVertexAttribArray(_renderTextureCoordSlot);
    glVertexAttribPointer(_renderTextureCoordSlot, 2, GL_FLOAT, GL_FALSE, 0, coords);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(_renderTextureSlot, 5);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [_mContext presentRenderbuffer:GL_RENDERBUFFER];
}


-(void)setupSaturationShader{
    self.saturationShader = [[DKShaderComplier alloc]initWithVertexShader:@"vertex.vsh" fragmentShader:@"saturation1.fsh" delegate:self];
    [self.saturationShader prepareToDraw];
    self.saturaionPositionSlot = [self.saturationShader attributeIndex:@"a_Position"];
    self.saturationTextureSlot = [self.saturationShader uniformIndex:@"u_Texture"];
    self.saturationTextureCoordSlot = [self.saturationShader attributeIndex:@"a_TextureCoord"];
    self.saturation = [self.saturationShader uniformIndex:@"saturation"];
}

-(void)setupBrightnessShader{
    self.brightnessShader = [[DKShaderComplier alloc]initWithVertexShader:@"vertex.vsh" fragmentShader:@"brightness1.fsh" delegate:self];
    [self.brightnessShader prepareToDraw];
    self.brightnessPositionSlot = [self.brightnessShader attributeIndex:@"a_Position"];
    self.birghtnessTextureSlot = [self.brightnessShader uniformIndex:@"u_Texture"];
    self.brightnessTextureCoordSlot = [self.brightnessShader attributeIndex:@"a_TextureCoord"];
    self.brightness = [self.brightnessShader uniformIndex:@"brightness"];
}

-(void)setupRenderShader{
    self.renderShader = [[DKShaderComplier alloc]initWithVertexShader:@"vertex.vsh" fragmentShader:@"fragment.fsh" delegate:self];
    [self.renderShader prepareToDraw];
    self.renderPositionSlot = [self.renderShader attributeIndex:@"a_Position"];
    self.renderTextureSlot = [self.renderShader uniformIndex:@"u_Texture"];
    self.renderTextureCoordSlot = [self.renderShader attributeIndex:@"a_TextureCoord"];
}

-(void)setupRenderScreenViewPort{
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.bounds.size.width, self.bounds.size.height);
}

-(void)createSaturationFrameBuffer:(UIImage *)image{
    glGenFramebuffers(1, &_saturationFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _saturationFrameBuffer);
    
    glGenTextures(1, &_saturationTextureID);
    glBindTexture(GL_TEXTURE_2D, _saturationTextureID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, image.size.width, image.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glFramebufferTexture2D(GL_TEXTURE_2D, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _saturationTextureID, 0);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer objec = %x",status);
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
}

//创建高亮缓存、高亮纹理ID
-(void)createBeightnessFrameBuffer:(UIImage *)image{
    glGenFramebuffers(1, &_brightnessFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _brightnessFrameBuffer);
    
    //create the texture
    
    glGenTextures(1, &_brightnessTextureID);
    glBindTexture(GL_TEXTURE_2D, _brightnessTextureID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, image.size.width, image.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    //bind the texture to your FBO
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _brightnessTextureID, 0);
    
    GLenum state = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (state != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer objec %x",state);
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
}

-(void)setImage:(UIImage *)image{
    _image = image;
    self.originalTextureID = [self createTextureFromImage:image];
}

-(GLuint)createTextureFromImage:(UIImage *)image{
    CGImageRef img = image.CGImage;
    
    if (!image) {
        if ([self.delegate respondsToSelector:@selector(DKTestViewDidFailedWithError:)]) {
            [self.delegate DKTestViewDidFailedWithError:nil];
        }
        return 0;
    }
    
    size_t width = CGImageGetWidth(img);
    size_t height = CGImageGetHeight(img);
    GLubyte *data = (GLubyte *)malloc(width * height * 4);
    CGContextRef context = CGBitmapContextCreate(data, width, height, 8, width * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0, -1.0f);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), img);
    
    glEnable(GL_TEXTURE_2D);
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    CGContextRelease(context);
    free(data);
    return texName;
}


-(void)setupRenderAndFrameBuffer{
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    [_mContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:_mLayer];
    
    //设置尺寸
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height);
    
    
}

-(void)clearRenderAndFrameBuffer{
    if (_renderBuffer) {
        glDeleteBuffers(1, &_renderBuffer);
    }
    
    if (_frameBuffer) {
        glDeleteBuffers(1, &_frameBuffer);
    }
}

-(void)setupLayer{
    self.mLayer = (CAEAGLLayer *)self.layer;
    
    _mLayer.opaque = YES;
    _mLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

-(void)setupContext{
    self.mContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.mContext) {
        if ([self.delegate respondsToSelector:@selector(DKTestViewDidFailedWithError:)]) {
            [self.delegate DKTestViewDidFailedWithError:nil];
        }
    }
    
    if ([EAGLContext setCurrentContext:_mContext]) {
        if ([self.delegate respondsToSelector:@selector(DKTestViewDidFailedWithError:)]) {
            [self.delegate DKTestViewDidFailedWithError:nil];
        }
    }
}

#pragma DKShaderComplierDelegate
-(void)DKShaderComplierDidFailedWithError:(NSError *)error{
    
}

@end
