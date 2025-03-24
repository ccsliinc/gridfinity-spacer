
GRID_DIMENSIONS_MM = [42, 42];
LIP_OFFSET = 3;
THICKNESS = 2;
RADIUS = 1;
 
// How many grid spaces does the bin take up
gridx = 3;
gridy = 3;

cols = 2;
rows = 3;


/*
    Do not edit any setting below this line.
    Edit the sections above to change the shape of the insert.
*/

// How many subdivisions are in each axis
sub_div_x = cols - 1;
sub_div_y = rows - 1;

// Globals
$fn=50;

// Overall dimensions in x, y, z directions
x = gridx * GRID_DIMENSIONS_MM.x;
y = gridy * GRID_DIMENSIONS_MM.y;
z = 6.9;

// Tickness of all walls
t1 = THICKNESS;
t2 = t1 * 2;

// Radius of all fillets
r1 = RADIUS;
r2 = r1 * 2;

// Offset for lip internal
l1 = LIP_OFFSET;
l2 = l1 * 2;

// Internal Dimensions(id) of 1x1 unit
id = GRID_DIMENSIONS_MM.x - l2;

// Spacer
sp = (GRID_DIMENSIONS_MM.x * 2) - (id * 2) - l2;

// Start building the spacer
union(){
    // Create the base structure
    //translate([0, -20, 0])
    /////base();
    
    // Subdivision spacing
    spacing_y = (y - l2) / (sub_div_y + 1);
    spacing_x = (x - l2) / (sub_div_x + 1);
    
    // Create Y dividers
    for (i = [0:sub_div_y-1]) {
        sp = (i + 1) * spacing_y;
        echo(sp);
        echo(41 % 38);
        // Only put bottom on if in center
        if( !(sp % 40 == 0)) {
            translate([0, sp])
            translate([0, -t1/2])
            full_divider(gridx);
        } else {
            translate([0, sp])
            translate([0, -t1/2])
            cube([x - l2, t1, t1]);
        }
    }
    
    // Create X dividers
    for (i = [0:sub_div_x-1]) {
        sp = (i + 1) * spacing_x;
        if( !(sp % 40 == 0)) {
            translate([sp, 0])
            translate([t1/2, 0])
            rotate([0, 0, 90])
            full_divider(gridy);
        } else {
            translate([sp, 0])
            translate([t1/2, 0])
            rotate([0, 0, 90])
            cube([y - l2, t1, t1]);
        }
    }
}



module base() {
    linear_extrude(t1)
    difference(){
        // Outline of base
        translate([r1, r1])
        minkowski(){
            square([x - t1 - l2, y - t1 - l2]);
            circle(r1);
        };
        
        // Base cutout
        translate([t1, t1])
        square([x - t2 - l2, y - t2 - l2]);
    }
};

module full_divider(length = 3) {
    union(){
        for( i = [0:length-1]) {
            translate([i * (id + sp) , 0, 0])
            divider();
        }
        
        // Create spacers
        if(length > 1) {
            for( i = [1:length - 1]) {
                translate([(id * i) + (sp * (i - 1)), 0, 0])
                spacer();
            }
        }
        // Begining inverted corner
        corners();
        
        // Ending inverted corner
        translate([(id * length) + (sp * (length - 1)) - t1, 0, 0])
        corners();
    }
}

module spacer() {
    union() {
        // Spacer
        color("blue")
        linear_extrude(t1)
        square([sp,t1]);
        
        color("red")
        translate([0, t1, t1])
        rotate([90, 0, 0])
        corner();
        
        color("green")
        translate([sp, 0, t1])
        rotate([90, 0, 180])
        corner();
    }
}

module divider(pos = 0) {
    //color("purple")
    union(){
        color("purple")
        uprite();
        
        // Bottom Piece
        cube([GRID_DIMENSIONS_MM.x - l2, t1, r1]);
        
        if(pos == 1 || pos == 3) {
            color("orange")
            corners();
        }
        
        if(pos == 2 || pos == 3) {
            translate([id - t1,0,0])
            corners();
        }        
    }
};

// Creates the uprite for the divider
module uprite() {
    union() {
        translate([0, t1])
        rotate([90])
        translate([r1, r1])
        linear_extrude(t1)
        minkowski(){
            square([GRID_DIMENSIONS_MM.x - r2 - l2, z - r2]);
            circle(r1);
        }
        
        cube([GRID_DIMENSIONS_MM.x - l2, t1, r1]);
    }
};

// Combines inverted corners for placement on edge
module corners() {
     // First corner
    translate([t1,0,t1])
    rotate([90,0,-90])
    corner();

    // Second corner
    mirror([0,1,0])
    translate([t1,-t1,t1])
    rotate([90,0,-90])
    corner();  
};

// Ceates a single inverted corner
module corner() { 
    difference(){
        cube([t1, t1, t1]);
        translate([t1, t1, -.1])
        cylinder(r=t1, h=t1+.2);
    }
};
