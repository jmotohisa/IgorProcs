#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


// Create Movie based on the graph/image in "twindow"
// "twave" is displayed in "twindow" and updated following in the waves
// in "twave_list"
 
Function MakeMovie0(twindow,twave,twave_list,frameRate)
	String twindow,twave,twave_list
	Variable frameRate
	
	Variable nframe=DimSize($twave_list,0)
	Variable i
	Wave/T wtwave_list=$twave_list

	DoWindow/F $twindow
	String ttwave
	for(i=0;i<nframe;i+=1)
		if(i==0)
			newmovie/O/F=(frameRate)
		endif
//		ModifyGizmo ModifyObject=surface0,objectType=surface,property={ plane,i}
		ttwave=wtwave_list[i]
		Duplicate/O $ttwave,$twave
		DoUpdate
		AddMovieFrame
	endfor
	
	closemovie
End

// Create Movie based on the graph/image in "twindow" of Gizmo window
// "twave" is a 3D wave containg 
// Setup of "twindow" should be finished before calling MakeGizmoMovie0
// surface

Function MakeGizmoMovie0(twindow,twave,frameRate)
	String twindow,twave
	Variable frameRate // 20

	Variable nframe
	Wave ttwave=$twave
	nframe=DimSize(ttwave,2)
	DoWindow/F $twindow

	Variable i
	for(i=0;i<nframe;i+=1)
		if(i==0)
			newmovie/O/F=(framerate)
		endif
		ModifyGizmo ModifyObject=surface0,objectType=surface,property={plane,i}
		DoUpdate
		addmovieframe
	endfor
	
	closemovie
End

Function MakeGizmoMovie00(frameRate)
	Variable frameRate // 20

	Variable nframe
//	nframe=DimSize(Ex_t,2)
	nframe=40
	// NewGizmo
	// add 3D wave as surface0 
	// ModifyGizmo opName=ortho0, operation=ortho,data={-1.1,1.1,-1.1,1.1,-2,2}

	Variable i
	for(i=0;i<nframe;i+=1)
		if(i==0)
			newmovie/O/F=(framerate)
		endif
		ModifyGizmo ModifyObject=surface0,objectType=surface,property={ plane,i}
		DoUpdate
		addmovieframe
	endfor
	
	closemovie
End