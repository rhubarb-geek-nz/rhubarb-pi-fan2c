/**************************************************************************
 *
 *  Copyright 1989-2012, Roger Brown
 *
 *  This file is part of rhubarb pi.
 *
 *  This program is free software: you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License as published by the
 *  Free Software Foundation, either version 3 of the License, or (at your
 *  option) any later version.
 * 
 *  This program is distributed in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 *  more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>
 *
 */

/*
 * $Id: fan2c.c 25 2021-01-19 23:12:21Z rhubarb-geek-nz $
 */

#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>

#define FAN_PIN 		14
#define TEMP_FILE		"/sys/class/thermal/thermal_zone0/temp"
#define TEMP_TURN_ON	70000
#define TEMP_TURN_OFF	65000

int main(int argc,char **argv)
{
	char buf[256];
	int fd=open(TEMP_FILE,O_RDONLY);
	int i,TmC;

	if (fd < 0)
	{
		perror(TEMP_FILE);
		return 1;
	}

	i=read(fd,buf,sizeof(buf)-1);

	if (i < 0)
	{
		perror(TEMP_FILE);
		return 1;
	}

	close(fd);

	while (i-- > 0)
	{
		char c=buf[i];

		if (c >= '0')
		{
			break;
		}

		buf[i]=0;
	}

	TmC=atoi(buf);

	if (TmC > TEMP_TURN_ON)
	{
		wiringPiSetupGpio();	
		pinMode(FAN_PIN,OUTPUT),
		digitalWrite(FAN_PIN,HIGH);		
	}
	else
	{
		if (TmC < TEMP_TURN_OFF)
		{
			wiringPiSetupGpio();	
			pinMode(FAN_PIN,OUTPUT),
			digitalWrite(FAN_PIN,LOW);
		}
	}
		
	return 0;
}
