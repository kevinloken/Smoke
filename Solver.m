//
//  Solver.m
//  GLPaint
//
//  Created by Kevin Loken on 11-02-17.
//  Copyright 2011 Stone Sanctuary Interactive Inc. All rights reserved.
//

#import "Solver.h"
#import <Accelerate/Accelerate.h>


/*
 ======================================================================
 solver03.c --- simple fluid solver
 ----------------------------------------------------------------------
 Author : Jos Stam (jstam@aw.sgi.com)
 Creation Date : Jan 9 2003
 
 Description:
 
 This code is a simple prototype that demonstrates how to use the
 code provided in my GDC2003 paper entitles "Real-Time Fluid Dynamics
 for Games". This code uses OpenGL and GLUT for graphics and interface
 
 =======================================================================
 */

#define IX(i,j) ((i)+(N+2)*(j))
#define SWAP(x0,x) {float * tmp=x0;x0=x;x=tmp;}
#define FOR_EACH_CELL for ( i=1 ; i<=N ; i++ ) { for ( j=1 ; j<=N ; j++ ) {
#define END_FOR }}

void add_source ( int N, float * x, float * s, float dt )
{
	const int size=(N+2)*(N+2);
	// for ( int i=0 ; i<size ; i++ ) x[i] += dt*s[i];
	cblas_saxpy(size, dt,  s, 1, x, 1);
}

void set_bnd ( int N, int b, float * x )
{
	int i;
	
	for ( i=1 ; i<=N ; i++ ) {
		x[IX(0  ,i)] = b==1 ? -x[IX(1,i)] : x[IX(1,i)];
		x[IX(N+1,i)] = b==1 ? -x[IX(N,i)] : x[IX(N,i)];
		x[IX(i,0  )] = b==2 ? -x[IX(i,1)] : x[IX(i,1)];
		x[IX(i,N+1)] = b==2 ? -x[IX(i,N)] : x[IX(i,N)];
	}
	x[IX(0  ,0  )] = 0.5f*(x[IX(1,0  )]+x[IX(0  ,1)]);
	x[IX(0  ,N+1)] = 0.5f*(x[IX(1,N+1)]+x[IX(0  ,N)]);
	x[IX(N+1,0  )] = 0.5f*(x[IX(N,0  )]+x[IX(N+1,1)]);
	x[IX(N+1,N+1)] = 0.5f*(x[IX(N,N+1)]+x[IX(N+1,N)]);
}

void lin_solve ( int N, int b, float * x, float * x0, float a, float c )
{
	static float* x_temp = NULL;
	static float* temp = NULL;
	const int row_size = (N+2);
	
	if ( temp == NULL ) {
		temp = malloc(row_size * sizeof(float));
	}
	
	if ( x_temp == NULL ) {
		x_temp = malloc(3 * row_size * sizeof(float));
	}
	
	int i, j, k;
	float divisor = 1.0f / c;
	
	register int index;
	register int left;
	register int right;
	register int up;
	register int down;

	i = 1;
	index = (i + (N+2));
	left = index - 1;
	right = index + 1;
	up = index + (N+2);
	down = index - (N+2);
	
	for ( k=0 ; k<20 ; k++ ) {
		/*
		 for ( i=1 ; i<=N ; i++ ) { 
			for ( j=1 ; j<=N ; j++ ) {
				index = IX(i,j);
				left = IX(i-1,j);
				right = IX(i+1,j);
				up = IX(i,j+1);
				down = IX(i,j-1);
		
				x[index] = (x0[index] + a*(x[left]+x[right]+x[down]+x[up])) * divisor;
			}
		}
		*/

		for ( j = 1; j <= N; j++ ) {
			cblas_scopy(row_size * 3, &x[IX(i-1,j-1)], 1, x_temp, 1);

			// (x0)
			cblas_scopy(row_size, &x0[IX(i-1,j)], 1, temp, 1);			
			// + a * left
			cblas_saxpy(N, a , &x_temp[left], 1, &temp[i], 1);
			// + a * right
			cblas_saxpy(N, a , &x_temp[right], 1, &temp[i], 1);
			// + a * down
			cblas_saxpy(N, a , &x_temp[down], 1, &temp[i], 1);
			// + a * up
			cblas_saxpy(N, a , &x_temp[up], 1, &temp[i], 1);
			// * divisor
			cblas_sscal(N, divisor, &temp[i], 1);			
			
			// x = 
			cblas_scopy(N, &temp[1], 1, &x[IX(i,j)], 1);
		}
		
		set_bnd ( N, b, x );
	}
}

void diffuse ( int N, int b, float * x, float * x0, float diff, float dt )
{
	float a=dt*diff*N*N;
	lin_solve ( N, b, x, x0, a, 1+4*a );
}

void advect ( int N, int b, float * d, float * d0, float * u, float * v, float dt )
{
	int i, j, i0, j0, i1, j1;
	float x, y, s0, t0, s1, t1, dt0;
	
	dt0 = dt*N;
	for ( j=1 ; j<=N ; j++ ) {
		for ( i=1 ; i<=N ; i++ ) { 
			x = i-dt0*u[IX(i,j)]; 
			if (x<0.5f) x=0.5f; 
			if (x>N+0.5f) x=N+0.5f; 
			i0=(int)x; 
			i1=i0+1;
		
			y = j-dt0*v[IX(i,j)];
			if (y<0.5f) y=0.5f; 
			if (y>N+0.5f) y=N+0.5f; 
			j0=(int)y; 
			j1=j0+1;
	
			s1 = x - i0; 
			s0 = 1.0f - s1; 
			t1 = y - j0; 
			t0 = 1.0f - t1;
	
			d[IX(i,j)] = s0*(t0*d0[IX(i0,j0)]+t1*d0[IX(i0,j1)])+s1*(t0*d0[IX(i1,j0)]+t1*d0[IX(i1,j1)]);
		}
	}
	set_bnd ( N, b, d );
}

void project ( int N, float * u, float * v, float * p, float * div )
{
	int i, j;
	/*
	for ( i=1 ; i<=N ; i++ ) { 
		for ( j=1 ; j<=N ; j++ ) {
			div[IX(i,j)] = -0.5f*(u[IX(i+1,j)]-u[IX(i-1,j)]+v[IX(i,j+1)]-v[IX(i,j-1)])/N;
			p[IX(i,j)] = 0;
		}
	}
	*/

	// zero out the arrays
	i = 1;
	for (j = 1; j <= N; j++) {
		catlas_sset(N, 0.0, &div[IX(i,j)], 1);
	}
	for (j = 1; j <= N; j++) {
		catlas_sset(N, 0.0, &p[IX(i,j)], 1);
	}
	
	// do the differential in the width
	i = 1;
	for ( j = 1; j <= N; j++) {
		cblas_saxpy(N, -0.5f, &u[IX(i+1,j)], 1, &div[IX(i,j)], 1);
		cblas_saxpy(N,  0.5f, &u[IX(i-1,j)], 1, &div[IX(i,j)], 1);
	}
	
	// and the height
	j = 1;
	for ( i = 1; i <= N; i++) {
		cblas_saxpy(N, -0.5f, &v[IX(i,j+1)], (N+2), &div[IX(i,j)], (N+2));
		cblas_saxpy(N,  0.5f, &v[IX(i,j-1)], (N+2), &div[IX(i,j)], (N+2));
	}
	
	// and scale by 1/N
	i = 1;
	for ( j = 1; j <= N; j++) {
		cblas_sscal(N, 1.0f/(float)N, &div[IX(i,j)], 1);
	}	
		 
	set_bnd ( N, 0, div ); 
	set_bnd ( N, 0, p );
	
	lin_solve ( N, 0, p, div, 1, 4 );
/*
	for ( j = 1; j <= N; j++ ) {
		for ( i = 1; i <= N; i++ ) {
			u[IX(i,j)] -= 0.5f*N*(p[IX(i+1,j)]-p[IX(i-1,j)]);
		}
	}
*/	
	i = 1;
	for ( j = 1; j <= N; j++ )
	{
		cblas_saxpy(N, -0.5f * N, &p[IX(i+1,j)], 1, &u[IX(i,j)], 1);
		cblas_saxpy(N,  0.5f * N, &p[IX(i-1,j)], 1, &u[IX(i,j)], 1);
	}
/*
	for ( j=1 ; j<=N ; j++ ) {
		for ( i=1 ; i<=N ; i++ ) { 
			v[IX(i,j)] -= 0.5f*N*(p[IX(i,j+1)]-p[IX(i,j-1)]);
		}
	}
*/	
	j = 1;
	for ( i = 1; i <= N; i++ )
	{
		cblas_saxpy(N, -0.5f * N, &p[IX(i,j+1)], (N+2), &v[IX(i,j)], (N+2));
		cblas_saxpy(N,  0.5f * N, &p[IX(i,j-1)], (N+2), &v[IX(i,j)], (N+2));
	}

	
	set_bnd ( N, 1, u ); set_bnd ( N, 2, v );
}

void dens_step ( int N, float * x, float * x0, float * u, float * v, float diff, float dt )
{
	add_source ( N, x, x0, dt );
	SWAP ( x0, x ); diffuse ( N, 0, x, x0, diff, dt );
	SWAP ( x0, x ); advect ( N, 0, x, x0, u, v, dt );
}

void vel_step ( int N, float * u, float * v, float * u0, float * v0, float visc, float dt )
{
	add_source ( N, u, u0, dt ); add_source ( N, v, v0, dt );
	SWAP ( u0, u ); diffuse ( N, 1, u, u0, visc, dt );
	SWAP ( v0, v ); diffuse ( N, 2, v, v0, visc, dt );
	project ( N, u, v, u0, v0 );
	SWAP ( u0, u ); SWAP ( v0, v );
	advect ( N, 1, u, u0, u0, v0, dt ); advect ( N, 2, v, v0, u0, v0, dt );
	project ( N, u, v, u0, v0 );
}


