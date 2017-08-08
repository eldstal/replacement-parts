
$fn=24;

HACK=0.001;

body_back_w = 21.2;
body_back_d = 2.5;
  
body_front_w = 20.8;
body_front_d = 2.3;

body_h = 5.6;

module half_pill(r, l) {
  rotate([90, 0, 0]) {
    translate([0, 0, l-r])
      sphere(r=r);
    cylinder(r=r, h=l-r);
  }
}


module main_body() {
  
  r = 0.05;
  
  back_w = body_back_w;
  back_d = body_back_d;
  
  front_w = body_front_w;
  front_d = body_front_d;
  
  
  // Sharp edges
/*
  rotate([90, 0, 0])
  translate([back_w/2, back_d/2])
    linear_extrude(body_h, scale=[front_w/back_w, front_d/back_d])
      square([back_w, back_d], center=true);
  */

  

  // Slow, but nicely rounded edges
  off_x = (back_w - front_w) / 2;
  off_z = (back_d - front_d) / 2;

  y = [ -r, -(body_h - r)];
  
  b_x = [ r, back_w - r];
  b_z = [ r, back_d - r];
  
  f_x = [ off_x + r, off_x + front_w - r ];
  f_z = [ off_z + r, off_z + front_d - r ];
  
  hull() {
    for (x = b_x)
      for (z = b_z)
        #translate([x, y[0], z])
          sphere(r=r, $fn=10);
    
    for (x = f_x)
      for (z = f_z)
        translate([x, y[1], z])
          sphere(r=r, $fn=10);
  }
  
}

guide_diam = 2.4;
guide_cc = 20.5 - guide_diam;
guide_length = 5;

module guide() {
  d = guide_diam;
  
  notch = 1.5;
  notch_d = d - 2;
  
  rotate([90, 0, 0])
    difference() {
      cylinder(d=d, h=guide_length + 1);
      
      translate([-d/2, -d - (d/2) + notch_d, notch])
      cube([d, d, guide_length + 1 - notch]);
    }
  
}

module wedge() {
  d = 1.2;
  r = d/2;
  
  wide = 7.5;
  narrow = 2;
  h_1 = 1;
  h_2 = 6.5;
  
  // The little ridge on top
  ridge_d = 2.1;
  ridge_w = 1;
  ridge_h = 2.7;
  ridge_x = 1.1 + (ridge_w/2);
  
  translate([0, 0, r])
  hull() {
    translate([r, -r, 0])
      sphere(r=r);
    
    translate([wide-r, -r, 0])
      sphere(r=r);
    
    translate([wide-r, h_1, 0])
      sphere(r=r);
    
    translate([r, h_2, 0])
      sphere(r=r);
    
    translate([r+narrow-r, h_2, 0])
      sphere(r=r);
    
  }
  
  translate([ridge_x, 0, 0])
    hull() {
      translate([0, 0, ridge_d])
      translate([0, 0, -ridge_d/2]) {
        
        cylinder(d=ridge_w, h=ridge_d/2);
        
        translate([0, ridge_h-ridge_w/2, 0])
        cylinder(d=ridge_w, h=ridge_d/2);
      }
    }
}


module eject_button() {
  pill_r = 1;
  
  
  w_pill_cc = 21.3 - 2*pill_r;
  w_pill_x = (body_back_w - w_pill_cc)/2;
  
  w_pill_angle = atan((body_back_w-body_front_w) / (2*body_h));
  w_pill_y = -0.5;
  w_pill_l = 4.3;
  

  d_pill_y = w_pill_y;
  d_pill_cc = 2.8 - 2*pill_r;
  d_pill_z = (body_back_d - d_pill_cc)/2;
  
  d_pill_angle = atan((body_back_d-body_front_d) / (2*body_h));
  d_pill_x1 = 4.5;
  d_pill_x2 = body_back_w - d_pill_x1;
  d_pill_l_top = 2.4;
  d_pill_l_bottom = 4.5;
  
  main_body();
  
  guide_1 = (body_back_w - guide_cc)/2;
  
  translate([guide_1, guide_length, body_back_d/2])
    guide();
  
  translate([guide_1 + guide_cc, guide_length, body_back_d/2])
    guide();
  
  translate([5.6, 0, 0.3])
    wedge();
  
  // The pills that expand the width
  translate([w_pill_x, w_pill_y, body_back_d/2])
    rotate([0, 0, w_pill_angle])
    half_pill(r=pill_r, l=w_pill_l);
    
  translate([w_pill_x + w_pill_cc, w_pill_y, body_back_d/2])
    rotate([0, 0, -w_pill_angle])
    half_pill(r=pill_r, l=w_pill_l);
    
    
  // The pills on the top edge
  translate([d_pill_x1, d_pill_y, d_pill_z + d_pill_cc])
    rotate([d_pill_angle, 0, 0])
    half_pill(r=pill_r, l=d_pill_l_top);

  translate([d_pill_x2, d_pill_y, d_pill_z + d_pill_cc])
    rotate([d_pill_angle, 0, 0])
    half_pill(r=pill_r, l=d_pill_l_top);
    
    
  translate([d_pill_x1, d_pill_y, d_pill_z])
    rotate([-d_pill_angle, 0, 0])
    half_pill(r=pill_r, l=d_pill_l_bottom);

  translate([d_pill_x2, d_pill_y, d_pill_z])
    rotate([-d_pill_angle, 0, 0])
    half_pill(r=pill_r, l=d_pill_l_bottom);
      
  
}




eject_button();
