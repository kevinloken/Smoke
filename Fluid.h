//
//  Fluid.h
//  GLPaint
//
//  Created by Kevin Loken on 11-02-17.
//  Copyright 2011 Stone Sanctuary Interactive Inc. All rights reserved.
//

#define TOUCH_UP 0
#define TOUCH_DOWN 1

void setupSolver(int width, int height);
int viewWidth();
int viewHeight();

void clear_data ( void );

void mouse_func ( int button, int state, int x, int y );
void motion_func ( int x, int y );
void idle_func ( void );
void display_func ( void );
void key_func ( unsigned char key, int x, int y );


