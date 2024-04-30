MARGIN = 0.01;
FN=100;

X_SIZE_BOTTOM = 95;
Y_SIZE_BOTTOM = 20;
X_SIZE_TOP = 100;
Y_SIZE_TOP = 50;
Z_SIZE = 50;
BORDER = 2;

FAN_MOUNT_POINT_SIZE = 10;
FAN_MOUNT_POINT_HOLE_SIZE = 1.2;
FAN_MOUNT_POINT_HOLE_Z_SIZE = 15;

CARD_MOUNT_POINT_X_SIZE = 50;
CARD_MOUNT_POINT_Y_SIZE = 15;
CARD_MOUNT_POINT_Z_SIZE = 2;
CARD_MOUNT_POINT_HOLE_SIZE = 2;
CARD_MOUNT_POINT_HOLE_Y_OFFSET = 10;
CARD_MOUNT_POINT_HOLE_X_OFFSETS = [10, 27.5, 45.5];

module box(x_bottom, y_bottom, x_top, y_top, z) {
  x = max(x_bottom, x_top);
  y = max(y_bottom, y_top);

  x_bottom_offset = (x - x_bottom) / 2;
  x_top_offset = (x - x_top) / 2;
  y_bottom_offset = y - y_bottom - FAN_MOUNT_POINT_SIZE + BORDER;
  // y_bottom_offset = (y - y_bottom) / 2;
  y_top_offset = (y - y_top) / 2;

  points = [
    [ x_bottom_offset, y_bottom_offset, 0 ],
    [ x_bottom_offset + x_bottom, y_bottom_offset, 0 ],
    [ x_bottom_offset + x_bottom, y_bottom_offset + y_bottom, 0 ],
    [ x_bottom_offset, y_bottom_offset + y_bottom, 0 ],
    [ x_top_offset, y_top_offset, z ],
    [ x_top_offset + x_top, y_top_offset, z ],
    [ x_top_offset + x_top, y_top_offset + y_top, z ],
    [ x_top_offset, y_top_offset + y_top, z ]
  ]; 

  faces = [
    [ 0, 1, 2, 3 ],
    [ 4, 5, 1, 0 ],
    [ 7, 6, 5, 4 ],
    [ 5, 6, 2, 1 ],
    [ 6, 7, 3, 2 ],
    [ 7, 4, 0, 3 ]
  ];
  polyhedron(points, faces);
}

module mount_point(x, y) {
  translate([x, y, 0]) 
  difference() {
    cube([FAN_MOUNT_POINT_SIZE, FAN_MOUNT_POINT_SIZE, Z_SIZE]);
    translate([FAN_MOUNT_POINT_SIZE / 2, FAN_MOUNT_POINT_SIZE / 2, Z_SIZE - FAN_MOUNT_POINT_HOLE_Z_SIZE + MARGIN]) cylinder(r=FAN_MOUNT_POINT_HOLE_SIZE, h=FAN_MOUNT_POINT_HOLE_Z_SIZE, $fn=FN);
  }
}

module card_mount_point() {
  x_offset = (X_SIZE_TOP - X_SIZE_BOTTOM) / 2;
  y_offset = (Y_SIZE_TOP - Y_SIZE_BOTTOM) - FAN_MOUNT_POINT_SIZE + BORDER;
  translate([x_offset + X_SIZE_BOTTOM - CARD_MOUNT_POINT_X_SIZE, y_offset + Y_SIZE_BOTTOM, 0]) {
    difference() {
      cube([CARD_MOUNT_POINT_X_SIZE, CARD_MOUNT_POINT_Y_SIZE, CARD_MOUNT_POINT_Z_SIZE]);
      
      //add mount holes
      for (x=CARD_MOUNT_POINT_HOLE_X_OFFSETS)
        translate([x, CARD_MOUNT_POINT_HOLE_Y_OFFSET, -MARGIN])
          cylinder(r=CARD_MOUNT_POINT_HOLE_SIZE, h=CARD_MOUNT_POINT_Z_SIZE + 2 * MARGIN, $fn=FN);
    }
  }
}

//Create Duct
difference() {
  box(X_SIZE_BOTTOM, Y_SIZE_BOTTOM, X_SIZE_TOP, Y_SIZE_TOP, Z_SIZE);
  translate([BORDER, BORDER, -MARGIN]) 
    box(X_SIZE_BOTTOM - 2 * BORDER, Y_SIZE_BOTTOM - 2 * BORDER, X_SIZE_TOP - 2 * BORDER, Y_SIZE_TOP - 2 * BORDER, Z_SIZE + 2 * MARGIN);
}

//Add fan mounting wedges
intersection() {
  union() {
    mount_point(0, 0);
    mount_point(0, Y_SIZE_TOP - FAN_MOUNT_POINT_SIZE);
    mount_point(X_SIZE_TOP - FAN_MOUNT_POINT_SIZE, 0);
    mount_point(X_SIZE_TOP - FAN_MOUNT_POINT_SIZE , Y_SIZE_TOP - FAN_MOUNT_POINT_SIZE);
    mount_point(X_SIZE_TOP / 2 - FAN_MOUNT_POINT_SIZE, 0);
    mount_point(X_SIZE_TOP / 2 - FAN_MOUNT_POINT_SIZE , Y_SIZE_TOP - FAN_MOUNT_POINT_SIZE);
    mount_point(X_SIZE_TOP / 2, 0);
    mount_point(X_SIZE_TOP / 2 , Y_SIZE_TOP - FAN_MOUNT_POINT_SIZE);
  }
  box(X_SIZE_BOTTOM, Y_SIZE_BOTTOM, X_SIZE_TOP, Y_SIZE_TOP, Z_SIZE);
}

//Add card mount point
card_mount_point();