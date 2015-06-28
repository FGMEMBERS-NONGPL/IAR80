#  easy_start.nas - Setup needed properties for simple "s"-key engine start
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
