//
//  CameraEngine.h
//  Encoder Demo
//
//  Created by Geraint Davies on 19/02/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^videoCaptureCompletionBlock)(NSURL *url, NSError *error);


@interface CameraEngine : NSObject

+ (CameraEngine *) engine;
+(CameraEngine *)shared;

- (void) startup;
- (void) shutdown;
- (AVCaptureVideoPreviewLayer*) getPreviewLayer;


- (void) startCapture;
- (void) pauseCapture;
- (void) stopCaptureWithComplitionBlock:(videoCaptureCompletionBlock)complitionBlock;
- (void) resumeCapture;

-(void)setUpVideoOutputForSession:(AVCaptureSession *)session;
-(void)updateSession:(AVCaptureSession *)session;

@property (atomic, readwrite) BOOL isCapturing;
@property (atomic, readwrite) BOOL isPaused;

@end
