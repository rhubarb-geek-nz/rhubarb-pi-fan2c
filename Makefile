#
#  Copyright 2008, Roger Brown
#
#  This file is part of rhubarb pi.
#
#  This program is free software: you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the
#  Free Software Foundation, either version 3 of the License, or (at your
#  option) any later version.
# 
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>
#
#  $Id: Makefile 25 2021-01-19 23:12:21Z rhubarb-geek-nz $

all: fan2c

fan2c: fan2c.c
	$(CC) -Wall -Werror $(CFLAGS) fan2c.c -lwiringPi -lc -lpthread -lcrypt -lrt -lm -o $@

clean:
	rm -rf fan2c
