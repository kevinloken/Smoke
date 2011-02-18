//
//  SmokeView.m
//  Smoke
//
//  Created by Kevin Loken on 11-02-18.
//  Copyright (c) 2011, Stone Sanctuary Interactive Inc. All rights reserved.
//

#import <OpenGL/glu.h>
#import "SmokeView.h"
#import "Fluid.h"

@implementation ComStoneSanctuaryInteractive_SmokeView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
	NSLog(@"initWithFrame !!!");
	
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
		/*
		NSOpenGLPixelFormatAttribute attributes[] = {
			NSOpenGLPFAAccelerated,
			NSOpenGLPFADepthSize, 16,
			NSOpenGLPFAMinimumPolicy,
			NSOpenGLPFAClosestPolicy,
			0
		};
		NSOpenGLPixelFormat *format = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
		*/
		
		// glView = [[ComStoneSanctuaryInteractive_TransparentOpenGLView alloc] initWithFrame:NSZeroRect pixelFormat:format];
		glView = [[ComStoneSanctuaryInteractive_TransparentOpenGLView alloc] init];
		
		if ( !glView ) {
			NSLog(@"Couldn't initialize OpenGL view.");
			abort();
			[self autorelease];
			return nil;
		}

		[self addSubview:glView];
		[self setUpOpenGL];
		
        [self setAnimationTimeInterval:1/30.0];
    }
    return self;
}

- (void)dealloc
{
	[glView removeFromSuperview];
	[glView release];
	[super dealloc];
}

#pragma mark -
#pragma mark OpenGL Stuff

- (void)setUpOpenGL
{
	NSLog(@"Setting up ScreenSaver OpenGL view.");

	[[glView openGLContext] makeCurrentContext];
	
	glMatrixMode(GL_PROJECTION);
	gluOrtho2D(0.0f,1.0f,0.0f,1.0f);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);	
}

- (void)setFrameSize:(NSSize)newSize
{
	NSLog(@"Setting up ScreenSaver OpenGL view.");
	
	[super setFrameSize:newSize];
	[glView setFrameSize:newSize];
	
	[[glView openGLContext] makeCurrentContext];
	
	// Reshape
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluOrtho2D(0.0f, 1.0f, 0.0f, 1.0f); // gluOrtho2D(0,1,0,1);
	glViewport(0, 0, (GLsizei)newSize.width, (GLsizei)newSize.height);	
	
	[[glView openGLContext] update];
	
	setupSolver(newSize.width, newSize.height);

}

#pragma mark -
#pragma mark Animation Stuff

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
	// NSLog(@"Drawing the rect");
	
    [super drawRect:rect];
	
	[[glView openGLContext] makeCurrentContext];
	
	display_func();
	
	glFlush();	
}

- (void)animateOneFrame
{
	static int button = 2;
	static int count = 0;
	
	if ( count % 30 == 0 )
	{
		// NSLog(@"Animating one frame. Rotation is now %f", rotation);	
		mouse_func(button, TOUCH_UP,SSRandomIntBetween(0, viewWidth()), SSRandomIntBetween(0, viewHeight()));
		button = ( button == 0 ) ? 2 : 0;
		mouse_func(button, TOUCH_DOWN,SSRandomIntBetween(0, viewWidth()), SSRandomIntBetween(0, viewHeight()));
		motion_func(SSRandomIntBetween(0, viewWidth()), SSRandomIntBetween(0, viewHeight()));
	}
	
	++count;
	
	if ( count % (60 * 30) == 0 )
	{
		clear_data();
	}
	
	idle_func();
	
    // Redraw
	[self setNeedsDisplay:YES];
}

#pragma mark -
#pragma mark Configuration Details

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
