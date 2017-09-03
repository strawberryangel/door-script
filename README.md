# Door Scripts

This has a couple of door scripts which are able to rotate around 
any arbitrary axis. 
One is for linked objects. 
The other is for root objects.

Because the axis of rotation is arbitrary, 
it doesn't need to go through the object center, 
eliminating the need for hinge objects, 
prim cutting or 
offsetting geometry. 

The axis of rotation doesn't need to be touching the object at all. 
In this case, the entire object will arc around an invisible hinge. 

**NOTE:** These scripts are not ready-to-run.
These were created as demonstrations of the process only. 

## Configuration 

These scripts read the description of the object the script resides in
for configuration information. 

The parameters are separated by spaces. 
Be very careful to ensure there are no spaces in vector parameters. 

1.  Door number. Unused. 

2.  "Left" or "right" to indicate the side the hinge is on. 

3.  "In" or "out" to indicate if the door swings inward (away) or 
    outward (towards) when a person is standing outside of the door and
    facing it. 
    
4.  Number of degrees to rotate. 

5.  The number of seconds to take opening. 

6.  A vector indicating the axis of rotation's direction. 

7.  Offset of the axis of rotation's origin relative to the object center. 

The configuration fills the values in the main script and set the 
`configured` variable to `TRUE`. 

```
integer configured = FALSE;         // Has this been configured?

float open_angle;                   // How far to  open the door.
float open_direction;               // 1 or -1 to change rotation direction.
float open_time;                    // Number of seconds spent opening.
vector rotation_axis = <0, 0, 1>;   // Default to Z axis.
vector rotation_origin = <0, 0, 0>; // Rotation axis origin relative to the object center. 
```

