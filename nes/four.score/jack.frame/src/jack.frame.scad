
$fn=16;



// Upper (slightly wider) frame
uf = [ 80.3, 34.8, 5 ];

// Lower (n arrower) frame
lf = [ uf[0], 30.8, 5 ];

// Height of the ear's barrel
ear_height = 12.7;

// Diameters
ear_od = 10;
ear_id = 7.3;
ear_hole = 3.2;

// Depth of the top and bottom large holes
ear_td = 8;
ear_bd = 2.8;


module body() {

  translate([-uf[0]/2, -uf[1]/2, -uf[2]])
    cube(uf);

  translate([-lf[0]/2, -lf[1]/2, -uf[2]-lf[2]])
    cube(lf);

}


module ear_cuts(screw=true) {


    translate([0,0, (ear_bd/2) - ear_height - 0.01])
      cylinder(h=ear_bd, d=ear_id, center=true);

    translate([0,0, -ear_td/2 + 0.01])
      cylinder(h=ear_td, d=ear_id, center=true);

    if (screw == true) {
      translate([0,0, -ear_height/2])
        cylinder(h=ear_height, d=ear_hole, center=true);

    }

}

// Centered X,Y and hanging under the XY plane
module ear() {

  r = ear_od/2;

  // Measurements extrapolated on paper
  chamfer_o_x = 7-r;
  chamfer_extent = 9.5;


  chamfer_o_a = 180+acos((chamfer_o_x)/r);
  chamfer_o_y = r * sin(chamfer_o_a);
  echo(a=chamfer_o_a, x=chamfer_o_x, y=chamfer_o_y);


  echo(chamfer_o_y);
  union() {
    translate([0,0,-ear_height/2])
      cylinder(h=ear_height, d=ear_od, center=true);

    // The surface where the ear chamfer meets the frame
    mirror([0,0,1])
      linear_extrude(uf[2] + lf[2])
        polygon([ [0,0],
                  [r,0],
                  [r, -chamfer_extent],
                  [-chamfer_o_x, chamfer_o_y] ]);
  }
}



//
// Top-level module
//
module jack_frame() {

  ear_ow = 96.4;
  ear_oh = 38;

  ear_cc_x = ear_ow - ear_od;
  ear_cc_y = ear_oh - ear_od;

  ear_x = ear_cc_x / 2;
  ear_y = ear_cc_y / 2;


  difference() {
    union() {
      body();

      translate([-ear_x, ear_y])
        ear();

      translate([ear_x, ear_y])
        mirror([1,0,0])
          ear();

      translate([ear_x, -ear_y])
        rotate([0,0,180])
          ear();

      translate([-ear_x, -ear_y])
        mirror([0,1,0])
          ear();
    }

    // Since the cuts actually go into the upper frame and not just
    // the ear barrels, they have to made separately...
    union() {

      translate([-ear_x, ear_y])
        ear_cuts(true);

      translate([ear_x, ear_y])
        mirror([1,0,0])
          ear_cuts(false);

      translate([ear_x, -ear_y])
        rotate([0,0,180])
          ear_cuts(true);

      translate([-ear_x, -ear_y])
        mirror([0,1,0])
          ear_cuts(false);
    }
  }


}



jack_frame();
