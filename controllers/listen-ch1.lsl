// Control door objects on channel one. 
//
// NOTE: This is development code only. 
//

//#include "lib/profiling.lsl"
#include "door-script/lib/messages.lsl"

default
{
    listen(integer channel, string name, key id, string message)
    {
        if(message == "config") 
            llMessageLinked(LINK_THIS, 
                OPENCLOSE_DOOR_CONTROL_MESSAGE, 
                OPENCLOSE_MESSAGE_CONFIG, 
                NULL_KEY
            );
        
        if(message == "close" || message == "open")
            llMessageLinked(LINK_THIS, 
                OPENCLOSE_DOOR_CONTROL_MESSAGE, 
                OPENCLOSE_MESSAGE_TOUCH, 
                NULL_KEY
            );
        //stop_profiling();
    }

    state_entry()
    {
        llSetMemoryLimit(8192);
        llListen(1, "", NULL_KEY, "");
    }
}
