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


body_w = 149;
body_d = 13.7;
outer_thickness = 1.6;

body_short_edge = 65;
inner_d = 11;
inner_lip_w = 1;
inner_lip_d = 1.1;
inner_w = body_w - 2*(outer_thickness + inner_lip_w);

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
// Reliefs on the front face.
// Origin is the top-left (outside) corner of the front face,
// cuts hang under the XY plane
//
module front_grooves() {

  box_x = 27.5;
  box_y = 22.3;
  box_width = 79.2;
  box_height = 29.7;
  line_height = 0.8;
  depth = 0.7;
  
  translate([0,0,-depth])
    linear_extrude(depth) {
      translate([box_x, -(box_y+box_height)])
        square([box_width, box_height]);
      
      translate([-10, -(box_y + line_height)])
        square([170, line_height]);
      
      translate([-10, -(box_y + box_height)])
        square([170, line_height]);
    }
}

//
// Hollowed-out body with front face reliefs cut out
// Origin is at the upper-left corner (inside)
//

module hollow_body() {


  body_rounding = 2;

  body_floor_edge = 21.3;
  body_short_ext = (body_floor_edge / cos(floor_angle));   // Assuming that the front lip has a 90 degree angle to the floor
  body_h = body_short_edge + body_short_ext;

  front_w = 148.4;
  front_h = 81.7;


  t = outer_thickness;
  l = outer_thickness + inner_lip_w;

  
  front_offset = (body_w - front_w) / 2;

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
      
      // Cut the front grooves
      // These are indexed by the top-left corner of the front face
      translate([front_offset, body_h - front_offset, body_d])
        front_grooves();
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

module screw_post_strut_4(rot, is_long=false) {
  short = 2;
  long = 5;
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
        if (is_long) {
          square([long+i, height]);
        } else {
          square([short+i, height]);
        }

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
    screw_post_strut_4(90, is_long=true);
    screw_post_strut_4(180, is_long=false);
    screw_post_strut_3(270);
    
  }

  translate([c_c_3, -c_r_1, 0]) {
    screw_post();
    screw_post_strut_4(0, is_long=false);
    screw_post_strut_4(90, is_long=true);
    screw_post_strut_3(180);
    screw_post_strut_3(270);
  }

  translate([c_c_1, -c_r_2, 0]) {
    screw_post();
    screw_post_strut_3(0);
    screw_post_strut_3(90);
    screw_post_strut_4(180, is_long=false);
    screw_post_strut_3(270);
  }

  translate([c_c_2, -c_r_2, 0]) {
    screw_post();
    screw_post_strut_3(0);
    screw_post_strut_3(180);
  }

  translate([c_c_3, -c_r_2, 0]) {
    screw_post();
    screw_post_strut_4(0, is_long=false);
    screw_post_strut_3(90);
    screw_post_strut_3(180);
    screw_post_strut_3(270);
  }
  
  
  
  // The frame screw posts are in a 2x2 configuration, and have no struts.
  // All measurements are to outside edges of posts.
  f_r_1 = 17 + (post_o/2);
  f_r_2 = 45 + (post_o/2);
  f_c_1 = 18.3 + (post_o/2);
  f_c_2 = 104.8 + (post_o/2);
  
  translate([f_c_1, -f_r_1, 0]) screw_post();
  translate([f_c_1, -f_r_2, 0]) screw_post();
  translate([f_c_2, -f_r_1, 0]) screw_post();
  translate([f_c_2, -f_r_2, 0]) screw_post();
  
}

// Indexed in the top-right corner (seen from the inside) and extending in positive Z direction
jack_hole_w = 16.7;
module jack_hole() {
  
  w = jack_hole_w;
  h = 24.9;
  r = 2.7;
  d = 5;
  
  translate([0, -h])
    linear_extrude(d)
      hull() {
        translate([r, r])
          circle(r=r);
        translate([w-r, r])
          circle(r=r);
        translate([r, h-r])
          circle(r=r);
        translate([w-r, h-r])
          circle(r=r);
      }
}

// Indexed in the inner top-right corner (above the selector switch)
module jack_holes() {
  start_x = 27.3;
  start_y = 22;
  total_w = 75.2;
  
  off_x = jack_hole_w + (total_w - (4*jack_hole_w))/3;
  
  translate([start_x+0*off_x, -start_y, 0])
    jack_hole();
  translate([start_x+1*off_x, -start_y, 0])
    jack_hole();
  translate([start_x+2*off_x, -start_y, 0])
    jack_hole();
  translate([start_x+3*off_x, -start_y, 0])
    jack_hole();
}


guide_thickness = 1.5;
module case_guide(rot=0) {
  d = inner_d;
  h = 3.5;
  w = guide_thickness;
  notch_h = 0.3;
  notch_d = inner_lip_d;
  
  rotate([0,90,rot])
    translate([0,-h,0])
      linear_extrude(w, center=true) {
        difference() {
          square([d,h]);
          translate([d-notch_d, h-notch_h])
            square([notch_d, notch_h]);
        }
      }
  
}

// The four case guides around the edge of the case
// Origin is at the inner top-right corner (above the selector switch)
module case_guides() {
  
  t2 = guide_thickness / 2;
  translate([46.4 + t2, 0, 0])
    case_guide(0);
  
  translate([97.3 + t2, 0, 0])
    case_guide(0);
  
  translate([0, -(34.2 + t2), 0])
    case_guide(90);
  
    
  translate([inner_w, -(34.2 + t2), 0])
    case_guide(270);
}


//
// Cable hole and other features around the top edge
//
module cable_hole() {
  w = 7.4;
  h = 8;
  d = 3.5;
  
  translate([68.3, -(h/2), -inner_d-0.01])
    cube([w, h, d+0.01]);
}

module cable_hole_lip() {
  h = 0.5;
  w = 10;
  d = inner_d - inner_lip_d;
  translate([67, -h, -d])
    cube([w, h, d+0.01]);
}

module tool_notch() {
  w = 6;
  h = inner_lip_w;
  d = 2;
  
  translate([108.9, -0.01, -(inner_d-inner_lip_d)-0.01])
    cube([w, h+0.01, d+0.01]);
}


//
// Holes for switches in the front
//

switch_rim_w = 11;
switch_rim_h = 19.1;


module switch_hole() {
  w = 8.4;
  h = 16.3;
  r = w/2;
  d = 15;
  translate([-w/2, -h/2, -d/2])
    linear_extrude(d)
      rounded_rect(w,h,r); 
}


// centered
module switch_rim() {
  w = switch_rim_w;
  h = switch_rim_h;
  r = w/2;
  d = 4.8;
  translate([-w/2, -h/2, -d])
    linear_extrude(d)
      rounded_rect(w,h,r); 
}


// false for rims, true for holes
module switch_holes(hole=false) {
  // Measurements to the edge to each switch hole
  switch_rim_x = [7.5, 111.1, 124.7];
  switch_rim_y = 25;

  for (x_start = switch_rim_x) {
    x = x_start + (switch_rim_w / 2);
    y = switch_rim_y + (switch_rim_h / 2);
    translate([x, -y])
      if (hole) {
        switch_hole();
      } else {
        switch_rim();
      }
  }
}


// Top-level module
module casing_front() {
 
  difference() {
    union() {
      hollow_body();
      case_guides();
      cable_hole_lip();
      screw_posts();
      switch_holes(hole=false);
    }
    
    translate([0,0,-0.01])
      jack_holes();
    
    cable_hole();
    tool_notch();
    switch_holes(hole=true);
  }
  

}



casing_front();
