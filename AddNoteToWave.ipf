#pragma rtGlobals=1		// Use modern global access method.

//	add notes to waves
//	ver 0.01	2012/12/11	develepment started 

Function AddStdNoteToWave(wv,pathname,filename)
	Wave wv
	String pathname,filename
	
	String buffer
	Pathinfo $pathname
	if(V_flag!=0)
		sprintf buffer,"Wave loed from; path:%s; file name: %s",S_path,filename
	else
		sprintf buffer,"Wave loed from file: %s",filename
	endif
	Note wv,buffer
End