/*
 * Front face for NES four score
 */

$fn = 16;

/*
 * Flat pill-shape with rounded top edge
 */
module pill_fillet_end(diameter, height, rounding) {
  r = diameter/2;
  cx = r - rounding;
  cy = height - rounding;


  rotate([0, 0, -90]) {
    rotate_extrude(angle=180) {

      // Rectangle with a single rounded corner
      square(size=[r, cy]);

      if (rounding > 0) {
        square(size=[cx, height]);
        translate([cx, cy, 0])
          rotate([0,0,45])
            circle(r=rounding);
      }
    };
  };
}

module flat_rounded_pill(length, diameter, height, rounding) {
  // Distance from the middle to the center of the round cap
  mid = (length/2) - (diameter/2);
  hull() {
    translate([mid,0,0])
      pill_fillet_end(diameter, height, rounding);
    translate([-mid,0,0])
      rotate([0,0,180])
        pill_fillet_end(diameter, height, rounding);
  }
}


/*
 * Rectangle with rounded corners, not centered
 */
module rounded_rect(w,h,r) {
  x0 = r;
  y0 = r;
  x1 = w - r;
  y1 = h - r;

  hull() {
    translate([x0, y0])
      circle(r=r);
    translate([x0, y1])
      circle(r=r);
    translate([x1, y1])
      circle(r=r);
    translate([x1, y0])
      circle(r=r);
  }
}


module rounded_3_corner(r) {
  intersection() {
    sphere(r=r);
    cube(r);
  }
}

// Cuboid with rounded top edges and corners,
// with its top on the XY plane
module rounded_rect_top(w,h,r) {
  x0 = r;
  y0 = r;
  z0 = -r;

  x1 = w - r;
  y1 = h - r;

  hull() {
    translate([x1, y1, z0])
      rounded_3_corner(r);

    translate([x0, y1, z0])
    rotate([0,0,90]) rounded_3_corner(r);

    translate([x0, y0, z0])
    rotate([0,0,180]) rounded_3_corner(r);

    translate([x1, y0, z0])
    rotate([0,0,270]) rounded_3_corner(r);
  }
}


body_short_edge = 65;
floor_angle = asin(31.5/body_short_edge);   // Measured under the short edge of the back


// The general wedgy shape of the main body
module body_shape(back_width, back_height, back_short_edge,
                  face_width, face_height,
                  depth, rounding) {

  // Difference between back and front, gives a slight chamfer to the sides.
  face_offset = (back_width - face_width)/2;

  difference() {
    // The extreme extents of the body, with the back extended
    hull() {
      // The open (back) surface
      linear_extrude(0.01) {
        rounded_rect(back_width, back_height, rounding);
      }

      // The front face, which is slightly smaller
      translate([face_offset, (back_height - face_height - face_offset), depth])
        rounded_rect_top(face_width, face_height, rounding);
    }

    // The angular cutout toward the "floor"
    translate([-0.5, back_height - back_short_edge, 0])
      rotate([90-floor_angle,0,0])
        mirror([0,1,0]) cube([back_width + 1, 20, 3*depth]);
  }
}

//
// Hollowed-out body without other features
// Origin is at the upper-left corner (inside)
//

module hollow_body() {

  body_w = 149;
  body_d = 13.7;
  body_rounding = 2;

  body_floor_edge = 21.3;
  body_short_ext = (body_floor_edge / cos(floor_angle));   // Assuming that the front lip has a 90 degree angle to the floor
  body_h = body_short_edge + body_short_ext;

  front_w = 148.4;
  front_h = 81.7;

  outer_thickness = 1.55;
  inner_d = 11;

  inner_lip_w = 1;
  inner_lip_d = 1.1;

  t = outer_thickness;
  l = outer_thickness + inner_lip_w;

  translate([-l, -(body_h -l), -inner_d]) {

    // Outer shell/lip
    difference() {
      // Outer shape
      body_shape(body_w, body_h, body_short_edge,
                 front_w, front_h,
                 body_d, body_rounding);

      // Hollow out to give the outer lip
      translate([t, t, -0.01])
        body_shape(body_w - (2*t), body_h - (2*t), body_short_edge,
                   front_w - (2*t), front_h - (t*1.5),
                   inner_d+0.01, 0.01);
    }

    // Inner lip
    difference() {
      translate([t, t, inner_lip_d])
        body_shape(body_w - (2*t), body_h - (2*t), body_short_edge - (t*1.5),
                   body_w - (2*t), front_h - (t*1.5),
                   inner_d, 0.01);

      translate([l, l, inner_lip_d-0.01])
        body_shape(body_w - (2*(l)), body_h - (2*(l)), body_short_edge - (t*1.5),
                   body_w - (2*(l)), front_h - (2*(l)),
                   inner_d+0.1, 0.01);
    }
  }
}



//
// Screw posts inside the case
//
post_o = 7;
post_i = 2.5;
post_h = 8;
post_sink_d = 4;
post_sink_s = 0.5;
module screw_post() {
  translate([0, 0, (-post_h/2)])
    difference() {
      cylinder(d=post_o, h=post_h, center=true);
      translate([0, 0, -0.01])
        cylinder(d=post_i, h=post_h, center=true);
      translate([0, 0, -(post_h - post_sink_s)/2 - 0.01 ])
        cylinder(d1=post_sink_d, d2=post_i, h=post_sink_s, center=true);
    }
}

module screw_post_strut_3(rot) {
  width = 2.3;
  height = 6.7;
  thickness= 1.4;

  // Extra width to make sure it intersects the post,
  // but doesn't interfere with the screw hole
  i = (post_o - post_i) / 2;
  //i=0;
  rotate([0, 0, rot])
    translate([post_o/2 - i, 0, 0])
      rotate([-90, 0, 0])
      linear_extrude(thickness, center=true)
        polygon(points = [ [ 0, 0 ], [width+i, 0], [i, height], [0, height] ]);

}

// Origin at the inside of the upper-left corner (above the selector switch)
module screw_posts() {
  // The case screw posts are in two rows, three columns.
  // All measurements are to outer edge of posts
  c_r_1 = 4.3 + (post_o/2);
  c_r_2 = 52.3 + (post_o/2);
  c_c_1 = 2 + (post_o/2);
  c_c_2 = 68.5 + (post_o/2);
  c_c_3 = 135 + (post_o/2);

  translate([c_c_1, -c_r_1, 0]) {
    screw_post();
    screw_post_strut_3(0);
    screw_post_strut_3(270);
  }

  translate([c_c_3, -c_r_1, 0]) {
    screw_post();
    screw_post_strut_3(180);
    screw_post_strut_3(270);
  }

  translate([c_c_1, -c_r_2, 0]) {
    screw_post();
    screw_post_strut_3(0);
    screw_post_strut_3(90);
    screw_post_strut_3(270);
  }

  translate([c_c_2, -c_r_2, 0]) {
    screw_post();
    screw_post_strut_3(0);
    screw_post_strut_3(180);
  }

  translate([c_c_3, -c_r_2, 0]) {
    screw_post();
    screw_post_strut_3(90);
    screw_post_strut_3(180);
    screw_post_strut_3(270);
  }

}

// Top-level module
module casing_front() {
  hollow_body();
  //translate([i
  screw_posts();
}



casing_front();
