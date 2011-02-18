//
//  Solver.h
//  GLPaint
//
//  Created by Kevin Loken on 11-02-17.
//  Copyright 2011 Stone Sanctuary Interactive Inc. All rights reserved.
//

void vel_step ( int N, float * u, float * v, float * u0, float * v0, float visc, float dt );
void dens_step ( int N, float * x, float * x0, float * u, float * v, float diff, float dt );


