/*
 * Selector switch cap for NES four score
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
 * Brim
 */

 ss_brim_length=20;
 ss_brim_diameter=10;
 ss_brim_height=2.3;
 ss_brim_rounding=0.2;


 /*
  * Steeple
  */

ss_steeple_bot_diameter = 7.5;
ss_steeple_bot_length = 11.9;
ss_steeple_height = 11.3;
ss_steeple_top_diameter = 7.1;
ss_steeple_top_length = 11.5;
ss_steeple_narrow_rounding = 0.2;
ss_steeple_wide_rounding = 0.5;

module ss_steeple_rounding() {
  top_rect_x = ss_steeple_top_length - (ss_steeple_top_diameter);
  top_rect_y = ss_steeple_top_diameter - (ss_steeple_wide_rounding*2);

  // Cut off a wider fillet along the X axis
  translate([0, 0, -ss_steeple_wide_rounding])
  rotate([0,90,0]) {
    translate([0,top_rect_y/2, 0])
      cylinder(h=ss_steeple_top_length, r=ss_steeple_wide_rounding, center=true);
    translate([0,-top_rect_y/2, 0])
      cylinder(h=ss_steeple_top_length, r=ss_steeple_wide_rounding, center=true);

    translate([-ss_steeple_wide_rounding/2, 0, 0])
    cube([ss_steeple_wide_rounding, top_rect_y, ss_steeple_top_length], center=true);
  }
}

 module ss_steeple() {
    mid = (ss_steeple_bot_length/2) - (ss_steeple_bot_diameter/2);


    hull() {
      // Bottom of steeple
      linear_extrude(0.01) {
        translate([mid,0,0])
          circle(d=ss_steeple_bot_diameter);
        translate([-mid,0,0])
          circle(d=ss_steeple_bot_diameter);
        square([2*mid, ss_steeple_bot_diameter], center=true);
      };

      // Top of steeple
      translate([0, 0, ss_steeple_height - (ss_steeple_narrow_rounding) ])
        intersection() {
          flat_rounded_pill(ss_steeple_top_length, ss_steeple_top_diameter,
                           ss_steeple_narrow_rounding*2, ss_steeple_narrow_rounding);

          // Wider rounding along the X axis
          translate([0, 0, ss_steeple_narrow_rounding*2])
          ss_steeple_rounding();
        }
    };
 }





 /*
  * Solid body
  */
module ss_body() {
  // Brim
  flat_rounded_pill(ss_brim_length, ss_brim_diameter, ss_brim_height, ss_brim_rounding);

  // Steeple
  translate([0, 0, ss_brim_height])
    ss_steeple();
}



/*
 * Cross-shaped hole in the bottom
 */
module ss_hole() {
  linear_extrude(height=11.2) {
    square([5.2, 5.1], center=true);
    square([8.7, 2.7], center=true);
  }
}


/*
 * Little round dimples on the bottom
 */
ss_dimple_cc = 14;
ss_dimple_diameter = 2.4;

module ss_dimples() {
  mid = ss_dimple_cc / 2;

  linear_extrude(height=0.8) {
    translate([mid, 0, 0])
      circle(d=ss_dimple_diameter);
    translate([-mid, 0, 0])
      circle(d=ss_dimple_diameter);
  };
}


 // Top-level module
 module selector_switch() {
  difference() {
    ss_body();
    ss_hole();
    ss_dimples();
  }
 }



 selector_switch();
