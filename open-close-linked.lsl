// Open/close linked doors using time-based calculations.
//

#include "lib/debug.lsl"
#include "lib/profiling.lsl"
#include "door-script/lib/configure.lsl"
#include "door-script/lib/messages.lsl"


////////////////////////////////////////////////////////////////////////////////
//
// These items need to be configured.
//
////////////////////////////////////////////////////////////////////////////////

integer configured = FALSE;         // Has this been configured?

float open_angle;                   // How far to  open the door.
float open_direction;               // 1 or -1 to change rotation direction.
float open_time;                    // Number of seconds spent opening.
vector rotation_axis = <0, 0, 1>;   // Default to Z axis.
vector rotation_origin = <0, 0, 0>; // Rotation axis origin relative to the object center. 

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Assumption: The local location of the door doesn't move 
// from the time that the door is opened until it is closed. 
// Store the current position and location of the door
// so we can restore it when the door is closed again. 
//
// This should work for most linked objects. 
// Most linked object doors aren't wandering around but return to their 
// relative starting point.
vector closed_position;
rotation closed_rotation;
vector open_position;
rotation open_rotation;
integer link_number;

post_config()
{
}

////////////////////////////////////////////////////////////////////////////////
//
// Math
//
////////////////////////////////////////////////////////////////////////////////

vector calculate_position(float angle)
{
    // We have the axis of rotation and the angle. 
    // Compose the quaternion that describes this rotation.
    rotation q = llAxisAngle2Rot(rotation_axis, angle);
    vector result = closed_position 
        + (rotation_origin - rotation_origin * q) * closed_rotation;

    return result;
}

rotation calculate_rotation(float angle)
{
    // We have the axis of rotation and the angle. 
    // Compose the quaternion that describes this rotation.
    rotation q = llAxisAngle2Rot(rotation_axis, angle);

    // Convert the calculated rotation to the local rotation. 
    // To rotate quaternion q by r,
    //
    //     q' = r * q  
    //
    // Remember that SL reverses the standard math notation.
    return q * closed_rotation;
}

////////////////////////////////////////////////////////////////////////////////
//
// Door Actions
//
////////////////////////////////////////////////////////////////////////////////

move_door(integer is_opening)
{
    float angle;

    // Don't be crashing into things. This is optional.
    llSetLinkPrimitiveParamsFast(link_number, [
        PRIM_PHANTOM, TRUE
    ]);
    
    integer iterations = 0; // Debugging information.

    // Rate of rotation in radians per second.
    float rotation_rate = 
        (open_direction * open_angle * DEG_TO_RAD / open_time);

    llResetTime();
    float current_time = llGetTime();
    while (current_time < open_time) {
        // Get rotation for this iteration.
        if(is_opening)
            // Moving from 0 angle to full open angle.
            angle = rotation_rate * current_time;
        else 
           // Moving from full open angle down to 0 angle. 
            angle = rotation_rate * (open_time - current_time);

        llSetLinkPrimitiveParamsFast(link_number, [
            PRIM_ROT_LOCAL, calculate_rotation(angle),
            PRIM_POS_LOCAL, calculate_position(angle)
        ]);

        current_time = llGetTime();
        ++iterations;
    }

    debug("Door movement iterations: " + (string)iterations);
}

move_door_finish(vector target_position, rotation target_rotation)
{
    // Final operation. Force it into place to avoid rounding error, etc. 
    llSetLinkPrimitiveParamsFast(link_number, [
        PRIM_ROT_LOCAL, target_rotation,
        PRIM_POS_LOCAL, target_position,
        PRIM_PHANTOM, FALSE
    ]);
}

close_door_start()
{
    debug("The door is closing");
    
    move_door(FALSE);
}

close_door_finish()
{
    move_door_finish(closed_position, closed_rotation);
}

open_door_start()
{
    float angle = open_direction * open_angle * DEG_TO_RAD;

    // Remember these positions.
    link_number = llGetLinkNumber();
    closed_position = llGetLocalPos();
    closed_rotation = llGetLocalRot();
    open_rotation = calculate_rotation(angle);
    open_position = calculate_position(angle);
    
    //debug("closed_position " + (string)(closed_position));
    //debug("closed_rotation " + (string)(closed_rotation));

    debug("The door is opening");
    move_door(TRUE);
}

open_door_finish()
{
    move_door_finish(open_position, open_rotation);
}

default // configuration
{
    link_message(integer sender_num, integer num, string str, key id)
    {
        if(num == OPENCLOSE_DOOR_CONTROL_MESSAGE)
        {
            if(str == OPENCLOSE_MESSAGE_CONFIG)
            {
                get_parameters(str);
                if(configured)
                {
                    describe_configuration();
                    state closed_state;
                }
            }
        }
    }

    state_entry()
    {
        llSetMemoryLimit(327268);
        debug_prefix = llGetScriptName();
        DEBUG = DEBUG_STYLE_OWNER;
        
        // Copied from the wiki. Without this, the script throws errors.
        llSetLinkPrimitiveParamsFast(LINK_THIS,
            [PRIM_PHYSICS_SHAPE_TYPE, PRIM_PHYSICS_SHAPE_NONE]);

        get_parameters(llGetObjectDesc());
        if(configured)
        {
            describe_configuration();
            state closed_state;
        }
        else
            debug("Not confugred.");
    }
}

state closed_state
{
    link_message(integer sender_num, integer num, string str, key id)
    {
        if(num == OPENCLOSE_DOOR_CONTROL_MESSAGE)
        {
            if(str == OPENCLOSE_MESSAGE_CONFIG)
                state default;
            else if(str == OPENCLOSE_MESSAGE_TOUCH)
            {
                //start_profiling();
                open_door_start();
                open_door_finish();
                //stop_profiling();
                state open_state;
            }
        }
    }
    
    state_entry()
    {
        debug("The door is now closed.");
        llListen(1, "", NULL_KEY, "");
    }
}

state open_state
{
    link_message(integer sender_num, integer num, string str, key id)
    {
        if(num == OPENCLOSE_DOOR_CONTROL_MESSAGE)
        {
            if(str == OPENCLOSE_MESSAGE_CONFIG)
                debug("Cannot be configured while open.");
            else if(str == OPENCLOSE_MESSAGE_TOUCH)
            {
                //start_profiling();
                close_door_start();
                close_door_finish();
                //stop_profiling();
                state closed_state;
            }
        }
    }
    
    state_entry()
    {
        debug("The door is now open.");
    }
}
