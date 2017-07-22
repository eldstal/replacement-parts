/*
 * Turbo button (A and B) for the NES four score
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


module flat_rounded_pill(length, diameter, height, rounding=0) {
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

module pill_2d(length, diameter) {
  mid = (length/2) - (diameter/2);

  translate([mid,0,0])
    circle(d=diameter);
  translate([-mid,0,0])
    circle(d=diameter);
  square([2*mid, diameter], center=true);

}



/*
 * Brim
 */

tb_brim_length=20;
tb_brim_diameter=9.9;
tb_brim_height=2;


module tb_brim() {

  linear_extrude(tb_brim_height) {
    pill_2d(tb_brim_length, tb_brim_diameter);
  }
}



/*
 * Steeple
 */

tb_steeple_bot_length=16.1;
tb_steeple_bot_diameter=8;
tb_steeple_height=11.4;

tb_steeple_top_length=15.6;
tb_steeple_top_diameter=7.8;
tb_steeple_narrow_rounding=0.2;
tb_steeple_wide_rounding=0.5;

module tb_steeple_rounding() {
  top_rect_x = tb_steeple_top_length - (tb_steeple_top_diameter);
  top_rect_y = tb_steeple_top_diameter - (tb_steeple_wide_rounding*2);

  // Cut off a wider fillet along the X axis
  translate([0, 0, -tb_steeple_wide_rounding])
  rotate([0,90,0]) {
    translate([0,top_rect_y/2, 0])
      cylinder(h=tb_steeple_top_length, r=tb_steeple_wide_rounding, center=true);
    translate([0,-top_rect_y/2, 0])
      cylinder(h=tb_steeple_top_length, r=tb_steeple_wide_rounding, center=true);

    translate([-tb_steeple_wide_rounding/2, 0, 0])
    cube([tb_steeple_wide_rounding, top_rect_y, tb_steeple_top_length], center=true);
  }
}

module tb_steeple() {


    hull() {
      // Bottom of steeple
      flat_rounded_pill(tb_steeple_bot_length, tb_steeple_bot_diameter, 0.01);

      // Top of steeple has two different fillets.
      // A narrow one around the ends and a wide one on the straight edges.
      translate([0, 0, tb_steeple_height])
        intersection() {
          // Base extent of the top surface, with narrow rounding all around
          flat_rounded_pill(tb_steeple_top_length, tb_steeple_top_diameter, tb_steeple_narrow_rounding*2, tb_steeple_narrow_rounding);

          // Wider rounding along the X axis
          translate([0, 0, tb_steeple_narrow_rounding*2])
          tb_steeple_rounding();
        }
    }



}

// The solid body
module tb_body() {
  tb_brim();
  translate([0,0,tb_brim_height])
    tb_steeple();
}



/*
 * Holes and cutouts
 */

tb_cutout_width=8.5;
tb_cutout_height = 3.5;

tb_hole_depth = 11.7;
tb_hole_length = 13;
tb_hole_diameter = 4.9;

module tb_holes() {
  // Cutout through the base
  translate([0, 0, tb_cutout_height/2])
    cube([tb_cutout_width, tb_brim_diameter+0.1, tb_cutout_height], center=true);

  // Hole up through the body
  linear_extrude(tb_hole_depth)
    pill_2d(tb_hole_length, tb_hole_diameter);
}



/*
 * The grips inside the hole
 */

tb_grip_b2b = 4.5;
tb_grip_width = 3.7;
tb_grip_thickness = 0.8;
tb_grip_spacing = 0.9;
tb_grip_rounding = tb_grip_b2b/2 - (tb_grip_thickness) - (tb_grip_spacing/2);

tb_grip_gap_width = 2.8;
tb_grip_gap_depth = 1.9;

tb_grip_extent=8.4;


module tb_grip() {
  w = (tb_grip_b2b/2) - (tb_grip_spacing/2);
  rx = w-tb_grip_rounding;
  ry = tb_grip_extent-tb_grip_rounding;

  rotate([-90, 0, 0])
  linear_extrude(tb_grip_width, center=true)
    // Cross-section of one gripper, seen from front
    translate([tb_grip_b2b / 2, 0, 0 ]) {
      rotate([0, 180, 0]) {
        square([rx, tb_grip_extent]);
        square([w, ry]);
        translate([rx, ry])
          intersection() {
            square(tb_grip_rounding);
            circle(r=tb_grip_rounding);
          }
      }
    }

}

module tb_grips() {
  difference() {
    union() {
      tb_grip();
      mirror([1,0,0])
        tb_grip();
    }

    // The hole between the prongs
    translate([0,0, -tb_grip_extent/2])
      cube([tb_grip_gap_width, tb_grip_gap_depth, tb_grip_extent], center=true);
  }
}




/*
 * Top-level module 
 */
module turbo_button() {
  difference() {
    tb_body();
    tb_holes();
  }

  translate([0,0,tb_hole_depth])
    tb_grips();
}



turbo_button();
