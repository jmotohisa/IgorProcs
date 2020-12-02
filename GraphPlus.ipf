#pragma TextEncoding = "MacRoman"// Procedure GraphPlus// by J. Motohisa// Collection of useful macros to do vairious procedures to drawn graphs// version 0.01, July 13, 1998// version 0.02, Oct 25, 2004 : update comment line// version 0.03, Jan 31,2005 : Add macro "SetUnit" and "SetUnitAll"// 05/12/15 ver 0.04: macro "DrawHline" and "DrawVline" added//	ver 0.05	08/09/20: AutoYoffset modified usint TraceNameList function//	ver 0.06	13/05/22: DrawVLine and DrawHline become function//	ver 0.07	16/11/12: addHglines and addArlines added// Procedure for calculation of the band line-ups in heterostructures// based on Model Solid Theory (C. van de Walle, PRB 39, 1871 (1989).)//   note: This procedure is not compatible with previouis "ModelSolidTheory.ipf" //			because of the globals defined in the latter.////	05/12/01 ver. 0.1a by J. Motohisa////	revision history//		05/12/01 ver. 0.1a: first version#pragma rtGlobals=1		// Use modern global access method.#include <Strings as Lists>Macro WavesPlot(waveName,startindex,ncol,skip)// plot multiple waves//	String waveName	Variable ncol,startindex,skip=1	Prompt waveName, "Enter String that begin with"|,popup,WaveList("*",";","")	Prompt startindex,"starting index"	Prompt ncol,"Number of Waves"		Silent 1; PauseUpDate	Variable nrow		Variable index=0,index1=startindex	String wn	//	wn=waveName+num2istr(index1)//	nrow = numpnts($wn)//	if(WaveExists($matwName)==0)//		Duplicate $wn,$matwName//		Redimension /N=(nrow,ncol) $matwName//	endif	display	do		wn = waveName +num2str(index1)		Append $wn		if(WaveExists($wn)==0)			break		endif		index+=1		index1+=skip	while(index<ncol)End MacroProc Yoffset(offset,wname)	String wname	Variable offset	Prompt offset,"y-offset"	Prompt wname,"wave name",popup,WaveList("*",";","WIN:")	PauseUpdate; Silent 1		ModifyGraph offset($wname)={0,offset}End ProcMacro AutoYOffset(offset)	Variable offset	PauseUpdate; Silent 1		Variable index=0	String wl,w1		wl=TraceNameList("",";",1)	do//		w1=WaveName("",index,1)		w1=StringFromList(index,wl)		if(strlen(w1)==0)			break		endif		ModifyGraph offset($w1)={0,offset*index}		index+=1	while(1)EndMacroMacro AutoXYOffset(xoffset,yoffset)	Variable xoffset,yoffset	PauseUpdate; Silent 1		Variable index=0	String w1		do		w1=WaveName("",index,1)		if(strlen(w1)==0)			break		endif		ModifyGraph offset($w1)={xoffset*index,yoffset*index}		index+=1	while(1)EndMacroMacro InitializeYLogOffset()	Variable/G/D g_yLogOffset=1End MacroMacro AutoYLogOffset(offset)	Variable/D offset=1	PauseUpdate; Silent 1		Variable index=0	Variable oldoffset=g_yLogOffset	String w1		oldoffset = (offset/g_yLogOffset)	do		w1=WaveName("",index,1)		if(strlen(w1)==0)			break		endif		$w1 *= oldoffset^index//		ModifyGraph offset($w1)={0,offset*index}		index+=1	while(1)	g_yLogOffset = offsetEndMacroMacro AttachOrigToOfsWave(grname,wname,xmin,xmax)	String grname,wname	Variable xmin=0,xmax=5	Prompt grname,"Graph name",popup,WinList("*",";","WIN:1")	Prompt wname,"wave name to attach vertical origin",popup,WaveList("*",";","WIN:"+grname)	Prompt xmin,"from"	Prompt xmax,"to % of bottom axis"	PauseUpdate; Silent 1		Variable yoffset	String Yaxisname	xmin/=100;xmax/=100	yoffset=YoffsetOfWave("",wname,0)	Yaxisname=YAxisOfWave("",wname,0)//	print yoffset,Yaxisname,xmin,xmax	SetDrawEnv ycoord= $Yaxisname,save	DrawLine xmin,yoffset,xmax,yoffsetEndMacroMacro AttachOrigToAllWave(grname,xmin,xmax)	String grname	Variable xmin=0,xmax=5	Prompt grname,"Graph name",popup,WinList("*",";","WIN:1")	Prompt xmin,"from"	Prompt xmax,"to % of bottom axis"	PauseUpdate; Silent 1		Variable index=0	String wname	do		wname=WaveName(grname,index,1)		if(strlen(wname)==0)			break		endif		AttachOrigToOfsWave(grname,wname,xmin,xmax)		index+=1	while(1)EndMacro AttachTags()	PauseUpdate; Silent 1		Variable index=0	String w1,tagname		do		w1=WaveName("",index,1)		if(strlen(w1)==0)			break		endif		tagname="tg"+num2istr(index)		if(strsearch(AnnotationList(""),tagname,0)<0)			Tag/N=$tagname/F=0/L=1 $w1, pnt2x($w1,0),"\\ON"		endif		index+=1	while(1)EndMacroMacro AddLegend(graphname)	String graphname	Prompt graphname,"Graph name to add legend",popup,WinList("*",";","WIN:1")		PauseUpdate; Silent 1		string wlist ,sleg,w0//	wlist = = WaveList("*",";","WIN:"+graphname)	wlist = TraceNameList(graphname,";",1)	variable index=1	w0=GetStrFromList(wlist,0,";")	sleg ="\\s(" + w0 + ") " + w0	do		w0 = GetStrFromList(wlist,index,";")		if(strlen(w0)==0)			break		endif		sleg +="\r\\s(" + w0 + ") " + w0		index+=1	while(1)	if(strsearch(AnnotationList(w0), "leg0", 0)<0)		Legend/J/N=leg0/F=0/A=MC/X=37.13/Y=31.88 sleg	else		Legend/C/N=leg0/J/F=0/A=MC/X=37.13/Y=31.88 sleg	endifEnd MacroMacro AddLegend2(graphname,str)	String graphname	String str	Prompt graphname,"Graph name to add legend",popup,WinList("*",";","WIN:1")	PauseUpdate;Silent 1	string wlist 	String sleg,w0,w1	variable index=1		wlist= TraceNameList(graphname,";",1)//	wlist=WaveList("*",";","WIN:"+graphname)	w0=StringFromList(0,wlist,";")	if(CmpStr(str,"")==0)		w1=w0	else		w1=StringFromList(0,str,";")	endif	sleg ="\\s(" + w0 + ") " + w1	do		w0= StringFromList(index,wlist,";")		if(strlen(w0)==0)			break		endif		if(CmpStr(str,"")==0)			w1=w0		else			w1=StringFromList(index,str,";")		endif		sleg +="\r\\s(" + w0 + ") " + w1		index+=1	while(1)	if(strsearch(AnnotationList(w0), "leg0", 0)<0)		Legend/J/N=leg0/F=0/A=MC/X=37.13/Y=31.88 sleg	else		Legend/C/N=leg0/J/F=0/A=MC/X=37.13/Y=31.88 sleg	endifEnd Macro	Macro AddLegendAll()	PauseUpdate; Silent 1		String gwlist=WinList("*",";","WIN:1"),winname	Variable index=0	do		winname = GetStrFromList(gwlist,index,";")		if(strlen(winname)==0)			break		endif		DoWindow/F $winname		AddLegend(winname)		index+=1	while(1)End MacroMacro ScaleX(wname,factor)	String wname	Variable factor=1	Prompt wname,"wave name",popup,WaveList("*",";","WIN:")	Silent 1;PauseUpdate		Variable xmin=leftx($wname)*factor	Variable xmax=pnt2x($wname,numpnts($wname)-1)*factor	SetScale/I x,xmin,xmax,$wnameEnd MacroMacro ScaleXAll(factor,winname)	String winname	variable factor=1	Prompt winname,"Window name",popup,WinList("*",";","WIN:1")	Silent 1;PauseUpdate	Variable index=0	String wavename,waveslist=WaveList("*",";","WIN:"+winname)	do		wavename=GetStrFromList(WavesList,index,";")		if(strlen(wavename)==0)			break		endif		ScaleX(wavename,factor)		index+=1	while(1)End MacroMacro SetUnit(wname,xunit,yunit)	String wname,xunit,yunit	Prompt wname,"wave name",popup,WaveList("*",";","WIN:")	Prompt xunit,"unit of x"	Prompt yunit,"unit of y"	PauseUpdate;Silent 1		Variable xmin,xmax	if(strlen(xunit)>0)		xmin=leftx($wname)		xmax=pnt2x($wname,numpnts($wname)-1)		SetScale/I x,xmin,xmax,xunit,$wname		endif	if(strlen(yunit)>0)		SetScale d 0,1,yunit, $wname	endifEndMacro SetUnitAll(xunit,yunit,winname)	String winname,xunit,yunit	Prompt xunit,"unit of x"	Prompt yunit,"unit of y"	Prompt winname,"Window name",popup,WinList("*",";","WIN:1")	Silent 1;PauseUpdate	Variable index=0	String wavename,waveslist=WaveList("*",";","WIN:"+winname)	do		wavename=GetStrFromList(WavesList,index,";")		if(strlen(wavename)==0)			break		endif		SetUnit(wavename,xunit,yunit)		index+=1	while(1)End MacroMacro NormalizeAtCsrAinGraph(grname)	String grname	Prompt grname,"graph name",popup,winlist("*",";","WIN:1")	Silent 1; PauseUpdate	Variable c=pcsr(A),cy	String wv=TraceNameList(grname,";",1),wname	Variable index=0	do		wname=StringFromList(index,wv,";")		if(strlen(wname)==0)			break		endif		cy=$wname[c]		$wname/=cy		index+=1	while(1)EndMacro NormalizeAtCsrA()	Silent 1;PauseUpdate	String wname	Variable/D nrm	wname=CsrWave(A)	nrm=vcsr(A)	print wname,nrm	$wname/=nrmEndFunction DrawHline(yval)	Variable yval	PauseUpdate; silent 1	SetDrawEnv xcoord= prel,ycoord= left	DrawLine 0,yval,1,yvalEndFunction DrawVLine(xval)	Variable xval	PauseUpdate; silent 1	SetDrawEnv xcoord=bottom ,ycoord= prel	DrawLine xval,0,xval,1End// Add Hg lines (based on Oecan photonics website)//253.652nm、296.728nm、312.566nm、365.015nm、404.656nm、407.781nm、434.750nm、435.835nm、546.074nm、576.959nm、579.065nm、690.716nm、1013.98nmFunction AddHgLines()	DrawVline(253.652)	DrawVline(296.728)	DrawVline(302.150)//????	DrawVline(313.155)//???	DrawVline(334.148)//???	DrawVline(365.015)	DrawVline(404.656)	DrawVline(407.783)	DrawVline(435.833)	DrawVline(546.074)	DrawVline(576.960)	DrawVline(579.066)	DrawVline(1013.976)EndFunction AddArLines()	DrawVline(696.543)	DrawVline(706.722)	DrawVline(710.748)	DrawVline(727.294)	DrawVline(738.398)	DrawVline(750.387)	DrawVline(763.511)	DrawVline(772.376)	DrawVline(794.818)	DrawVline(800.616)	DrawVline(811.531)	DrawVline(826.452)	DrawVline(842.465)	DrawVline(852.144)	DrawVline(866.794)	DrawVline(912.297)	DrawVline(922.45)	DrawVline(965.7786)EndFunction VaxisAllLog(val)	Variable Val		String alist,ax,ax0	Variable index	alist=AxisList("")	index=0	do		ax=StringFromList(index,alist)		if(strlen(ax)==0)			break		endif		ax0=StringByKey("AXTYPE",AxisInfo("",ax))		if(stringmatch(ax0,"left")==1)			if(val<=0)				ModifyGraph log($ax)=0//				SetAxis $ax *,*			else				ModifyGraph log($ax)=1				SetAxis $ax val,*			endif		endif		index+=1	while(1)End