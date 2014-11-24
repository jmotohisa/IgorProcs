#pragma rtGlobals=1		// Use modern global access method.

// Correct wavelength calibration data based on spectrmeter central wavelength
//
// you must prepare:
//	-list of wave names (data0, etc)
//	-list of centeral wavelength (wlcen, etc)
//  -waves of calibrated wavelength data (stat with "wl", ("wl"+num2str(wlcen)"

Macro WLcorrect(bwname,wlcenv)
	String bwname
	Variable wlcenv
	PauseUpdate;Silent 1
	
	String xwv=bwname+"_0"
	String ywv=bwname+"_1"
	String wlwv="WL"+num2str(wlcenv)
	if(exists(wlwv))
		$xwv=$wlwv
		Wavestats/Q $xwv
		SetScale/I x V_min,V_max,"",$ywv
		print "wave ",xwv,ywv,"corrected with wlcen=",wlcenv
	else
		print "original wavename:", bwname," :wave ",wlwv,"does not exist."
	endif
End

Macro WLcorrect_ALL(wvlist,wlcenlist)
	String wvlist="data0"
	String wlcenlist="wlcen"
	PauseUpdate; Silent 1
	
	Variable n=DimSize($wlcenlist,0)
	Variable i=0
	do
		WLcorrect($wvlist[i],$wlcenlist[i])
		i+=1
	while(i<n)
End
	