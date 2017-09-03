#define OPEN_INWARD 1
#define OPEN_OUTWARD 2

integer door_number;
string hinge_side;
integer open_inout;

boot_help()
{
    debug("This object could not be booted.");
    debug("The object description needs to contain:");
    debug("1) The door or door pair number. This must be a whole number greater than zero.");
    debug("2) A space.");
    debug("3) The word 'left' or 'right' to indicate if the door has a hinge on the left or right side.");
}

describe_configuration()
{
    if(!configured)
    {
        boot_help();
        return;
    }
    
    string message = "Door #" + (string)door_number 
        + " (" + llToLower(hinge_side) + ")"
        + " will open";
        
    if(open_inout == OPEN_INWARD)
        message += " away from";
    else
        message += " towards";
        
    if(open_direction > 0)
        message += " (right handed)";
    else
        message += " (left handed)";

    message += " the person at the door by "
        + (string)(open_angle)
        + " degrees over a period of "
        + (string)open_time
        + " seconds. ";
    message += "The axis of rotation is " + (string)rotation_axis + ". ";
    message += "The rotation center offset is " + (string)rotation_origin + ". ";
    
    debug(message);
}
 
get_parameters(string configuration_string)
{
    vector v;
    debug("---");
    debug("Configuring door.");
    debug(" ");
    debug("The door must be in its CLOSED position during configuration.");
    debug(" ");
    configured = FALSE;
    
    list pieces = llParseString2List(llGetObjectDesc(), [" "], []);
    integer length = llGetListLength(pieces);
    if(length < 2) return;
    
    
    // First parameter ~ door number
    door_number = (integer)llList2String(pieces, 0);
    if(door_number < 1) 
    {
        debug("Please check the door/door pair number.");
        return;
    }
    
    // Second parameter ~ is the hinge on the left or right side? 
    hinge_side = llToUpper(llList2String(pieces, 1));
    if(hinge_side != "LEFT" && hinge_side != "RIGHT")
    {
        debug("Please check the spelling of left/right.");
        return;
    }

    // Third parameter ~ open inwards/outwards.
    // This will be "in" or "out".
    open_inout = OPEN_INWARD;
    if(length >= 2)
    {
        string s = llToUpper(llList2String(pieces, 2));
        if(s == "OUT")
            open_inout = OPEN_OUTWARD;
        else if(s != "IN")
            debug("Bad open direction. Defaulting to inwards.");
    }
    
    // Fourth parameter ~ how far to oepn.
    open_angle = 80.0;
    if(length >= 3)
    {
        float f = (float)llList2String(pieces, 3);
        if(f > 0)
            open_angle = f;
        else
            debug("Bad open direction. Defaulting to " + (string)open_angle);
    }
    
    // Fifth parameter ~  how many seconds to take to open 
    open_time = 4.0;
    if(length >= 4)
    {
        float f = (float)llList2String(pieces, 4);
        if(f > 0)
            open_time = f;
        else
            debug("Bad open time. Defaulting to " + (string)open_time);
    }
    
    // Sixth parameter ~ rotation axis 
    // NOTE: This requires the form <x,y,z> with the angle brackets. 6
    // NOTE: don't put spaces inbetween the vector's < and >. 
    rotation_axis = <0, 0, 1>;
    if(length >= 5)
    {
        v = (vector)llList2String(pieces, 5);
        if(v != ZERO_VECTOR)
            rotation_axis = llVecNorm(v);
        else
            debug("Bad rotation axis. Defaulting to " + (string)rotation_axis);
    }
    
    // Seventh parameter ~ object center coordinates in terms of the 
    // axis of rotation.
    // NOTE: This requires the form <x,y,z> with the angle brackets. 6
    // NOTE: don't put spaces inbetween the vector's < and >. 
    rotation_origin = <0, 0, 0>;
    if(length >= 6)
    {
        v = (vector)llList2String(pieces, 6);
        if(v != ZERO_VECTOR)
            rotation_origin = v;
        else
            debug("Bad object offset. Defaulting to " + (string)rotation_origin);
    }
    
    open_direction = 1.0;
    if(open_inout == OPEN_INWARD && hinge_side == "RIGHT")  
        open_direction = -1.0;
    if(open_inout == OPEN_OUTWARD && hinge_side == "LEFT")  
        open_direction = -1.0;
        
    configured = TRUE;
    
    post_config();
}

