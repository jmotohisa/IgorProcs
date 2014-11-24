#pragma rtGlobals=1		// Use modern global access method.
#include "3DMatrixOperations"

// GizmoXYZSliceProc.ipf by J. Motohisa
//	Control 3D wave and XYZ slices
//
//	revision history
//		11/03/20	ver 0.1	Development started

// Control Panel for XYZ Slize
Function JM_GizmoXYZSlicePanel() : Panel
	PauseUpdate; Silent 1		// building window...
	Variable/G g_JM_GizmoXYZSliceXYZ
	If(WinType("JMGizmoXYZSlicePanel")==7)
		DoWindow/F JMGIzmoXYZSlicePanel
		return 0
	endif
	NewPanel/N=JMGizmoXYZSlicePanel /W=(724,204,1119,443)
	SetDrawLayer UserBack
	DrawText 14,76,"x"
	DrawText 14,122,"y"
	DrawText 14,168,"z"
	PopupMenu popupGizmoWin,pos={10,8},size={134,17},proc=JMGizmoBringToFront,title="Window Name"
	PopupMenu popupGizmoWin,mode=1,popvalue="_none_",value= #"\"_none_;\"+WinList(\"*\",\";\",\"WIN:4096\")"
	PopupMenu popupGizmoWave,pos={172,8},size={121,17},proc=JMGizmoSelectWave,title="wave name"
	PopupMenu popupGizmoWave,mode=3,popvalue="_none_",value= #"\"_none_;\"+WaveList(\"*\",\";\",\"DIMS:3\")"
	Slider sliderx,pos={28,64},size={262,45},proc=JM_GSSliderXProc
	Slider sliderx,limits={0,2,1},value= 0,vert= 0
	Slider slidery,pos={28,110},size={262,45},proc=JM_GSSliderYproc
	Slider slidery,limits={0,2,1},value= 0,vert= 0
	Slider sliderz,pos={28,156},size={262,45},proc=JM_GSSliderZproc
	Slider sliderz,limits={0,2,1},value= 0,vert= 0
	Button JMShowGizmoSlice,pos={332,7},size={50,20},proc=JM_GSDIsplayGizmoSlice,title="Display"
	CheckBox JM_GSAspect,pos={168,37},size={97,14},proc=JM_GSAspectCheckProc,title="Keep Aspect Ratio"
	CheckBox JM_GSAspect,value= 0
	SetVariable setvarx,pos={290,57},size={50,15},proc=JM_GSSetXVarProc
	SetVariable setvarx,value= _NUM:0
	SetVariable setvary,pos={290,110},size={50,15},proc=JM_GSSetYVarProc
	SetVariable setvary,value= _NUM:0
	SetVariable setvarz,pos={290,156},size={50,15},proc=JM_GSSetZVarProc
	SetVariable setvarz,value= _NUM:0
	PopupMenu JM_GSColorTablePopup,pos={10,34},size={63,17},proc=JM_GSChangeSliceColor
	PopupMenu JM_GSColorTablePopup,mode=1,popvalue="Grays",value= #"CTabList()"
	Button JM_GSDisplaySliceButton,pos={144,205},size={90,20},proc=JM_GSDisplaySlice,title="Retreive Slice"
	PopupMenu JM_GSXYZPopUp,pos={35,206},size={35,17},proc=JM_GSSelectXYZ
	PopupMenu JM_GSXYZPopUp,mode=1,popvalue="x",value= #"\"x;y;z\""
	SetWindow JMGizmoXYZSlicePanel,hook(MyHook)=JM_GSXYZSliceWindowHook
EndMacro

// Creation of Gizmo Window for XYZ slice
Function JMGizmoShowXYZSlice(wname,wnname)
	String wname,wnname

	String cmd
	Variable xplane,yplane,zplane
	String objectname
		// Do nothing if the Gizmo XOP is not available.
	if(exists("NewGizmo")!=4)
		DoAlert 0, "Gizmo XOP must be installed"
		return -1
	endif
	
	if(strlen(wnname)==0)
		wnname=wname+"_Gizmo"
	Endif
	
	xplane=DimSize($wname,0)/2
	yplane=DimSize($wname,1)/2
	zplane=DimSize($wname,2)/2

//	sprintf cmd,"NewGizmo/N=Gizmo0/T=\"%s\" /W=(145,44,638,544)",wname
	sprintf cmd,"NewGizmo/N=%s/W=(145,44,638,544)",wnname
	Execute cmd
	
	cmd="ModifyGizmo startRecMacro"
	Execute cmd
	
	// axes0
	JMGizmoAddAxes(wnname,"axes0")
	
	objectName="Surface_x"
	JMGizmoAppendSurface(wnname,wname,objectName,xplane,128)
	objectName="Surface_y"
	JMGizmoAppendSurface(wnname,wname,objectName,yplane,64)
	objectName="Surface_z"
	JMGizmoAppendSurface(wnname,wname,objectName,zplane,32)

	cmd="ModifyGizmo SETQUATERNION={0.626303,-0.113616,-0.165080,0.753382}";Execute cmd
	cmd="ModifyGizmo autoscaling=1";Execute cmd
//	cmd="ModifyGizmo currentGroupObject=""";Execute cmd
	cmd="ModifyGizmo compile";Execute cmd

	cmd="ModifyGizmo showInfo";Execute cmd
	cmd="ModifyGizmo infoWindow={635,119,1166,363}";Execute cmd
//	cmd="ModifyGizmo bringToFront";Execute cmd
//	cmd="ModifyGizmo userString={wmgizmo_df,wnname}";Execute cmd
	cmd="ModifyGizmo endRecMacro";Execute cmd
End

Function JMGizmoAppendSurface(gizmoName,srcWaveName,surfaceName,planeNumber,srcMode)
	String gizmoname,srcWaveName,surfaceName
	Variable planeNumber,srcMode
	// srcMode: xsurface=128, ysurface=64, zsurface=32
	
	String cmd
	sprintf cmd,"AppendToGizmo Surface=%s,name=%s",srcWaveName,surfaceName
	Execute cmd
	
	sprintf cmd,"ModifyGizmo ModifyObject=%s property={ srcMode,%d}",surfaceName,srcMode
	Execute cmd
	
	sprintf cmd,"ModifyGizmo ModifyObject=%s property={surfaceCTab,Rainbow}",surfaceName
	Execute cmd
	
	sprintf cmd,"ModifyGizmo ModifyObject=%s property={ plane,%d}",surfaceName,planeNumber
	Execute cmd
	
	sprintf cmd,"ModifyGizmo modifyObject=%s property={calcNormals,1}",surfaceName
	Execute cmd
	
	sprintf cmd,"ModifyGizmo setDisplayList=-1,object=%s",surfaceName
	Execute cmd	
End

Function JMGizmoAddAxes(wnname,axesName)
	String wnname,axesName
	
	String cmd
	sprintf cmd, "AppendToGizmo Axes=boxAxes,name=%s",axesName;Execute cmd
	sprintf cmd, "ModifyGizmo ModifyObject=%s,property={-1,axisScalingMode,1}",axesName;Execute cmd
	sprintf cmd, "ModifyGizmo ModifyObject=%s,property={-1,axisColor,0,0,0,1}",axesName;Execute cmd
	sprintf cmd, "ModifyGizmo ModifyObject=%s,property={0,ticks,3}",axesName;Execute cmd
	sprintf cmd, "ModifyGizmo ModifyObject=%s,property={1,ticks,3}",axesName;Execute cmd
	sprintf cmd, "ModifyGizmo ModifyObject=%s,property={2,ticks,3}",axesName;Execute cmd
	sprintf cmd, "ModifyGizmo modifyObject=%s property={Clipped,0}",axesName;Execute cmd
	sprintf cmd, "ModifyGizmo setDisplayList=-1,object=%s",axesName;Execute cmd
End

//////////////////////////////////////////// select window popup
Function JMGizmoBringToFront(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

//	String cmd,ObjectName
//	ControlInfo/W=JMGizmoXYZSlicePanel popupGizmoWin
//	objectName=S_Value
//	if(cmpstr(objectName,"_none_")==0)
//		return 0
//	endif

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			If(WinType(popStr)==0)
				return 0
			endif
			DoWindow/F $popStr
//			cmd="PopupMenu popupGizmoWave value=#\"_none_;"+ImageNameList(popStr,";")+"\""
//			cmd="PopupMenu popupGizmoWave value=#"ImageNameList(popStr,\";\")"
//			Execute cmd
			JM_GIzmoXYZSlicePanelUpdate(popStr)
//			sprintf cmd,"ControlUpdate/W=JMGizmoXYZSlicepanel popupGizmoWave"
//			Execute cmd
			break
	endswitch

	return 0
End

// select wave popup
Function JMGizmoSelectWave(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	String cmd,ObjectName
	
	ControlInfo/W=JMGizmoXYZSlicePanel popupGizmoWave
	objectName=S_Value
	if(cmpstr(objectName,"_none_")==0)
		return 0
	endif
	
//	switch( pa.eventCode )
//		case 2: // mouse up
//			Variable popNum = pa.popNum
//			String popStr = pa.popStr
//			sprintf cmd,"ModifyGizmo ModifyObject=%s property={ plane,%d}",popStr
//			Execute cmd
//			break
//	endswitch

	return 0
End

//////////////////////////////// slider
Function JM_GSSliderXProc(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved

	String cmd,objectName
	ControlInfo/W=JMGizmoXYZSlicePanel popupGizmoWin
	objectName=S_Value
	
	if(cmpstr(objectName,"_none_")==0)
		return 0
	endif
	
	JM_GSSliderProc(event,"surface_X",sliderValue)
	JM_GSUpdateVariable("setvarx",sliderValue)
	return 0
End

Function JM_GSSliderYProc(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved

	String cmd,objectName
	
	ControlInfo/W=JMGizmoXYZSlicePanel popupGizmoWin
	objectName=S_Value
	
	if(cmpstr(objectName,"_none_")==0)
		return 0
	endif
	
	JM_GSSliderProc(event,"surface_Y",sliderValue)
	JM_GSUpdateVariable("setvary",sliderValue)
	return 0
End

Function JM_GSSliderZProc(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved

	String cmd,objectName
	
	ControlInfo/W=JMGizmoXYZSlicePanel popupGizmoWin
	objectName=S_Value
	if(cmpstr(objectName,"_none_")==0)
		return 0
	endif
	
	JM_GSSliderProc(event,"surface_Z",sliderValue)
	JM_GSUpdateVariable("setvarz",sliderValue)
	return 0
End

Function JM_GSSliderProc(event,objectName,sliderValue)
	String objectName
	Variable event,sliderValue
	
	String cmd
	if(event %& 0x1)	// bit 0, value set
		JM_GSSetPlane(objectName,sliderValue)
	endif
	return 0
End

Function JM_GSUpdateVariable(varstr,sliderValue)
	String varstr
	Variable sliderValue
	
	String cmd
	sprintf cmd,"SetVariable %s,value= _NUM:%d",varstr,sliderValue
	Execute cmd
End

Function JM_GSUpdateSlider(varstr,sliderValue)
	String varstr
	Variable sliderValue
	
	String cmd
	sprintf cmd,"Slider %s,value=%d",varstr,sliderValue
	Execute cmd
End

///////////////////// Set Variables
Function JM_GSSetXVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	String objectName
	ControlInfo/W=JMGizmoXYZSlicePanel popupGizmoWin
	objectName=S_Value
	if(cmpstr(objectName,"_none_")==0)
		return 0
	endif

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			JM_GSSetPlane("Surface_x",dval)
			JM_GSUpdateSlider("sliderx",dval)
			break
	endswitch

	return 0
End

Function JM_GSSetYVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	String objectName
	ControlInfo/W=JMGizmoXYZSlicePanel popupGizmoWin
	objectName=S_Value
	if(cmpstr(objectName,"_none_")==0)
		return 0
	endif

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			JM_GSSetPlane("surface_Y",dval)
			JM_GSUpdateSlider("slidery",dval)
			break
	endswitch

	return 0
End

Function JM_GSSetZVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	String objectName
	ControlInfo/W=JMGizmoXYZSlicePanel popupGizmoWin
	objectName=S_Value
	if(cmpstr(objectName,"_none_")==0)
		return 0
	endif

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			JM_GSSetPlane("surface_Z",dval)
			JM_GSUpdateSlider("sliderz",dval)
			break
	endswitch

	return 0
End

///////////////// Set plane
Function JM_GSSetPlane(objectName,val)
	String objectName
	Variable val
	
	String cmd
	sprintf cmd,"ModifyGizmo ModifyObject=%s property={ plane,%d}",objectName,val
	Execute cmd
	return 0
End


/////////// Aspect ratio checkbox
Function JM_GSAspectCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	String objectName
	ControlInfo/W=JMGizmoXYZSlicePanel popupGizmoWin
	objectName=S_Value
	if(cmpstr(objectName,"_none_")==0)
		return 0
	endif
	
	if(checked)
		Execute "ModifyGizmo AspectRatio=1"
	else
		Execute "ModifyGizmo AspectRatio=0"
	endif
	Execute "ModifyGizmo update=2"
End

/////////
//Macro SetScaleGizmo(xyspan,zspan)
//	Variable xyspan,zspan
//	PauseUpdate;Silent 1
//	
//	MakeGizmoAspectRatio("",xyspan/zspan)
//End

//////////////////////// color table popup
Function JM_GSChangeSliceColor(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	String cmd,objectName
	ControlInfo/W=JMGizmoXYZSlicePanel popupGizmoWin
	objectName=S_Value
	if(cmpstr(objectName,"_none_")==0)
		return 0
	endif
	
	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(cmpstr(popStr,"_none_")==0)
				Beep
			return 0
			endif
			objectName="Surface_x"
			JM_ChangeColorTable(objectName,popStr)
			objectName="Surface_y"
			JM_ChangeColorTable(objectName,popStr)
			objectName="Surface_z"
			JM_ChangeColorTable(objectName,popStr)
			break
		endswitch

	return 0
End

Function JM_ChangeColorTable(objectName,cname)
	String objectName,cname
	
	String cmd
	sprintf cmd,"ModifyGizmo ModifyObject=%s property={surfaceCTab,%s}",objectName,cname
	Execute cmd
	return 0
End

//////
Function JM_GIzmoXYZSlicePanelUpdate(gizmoName)
	String gizmoName
	
	String recMacro=WinRecreation(gizmoName, 0)
	String findThis="name="+gizmoName
	Variable pos,pos2

	String srcWaveName
	// step 1: find the wave associated with the slice
//	pos=strsearch(recMacro,findThis, 0)
//	if(pos<0)
//		return 0
//	endif
	pos=strsearch(recMacro,"Surface=", pos,0)
	if(pos<0)
		return 0
	endif
	pos2=strsearch(recMacro,",", pos)
	srcWaveName=recMacro[pos+8,pos2-1]
	Wave/Z ww=$srcWaveName
	if(WaveExists(ww)==0)
		return 0
	endif
	
	// step 2: update wave name
	Popupmenu popupGizmoWave win=JMGizmoXYZSlicePanel,popmatch=NameOfWave(ww)
//	ControlUpdate/W=JMGizmoXYZSlicePanel popupGizmoWave

	// step 3: find the color table
	string ctabName
	pos=strsearch(recMacro,"property={ surfaceCTab",pos)
	if(pos<0)
		return 0
	endif
	pos2=strsearch(recMacro,"}",pos)
	ctabName=recMacro[pos+23,pos2-1]

	// step 4: find the current setting:
	pos=strsearch(recMacro,"Surface_x",0)
	pos=strsearch(recMacro,"property={ plane",pos)
	if(pos>-1)
		pos2=strsearch(recMacro,"}",pos)
		Variable planeNumx
		String planeStr=recMacro[pos+17,pos2-1]
		sscanf planeStr,"%d",planeNumx
	else
		planeNumx=0
	endif
	
	pos=strsearch(recMacro,"Surface_y",0)
	pos=strsearch(recMacro,"property={ plane",pos)
	if(pos>-1)
		pos2=strsearch(recMacro,"}",pos)
		Variable planeNumy
		planeStr=recMacro[pos+17,pos2-1]
		sscanf planeStr,"%d",planeNumy
	else
		planeNumy=0
	endif
	
	pos=strsearch(recMacro,"Surface_z",0)
	pos=strsearch(recMacro,"property={ plane",pos)
	if(pos>-1)
		pos2=strsearch(recMacro,"}",pos)
		Variable planeNumz
		planeStr=recMacro[pos+17,pos2-1]
		sscanf planeStr,"%d",planeNumz
	else
		planeNumz=0
	endif
	
	// step 5: adjust the slider and  number control
	Slider sliderx,limits={0,DimSize(ww,0)-1,1},value=(planeNumx),win=JMGizmoXYZSlicePanel
	Slider slidery,limits={0,DimSize(ww,1)-1,1},value=(planeNumy),win=JMGizmoXYZSlicePanel
	Slider sliderz,limits={0,DimSize(ww,2)-1,1},value=(planeNumz),win=JMGizmoXYZSlicePanel
	SetVariable setvarx,value=_NUM:planeNumx
	SetVariable setvary,value=_NUM:planeNumy
	SetVariable setvarz,value=_NUM:planeNumz

	String list=CTabList()
	Variable item=1+WhichListItem(ctabName, list)	// 1 for 1 base and 1 for _none_.
	PopupMenu JM_GSColorTablePopup mode=item,win=JMGizmoXYZSlicePanel
	ControlUpdate/W=JMGizmoXYZSlicePanel JM_GSColorTablePopup
End

Function JM_GSGetSlider(index)
	Variable index
	
	String xyz,cmd
	switch(index)
		case 0:
			xyz="x"
			break
		case 1:
			xyz="y"
			break
		case 2:
			xyz="z"
			break
	endswitch

	sprintf cmd, "ControlInfo/W=JMGizmoXYZSlicePanel slider%s",xyz
	Execute cmd
	NVAR V_Value
	return(V_value)
End

Function JM_GSIncSlider(index)
	Variable index
	
	String xyz,cmd
	Variable planeNum
	switch(index)
		case 0:
			xyz="x"
			break
		case 1:
			xyz="y"
			break
		case 2:
			xyz="z"
			break
	endswitch

	sprintf cmd, "ControlInfo/W=JMGizmoXYZSlicePanel slider%s",xyz
	Execute cmd
	NVAR V_value
	planeNum=V_value+1
	sprintf cmd,"JM_GSSetPlane(\"Surface_%s\",%d)",xyz,planeNum
	Execute cmd
	sprintf cmd, "JM_GSUpdateSlider(\"slider%s\",%d)",xyz,planeNum
	Execute cmd
	sprintf cmd, "JM_GSUpdateVariable(\"setvar%s\",%d)",xyz,planeNum
	Execute cmd

	return(planeNum)
End

Function JM_GSdecSlider(index)
	Variable index
	
	String xyz,cmd
	Variable planeNum
	switch(index)
		case 0:
			xyz="x"
			break
		case 1:
			xyz="y"
			break
		case 2:
			xyz="z"
			break
	endswitch

	sprintf cmd, "ControlInfo/W=JMGizmoXYZSlicePanel slider%s",xyz
	Execute cmd
	NVAR V_value
	planeNum=V_value-1
	sprintf cmd,"JM_GSSetPlane(\"Surface_%s\",%d)",xyz,planeNum
	Execute cmd
	sprintf cmd, "JM_GSUpdateSlider(\"slider%s\",%d)",xyz,planeNum
	Execute cmd
	sprintf cmd, "JM_GSUpdateVariable(\"setvar%s\",%d)",xyz,planeNum
	Execute cmd

	return(planeNum)
End

Function JM_GSXYZSliceWindowHook(s)
	STRUCT WMWinHookStruct &s
	
	NVAR g_JM_GizmoXYZSliceXYZ
	String objectName
	Variable hookResult = 0 // 0 if we do not handle event, 1 if we handle it.
	Variable planeNum

	switch(s.eventCode)
		case 17: // KillVote 
//			DoWindow/K JMGIzmoXYZSlicePanel
			DoWindow/K $s.winName // Kill window without saving
			hookResult=1
			break
		case 11: // Keyboard event
			ControlInfo/W=JMGizmoXYZSlicePanel popupGizmoWin
			objectName=S_Value
			if(cmpstr(objectName,"_none_")==0)
//				return hookResult
				break
			endif
		switch (s.keycode)
		case 28:
//			Print "Left arrow key pressed."
			planeNum=JM_GSdecSlider(g_JM_GizmoXYZSliceXYZ)
			hookResult = 1 
			break
		case 29:
//			Print "Right arrow key pressed." 
			planeNum=JM_GSIncSlider(g_JM_GizmoXYZSliceXYZ)
			hookResult = 1
			break
		case 30:
//			Print "Up arrow key pressed."
			g_JM_GizmoXYZSliceXYZ-=1
			if(g_JM_GizmoXYZSliceXYZ<0)
				g_JM_GizmoXYZSliceXYZ=2
			endif
			JM_GSXYZSliceXYZset(g_JM_GizmoXYZSliceXYZ)
			hookResult = 1
			break
		case 31:
//			Print "Down arrow key pressed."
			g_JM_GizmoXYZSliceXYZ+=1
			if(g_JM_GizmoXYZSliceXYZ>2)
				g_JM_GizmoXYZSliceXYZ=0
			endif
			JM_GSXYZSliceXYZset(g_JM_GizmoXYZSliceXYZ)
			hookResult = 1
			break
		endswitch
		break
	endswitch
	return hookResult
// If non-zero, we handled event and Igor will ignore it. 
End 

Function JM_GSDIsplaySlice(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	NVAR g_JM_GizmoXYZSliceXYZ
	String objectName
	ControlInfo/W=JMGizmoXYZSlicePanel popupGizmoWin
	objectName=S_Value
	if(cmpstr(objectName,"_none_")==0)
		return 0
	endif
	ControlInfo/W=JMGizmoXYZSlicePanel popupGizmoWave
	objectName=S_Value
	if(cmpstr(objectName,"_none_")==0)
		return 0
	endif

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
//			Slice3DMatrixWaveFunc(objectName,g_JM_GizmoXYZSliceXYZ+1,JM_GSGetSlider(g_JM_GizmoXYZSliceXYZ),"","")
			Slice3DMatrixWaveFunc(objectName,g_JM_GizmoXYZSliceXYZ+1,JM_GSGetSlider(g_JM_GizmoXYZSliceXYZ),"")
			break
	endswitch

	return 0
End

Function JM_GSSelectXYZ(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	NVAR g_JM_GizmoXYZSliceXYZ
	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			g_JM_GizmoXYZSliceXYZ=popNum-1
			break
	endswitch

	return 0
End

Function JM_GSXYZSliceXYZset(index)
	Variable index
	
	switch (index)
		case 0:
			PopupMenu JM_GSXYZPopUp,win=JMGizmoXYZSlicePanel,popmatch="x"
			break
		case 1:
			PopupMenu JM_GSXYZPopUp,win=JMGizmoXYZSlicePanel,popmatch="y"
			break
		case 2:
			PopupMenu JM_GSXYZPopUp,win=JMGizmoXYZSlicePanel,popmatch="z"
			break
	endswitch	
End

Function JM_GSDisplayGizmoSlice(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	String cmd,wname,wnname
// If wave = _none_, do nothing
	ControlInfo/W=JMGizmoXYZSlicePanel popupGizmoWave
	wname=S_Value
	if(cmpstr(wname,"_none_")==0)
		return 0
	endif
	

	switch( ba.eventCode )
		case 2: // mouse up
			ControlInfo/W=JMGizmoXYZSlicePanel popupGizmoWin
			wnname=S_Value
			if(cmpstr(wnname,"_none_")==0)
				wnname=wname+"_Gizmo"
				JMGizmoShowXYZSlice(wname,wnname)
				Popupmenu popupGizmoWin win=JMGizmoXYZSlicePanel,popmatch=wnname
				DoWindow/F JMGizmoXYZSlicePanel
			else
				DoWindow/F $wnname
			endif
			JM_GIzmoXYZSlicePanelUpdate(wnname)
			break
	endswitch

	return 0
End
