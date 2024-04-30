MARGIN = 0.01;
//Cylinder Fragment Resolution
FN=100;


//Plastic thickness
NVIDIA_SHROUD_T = 2;
ADAPTER_SHROUD_T= 2;

//Air Hole sizing for loop
AIR_HOLE_INTERNAL_H = 20;
AIR_HOLE_INTERNAL_W = 91;
SHROUD_EXTERNAL_W = AIR_HOLE_INTERNAL_W + 2*ADAPTER_SHROUD_T;

//Fan Frame sizing
FAN_FRAME_DEPTH = 5;
FAN_FRAME_EXT_H = 40;
FAN_FRAME_EXT_W = 80;

//Fan Mount sizing
FAN_MOUNT_HOLE_DIAM = 3;
FAN_MOUNT_DIAM = 7.5;

//X wise length of the slant between the air loop + fan frame
SLANT_SIZE = 20;



//Draw the air looper cylinders
module air_looper_parts(air_hole_h, air_hole_w)
{    
    //Calculate cylinder diameter
    
    AIR_LOOPER_D = air_hole_h*2 + NVIDIA_SHROUD_T + ADAPTER_SHROUD_T + 2*ADAPTER_SHROUD_T;
    
    difference(){
        //Keep it centered vertically but not horizontally
        translate([0,(air_hole_w+2*ADAPTER_SHROUD_T),0])
        {
            //Rotate cylinder along the X axis
            rotate(90,[1,0,0])
            {
                cylinder(h=(air_hole_w+2*ADAPTER_SHROUD_T),d=AIR_LOOPER_D,$fn=FN);
            }
        }
        //Slice it along the XY plane on the negative X side
        translate([-AIR_LOOPER_D,-MARGIN/2,-AIR_LOOPER_D/2])
        {
            cube([AIR_LOOPER_D,(air_hole_w+2*ADAPTER_SHROUD_T+MARGIN),AIR_LOOPER_D]);
        }
        
    }
}

//Draw the air looper
module air_looper(air_hole_h, air_hole_w)
{
    difference()
    {
        air_looper_parts(air_hole_h,air_hole_w);
        
        translate([-MARGIN,ADAPTER_SHROUD_T,0])
        {
            air_looper_parts(air_hole_h-ADAPTER_SHROUD_T, air_hole_w - 2* ADAPTER_SHROUD_T);
        }
        
    }
}

module mount_tab()
{
    //Draw the screw tab
    MOUNT_TAB_W = 50;
    MOUNT_TAB_H = 11;

    MOUNT_TAB_HOLE_DIAM = 3;
    MOUNT_TAB_HOLE_Z_OFFSET = 4.75;
    MOUNT_TAB_HOLE_Y_OFFSETS = [7.5, 7.5+18*1, 7.5+18*2];
    translate([0,0,-AIR_HOLE_INTERNAL_H-NVIDIA_SHROUD_T-MOUNT_TAB_H])
    {
        difference()
            {
                //Create Base Mount Structure
                cube([ADAPTER_SHROUD_T, MOUNT_TAB_W, MOUNT_TAB_H]);
                
                //Add mount holes
                for (x=MOUNT_TAB_HOLE_Y_OFFSETS)
                {
                    translate([-MARGIN, x, MOUNT_TAB_HOLE_Z_OFFSET])
                    {
                        rotate(90,[0,1,0])
                        {
                            cylinder(h=ADAPTER_SHROUD_T + 2 * MARGIN,r=MOUNT_TAB_HOLE_DIAM/2, $fn=FN);
                        }
                    }
                }
            }
        }
}

module fan_mount(x_offset,y_offset,z_offset)
{
    //Shift coord to upper left corner
    translate([x_offset,FAN_MOUNT_DIAM/2+y_offset,-FAN_MOUNT_DIAM/2+z_offset])
    {
        rotate(90,[0,1,0])
        {
            difference()
            {
                cylinder(h=FAN_FRAME_DEPTH, d=FAN_MOUNT_DIAM,$fn=FN);
                translate([0,0,-MARGIN/2])
                    cylinder(h=FAN_FRAME_DEPTH+MARGIN, d=FAN_MOUNT_HOLE_DIAM,$fn=FN);
            }
        }
    }
}
module fan_frame()
{
    //Build Frame Main Structure
    translate([-FAN_FRAME_DEPTH-SLANT_SIZE,(SHROUD_EXTERNAL_W-FAN_FRAME_EXT_W)/2,0])
    {
        difference()
        {
            cube([FAN_FRAME_DEPTH,FAN_FRAME_EXT_W,FAN_FRAME_EXT_H]);
            translate([-MARGIN/2,ADAPTER_SHROUD_T,ADAPTER_SHROUD_T])
            {
                cube([FAN_FRAME_DEPTH+MARGIN,FAN_FRAME_EXT_W-2*ADAPTER_SHROUD_T,FAN_FRAME_EXT_H-2*ADAPTER_SHROUD_T]);
            }
        }
    }
    //Add fan mount points
    NORM_FRAME_Y_LOCATION=(SHROUD_EXTERNAL_W-FAN_FRAME_EXT_W)/2;
    NORM_FRAME_X_LOCATION=(-FAN_FRAME_DEPTH-SLANT_SIZE);
    
    
    FAN_MOUNT_TAB_HOLE_Y_OFFSETS = [0,FAN_FRAME_EXT_W/2-FAN_MOUNT_DIAM,FAN_FRAME_EXT_W/2,FAN_FRAME_EXT_W-FAN_MOUNT_DIAM];
    FAN_MOUNT_TAB_HOLE_Z_OFFSETS = [FAN_FRAME_EXT_H, FAN_MOUNT_DIAM];
    for(i=FAN_MOUNT_TAB_HOLE_Y_OFFSETS)
    {
        for(j=FAN_MOUNT_TAB_HOLE_Z_OFFSETS)
        {
            fan_mount(NORM_FRAME_X_LOCATION,NORM_FRAME_Y_LOCATION+i,j);    
        }
    }
    
}

//Duct Objects
module duct_parts(skrink=0,extend=0) 
{
    //Draw Duct in place
    
    AIR_LOOPER_D = AIR_HOLE_INTERNAL_H*2 + NVIDIA_SHROUD_T + ADAPTER_SHROUD_T + 2*ADAPTER_SHROUD_T;

    //Polyhedron Vectors
    points = [
    [ -SLANT_SIZE-extend-MARGIN, (SHROUD_EXTERNAL_W-FAN_FRAME_EXT_W)/2+skrink, 0 + skrink], //0
    [ 0+extend+MARGIN, 0+skrink, 0 + skrink], //1
    [ 0+extend+MARGIN, SHROUD_EXTERNAL_W-skrink, 0 + skrink], //2
    [ -SLANT_SIZE-extend-MARGIN, (SHROUD_EXTERNAL_W-FAN_FRAME_EXT_W)/2+FAN_FRAME_EXT_W-skrink, 0 + skrink], //3
    [ -SLANT_SIZE-extend-MARGIN, (SHROUD_EXTERNAL_W-FAN_FRAME_EXT_W)/2+skrink, FAN_FRAME_EXT_H - skrink], //4
    [ 0+extend+MARGIN, 0+skrink, AIR_LOOPER_D/2 - skrink], //5
    [ 0+extend+MARGIN, SHROUD_EXTERNAL_W-skrink, AIR_LOOPER_D/2 - skrink], //6
    [ -SLANT_SIZE-extend-MARGIN,(SHROUD_EXTERNAL_W-FAN_FRAME_EXT_W)/2+FAN_FRAME_EXT_W-skrink, FAN_FRAME_EXT_H - skrink]]; //7
    

    //Polyhedron Faces
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

//Final Duct
module duct()
{
    difference()
    {
        duct_parts();
        duct_parts(2,MARGIN);
    }    
}



//MAIN
air_looper(AIR_HOLE_INTERNAL_H,AIR_HOLE_INTERNAL_W);
mount_tab();
fan_frame();
duct();



