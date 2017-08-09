
$fn=16;

HACK=0.001;

body = [ 96.9, 11.9, 2.7 ];

wall = 1.5;
hollow_depth = 1.6;

end_corner_notch = [ 4.5, 3.2+HACK, 1.5];
half_end_corner_notch = [ 4.5, 1.1+HACK, 3*body[2]];
t_hole_chamfer = 0.4;

slide_cut_h = 5;
upper_notch_h = 0.5;

module chamfer_cuboid(w, h, chamfer) {
  scale = [ (w-2*chamfer)/w,
            (h-2*chamfer)/h
          ];
  
  translate([w/2, h/2])
  linear_extrude(chamfer, scale=scale) {
    square([w,h], center=true);
    
  }
}


// Origin is Bottom-right, on the top surface (hanging below the X/Y plane)
// T-shaped hole with chamfers on both openings
module t_hole(depth) {
  chamfer=t_hole_chamfer;
  w=9;
  h=7.8;
  t=3.5;
  d=depth - 2*chamfer;    // Depth of the straight portion
  
  cw = w + 2*chamfer;
  ch = h + 2*chamfer;
  ct = t + 2*chamfer;

  // Extended above the top of the upper surface
  translate([-chamfer, -chamfer, HACK]) {
    translate([0, (ch-ct)/2]) {
      //cube([cw,ct,depth+HACK]);
      mirror([0,0,1])
        chamfer_cuboid(cw,ct, chamfer);
    }
    translate([(cw-ct), 0]) {
      //cube([ct,ch,depth+HACK]);
      mirror([0,0,1])
        chamfer_cuboid(ct,ch, chamfer);
    }
  }
  
  // FIXME: Chamfer these holes
  
  // Straight bit of the hole
  translate([0, 0, -depth+HACK]) {
    translate([0, (h-t)/2])
      cube([w,t,depth]);
    translate([(w-t), 0])
      cube([t,h,depth]);
  }
  
  // Extended below the bottom surface
  translate([-chamfer, -chamfer,-depth-HACK]) {
    translate([0, (ch-ct)/2]) {
      //cube([cw,ct,depth+HACK]);
      chamfer_cuboid(cw,ct, chamfer);
    }
    translate([(cw-ct), 0]) {
      //cube([ct,ch,depth+HACK]);
      chamfer_cuboid(ct,ch, chamfer);
    }
  }

}

// The long rectangular cut, including the chamfers of the little vertical wall
// Origin is the far-bottom (+x, -y) corner of the rectangular hole
// Z-aligned with the top surface of the body
module slide_cut() {
  
  chamfer = 1;
  h = slide_cut_h;
  l = 25;
  d = body[2] + 1 - chamfer;
  
  // Extend one extra mm past top surface
  translate([0,0,1])
  rotate([90, 0, -90])
  linear_extrude(l) {
    polygon(
      [
        [ 0, 0],
        [ -h, 0],
        [ -h, -d],
        [ -(h+chamfer), -(d+chamfer) ],
        [ -(h+chamfer), -(d+3*chamfer) ],  // Extend cut below
    
        [ (chamfer), -(d+3*chamfer) ],  // Extend cut below
        [ (chamfer), -(d+chamfer) ],
        [ 0, -d],
      ]
    );
  }
}

module spring_hook() {
  chamfer = 1;
  top = 1.7;
  neck_w = 1.8;
  tip = 0.3;
  
  width = chamfer + top + chamfer;
  height = 1.9;
  depth = 2.2;
  
  bar_depth = body[2] - depth;
  
  // The little hook that hangs under the bar
  translate([0,0,-bar_depth])
  rotate([90, 0, 0])
  linear_extrude(height, center=true)
    polygon(
      [
        [ 0, HACK ],
        [ neck_w, HACK],
        [ neck_w, -(height - chamfer)],
        [ neck_w - chamfer, -depth ],
        [ neck_w - chamfer - top, -depth],
        [ neck_w - chamfer - top - chamfer, -(depth - chamfer)],
        [ neck_w - chamfer - top - chamfer, -(depth - chamfer - tip)],
        [ 0, -(depth- chamfer - tip)],
      ]
    );
    
    // The vertical bar the hook sits on
    translate([neck_w/2, 0, -bar_depth/2])
    cube([neck_w, body[1] - wall, bar_depth], center=true);
}


module latch_tip() {
  mirror([0,1,0])
  rotate([90, 0, 0])
  linear_extrude(1.9)
  polygon(
    [
      [ 0,0 ],
      [ 0, 2 ],
      [ 1.5, 2],
      [ 3.1, 0 ]
    ]
  );
}
  
module front_latch() {
  d = 3.6;
  h = 5.4;
  
  translate([0,-h, 0])
  union() {
    
    // L-shaped bit on the left
    cube([1.6, h, d]);
    cube([3.5, 1.5, d]);
    
    // Latch on top of the L-shaped bit
    translate([0, 1.5, d])
      latch_tip();
    
    // Latchy thing to the right
    translate([8.9, h - upper_notch_h, 0])
    rotate([90, 0, 0])
    linear_extrude(3) {
      polygon([
        [ -3,0 ],
        [ 0,0 ],
        [ 0, 3.7 ],
        [ -1.6, 3.7 ],
        [ -3, 1.7 ]
      ]);
    }
  }
}

module br_fillet(r) {
  translate([r, r])
  difference() {
    translate([-(r+HACK), -(r+HACK)])
      square(r+HACK, center=false);
    
    circle(r=r, center=true);
  }
}

module rear_latch() {
  d = 3.6;
  rounding = 1.5;
  extra_depth = body[2] - 1.5;
  difference() {
    translate([0,0,-extra_depth])
    linear_extrude(d+extra_depth) {
      polygon([
        // Lower (outside) edge of contour
        [ 0, 1.1 ],
        [ -end_corner_notch[0], 1.1 ],
        [ -end_corner_notch[0], 0 ],
        [ -9.2, 0 ],
        [ -9.2, 2.4 ],
        [ -12.7, 5.6 ],
        [ -12.7, 2.4 ],
        [ -26.7, 2.4 ],   // Rounded
        [ -26.7, 6.5 ],
        [ -31.1, 6.5 ],     // Rounded
        [ -31.1, body[1] ], // Top-left corner
      
        // Inside edge (upper)
        [ -29.7, body[1] ],
        [ -29.7, body[1] - 3.9 ],
        [ -25.3, body[1] - 3.9 ],
        [ -25.3, body[1] - 5.7 ],
        [ -(25.3-2.2), body[1] - 5.7 ],
        [ -20.8, body[1] - 8.2 ],
        [ -17.5, body[1] - 8.2 ],
        [ -17, body[1] - 7.7 ],
        [ -14.2, body[1] - 7.7 ],
        [ -14.2, body[1] - 3.7 ],
        [ -10.2, body[1] - 3.7 ],
        [ -6, 4.1 ],
        [ 0, 4.1 ],
      
      ]);
    }
    
    // Groove into sloped part
    translate([0, 0, 1.5])
      linear_extrude(1.5) {
        polygon([
            [ -1.4, 2.7 ],
            [ -7.4, 2.7 ],
            [ -12.8, body[1] - 3.7 ],
            [ -12.8, body[1] ],
            [ -1.4, body[1]],
        ]);
      }
    
    // Fillet of rounded corners
    translate([-26.7, 2.4])
      linear_extrude(d+HACK) br_fillet(rounding);
    translate([-31.1, 6.5])
      linear_extrude(d+HACK) br_fillet(rounding);
    
    
    // Cuts around the lowered rounded corner
    translate([-26.7, 2.4, 2.0]) {
      rotate([90,0,0])
        translate([0,0,-1.5])
        linear_extrude(1.5+HACK)
          polygon([
            [0, 0],
            [3.2, 0],
            [4.1, 0.9],
            [4.1, 2],
            [0, 2]
          ]);
        translate([-HACK, 0, 0])
          cube([1.5+HACK, 2.8, d]);
    }
          
     // Hole down into the rounded corner
     linear_extrude(d+HACK) {
        polygon([
          [-25.3, 3.8],
          [-25.3, 5.2],
          [-23.6, 5.2],
          [-22.5, 3.8],
        ]);
     }
     
     // Wide chamfer near the right end
     rotate([0, -90, 0])
     linear_extrude(9.5) {
      polygon([
          [1.3, 0],
          [3.6+HACK, 2.2],
          [3.6+HACK, 0]
       
       ]);
     }
     
  }
  
  translate([-31.1, 7.9, d])
    latch_tip();
}

module main_body () {
  
              
  hollow_h = body[1]-2*wall; 
  hollow_1 = 22.1;
  hollow_2 = 19;
  hollow_3 = 45;
  hollow_4 = [ hollow_3 + end_corner_notch[0],
               5.7 ];
  
  slide_cut_y = 2.9;
    
  difference() {
    union() {
      cube(body);
               
    translate([0, body[1], body[2]])
      front_latch();
        
      translate([body[0], 0, body[2]])
        rear_latch();
    }
  
    // Corner notch
    translate([body[0] - end_corner_notch[0]+HACK, -HACK, -HACK]) {
      cube(end_corner_notch);
      cube(half_end_corner_notch);
    }
    
    // Smaller part of the corner notch
       
    // Hollowing on the underside  
    translate([0,0,-HACK]) {

      linear_extrude(hollow_depth+HACK) {

        translate([wall, wall])
          square([hollow_1, hollow_h]);
        
        translate([2*wall + hollow_1, wall,])
          square([hollow_2, hollow_h]);
        
        translate([3*wall + hollow_1 + hollow_2, wall])  {
          square([hollow_3, hollow_h]);
          
          // The extra bit that sticks out under the corner notch
          translate([0,end_corner_notch[1]])
            square(hollow_4);
        }
      }
      
      // Long rectangular hole that cuts into the left T
      translate([2*wall + hollow_1 + hollow_2, slide_cut_y, body[2]])
        slide_cut();
    }    
    
    // Long upper edge notch
    translate([2.3, body[1]])
    linear_extrude(3*body[2], center=true) {
      notch_chamfer_w = 2;
      notch_w = 61.6;
      notch_h = upper_notch_h;
      polygon([ [ 0, HACK ],
                [ 0, 0],
                [ notch_chamfer_w, -notch_h ],
                [ notch_w - notch_chamfer_w, -notch_h ],
                [ notch_w, 0 ],
                [ notch_w, HACK]
              ]);
    }

    
    // T-shaped holes through the body    
    translate([0, 1.6, body[2]]) {

      translate([12.4, 0, 0])
        t_hole(body[2] - hollow_depth);
      
      translate([47.3, 0, 0])
        t_hole(body[2] - hollow_depth);
    }
  }
  
  // Fix-up for chamfers in T-holes on the underside
  cube([body[0]-end_corner_notch[0], wall, body[2]-t_hole_chamfer]);
          
        
  // Hook for spring, inside the long rectangular hole
  translate([wall + hollow_1 - 0.1, slide_cut_y + (slide_cut_h/2), body[2]])
    spring_hook();



}







module eject_slider() {
  main_body();
  
}


eject_slider();
