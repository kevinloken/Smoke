//
//  Fluid.m
//  GLPaint
//
//  Created by Kevin Loken on 11-02-17.
//  Copyright 2011 Stone Sanctuary Interactive Inc. All rights reserved.
//

#import "Fluid.h"
#import "Solver.h" /* external definitions (from solver.m) */

#import <OpenGL/gl.h>

#import <Accelerate/Accelerate.h>

/*
 ======================================================================
 demo03.c --- protoype to show off the simple solver
 ----------------------------------------------------------------------
 Author : Jos Stam (jstam@aw.sgi.com)
 Creation Date : Jan 9 2003
 
 Description:
 
 This code is a simple prototype that demonstrates how to use the
 code provided in my GDC2003 paper entitles "Real-Time Fluid Dynamics
 for Games". This code uses OpenGL and GLUT for graphics and interface
 
 =======================================================================
 */


/* macros */
#define IX(i,j) ((i)+(N+2)*(j))


/* global variables */

static int N;
static float dt, diff, visc;
static float force, source;
static int dvel;

static float * u, * v, * u_prev, * v_prev;
static float * dens, * dens_prev;

static int win_x, win_y;
static int mouse_down[3];
static int omx, omy, mx, my;


/*
 ----------------------------------------------------------------------
 free/clear/allocate simulation data
 ----------------------------------------------------------------------
 */



static int allocate_data ( void )
{
	int size = (N+2)*(N+2);
	
	u			= (float *) malloc ( size*sizeof(float) );
	v			= (float *) malloc ( size*sizeof(float) );
	u_prev		= (float *) malloc ( size*sizeof(float) );
	v_prev		= (float *) malloc ( size*sizeof(float) );
	dens		= (float *) malloc ( size*sizeof(float) );	
	dens_prev	= (float *) malloc ( size*sizeof(float) );
	
	if ( !u || !v || !u_prev || !v_prev || !dens || !dens_prev ) {
		NSLog( @"cannot allocate data" );
		return ( 0 );
	}
	
	return ( 1 );
}

static void free_data ( void )
{
	if ( u ) free ( u );
	if ( v ) free ( v );
	if ( u_prev ) free ( u_prev );
	if ( v_prev ) free ( v_prev );
	if ( dens ) free ( dens );
	if ( dens_prev ) free ( dens_prev );
}

void clear_data ( void )
{
	const int size=(N+2)*(N+2);
	
/*
 
 for ( int i=0 ; i<size ; i++ ) {
	u[i] = v[i] = u_prev[i] = v_prev[i] = dens[i] = dens_prev[i] = 0.0f;
 }
 */
	catlas_sset(size, 0.0f, u, 1);
	catlas_sset(size, 0.0f, u_prev, 1);
	catlas_sset(size, 0.0f, v, 1);
	catlas_sset(size, 0.0f, v_prev, 1);
	catlas_sset(size, 0.0f, dens, 1);
	catlas_sset(size, 0.0f, dens_prev, 1);

}



/*
 ----------------------------------------------------------------------
 OpenGL specific drawing routines
 ----------------------------------------------------------------------
 */


static void draw_velocity ( void )
{
	/*
	int i, j;
	float x, y, h;
	
	h = 1.0f/N;
	
	glColor3f ( 1.0f, 1.0f, 1.0f );
	glLineWidth ( 1.0f );
	
	glBegin ( GL_LINES );
	
	for ( i=1 ; i<=N ; i++ ) {
		x = (i-0.5f)*h;
		for ( j=1 ; j<=N ; j++ ) {
			y = (j-0.5f)*h;
			
			glVertex2f ( x, y );
			glVertex2f ( x+u[IX(i,j)], y+v[IX(i,j)] );
		}
	}
	
	glEnd ();
	 */
}

static void draw_density ( void )
{
	static GLfloat *vertexBuffer = NULL;
	static GLfloat *colorBuffer = NULL;
	
	if (vertexBuffer == NULL) {
		vertexBuffer = malloc( (N+2) * (N+2) * 2 * 6 * sizeof(GLfloat));
	}
	
	if (colorBuffer == NULL ) {
		colorBuffer = malloc( (N+2) * (N+2) * 4 * 6 * sizeof(GLfloat));
	}
	
	int i, j;
	const float h = 1.0f / N;

	
	float x, y, d00, d01, d10, d11;
	int vertexCount = 0;
	
	for ( j=0 ; j<=N ; j++ ) {
		y = (j-0.5f)*h;
		for ( i=0 ; i<=N ; i++ ) {
			x = (i-0.5f)*h;
			
			d00 = dens[IX(i,j)];
			d01 = dens[IX(i,j+1)];
			d10 = dens[IX(i+1,j)];
			d11 = dens[IX(i+1,j+1)];
			
			// glColor4f ( d00, d00, d00, 1.0 ); glVertex2f ( x, y );
			colorBuffer[4 * vertexCount + 0] = d00;
			colorBuffer[4 * vertexCount + 1] = d00;
			colorBuffer[4 * vertexCount + 2] = d00;
			colorBuffer[4 * vertexCount + 3] = 1.0f;
			vertexBuffer[2 * vertexCount + 0] = x;
			vertexBuffer[2 * vertexCount + 1] = y;
			vertexCount += 1;
			
			// glColor4f ( d10, d10, d10, 1.0 ); glVertex2f ( x+h, y );
			colorBuffer[4 * vertexCount + 0] = d10;
			colorBuffer[4 * vertexCount + 1] = d10;
			colorBuffer[4 * vertexCount + 2] = d10;
			colorBuffer[4 * vertexCount + 3] = 1.0f;
			vertexBuffer[2 * vertexCount + 0] = x+h;
			vertexBuffer[2 * vertexCount + 1] = y;
			vertexCount += 1;
			
			// glColor4f ( d11, d11, d11, 1.0 ); glVertex2f ( x+h, y+h );
			colorBuffer[4 * vertexCount + 0] = d11;
			colorBuffer[4 * vertexCount + 1] = d11;
			colorBuffer[4 * vertexCount + 2] = d11;
			colorBuffer[4 * vertexCount + 3] = 1.0f;
			vertexBuffer[2 * vertexCount + 0] = x+h;
			vertexBuffer[2 * vertexCount + 1] = y+h;
			vertexCount += 1;

			// glColor4f ( d00, d00, d00, 1.0 ); glVertex2f ( x, y );
			colorBuffer[4 * vertexCount + 0] = d00;
			colorBuffer[4 * vertexCount + 1] = d00;
			colorBuffer[4 * vertexCount + 2] = d00;
			colorBuffer[4 * vertexCount + 3] = 1.0f;
			vertexBuffer[2 * vertexCount + 0] = x;
			vertexBuffer[2 * vertexCount + 1] = y;
			vertexCount += 1;
			
			// glColor4f ( d11, d11, d11, 1.0 ); glVertex2f ( x+h, y+h );
			colorBuffer[4 * vertexCount + 0] = d11;
			colorBuffer[4 * vertexCount + 1] = d11;
			colorBuffer[4 * vertexCount + 2] = d11;
			colorBuffer[4 * vertexCount + 3] = 1.0f;
			vertexBuffer[2 * vertexCount + 0] = x+h;
			vertexBuffer[2 * vertexCount + 1] = y+h;
			vertexCount += 1;

			// glColor4f ( d01, d01, d01, 1.0 ); glVertex2f ( x, y+h );
			colorBuffer[4 * vertexCount + 0] = d01;
			colorBuffer[4 * vertexCount + 1] = d01;
			colorBuffer[4 * vertexCount + 2] = d01;
			colorBuffer[4 * vertexCount + 3] = 1.0f;
			vertexBuffer[2 * vertexCount + 0] = x;
			vertexBuffer[2 * vertexCount + 1] = y+h;
			vertexCount += 1;
		}
	}
	
	glVertexPointer(2, GL_FLOAT, 0, vertexBuffer);
	glColorPointer(4, GL_FLOAT, 0, colorBuffer);
	glDrawArrays(GL_TRIANGLES, 0, vertexCount);
}

/*
 ----------------------------------------------------------------------
 relates mouse movements to forces sources
 ----------------------------------------------------------------------
 */

static void get_from_UI ( float * d, float * u, float * v )
{
	int i, j, size = (N+2)*(N+2);
	
	/*
	for ( i=0 ; i<size ; i++ ) {
		u[i] = v[i] = d[i] = 0.0f;
	}
	*/
	
	catlas_sset(size, 0.0f, d, 1);
	catlas_sset(size, 0.0f, u, 1);
	catlas_sset(size, 0.0f, v, 1);
	
	if ( !mouse_down[0] && !mouse_down[2] ) return;
	
	i = (int)((       mx /(float)win_x)*N+1);
	j = (int)(((win_y-my)/(float)win_y)*N+1);
	
	if ( i<1 || i>N || j<1 || j>N ) return;
	
	if ( mouse_down[0] ) {
		u[IX(i,j)] = force * (mx-omx);
		v[IX(i,j)] = force * (omy-my);
	}
	
	if ( mouse_down[2] ) {
		d[IX(i,j)] = source;
	}
	
	omx = mx;
	omy = my;
	
	return;
}

/*
 ----------------------------------------------------------------------
 GLUT callback routines
 ----------------------------------------------------------------------
 */

void key_func ( unsigned char key, int x, int y )
{
	switch ( key )
	{
		case 'c':
		case 'C':
			clear_data ();
			break;
			
		case 'q':
		case 'Q':
			free_data ();
			exit ( 0 );
			break;
			
		case 'v':
		case 'V':
			dvel = !dvel;
			break;
	}
}

void mouse_func ( int button, int state, int x, int y )
{
	omx = mx = x;
	omx = my = y;
	
	mouse_down[button] = (state == TOUCH_DOWN);
}

void motion_func ( int x, int y )
{
	mx = x;
	my = y;
}


void idle_func ( void )
{
	get_from_UI ( dens_prev, u_prev, v_prev );
	vel_step ( N, u, v, u_prev, v_prev, visc, dt );
	dens_step ( N, dens, dens_prev, u, v, diff, dt );
}

void display_func ( void )
{	
	/*
	 glViewport ( 0, 0, win_x, win_y );
	 glMatrixMode ( GL_PROJECTION );
	 glLoadIdentity ();
	 // gluOrtho2D ( 0.0, 1.0, 0.0, 1.0 );
	 glOrthof(0.0f, 1.0f, 0.0f, 1.0f, -1.0, 1.0);
	 glClearColor ( 0.0f, 0.0f, 0.0f, 1.0f );
	 */
	glClear ( GL_COLOR_BUFFER_BIT );	
	
	if ( dvel ) draw_velocity ();
	else		draw_density ();
}



/*
 ----------------------------------------------------------------------
 main --- main routine
 ----------------------------------------------------------------------
 */

void setupSolver(int width, int height)
{
	N = 128;
	dt = 0.1f;
	diff = 0.0f;
	visc = 0.0f;
	force = 5.0f;
	source = 100.0f;
	NSLog ( @"Using defaults : N=%d dt=%g diff=%g visc=%g force = %g source=%g\n", N, dt, diff, visc, force, source );
	dvel = 0;
	
	if ( !allocate_data () ) exit ( 1 );
	clear_data ();
	
	win_x = width;
	win_y = height;	
}

