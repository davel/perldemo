#!/usr/bin/perl
# vim:ts=4:shiftwidth=4:expandtab

use strict;
use warnings;
use OpenGL;

glpOpenWindow();

while (1) {
    glClear(GL_COLOR_BUFFER_BIT);

    glBegin(GL_POLYGON);
    glVertex2f(-1, -1);
    glVertex2f(-1,  1);
    glVertex2f( 1,  1);
    glVertex2f( 1, -1);
    glEnd();
    

    glpFlush(); 
}
