////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  
////////////////////////////////////////////////////////////////////////////////////////////////////////   

class UserConfig {
</ label="--------  Main theme layout  --------", help="Show or hide additional images", order=1 /> uct1="select below";
   </ label="Enable wheel fade", help="Enable Wheel or disable wheel fade", options="Yes,No", order=2 /> enable_wheelfade="No";   
   </ label="Preserve Video Aspect Ratio", help="Preserve Video Aspect Ratio", options="Yes,No", order=4 /> Preserve_Aspect_Ratio="Yes";   
   </ label="Select wheel layout", help="Select wheel type or listbox", options="vert_wheel_left", order=6 /> enable_list_type="vert_wheel_left";
   </ label="Select spinwheel art", help="The artwork to spin", options="wheel", order=7 /> orbit_art="wheel";
   </ label="Wheel transition time", help="Time in milliseconds for wheel spin.", order=8 /> transition_ms="35";  
   </ label="Wheel fade time", help="Time in milliseconds to fade the wheel.", options="Off,1250,2500,5000,7500,10000", order=9 /> wheel_fade_ms="5000"; 
</ label="--------    Miscellaneous    --------", help="Miscellaneous options", order=23 /> uct6="select below";
   </ label="Random Wheel Sounds", help="Play random sounds when navigating games wheel", options="Yes,No", order=25 /> enable_random_sound="Yes";   
}  

local my_config = fe.get_config();
local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;
fe.layout.font="fantom.ttf";

//for fading of the wheel
first_tick <- 0;
stop_fading <- true;
wheel_fade_ms <- 0;
try {	wheel_fade_ms = my_config["wheel_fade_ms"].tointeger(); } catch ( e ) { }

// modules
fe.load_module("fade");
fe.load_module( "animate" );
fe.load_module("scrollingtext");

///////////////////////////////////////////////////////////////////////////////////
// load background image
local b_art = fe.add_image("graffiti.png", 0, 0, flw, flh );
b_art.alpha=255;

// create surface for snap
local surface_snap = fe.add_surface( 640, 480 );
local snap = FadeArt("snap", 0, 0, 640, 480, surface_snap);
snap.trigger = Transition.EndNavigation;
snap.preserve_aspect_ratio = true;

// now position and pinch surface of snap
// adjust the below values for the game video preview snap
surface_snap.set_pos(flx*0.1825, fly*0.05, flw*0.35, flh*0.45);
surface_snap.skew_y = 0;
surface_snap.skew_x = 0;
surface_snap.pinch_y = 0;
surface_snap.pinch_x = 0;
surface_snap.rotation = 0;

///////////////////////////////////////////////////////////////////////////////////
// The following section sets up what type and wheel and displays the users choice

//This enables vertical art on left side instead of default wheel
if ( my_config["enable_list_type"] == "vert_wheel_left" )
{
fe.load_module( "conveyor" );
local wheel_x = [ flx*0.76, flx* 0.76, flx* 0.76, flx* 0.76, flx* 0.76, flx* 0.76, flx* 0.7225, flx* 0.76, flx* 0.76, flx* 0.76, flx* 0.76, flx* 0.76, ];
local wheel_y = [ -fly*0.22, -fly*0.105, fly*0.0, fly*0.105, fly*0.215, fly*0.325, fly*0.436, fly*0.6, fly*0.71, fly*0.82, fly*0.925, fly*0.98, ];
local wheel_w = [ flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.24, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, ];
local wheel_a = [  150,  150,  150,  150,  150,  150, 255,  150,  150,  150,  150,  150, ];
local wheel_h = [  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11, flh*0.168,  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11, ];
local wheel_r = [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ];
local num_arts = 8;

class WheelEntry extends ConveyorSlot
{
	constructor()
	{
		base.constructor( ::fe.add_artwork( my_config["orbit_art"] ) );
		preserve_aspect_ratio = true;
	}

	function on_progress( progress, var )
	{
	  local p = progress / 0.1;
		local slot = p.tointeger();
		p -= slot;
		
		slot++;

		if ( slot < 0 ) slot=0;
		if ( slot >=10 ) slot=10;

		m_obj.x = wheel_x[slot] + p * ( wheel_x[slot+1] - wheel_x[slot] );
		m_obj.y = wheel_y[slot] + p * ( wheel_y[slot+1] - wheel_y[slot] );
		m_obj.width = wheel_w[slot] + p * ( wheel_w[slot+1] - wheel_w[slot] );
		m_obj.height = wheel_h[slot] + p * ( wheel_h[slot+1] - wheel_h[slot] );
		m_obj.rotation = wheel_r[slot] + p * ( wheel_r[slot+1] - wheel_r[slot] );
		m_obj.alpha = wheel_a[slot] + p * ( wheel_a[slot+1] - wheel_a[slot] );
	}
};

local wheel_entries = [];
for ( local i=0; i<num_arts/2; i++ )
	wheel_entries.push( WheelEntry() );

local remaining = num_arts - wheel_entries.len();

// we do it this way so that the last wheelentry created is the middle one showing the current
// selection (putting it at the top of the draw order)
for ( local i=0; i<remaining; i++ )
	wheel_entries.insert( num_arts/2, WheelEntry() );

conveyor <- Conveyor();
conveyor.set_slots( wheel_entries );
conveyor.transition_ms = 50;
try { conveyor.transition_ms = my_config["transition_ms"].tointeger(); } catch ( e ) { }
}
 
// Play random sound when transitioning to next / previous game on wheel
function sound_transitions(ttype, var, ttime) 
{
	if (my_config["enable_random_sound"] == "Yes")
	{
		local random_num = floor(((rand() % 1000 ) / 1000.0) * (124 - (1 - 1)) + 1);
		local sound_name = "sounds/GS"+random_num+".mp3";
		switch(ttype) 
		{
		case Transition.EndNavigation:		
			local Wheelclick = fe.add_sound(sound_name);
			Wheelclick.playing=true;
			break;
		}
		return false;
	}
}
fe.add_transition_callback("sound_transitions")


/////////////////////////////////////////////////////////////////////////////////// 
//Wheel fading
if ( my_config["enable_wheelfade"] == "Yes" )
{
if ( wheel_fade_ms > 0 && ( my_config["enable_list_type"] == "vert_wheel_left") )
{
	
	function wheel_fade_transition( ttype, var, ttime )
	{
		if ( ttype == Transition.ToNewSelection || ttype == Transition.ToNewList )
				first_tick = -1;
	}
	fe.add_transition_callback( "wheel_fade_transition" );
	
	function wheel_alpha( ttime )
	{
		if (first_tick == -1)
			stop_fading = false;

		if ( !stop_fading )
		{
			local elapsed = 0;
			if (first_tick > 0)
				elapsed = ttime - first_tick;

			local count = conveyor.m_objs.len();

			for (local i=0; i < count; i++)
			{
				if ( elapsed > wheel_fade_ms)
					conveyor.m_objs[i].alpha = 0;
				else
					//uses hardcoded default alpha values does not use wheel_a
					//4 = middle one -> full alpha others use 80
					if (i == 4)
						conveyor.m_objs[i].alpha = (255 * (wheel_fade_ms - elapsed)) / wheel_fade_ms;
					else
						conveyor.m_objs[i].alpha = (80 * (wheel_fade_ms - elapsed)) / wheel_fade_ms;
			}

		  if (first_tick == -1)
				first_tick = ttime;
		}
	}
	fe.add_ticks_callback( "wheel_alpha" );
}
}



/////////////////////////////////////////////////////////////////////////////////// 
//setup Overview text
// make the new surface
local surface = fe.add_surface(flw*0.6, flh*0.275  );
surface.x = flx*0.0525;
surface.y = fly*0.675;

// put overview text on the new surface
local text = surface.add_text( "[Overview]", 0, 0, flx*0.595, flh );
text.word_wrap = true;
text.align = Align.TopLeft;
text.set_rgb (255, 255, 255);
text.charsize = 20;

//text.set_bg_rgb( 100, 100, 100 );
// uncoment the ubove line to visibley see the transparent text layer !
// so can u position and size in layout easier!

// calling "local text" in the animation     
local an = { when=Transition.ToNewSelection, 
//local an = { when=Transition.StartLayout, 
property="y", 
start=text.y+200 , 
end=text.y-340, 
time=55000 
loop = true,
}
animation.add( PropertyAnimation( text, an ) );

// emulator text info
local textemu = fe.add_text( "Emulator: [Emulator]", flx* 0.1625, fly*0.5, flw*0.6, flh*0.025  );
textemu.set_rgb( 255, 255, 255 );
textemu.align = Align.Left;
textemu.word_wrap = false;

// year text info
local texty = fe.add_text("Year: [Year]", flx*0.1625, fly*0.525, flw*0.13, flh*0.025 );
texty.set_rgb( 255, 255, 255 );
texty.align = Align.Left;

// players text info
local textp = fe.add_text("Players: [Players]", flx*0.25, fly*0.525, flw*0.13, flh*0.025 );
textp.set_rgb( 255, 255, 255 );
textp.align = Align.Left;

// played count text info
local textpc = fe.add_text("Played Count: [PlayedCount]", flx*0.35, fly*0.525, flw*0.13, flh*0.025 );
textpc.set_rgb( 255, 255, 255 );
textpc.align = Align.Left;

// display filter info
local filter = fe.add_text( "Filter: [ListFilterName]", flx*0.45, fly*0.525, flw*0.2, flh*0.025 );
filter.set_rgb( 255, 255, 255 );
filter.align = Align.Left;

// manufacturer filter info
local manufact = fe.add_text( "Manufacturer: [Manufacturer]", flx*0.1625, fly*0.55, flw*0.25, flh*0.025 );
manufact.set_rgb( 255, 255, 255 );
manufact.align = Align.Left;

// display game count info
local gamecount = fe.add_text( "Game Count: [ListEntry]-[ListSize]", flx*0.41, fly*0.55, flw*0.5, flh*0.025 );
gamecount.set_rgb( 255, 255, 255 );
gamecount.align = Align.Left;
gamecount.rotation = 0;

// category genre icons 
local glogo1 = fe.add_image("glogos/unknown1.png", flx*0.3, fly*0.57, flw*0.1, flh*0.1);
glogo1.trigger = Transition.EndNavigation;

class GenreImage1
{
    mode = 2;       //0 = first match, 1 = last match, 2 = random
    supported = {
        //filename : [ match1, match2 ]
        "action": [ "action","gun", "climbing" ],
        "adventure": [ "adventure" ],
        "arcade": [ "arcade" ],
        "casino": [ "casino" ],
        "computer": [ "computer" ],
        "console": [ "console" ],
        "collection": [ "collection" ],
        "fighter": [ "fighting", "fighter", "beat-'em-up" ],
        "handheld": [ "handheld" ],
		"jukebox": [ "jukebox" ],
        "platformer": [ "platformer", "platform" ],
        "mahjong": [ "mahjong" ],
        "maze": [ "maze" ],
        "paddle": [ "breakout", "paddle" ],
        "puzzle": [ "puzzle" ],
	    "pinball": [ "pinball" ],
	    "quiz": [ "quiz" ],
	    "racing": [ "racing", "driving","motorcycle" ],
        "rpg": [ "rpg", "role playing", "role-playing" ],
	    "rhythm": [ "rhythm" ],
        "shooter": [ "shooter", "shmup", "shoot-'em-up" ],
	    "simulation": [ "simulation" ],
        "sports": [ "sports", "boxing", "golf", "baseball", "football", "soccer", "tennis", "hockey" ],
        "strategy": [ "strategy"],
        "utility": [ "utility" ]
    }

    ref = null;
    constructor( image )
    {
        ref = image;
        fe.add_transition_callback( this, "transition" );
//		ref.preserve_aspect_ratio = true;
    }
    
    function transition( ttype, var, ttime )
    {
        if ( ttype == Transition.ToNewSelection || ttype == Transition.ToNewList )
        {
            local cat = " " + fe.game_info(Info.Category, var).tolower();
            local matches = [];
            foreach( key, val in supported )
            {
                foreach( nickname in val )
                {
                    if ( cat.find(nickname, 0) ) matches.push(key);
                }
            }
            if ( matches.len() > 0 )
            {
                switch( mode )
                {
                    case 0:
                        ref.file_name = "glogos/" + matches[0] + "1.png";
                        break;
                    case 1:
                        ref.file_name = "glogos/" + matches[matches.len() - 1] + "1.png";
                        break;
                    case 2:
                        local random_num = floor(((rand() % 1000 ) / 1000.0) * ((matches.len() - 1) - (0 - 1)) + 0);
                        ref.file_name = "glogos/" + matches[random_num] + "1.png";
                        break;
                }
            } else
            {
                ref.file_name = "glogos/unknown1.png";
            }
        }
    }
}
GenreImage1(glogo1);

