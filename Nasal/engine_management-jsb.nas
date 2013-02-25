var kill_engine = func {
	setprop("/engines/engine[0]/running", 0);
	setprop("/engines/engine[0]/out-of-fuel", 1);
	setprop("/consumables/fuel/set", 0);
	interpolate("/fdm/jsbsim/propulsion/engine/friction-hp", 1000, 0.5);
}

var engine_cough = func {
	var timer = rand() * 5;
	var frictionInit = getprop("/fdm/jsbsim/propulsion/engine/friction-hp");
	var eng_on = func {
		setprop("/engines/engine[0]/running", 1);
		setprop("/engines/engine[0]/out-of-fuel", 0);
		setprop("/sim/failure-manager/engines/engine[0]/coughing", 0);
		setprop("/consumables/fuel/tank[0]/selected", 1);
		setprop("/consumables/fuel/tank[1]/selected", 1);
		interpolate("/fdm/jsbsim/propulsion/engine/friction-hp", frictionInit, 0.5);
	};
	var eng_off = func {
		setprop("/engines/engine[0]/running", 0);
		setprop("/engines/engine[0]/out-of-fuel", 1);
		setprop("/sim/failure-manager/engines/engine[0]/coughing", 1);
		setprop("/consumables/fuel/tank[0]/selected", 0);
		setprop("/consumables/fuel/tank[1]/selected", 0);
		interpolate("/fdm/jsbsim/propulsion/engine/friction-hp", 750, 0.5);
		settimer(eng_on, timer + 0.5);
	};

	eng_off();


}

# var fuel_update = func {
#     if (getprop("/engines/engine[0]/running") == 0){
#     var tank0 = getprop("/consumables/fuel/tank[0]/level-gal_us") or 0;
#     var t0density = getprop("/consumables/fuel/tank[0]/density-ppg") or 1;
#     var tank1 = getprop("/consumables/fuel/tank[1]/level-gal_us") or 0;
#     var t1density = getprop("/consumables/fuel/tank[1]/density-ppg") or 1;
#     setprop("/consumables/fuel/tank[0]/level-lbs", tank0 * t0density);
#     setprop("/consumables/fuel/tank[1]/level-lbs", tank1 * t1density);
#     settimer(fuel_update, 0);
#     }
# }

#######     INIT Engine Management     ########################################
###############################################################################
setlistener("/sim/signals/fdm-initialized", func {
	var ambtemp = getprop("/environment/temperature-degc");
	var tank0 = getprop("/consumables/fuel/tank[0]/level-gal_us") or 0;
	var tank1 = getprop("/consumables/fuel/tank[1]/level-gal_us") or 0;
	setprop("/consumables/fuel/set", 0);
	setprop("/consumables/fuel/fuel-level-gal_us", tank0 + tank1);
	setprop("/engines/engine[0]/oil-temp", ambtemp);
	setprop("/engines/engine[0]/oil-temp-ind", ambtemp);
	setprop("/engines/engine[0]/cyl-temp", ambtemp);
	setprop("/engines/engine[0]/oil-visc", ambtemp / 62);
	setprop("/engines/engine[0]/oil-press", 0);
	setprop("/engines/engine[0]/out-of-fuel", 1);
	setprop("/engines/engine[0]/mp-inhg", 0);
	setprop("/sim/failure-manager/engines/engine[0]/coughing", 0);
	print("Engine management  ---INITIALIZED");
	#oil_temp_ind();
	main_loop();
	#fuel_update();

});



##### PRIMER ##################################################################
###############################################################################
setlistener("/controls/engines/engine[0]/primer-pos-norm", func(n) {
	var pos2 = n.getValue();
	var primed = getprop("/controls/engines/engine[0]/primer");
	if(pos2 > 0.95){
		var prime = rand() * 0.18;
		setprop("/controls/engines/engine[0]/primer", primed + prime);
	};
},1);


setlistener("/controls/engines/engine[0]/primer", func(n) {
	var prm = n.getValue();
	if(prm > 0.9){
		setprop("/engines/engine[0]/out-of-fuel", 0);
		setprop("/consumables/fuel/set", 1);
	} else {
		setprop("/consumables/fuel/set", 0);
	};
},1);

##### Check Engine Started ####################################################
###############################################################################
setlistener("/engines/engine[0]/rpm", func(n) {
	var rev3 = n.getValue();
	if(rev3 > 1800){
		var sndAdjust = (rev3 - 1800) / 2400;
		setprop("/engines/engine[0]/snd-vol", 1 - sndAdjust);
	} else {
		setprop("/engines/engine[0]/snd-vol", 1);
	}
},1);

##### KILL ENGINE ON CRASH ####################################################
###############################################################################
setlistener("/sim[0]/crashed", func(n) {
	var crash = n.getValue();
	if(crash){
		kill_engine();
	};
},1);

##### some coughing when too much wear ########################################
###############################################################################
setlistener("/sim/failure-manager/engines/engine[0]/seize-strain", func(n) {
	var cur_seize = n.getValue();
	var last_seize = getprop("/sim/failure-manager/engines/engine[0]/last-cough-s");
	var coughing = getprop("/sim/failure-manager/engines/engine[0]/coughing");
	if(cur_seize > 1100 ){
		var diff = cur_seize - last_seize;
		if (diff > 60){
			if(!coughing){
				engine_cough();
				setprop("/sim/failure-manager/engines/engine[0]/last-cough-s", last_seize + diff);
			};
		};
	};
},1);

setlistener("/sim/failure-manager/engines/engine[0]/rev-strain", func(n) {
	var cur_revstr = n.getValue();
	var last_revstr = getprop("/sim/failure-manager/engines/engine[0]/last-cough-r");
	var coughing = getprop("/sim/failure-manager/engines/engine[0]/coughing");
	if(cur_revstr > 300000 ){
		var diff = cur_revstr - last_revstr;
		if (diff > 1500){
			if(!coughing){
				engine_cough();
				setprop("/sim/failure-manager/engines/engine[0]/last-cough-r", last_revstr + diff);
			}
		};
	};
},1);

setlistener("/consumables/fuel/set", func(n){
	var set = n.getValue();
	if (set > 0){
		setprop("/consumables/fuel/tank[0]/selected", 1);
		setprop("/consumables/fuel/tank[1]/selected", 1);
	} else {
		setprop("/consumables/fuel/tank[0]/selected", 0);
		setprop("/consumables/fuel/tank[1]/selected", 0);
	}
},1);

#update level-gal_us
# setlistener("/engines/engine/fuel-consumed-lbs", func(n) {
# 	var tank0lb = getprop("/consumables/fuel/tank[0]/level-lbs") or 0;
# 	var t0density = getprop("/consumables/fuel/tank[0]/density-ppg") or 1;
# 	if (t0density == 0){
# 	    t0density = 1;
# 	};
# 	var tank1lb = getprop("/consumables/fuel/tank[1]/level-lbs") or 0;
# 	var t1density = getprop("/consumables/fuel/tank[0]/density-ppg") or 1;
# 	if (t1density == 0){
# 	    t1density = 1;
# 	}
# 	setprop("/consumables/fuel/tank[0]/level-gal_us", tank0lb/t0density);
# 	setprop("/consumables/fuel/tank[1]/level-gal_us", tank1lb/t1density);
# },1);

setlistener("/engines/engine/fuel-flow_pph", func(n) {
	var tank0_lbs = getprop("/consumables/fuel/tank[0]/level-lbs") or 0;
	var t0density = getprop("/consumables/fuel/tank[0]/density-ppg") or 1;
	if (t0density == 0){ 		    t0density = 1;		};
	var tank0 = tank0_lbs/t0density;
	var tank1_lbs = getprop("/consumables/fuel/tank[1]/level-lbs") or 0;
	var t1density = getprop("/consumables/fuel/tank[0]/density-ppg") or 1;
	if (t1density == 0){ 		    t0density = 1;		};
	var tank1 = tank1_lbs/t1density;
	var tank_sw = getprop("/consumables/fuel/set");
	setprop("/consumables/fuel/fuel-level-gal_us", tank0 + tank1);
	var total_fuel = getprop ("/consumables/fuel/fuel-level-gal_us");
	var last_fuel = getprop("/sim/failure-manager/engines/engine[0]/last-cough-f") or 0;
	var coughing = getprop("/sim/failure-manager/engines/engine[0]/coughing");
	if (tank_sw == 1){
		if (tank0 > 0.25 ){
		    if (!coughing){
			setprop("/consumables/fuel/tank[0]/selected", 1);
			setprop("/consumables/fuel/tank[1]/selected", 0);
		    }
		} else {
		     if(tank1 > 0){
			if (!coughing){
			    setprop("/consumables/fuel/tank[0]/selected", 0);
			    setprop("/consumables/fuel/tank[1]/selected", 1);
			}
		     }
		}
	}
	###ok yo're in trouble.. find a gas station :P quick ##################
	#######################################################################
	if (total_fuel < 3) {
	    if (abs(total_fuel - last_fuel) > total_fuel/10 ){
		if (!coughing){
			engine_cough();
			setprop("/sim/failure-manager/engines/engine[0]/last-cough-f", total_fuel);
		}
	    }
	}
},1);

#######  this is where all the work gets done ################################
##############################################################################
var main_loop = func {

	### kill engine when overreved for too much
	var rev2 = getprop("/engines/engine[0]/rpm");
	var rstrain = getprop("/sim/failure-manager/engines/engine[0]/rev-strain");
	var lubricationLoss = 0;
	var boost = getprop("/engines/engine[0]/mp-inhg");

	if (rstrain > 400000) {
		setprop("/engines/engine[0]/overrev", 1);
		kill_engine();
	}

	if (rev2 > 2825) {
		if (rev2 > 3050) {
			var strain = rev2 - 3050;
		} else {
			var strain = 0.25 * (rev2 - 2825);
		}
		setprop("/sim/failure-manager/engines/engine[0]/rev-strain", rstrain + strain);
	}

	if (boost > 39.4) {
		var tstrain = 0;
		var bstrain = 15 * (boost - 39.4);
		if (rev2 > 2850) {
			if (rev2 > 3050) {
				var strain = rev2 - 3050;
			} else {
				var strain = 0.25 * (rev2 - 2850);
			}
			tstrain = bstrain + strain;
		} else {
			tstrain = bstrain;
		}
		setprop("/sim/failure-manager/engines/engine[0]/rev-strain", rstrain + tstrain);
	}

	### coolant (oil) temp
#  	if (getprop("/engines/engine[0]/running") == 1) {
		var rev = getprop("/engines/engine[0]/rpm");
		var visc = getprop("/engines/engine[0]/oil-visc");
		var sstrain = getprop("/sim/failure-manager/engines/engine[0]/seize-strain");
		var jsboiltemp = getprop("/engines/engine[0]/oil-temperature-degf") or 0.0;
		var otemp = (jsboiltemp - 32) * 5 / 9;

		setprop("/engines/engine[0]/oil-temp", otemp);

		if (otemp > 121.0) {
			var strain1 = (otemp - 121.0) / 10.0;
			setprop("/sim/failure-manager/engines/engine[0]/seize-strain", sstrain + strain1);
			setprop("/engines/engine[0]/oil-visc", visc - 0.002);
		} else {
			var strain2 = (121 - otemp) / 50;
			var new_sstrain = sstrain - strain2;
			if (new_sstrain > 1){
			    setprop("/sim/failure-manager/engines/engine[0]/seize-strain", new_sstrain);
			} else {
			    setprop("/sim/failure-manager/engines/engine[0]/seize-strain", 1);
			}
		}

		### oil and viscosity
		if ( visc < 1.0 ) {
			setprop("/engines/engine[0]/oil-visc", otemp / 62);
			lubricationLoss = 20.5 - 19 * visc;
			if (rev2 > 1524) {
				setprop("/sim/failure-manager/engines/engine[0]/rev-strain", rstrain + (150 / visc));
			}
		}

# 		if (rev > 320){
# 			if (rev > 3050) {
# 				press1 = press1 + 0.05;
# 			} else {
# 				press1 = 10.5 - 5 * (1 - visc);
# 			}
# 			interpolate("/engines/engine[0]/oil-press", press1, 3);
#		}

		#OK eggs baked, ham smoked.. we close the shop :D
		if ( sstrain > 1300 ) {
			setprop("/engines/engine[0]/seized", 1);
			kill_engine();
		}
		#now throw some oil on the hud :P
		var dirtFactor = math.max( rstrain / 380000, sstrain / 1200 );
		setprop("/sim/model/livery/dirt-factor", dirtFactor);
		#and add some friction
		var frictionFactor = math.max((rstrain - 320000)/80000, (sstrain - 800)/400);
		if ( frictionFactor > 0 and getprop("/engines/engine[0]/running") == 1 ) {
			setprop("/fdm/jsbsim/propulsion/engine/friction-hp", frictionFactor * 750 + lubricationLoss);
		} elsif ( getprop("/engines/engine[0]/running") == 1 ) {
			setprop("/fdm/jsbsim/propulsion/engine/friction-hp", lubricationLoss );
		}
# 	} else {
# 		if (getprop("/engines/engine[0]/rpm") > 100){
# 			var otemp = getprop("engines/engine[0]/oil-temp");
# 			var et0 = getprop("/environment/temperature-degc");
# 			var dtemp = 0.18 * et0 - 0.18 * otemp;
# 			interpolate("/engines/engine[0]/oil-temp" , dtemp + otemp, 10);
# 			var press1 = getprop("/engines/engine[0]/oil-press");
# 			var visc = getprop("/engines/engine[0]/oil-visc");
# 			press1 = press1 - 0.25;
# 			interpolate("/engines/engine[0]/oil-press", press1, 3);
# 		}
#	}

  settimer(main_loop, 0.2)
}

# interpolate indicated oil pressure (we don't want to see the needle stepping)
###############################################################################
# var oil_temp_ind = func {
# 	var oiltempinst = getprop("/engines/engine[0]/oil-temp");
# 	var oiltempind = getprop("/engines/engine[0]/oil-temp-ind");
# 	var diff = oiltempinst - oiltempind;
# 	if (abs(diff) >= 5){
# 		interpolate("/engines/engine[0]/oil-temp-ind", oiltempinst, 7.5);
# 	};
# 	settimer(oil_temp_ind, 7.5);
# }

setlistener("controls/switches/starter-pos-norm", func(n) {
	var starter_power = getprop("/systems/electrical/volts");
	var starter_pos = n.getValue();
	if (starter_pos >= 0.75){
		if( starter_power > 0){
			setprop("/controls/engines/engine[0]/starter", 1);
		};
	} else {
		setprop("/controls/engines/engine[0]/starter", 0);
	};
},1);