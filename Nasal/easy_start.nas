var easy_start = func {
	setprop("controls/switches/master-switch", 1);
	setprop("controls/engines/engine[0]/master-alt",1);
	setprop("controls/engines/engine[0]/master-bat",1);
	setprop("controls/electric/battery-switch",1);
	setprop("controls/electric/engine[0]/generator",1);
	setprop("controls/engines/engine[0]/magnetos",3);
	setprop("controls/engines/engine[0]/primer",1);
	setprop("controls/engines/engine[0]/throttle",0.9);
	setprop("controls/engines/engine[0]/mixture",1);
	setprop("controls/engines/engine[0]/cowl-flaps-norm",1);
	screen.log.write("Now press S to start the engine !");
}
