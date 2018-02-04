#!/usr/bin/perl
# vim:ts=4:shiftwidth=4:expandtab

use strict;
use warnings;
use OpenGL qw/ :glufunctions :glutfunctions :glconstants :glfunctions :glutconstants /;

my $stars = 100;

glutInit();
glutInitDisplayMode( GLUT_DOUBLE );
glutCreateWindow('demo');
glutDisplayFunc(\&display);
glutReshapeFunc(\&resize);

my $vertex_shader = glCreateShaderObjectARB( GL_VERTEX_SHADER );

glShaderSourceARB_p($vertex_shader, q{
void main() {
    gl_FrontColor = gl_Color;
    gl_Position = ftransform();
}
});

glCompileShaderARB($vertex_shader);

if (!glGetObjectParameterivARB_p($vertex_shader, GL_COMPILE_STATUS)) {
    die glGetInfoLogARB_p($vertex_shader);
}

my $frag_shader = glCreateShaderObjectARB( GL_FRAGMENT_SHADER );

my $star_data = join(", ", map {
    my $x = rand();
    my $y = rand();
    my $z = int(rand(5));
    "vec3($x, $y, $z)"
} 1..$stars);

glShaderSourceARB_p($frag_shader, qq{#version 120
    uniform vec3 stars[$stars] = vec3[$stars]( $star_data );

    void main() {
        float bright = 0;
        float shift = gl_Color.z;

        for (int n = 0; n<$stars; n++) {
            float d = distance(
                vec2(fract(gl_Color.x+10*shift / stars[n].z), gl_Color.y),
                vec2(stars[n].x, stars[n].y)
            );
            bright += clamp(
                (1.0-d*500)/stars[n].z,
                0.0, 1.0
            );
        }
        gl_FragColor = vec4(bright, bright, bright, bright);
    }
});

glCompileShaderARB($frag_shader);

if (!glGetObjectParameterivARB_p($frag_shader, GL_COMPILE_STATUS)) {
    die glGetInfoLogARB_p($frag_shader);
}

my $prog = glCreateProgramObjectARB();
glAttachObjectARB($prog, $frag_shader);
glAttachObjectARB($prog, $vertex_shader);
glLinkProgramARB($prog);

if (!glGetObjectParameterivARB_p($prog, GL_OBJECT_LINK_STATUS_ARB)) {
    die glGetInfoLogARB_p($prog);
}

glUseProgramObjectARB($prog);

my $offset = 0;


while (1) {
    glutMainLoopEvent();

    $offset += 1/(2**13);
    $offset = $offset > 1 ? $offset-1 : $offset;

    glutPostRedisplay();
}

sub display {
    glClear(GL_COLOR_BUFFER_BIT);

    glBegin(GL_POLYGON);
    glColor3f(0, 0, $offset);
    glVertex2f(-1, -1);
    glColor3f(0, 1, $offset);
    glVertex2f(-1,  1);
    glColor3f(1, 1, $offset);
    glVertex2f( 1,  1);
    glColor3f(1, 0, $offset);
    glVertex2f( 1, -1);
    glEnd();
    glutSwapBuffers();

    return;
}

sub resize {
    my ($w, $h) = @_;

    print "Resizing $w $h\n";
    glMatrixMode( GL_PROJECTION );
    glLoadIdentity();
    glViewport(0, 0, $w, $h);
    gluOrtho2D(-$h/$w, $h/$w, -$h/$w, $h/$w);
    glMatrixMode( GL_MODELVIEW );
    return;
}
