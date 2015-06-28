#  failure.nas - script to implement several failures
#
#  Copyright (C) 2013 Emilian Huminiuc <emilianh@gmail.com>
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License as
#  published by the Free Software Foundation; either version 2 of the
#  License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

var wing_reset = func{
	setprop("/sim/failure-manager/wing/bent", 0);
}

setlistener("/gear/gear[0]/position-norm", func(n){
	var pos = n.getValue() or 0.0;
	var as = getprop("/velocities/airspeed-kt");
	if (as > 140 and ((pos > 0.2 and pos < 0.45) or (pos > 0.45 and pos < 0.8))){
		setprop("/gear/serviceable", 0);
		setprop("/gear/gear[0]/position-norm", 0.45);
	} elsif (as > 140 and pos > 0.8){
		setprop("/gear/serviceable", 0);
		setprop("/gear/gear[0]/position-norm", 1);
	}
},1);

setlistener("/gear/gear[0]/wow", func(n){
	var wow = n.getValue() or 0.0;
	var dn_spd = getprop("/velocities/speed-down-fps");
	if (wow and dn_spd > 20 ){
		setprop("/gear/serviceable", 0);
		interpolate("/gear/gear[0]/position-norm", 0.45, 0.2);
	}
},1);

setlistener("/gear/gear[1]/position-norm", func(n){
	var pos = n.getValue() or 0.0;
	var as = getprop("/velocities/airspeed-kt");
	if (as > 140 and ((pos > 0.2 and pos < 0.45) or (pos > 0.45 and pos < 0.8))){
		setprop("/gear/serviceable", 0);
		setprop("/gear/gear[1]/position-norm", 0.45);
	} elsif (as > 140 and pos > 0.8){
		setprop("/gear/serviceable", 0);
		setprop("/gear/gear[1]/position-norm", 1);
	}
},1);

setlistener("/gear/gear[1]/wow", func(n){
	var wow = n.getValue() or 0.0;
	var dn_spd = getprop("/velocities/speed-down-fps");
	if (wow and dn_spd > 20 ){
		setprop("/gear/serviceable", 0);
		interpolate("/gear/gear[1]/position-norm", 0.65, 0);
	}
},1);

setlistener("/surface-positions/flap-pos-norm", func(n){
	var fl_pos = n.getValue() or 0.0;
	var as = getprop("/velocities/airspeed-kt") or 0.0;
	if (as > 173 and fl_pos > 0.3){
		setprop("/sim/failure-manager/controls/flight/flaps/serviceable", 0);
	}
},1);

setlistener("/surface-positions/left-aileron-pos-norm", func(n){
	var ail_pos = n.getValue() or 0.0;
	var as = getprop("/velocities/airspeed-kt") or 0.0;
	if (as > 405 and ail_pos > 0.1){
		setprop("/sim/failure-manager/controls/flight/aileron/serviceable", 0);
	}
},1);

setlistener("/surface-positions/elevator-pos-norm", func(n){
	var el_pos = n.getValue() or 0.0;
	var as = getprop("/velocities/airspeed-kt") or 0.0;
	if (as > 405 and el_pos > 0.1){
		setprop("/sim/failure-manager/controls/flight/elevator/serviceable", 0);
	}
},1);

setlistener("/surface-positions/rudder-pos-norm", func(n){
	var rud_pos = n.getValue();
	var as = getprop("/velocities/airspeed-kt") or 0.0;
	if (as > 405 and rud_pos > 0.1){
		setprop("/sim/failure-manager/controls/flight/rudder/serviceable", 0);
	}
},1);

setlistener("/accelerations/pilot-gdamped", func(n){
	var g_load = n.getValue() or 0.0;
	var roll = getprop("/orientation/roll-deg") or 0.0;
	if (g_load > 8){
		if(roll > 0){
			setprop("/sim/failure-manager/wing/bent", 1);
		}else{
			setprop("/sim/failure-manager/wing/bent", -1);
		}
	}elsif (g_load < -5){
		if(roll > 0){
			setprop("/sim/failure-manager/wing/bent", -1);
		}else{
			setprop("/sim/failure-manager/wing/bent", 1);
		}
	}
},1);

setlistener("/gear/gear[3]/wow", func(n){
	var prop_strike = n.getValue();
	var fdm = getprop("/sim/flight-model");
	if (prop_strike){
		setprop("/sim/failure-manager/propeller/bent", 1);
		setprop("/engines/engine[0]/running", 0);
		setprop("/engines/engine[0]/out-of-fuel", 1);
		setprop("/consumables/fuel/set", 0);
		interpolate("/engines/engine[0]/rpm", 0, 1);
		if (fdm == "jsb"){
			interpolate("/fdm/jsbsim/propulsion/engine/friction-hp", 3000, 3);
		}
	}
},1);
