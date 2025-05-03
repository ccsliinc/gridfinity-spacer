/////////////////////////////////////////////// 
/////// Edit the following settings /////////// 
/////////////////////////////////////////////// 
 
// How many grid spaces does the bin take up
gridx = 2; // Grid Cols
gridy = 2; // Grid Rows

// How many divisions in each direction
divx = 2; // Cols
divy = 3; // Rows

/////////////////////////////////////////////// 
///////////   Global Settings   /////////////// 
/////// Should not need to changed  /////////// 
/////////////////////////////////////////////// 
$fn=50;          // Generates smoother rounded edges
GRID_DIMENSIONS_MM = [42, 42];
LIP_OFFSET = 3;  // Offest from side of bin so spacer lays on ledge
THICKNESS = 2;   // Wall thickness
RADIUS = 1;      // Radius
TOLERANCE = .5;  // Tolerance for bins
HEIGHT = 6.9;    // Total height with dividers

/////////////////////////////////////////////// 
/////// Shouldn't need to edit below ////////// 
/////////////////////////////////////////////// 
/////////////////////////////////////////////// 
/////////////////////////////////////////////// 


// Computed Variables
total_x_length = GRID_DIMENSIONS_MM.x * gridx;
total_y_length = GRID_DIMENSIONS_MM.x * gridy;
spacer_x_length = total_x_length - (LIP_OFFSET * 2);
spacer_y_length = total_y_length - (LIP_OFFSET * 2);
sub_div_x = divx - 1;
sub_div_y = divy - 1;
spacing_x = total_x_length / divx;
spacing_y = total_y_length / divy;
radius_fillet = RADIUS;

// Debugging is off if asterix is before.
*debugging();
// Run main module
main();

module main() {
    union(){
        color("red")
        base();
        color("green")
        cross_members();
    }
}

// Spacer base
module base() {
    translate([LIP_OFFSET, LIP_OFFSET])
    linear_extrude(THICKNESS)
    difference(){
        
        // Accounts for radius for minkowski
        l_x = spacer_x_length - (RADIUS * 2); 
        l_y = spacer_y_length - (RADIUS * 2); 
        
        // Outline of base
        translate([radius_fillet, radius_fillet])
        minkowski(){
            square([l_x, l_y]);
            circle(radius_fillet);
        };
        
        // Cut out for base contracting shape for thickness
        l_x2 = spacer_x_length - (THICKNESS * 2); 
        l_y2 = spacer_y_length - (THICKNESS * 2); 
        
        // Base cutout
        translate([2,2])
        square([l_x2, l_y2]);
    }
};

// Generates all the cross bars
module cross_members() {
    // Create X cross member(s)
    for (i = [1:1:sub_div_x]) {
        translate([i * spacing_x , 0, 0])
        translate([-1 * (THICKNESS / 2), LIP_OFFSET])
        if((i * spacing_x) % GRID_DIMENSIONS_MM.x == 0) {
            spacer_bar(spacer_y_length, 90, false);
        } else {
            spacer_bar(spacer_y_length, 90, true);
        }
    }
 
    // Create Y cross member(s)
    for (i = [1:1:sub_div_y]) {
        translate([0, i * spacing_y , 0])
        translate([LIP_OFFSET, -i * (THICKNESS / 2)])
        if((i * spacing_y) % GRID_DIMENSIONS_MM.y == 0) {
            spacer_bar(spacer_x_length, 0, false);
        } else {
            spacer_bar(spacer_x_length, 0, true);
        }
    }
};

// Generates each bar based open length, rotation, height, and location
module spacer_bar(length, rotation = 0, full = true) {
    translate( rotation == 0 ? [ 0, 0, 0 ] : [ 2, 0, 0 ] )
    rotate([0, 0, rotation]){
        if (full) {
            difference() {
                union(){
                    edge_bottom();
                    translate([length - THICKNESS, 0, 0])
                    edge_bottom();
                    cube([length, THICKNESS, HEIGHT]);
                }
                
                translate([0, -.1, 0])
                scale([1,1.1,1])
                translate([0, 0, 6.9])
                rotate([90,0,90])
                corner(1, 1);
                
                translate([0, -.1, 0])
                scale([1,1.1,1])
                translate([length, THICKNESS, 6.9])
                rotate([90,0,270])
                corner(1, 1);
                
                for (i = [GRID_DIMENSIONS_MM.x:GRID_DIMENSIONS_MM.x:length]){
                    color("RED");
                    scale([1, 1.2, 1.01])
                    translate([i - LIP_OFFSET, THICKNESS/2 -.1, 2])
                    negative_center();
                };
            };
        } else {
            cube([length, THICKNESS, THICKNESS]);
        }

    };
}

// This is the shape used for removal from cross section where top fits
module negative_center () {
    translate([-3, THICKNESS / 2, 2])
    rotate([90])
    linear_extrude(THICKNESS)
    union(){
        square([6, 2.9]);
        
        translate([2, 0, 0])
        circle(2);
        
        translate([4, 0, 0])
        circle(2);
        
        translate([2,-2, 0])
        square([2,2]);
        
        // Top left inverted corner
        difference(){
            translate([-1, 1.9])
            square([1, 1]);
            translate([-1, 1.9])
            circle(1);
        };
        // Top right inverted corner
        difference(){
            translate([6, 1.9])
            square([1, 1]);
            translate([7, 1.9])
            circle(1);
        };
    };
}

// Creates a spaced double inverted corner for cross members
module edge_bottom() {
    translate([0,THICKNESS,THICKNESS])
    rotate([-90,0,0])
    corner();
    translate([0, 0, THICKNESS])
    corner();
};

// Ceates a single inverted corner
module corner(negative = 0, radius = 2) {
    rotate([0,270,180])
    difference(){
        if (!negative) {
            cube([radius, radius, THICKNESS]);
        } else {
            translate([-radius, -radius, 0])
            cube([radius*2, radius*2, THICKNESS]);
        }
        translate([radius, radius, -.1])
        cylinder(r=radius, h=THICKNESS+.2);
    };
};

// Used for debugging
module debugging() {
    echo ("-------");
    echo ("-------");
    echo("Total X Length :", total_x_length);
    echo("Total Y Length :", total_y_length);
    echo("Spacer Y Length :", spacer_x_length);
    echo("Spacer Y Length :", spacer_y_length);
    echo("Subdivisions X :", sub_div_x);
    echo("Subdivisions Y :", sub_div_y);
    echo("Spacing X :", spacing_x);
    echo("Spacing Y :", spacing_y);
    echo("Radius :", radius_fillet);
    echo ("-------");
    echo ("-------");
    
    //Base
    color("pink")
    translate([0,0,-1])
    square([total_x_length, total_y_length]);
}
