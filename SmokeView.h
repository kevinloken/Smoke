//
//  SmokeView.h
//  Smoke
//
//  Created by Kevin Loken on 11-02-18.
//  Copyright (c) 2011, Stone Sanctuary Interactive Inc. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <OpenGL/gl.h>
#import "TransparentOpenGLView.h"

@interface ComStoneSanctuaryInteractive_SmokeView : ScreenSaverView 
{
	ComStoneSanctuaryInteractive_TransparentOpenGLView *glView;
}

- (void)setUpOpenGL;

@end

