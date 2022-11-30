// iPhone Camera Bracket Thingy
// By Matthew Carlson

// All dimensions are in mm
MAGSAFE_WIDTH = 56.1; // how width the magsafe puck is
MAGSAFE_DEPTH = 5; // how deep the ring around the magsafe is (towards the phone)
CORD_THICKNESS = 5; // how thick the magsafe cord is
RING_THICKNESS = 7; // how thick the ring around the magsafe is
EPSILON = 0.01; 
BODY_HEIGHT = 35; // how tall the bottom body is
ARM_LENGTH = 30; // how long the arms are (total)
ARM_THICKNESS = 7; // how thick each arm is
ARM_PERCH_LENGTH = 17; // how long the perch of the arm as (this should be how big the flat part of your monitor is)
HAND_DEPTH = 6.5; // how far down the hand of the arm hangs down from the perch
BOTTOM_THICKNESS_FACTOR = 1.1; // how thick the bottom is relative to the ring depth
BODY_WIDTH_FACTOR = 1.1; // how wide the bottom body is relative to the magsafe width

$fn = 128; // turn this down to a lower number if your computer is struggling

// computed
body_width = MAGSAFE_WIDTH * BODY_WIDTH_FACTOR;
body_gap = 0.45 * MAGSAFE_WIDTH;
body_bottom_thickness = MAGSAFE_DEPTH * BOTTOM_THICKNESS_FACTOR;
arm_width = body_width - MAGSAFE_WIDTH;

module halfCylinder(h,r) {
  intersection() {
    cylinder(h=h,r=r);
    translate([0,-r,0]) cube([r,2*r,h]);
  }
}

module arcCylinder(h,r,angle) {
  if (angle > 180) {
    union() {
      halfCylinder(h,r);
      rotate([0,0,angle-180]) halfCylinder(h,r);
    }
  } else {
    intersection() {
      halfCylinder(h,r);
      rotate([0,0,angle-180]) halfCylinder(h,r);
    }
  }
}

// https://en.m.wikibooks.org/wiki/OpenSCAD_User_Manual/Primitive_Solids
module prism(l, w, h){
  polyhedron(//pt 0        1        2        3        4        5
          points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
          faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
          );
}


module magsafe_loop(){
    loop_outer_radius = (MAGSAFE_WIDTH + RING_THICKNESS) / 2;
    rotate([0,90,0]) cylinder(MAGSAFE_DEPTH, loop_outer_radius, loop_outer_radius);
}

module magsafe_void() {
    loop_inner_radius = (MAGSAFE_WIDTH) / 2;
    cord_length = 50;
    rotate([0,90,0]) translate([0,0,-EPSILON]) union() {
        translate([0,0,-MAGSAFE_DEPTH*10]) cylinder(MAGSAFE_DEPTH*20, loop_inner_radius, loop_inner_radius);
        translate([loop_inner_radius,0,0]) cube([cord_length, CORD_THICKNESS, CORD_THICKNESS], center=true);
        translate([loop_inner_radius,0,CORD_THICKNESS/2]) rotate([0,90,0]) cylinder(cord_length, CORD_THICKNESS/2, CORD_THICKNESS/2, center=true);
        
    }
}

module body_arm() {
    total_hand = HAND_DEPTH + ARM_THICKNESS;
    hand_offset = ARM_THICKNESS - (total_hand/2); //-ARM_THICKNESS;
    union() {
        cube([ARM_LENGTH,arm_width,ARM_THICKNESS]);
        translate([ARM_LENGTH, arm_width, hand_offset]) rotate([90,0,0]) halfCylinder(arm_width, total_hand / 2);
    }
}

module main_body() {
    union() {
        magsafe_loop();
        // the underside of the body
        translate([0,-body_width/2,-BODY_HEIGHT/2 - body_gap]) cube([body_bottom_thickness, body_width, BODY_HEIGHT]);
        // arms
        translate([0,body_width/2-arm_width,BODY_HEIGHT/2 - body_gap - ARM_THICKNESS]) body_arm();
        translate([0,body_width/2-body_width,BODY_HEIGHT/2 - body_gap - ARM_THICKNESS]) body_arm();
        
        translate([body_bottom_thickness,-body_width/2,-BODY_HEIGHT/2 - body_gap]) rotate([90,0,90]) prism(body_width,BODY_HEIGHT-ARM_THICKNESS,ARM_LENGTH-body_bottom_thickness-ARM_PERCH_LENGTH);
    }
}

//translate([0,MAGSAFE_WIDTH* 1.4,0]) magsafe_void();
//translate([0,- MAGSAFE_WIDTH * 1.4,0]) main_body();
difference() {
    main_body();
    magsafe_void();
}