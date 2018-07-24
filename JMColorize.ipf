#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// GetColor function by H. Rodstein 
//http://www.igorexchange.com/node/1535

Function/S FJMColorize()
	String gname
	Variable numcolors
	gname=WinName(0,1)
	numcolors=ItemsInList(TraceNameList(gname,";",1))
	JMColorize(gname,numcolors)
	return gname
End

Function JMColorize(gname,numcolors)
	String gname
	Variable numcolors
	Prompt gname,"Graph Name",popup,WinList("*",";","WIN:1")
	PauseUpdate; Silent 1
	
	String tnames,trname,cmd
	Variable red,green,blue,index,numt
	tnames=TraceNameList(gname,";", 1 )
	numt=ItemsInList(tnames)
	index=0
	do
		trname=StringFromList(index,tnames,";")
		if(strlen(trname)==0)
			break
		endif
		GetColor2(index, numcolors,red, green, blue)
//		sprintf cmd,"ModifyGraph rgb(%s)=(%d,%d,%d)",tname,
		ModifyGraph rgb($trname)=(red,green,blue)
		ModifyGraph lstyle($trname)=floor(index/numcolors)
		index+=1
//		ModifyGraph lstyle(zm0r000z000ref_theo)=2,
	while(1)
End

Function GetColor(colorIndex, red, green, blue)
	Variable colorIndex
	Variable &red, &green, &blue				// Outputs
 
//	colorIndex = mod(colorIndex, kNumVanBlariganWaves)			// Wrap around if necessary
	switch(colorIndex)
		case 0:		// Time wave
			red = 0; green = 0; blue = 0;								// Black
			break
 
		case 1:
			red = 65535; green = 16385; blue = 16385;			// Red
			break
 
		case 2:
			red = 2; green = 39321; blue = 1;						// Green
			break
 
		case 3:
			red = 0; green = 0; blue = 65535;						// Blue
			break
 
		case 4:
			red = 39321; green = 1; blue = 31457;					// Purple
			break
 
		case 5:
			red = 39321; green = 39321; blue = 39321;			// Gray
			break
 
		case 6:
			red = 65535; green = 32768; blue = 32768;			// Salmon
			break
 
		case 7:
			red = 0; green = 65535; blue = 0;						// Lime
			break
 
		case 8:
			red = 16385; green = 65535; blue = 65535;			// Turquoise
			break
 
		case 9:
			red = 65535; green = 32768; blue = 58981;			// Light purple
			break
 
		case 10:
			red = 39321; green = 26208; blue = 1;					// Brown
			break
 
		case 11:
			red = 52428; green = 34958; blue = 1;					// Light brown
			break
 
		case 12:
			red = 65535; green = 32764; blue = 16385;			// Orange
			break
 
		case 13:
			red = 1; green = 52428; blue = 26586;					// Teal
			break
 
		case 14:
			red = 1; green = 3; blue = 39321;						// Dark blue
			break
 
		case 15:
			red = 65535; green = 49151; blue = 55704;			// Pink
			break
	endswitch
End

Function GetColor2(colorIndex, numcolor,red, green, blue)
	Variable colorIndex,numcolor
	Variable &red, &green, &blue				// Outputs
 
	colorIndex = mod(colorIndex, numcolor)
	switch(colorIndex)
		case 0:		// Time wave
			red = 0; green = 0; blue = 0;								// Black
			break
 
		case 1:
			red = 65535; green = 16385; blue = 16385;			// Red
			break
 
		case 2:
			red = 2; green = 39321; blue = 1;						// Green
			break
 
		case 3:
			red = 0; green = 0; blue = 65535;						// Blue
			break
 
		case 4:
			red = 39321; green = 1; blue = 31457;					// Purple
			break
 
		case 5:
			red = 39321; green = 39321; blue = 39321;			// Gray
			break
 
		case 6:
			red = 65535; green = 32768; blue = 32768;			// Salmon
			break
 
		case 7:
			red = 0; green = 65535; blue = 0;						// Lime
			break
 
		case 8:
			red = 16385; green = 65535; blue = 65535;			// Turquoise
			break
 
		case 9:
			red = 65535; green = 32768; blue = 58981;			// Light purple
			break
 
		case 10:
			red = 39321; green = 26208; blue = 1;					// Brown
			break
 
		case 11:
			red = 52428; green = 34958; blue = 1;					// Light brown
			break
 
		case 12:
			red = 65535; green = 32764; blue = 16385;			// Orange
			break
 
		case 13:
			red = 1; green = 52428; blue = 26586;					// Teal
			break
 
		case 14:
			red = 1; green = 3; blue = 39321;						// Dark blue
			break
 
		case 15:
			red = 65535; green = 49151; blue = 55704;			// Pink
			break
	endswitch
End