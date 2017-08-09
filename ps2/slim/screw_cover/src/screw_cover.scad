
$fn=32;

HACK=0.001;

module corner(rot) {
  
  w = 7.5;
  d = 1;
  chamfer_width = 3.3;
  low_depth = 1.9;
  
  rotate([0,0,rot]) {
    
    // Bottom pad, with chamfer
    difference() {
      translate([0, 0, -1])
        cube([w/2, w/2, d]);
      
      for (side = [0, -90]) {
        rotate([0, 0, side])
        translate([0, w/2, -d/2])
          rotate([45, 0, 0])
          translate([-chamfer_width/2,0, -1])
          cube([chamfer_width, 2, 2]);
      }
    }
    
    // Low guide
    linear_extrude(low_depth)
    difference() {
      circle(d=6.4, center=true);
      circle(d=5.2, center=true);
      translate([-10,-5])
        square(10);
      translate([-5,-10])
        square(10);
      translate([1, 1])
        square(10);
    }
    
    // High clip
    rotate([0,0,45])
    translate([(5.8/2), 0, 0])
    rotate([90, 0, 0])
    linear_extrude(1.8, center=true){
      polygon([
        [0, 0],
        [0, 3],
        [0.6, 3],
        [1, 2.6],
        [1, 2.4],
        [0.6, 2.2],
        [0.6, 0]
      
      ]);
    }
  }
}


module screw_cover() {
  for (a = [0, 90, 180, 270])
    corner(a);
  
  
}


screw_cover();