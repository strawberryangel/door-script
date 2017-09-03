// Notify door objects that they should react to a touch.
//

#include "lib/debug.lsl"
//#include "lib/profiling.lsl"
#include "door-script/lib/messages.lsl"

default
{
    state_entry()
    {
        //DEBUG = DEBUG_STYLE_OWNER;
        llSetMemoryLimit(6144);
    }

    touch_start(integer index)
    {
        //debug("touch_start. Sending link message.");
        //start_profiling();
        llMessageLinked(LINK_THIS, 
            OPENCLOSE_DOOR_CONTROL_MESSAGE, 
            OPENCLOSE_MESSAGE_TOUCH, 
            NULL_KEY
        );
        //stop_profiling();
    }
}
