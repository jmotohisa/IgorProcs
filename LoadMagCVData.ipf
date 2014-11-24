#include <Strings as Lists>Macro LoadMagCVData(dtype,fileName,pathName,index,wantToDisp)	Variable dtype=1	String fileName	String pathName="home"	Variable index=-1,wantToDisp=1	Prompt dtype,"measurement type",popup,"C-V;C-B"	Prompt wantToDisp, "Do you want to display graphs?", popup, "Yes;No"	Silent 1; PauseUpDate		String xwaven,B,Vg,cap,loss	String SIndex	Variable ref		if (strlen(fileName)<=0)		Open /D/R/P=$pathName/T="sGBWTEXT" ref		fileName= S_fileName	endif		LoadWave/G/D/A/W/P=$pathName fileName	if(V_flag==0)		return	endif		xwaven = GetStrFromList(S_waveNames,0,";")	cap = GetStrFromList(S_waveNames,1,";")	loss = GetStrFromList(S_waveNames,2,";")		if(index<0)		SIndex = wname(fileName)	else		Sindex = num2istr(index)	endif	B="B" + SIndex	Vg = "V" + SIndex	Sort $xwaven, $xwaven, $cap,$loss	if(dtype==1) 		WaveStats $xwaven		SetScale/I x,V_min,V_max,"V",$cap,$loss		SetScale y,0,1,"V",$xwaven	|	KillWaves $xwaven		Rename $xwaven,$Vg	else		SetScale y,0,1,"T",$xwaven		Rename $xwaven,$B	endif		SetScale y,0,1,"F",$cap	SetScale y,0,1,"S",$loss	Rename $cap,$("C" + SIndex)	Rename $loss,$("G" +SIndex)	if(wantToDisp ==1)		if(dtype==1)			Display_CV2(Vg)		else			Display_CB2(B)		endif		Textbox/C/N=tb_file/F=0/A=MT/X=-30/Y=5 "File: "+SIndex	endifEndMacro LoadMagCVDataAll(dtype,pathName,wantToDisp,startindex)	Variable dtype=1	String pathName="_New Path_"	Variable wantToDisp=1,startindex=0	Prompt dtype,"measurement type",popup,"C-V;C-B"	Prompt pathName, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"	Prompt wantToDisp, "Do you want to display graphs?", popup, "Yes;No"	Prompt startindex,"starting index"		Silent 1; PauseUpDate		String fileName|	String ftype="sGBW"	String ftype="TEXT"	Variable index		if (CmpStr(PathName, "_New Path_") == 0)		| user selected new path ?		NewPath/O data			| this brings up dialog and creates or overwrites path		PathName = "data"	endif		do		fileName = IndexedFile($pathName, index,ftype)		if(strlen(fileName)==0)			break		endif|		LoadCVData(fileName,pathName,index+startindex,wantToDisp)		LoadMagCVData(dtype,fileName,pathName,-1,wantToDisp)|		if(strlen(S_waveNames)>0)|		endif		index +=1	while(1)		if(Exists("temporaryPath"))		KillPath temporaryPath	endifEndMacro Display_CV(index)	Variable index	PauseUpdate;PauseUpDate	String  Vol,cap,loss		Vol = "V"+num2istr(index)	Cap = "C"+num2istr(index)	loss = "G"+num2istr(index)		Display /W=(5,42,400,250) $Cap vs $Vol	Append/R $loss vs $Vol	ModifyGraph lStyle($loss)=1	ModifyGraph rgb($loss)=(0,0,65535)	ModifyGraph tick=2	ModifyGraph mirror(bottom)=1	ModifyGraph standoff=0	Label left "Capacitance C (\\U)"	Label bottom "Bias Voltage  V (\\U)"	Label right "Loss G (\\U)"EndMacroMacro Display_CB(index)	Variable index	PauseUpdate;PauseUpDate	String  B,cap,loss		B = "B"+num2istr(index)	Cap = "C"+num2istr(index)	loss = "G"+num2istr(index)		Display /W=(5,42,400,250) $cap vs $B	Append/R $loss vs $B	ModifyGraph lStyle($loss)=1	ModifyGraph rgb($loss)=(0,0,65535)	ModifyGraph tick=2	ModifyGraph mirror(bottom)=1	ModifyGraph standoff=0	Label left "Capacitance C (\\U)"	Label bottom "Bias Voltage  V (\\U)"	Label right "Loss G (\\U)"EndMacroMacro Display_CV2(Vwave)	String vwave	Prompt Vwave,"Vg wave name",popup,WaveList("V*",";","")	PauseUpdate;PauseUpDate	String Vol,cap,loss,SIndex		SIndex = Vwave[1,strlen(Vwave)-1]		Vol = Vwave	Cap = "C"+SIndex	loss = "G"+SIndex		Display /W=(5,42,400,250) $Cap vs $Vol	Append/R $loss vs $Vol	ModifyGraph lStyle($loss)=1	ModifyGraph rgb($loss)=(0,0,65535)	ModifyGraph tick=2	ModifyGraph mirror(bottom)=1	ModifyGraph standoff=0	Label left "Capacitance C (\\U)"	Label bottom "Bias Voltage  V (\\U)"	Label right "Loss G (\\U)"EndMacroMacro Display_CB2(Bwave)	String Bwave	Prompt Bwave,"B wave name",popup,WaveList("B*",";","")	PauseUpdate;PauseUpDate	String  B,cap,loss,SIndex		SIndex = Bwave[1,strlen(Bwave)-1]		B = Bwave	Cap = "C"+Sindex	loss = "G"+Sindex		Display /W=(5,42,400,250) $cap vs $B	Append/R $loss vs $B	ModifyGraph lStyle($loss)=1	ModifyGraph rgb($loss)=(0,0,65535)	ModifyGraph tick=2	ModifyGraph mirror(bottom)=1	ModifyGraph standoff=0	Label left "Capacitance C (\\U)"	Label bottom "Bias Voltage  V (\\U)"	Label right "Loss G (\\U)"EndMacro