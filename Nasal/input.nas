#  input.nas - input filters
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
#
# function to simulate airspeed effects on control surfaces with direct links (no hidraulics)
# it reduces effective input by a factor proportional to the square of the speed
# also simulating dynamic compensators (for elevator input)
#
# revereses throttle input

setlistener("/sim/signals/fdm-initialized", func {
  var fdm = getprop("/sim/flight-model");
  if (fdm == "yasim"){
	print("Control filter for YASim ---INITIALIZED");
	control_loop_yasim();
  } else {
	print("Control filter for JSBSim ---INITIALIZED");
	control_loop_jsb();
  }
});

var control_loop_yasim = func {
	var  airspeed = getprop("/velocities/airspeed-kt");
	var  el_input = getprop("/controls/flight/elevator");
	var ail_input = getprop("/controls/flight/aileron");
	var rud_input = getprop("/controls/flight/rudder");
	var thr_input = getprop("/controls/engines/engine[0]/throttle");

	setprop("/controls/engines/engine[0]/throttle-input", 1 - thr_input);

	if (airspeed > 90){
		if (airspeed <= 375){
			var comp_factor = 0.65 * math.pow(( airspeed - 90 ), 2) /81225;
			setprop("/controls/flight/elevator-input", el_input * (1 - comp_factor));
			setprop("/controls/flight/rudder-input", rud_input * (1 - comp_factor * 0.66));
			setprop("/controls/flight/aileron-input", ail_input * (1 - comp_factor * 0.8));
		}else{
			setprop("/controls/flight/elevator-input", el_input * 0.35);
			setprop("/controls/flight/rudder-input", rud_input * 0.57);
			setprop("/controls/flight/aileron-input", ail_input * 0.48);
		};
	}else{
		setprop("/controls/flight/elevator-input", el_input);
		setprop("/controls/flight/rudder-input", rud_input);
		setprop("/controls/flight/aileron-input", ail_input);
	};

	settimer(control_loop_yasim, 0);
};

var control_loop_jsb = func {
  var thr_input = getprop("/controls/engines/engine[0]/throttle");

  setprop("/controls/engines/engine[0]/throttle-input", 1 - thr_input);

  settimer(control_loop_jsb, 0);
}
