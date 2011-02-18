//
//  TransparentOpenGLView.m
//  Smoke
//
//  Created by Kevin Loken on 11-02-18.
//  Copyright 2011 Stone Sanctuary Interactive Inc. All rights reserved.
//

#import "TransparentOpenGLView.h"


@implementation ComStoneSanctuaryInteractive_TransparentOpenGLView


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
	NSLog(@"TransparentOpenGLView initialized");	
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
	[super drawRect:dirtyRect];
}


- (BOOL)isOpaque
{
	NSLog(@"returning NO from isOpaque");
	return NO;
}

@end
