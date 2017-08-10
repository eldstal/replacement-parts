
$fn=64;

HACK=0.005;

body_w = 8.9;
ear_d = 2.8;

module screw_hole() {
  
  wide_diam = 6.6;
  hole_diam = 4;
  chamfer = 1;
  
  cut_w = 0.9;
  cut_h = wide_diam / 2;  // Extends to the edge of the wide opening
  
  // Wide opening
  translate([0, 0, -HACK])
    cylinder(d=wide_diam, h=0.6+HACK);
  
  // Straight hole
  cylinder(d=hole_diam, h=ear_d+HACK);
  
  // Top chamfer
  translate([0, 0, ear_d - chamfer])
  cylinder(d1=hole_diam, d2=hole_diam+chamfer, h=chamfer+HACK);
  
  // The little straight cut
  cut_l = cut_h - cut_w/2;
  translate([-cut_w/2, -cut_l, 0]) {
    cube([cut_w, cut_l, ear_d+HACK]);
    
    translate([cut_w/2, 0, 0])
    cylinder(d=cut_w, h=ear_d+HACK);
  }

}

module screw_ear() {
  
  ear_diam = 8.1;
  
  extent_y = 8.5 ;
  
  off_x = (body_w - (ear_diam/2));
  
  translate([-off_x, 0, 0 ]) {
    difference() {
      
      hull() {
        cylinder(d=ear_diam, h=ear_d);
        
        translate([off_x-HACK, -(extent_y - 0.1), 0])
        cube([HACK, extent_y, ear_d]);
      }
      
      screw_hole();
    }
    
  }
  
}

prongs_diam = 2;

module prongs() {
  
  
  d = 2.1;
  chamfer = 0.3;
  od = prongs_diam;
  id = 1.3;
  
  // The two little prongs
  difference() {
    union() {
      cylinder(d=od, h=d-chamfer);
      translate([0,0,d-chamfer])
        cylinder(d1=od, d2=od-chamfer, h=chamfer);
    }
    
    cylinder(d=id, h=d+0.1);
    
    cube([od*2, 0.5, d*3], center=true);
  }
  
}

module base_plate() {
  t = 1.5;
  
  w = 5;
  off_x = 0.2;
  
  r_1 = 0.1;
  r_2 = 0.75;
  
  tip_diam = 3.1;
  
  left_x = -(tip_diam/2 + (w-tip_diam-off_x));
  
  right_x = tip_diam/2 + off_x;
  
  // Centered X at the right edge
  // Y at the center of the nub
  translate([-(tip_diam/2 + off_x), 0, -t]) {
    hull() {
      cylinder(d=tip_diam, h=t);
      
      translate([ left_x + r_1,7.5 - (tip_diam/2), 0])
        cylinder(r=r_1, h=t);
      
      translate([ left_x + r_2 ,10.3 - (tip_diam/2), 0])
        cylinder(r=r_2, h=t);
      
      translate([ right_x - r_2, 11, 0])
        cylinder(r=r_2, h=t);
      
      translate([ right_x - r_2, 6 - (tip_diam/2), 0])
        cylinder(r=r_2, h=t);
    }
    
    
    // The little nub that gives our detent
    nub_t = 2.4;
    nub_diam = tip_diam;
    difference() {
      translate([0, 0, nub_t-(nub_diam/2)])
        sphere(d=nub_diam);
      
      translate([0, 0, -nub_diam/2 + HACK])
        cube(nub_diam, center=true);
    }
    
    translate([- (2.2 - prongs_diam/2), 9.5 - tip_diam/2 - prongs_diam/2, t])
    prongs();
    
  }
}

module slider() {
  or = 11.5;
  ir = or - 2.6;
  max_t = 2.1;
  
  angle = 34;
  
  cut_r = or + 1;
  cut_x = cut_r * cos(90-angle);
  cut_y = cut_r * sin(90-angle);
  
  
  small_chamfer = 30;
  
  large_chamfer = 18;
  
  
  translate([0, -ir, 0])
  rotate([0, 90, 0])
  difference() {
    translate([0, 0, max_t/2])
      cylinder(r=or, h=max_t, center=true); 

    translate([0, 0, max_t/2])
      cylinder(r=ir, h=max_t*2, center=true);

    // Cut out the left half
    translate([-2*or, -or, -max_t])
      cube([2*or, 3*or, max_t*3]);

    // Cut out the segment we want, from 90 to angle
    linear_extrude(max_t*3, center=true) {
        polygon([
            [0,0],
            [-HACK, -3*or],
            [3*or, HACK],
            [cut_x, cut_y]
        ]);
    }
    
   
    translate([0.3, 0, -0.6])
    rotate([large_chamfer, large_chamfer, 0])
    cube([10, or*2, max_t*2]);
    
    translate([-0.9, 0, 0.5])
    rotate([0, -small_chamfer, 0])
    //rotate([small_chamfer/2, 0, 0])
    cube([5, or*2, max_t*2]);
    
    
  }
  
}

module hinge_clip() {
  screw_ear();
  
  translate([0, -13, 0])
  rotate([0, 90, 0])
  base_plate();
  
  translate([ -1, -2.8, 1])
  slider();
}

hinge_clip();
