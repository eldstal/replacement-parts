
$fn=16;

HACK=0.001;

body = [ 41.5, 7.4, 1.3 ];

body_rounding = 0.7;

module main_body() {
  r = body_rounding;
  i_w = body[0] - r*2;
  i_h = body[1] - r*2;
  d = body[2];
  
  translate([0,0,-d])
  hull() {
    translate([r, r, 0])
    cylinder(r=r, h=d);
    
    translate([i_w+r, r, 0])
    cylinder(r=r, h=d);
  
    translate([r, i_h+r, 0])
    cylinder(r=r, h=d);
    
    translate([i_w+r, i_h+r, 0])
    cylinder(r=r, h=d);  
    
  }
  
}

module stopper() {
  d = 0.7;
  w = 1.9;
  h = 1.7;
  
  difference() {
    union() {
      cube([w, h - d, d]);
      
      translate([0, h-d, 0])
        rotate([0, 90, 0])
          cylinder(r=d, h=w);
    }
    
    translate([-HACK,-HACK,-d-HACK])
      cube([w+2*HACK, h+HACK, d+HACK]);
  }
}

module spring_guides() {
  h = 1.5;
  d = 1.2;
  w1 = 1;
  w2 = 1.2;
  
  cube([w1, h, d]);
  
  translate([3 - (w2), 0, 0]) {
    cube([w2, h, d]);
    
    translate([0, (h/2), d])
      rotate([0, 90, 0])
      cylinder(d=h, h=w2);
  }
}


hinge_diam = 1.1;

module hinge(hinge_w = 10.7, mount_w = 4.3) {
  
  total_h = 4.5;
  
  
  mount_h = total_h - hinge_diam/2;
  mount_d = 0.9;
  
  
  translate([0, 0, (mount_d-hinge_diam/2)])
    rotate([0, 90, 0])
    cylinder(d=hinge_diam, h=hinge_w);
  
  
  translate([(hinge_w - mount_w), -mount_h, 0]) {
    difference() {
      cube([mount_w, mount_h, mount_d]);
  
      // chamfer
      translate([-HACK, 0, 0])
      rotate([40, 0, 0])
        cube(mount_w+2*HACK);
    }
  }
  
}


module memory_card_door() {
  hinge_to_bottom = 10;
  
  main_body();
  
  translate([8.8, -1, 0])
    stopper();
  
  translate([30.8, -1, 0])
    stopper();
  
  translate([1.7, 2, 0])
    spring_guides();
  
  translate([-3, (hinge_to_bottom - hinge_diam/2), 0])
    hinge(hinge_w = 10.7, mount_w = 4.3);
  
  translate([body[0] + 2.4, (hinge_to_bottom - hinge_diam/2), 0])
    mirror([1, 0, 0])
      hinge(hinge_w = 10, mount_w = 4.9);
}

memory_card_door();
