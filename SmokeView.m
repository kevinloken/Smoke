//
//  SmokeView.m
//  Smoke
//
//  Created by Kevin Loken on 11-02-18.
//  Copyright (c) 2011, Stone Sanctuary Interactive Inc. All rights reserved.
//

#import "SmokeView.h"
#import <OpenGL/glu.h>


@implementation ComStoneSanctuaryInteractive_SmokeView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
	NSLog(@"initWithFrame !!!");
	
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
		NSOpenGLPixelFormatAttribute attributes[] = {
			NSOpenGLPFAAccelerated,
			NSOpenGLPFADepthSize, 16,
			NSOpenGLPFAMinimumPolicy,
			NSOpenGLPFAClosestPolicy,
			0
		};
		NSOpenGLPixelFormat *format;
		
		format = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
		glView = [[ComStoneSanctuaryInteractive_TransparentOpenGLView alloc] initWithFrame:NSZeroRect pixelFormat:format];
		// glView = [[NSOpenGLView alloc] initWithFrame:NSZeroRect pixelFormat:format];
		
		
		if ( !glView ) {
			NSLog(@"Couldn't initialize OpenGL view.");
			abort();
			[self autorelease];
			return nil;
		}
		NSLog(@"Adding OpenGL View");
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
	glShadeModel(GL_SMOOTH);
	glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
	glClearDepth(1.0f);
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
	
	rotation = 0.0f;
}

- (void)setFrameSize:(NSSize)newSize
{
	NSLog(@"Setting up ScreenSaver OpenGL view.");
	
	[super setFrameSize:newSize];
	[glView setFrameSize:newSize];
	
	[[glView openGLContext] makeCurrentContext];
	
	// Reshape
	glViewport(0, 0, (GLsizei)newSize.width, (GLsizei)newSize.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(45.0f, (GLfloat)newSize.width/(GLfloat)newSize.height, 0.1f, 100.0f);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	[[glView openGLContext] update];
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
	NSLog(@"Drawing the rect");
	
    [super drawRect:rect];
	
	[[glView openGLContext] makeCurrentContext];
	
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT ); 
	glLoadIdentity(); 
	
	glTranslatef( -1.5f, 0.0f, -6.0f );
	glRotatef( rotation, 0.0f, 1.0f, 0.0f );
	
	glBegin( GL_TRIANGLES );
	{
		glColor3f( 1.0f, 0.0f, 0.0f );
		glVertex3f( 0.0f,  1.0f, 0.0f );
		glColor3f( 0.0f, 1.0f, 0.0f ); 
		glVertex3f( -1.0f, -1.0f, 1.0f );
		glColor3f( 0.0f, 0.0f, 1.0f ); 
		glVertex3f( 1.0f, -1.0f, 1.0f ); 
		
		glColor3f( 1.0f, 0.0f, 0.0f ); 
		glVertex3f( 0.0f, 1.0f, 0.0f );  
		glColor3f( 0.0f, 0.0f, 1.0f ); 
		glVertex3f( 1.0f, -1.0f, 1.0f ); 
		glColor3f( 0.0f, 1.0f, 0.0f );
		glVertex3f( 1.0f, -1.0f, -1.0f );
		
		glColor3f( 1.0f, 0.0f, 0.0f );
		glVertex3f( 0.0f, 1.0f, 0.0f );  
		glColor3f( 0.0f, 1.0f, 0.0f );     
		glVertex3f( 1.0f, -1.0f, -1.0f );  	
		glColor3f( 0.0f, 0.0f, 1.0f );    	
		glVertex3f( -1.0f, -1.0f, -1.0f );  
		
		glColor3f( 1.0f, 0.0f, 0.0f );
		glVertex3f( 0.0f, 1.0f, 0.0f );
		glColor3f( 0.0f, 0.0f, 1.0f );
		glVertex3f( -1.0f, -1.0f, -1.0f );
		glColor3f( 0.0f, 1.0f, 0.0f );
		glVertex3f( -1.0f, -1.0f, 1.0f );  
	}
	glEnd();
	
	glFlush();	
}

- (void)animateOneFrame
{
	// Adjust our state
	rotation += 0.2f;
	if ( rotation > 360.0f )
		rotation = 0.0f;
	

	NSLog(@"Animating one frame. Rotation is now %f", rotation);
	
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
