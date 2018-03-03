#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#include "MatrixOperations2"

// Procedures for fityk

// Data folder root:$(bwvname) is created
// Original data are duplicated into root:$(dfname)
// data are sort according to x-wave (wavelength or photon energy)
// $(wvname)_1 and $(bwvname)_eV2 are exported
// fev: 1...x is wavelengh (nm), 2...x is photon energy (eV)
 
Function FExportforFityk(bwvname,fev)
	String bwvname
	Variable fev
	
	String wvname=bwvname+"_1"
	String xwvname
	String saveDataFolder=GetDataFolder(1)
	NewDataFolder/O/S root:$(bwvname)
	
// x-axis data
	if(fev==2)
		xwvname=bwvname+"_eV2"
		String xwv0=bwvname+"_0"
		Duplicate/O root:$xwv0,$xwvname
		Wave xwv=$xwvname
		xwv=1239.8/xwv
		SetScale d 0,0,"eV", xwv
	else
		xwvname=bwvname+"_0"
		Duplicate/O root:$(xwvname),$xwvname
		Wave xwv=$xwvname
	endif

// y-axis data
	String wvlist,wvlist2
	If(WaveDims(root:$(wvname))==2)
		FmatrixAllToWavesDF(wvname)
		wvlist=xwvname+";"+SortList(WaveList(wvname+"_*",";",""),";",16)
		wvlist2=xwvname+","+SortList(WaveList(wvname+"_*",",",""),",",16)
	else
		Duplicate/O root:$wvname,$wvname
		wvlist=xwvname+";"+wvname
		wvlist2=xwvname+","+wvname
	endif

// sort	
	String cmd
	cmd="Sort "+xwvname+" "+wvlist2
	Execute cmd

// export
	Save/G/M="\r\n"/B wvlist as wvname+"++.txt"
// Save/G/M="\n"/W/P=home Wil79_eV2,Wil79_1_1,Wil79_1_2,Wil79_1_3 as "wil79/test.txt"

	SetDataFolder saveDataFolder
End

// import gaussian peak parameters
Function FImportFitykPeaksG(path,file,wvname,dfname,fShowTable)
	String path,file,wvname,dfname
	Variable fShowTable
	
	variable ref
	string ftype="*"
	if (strlen(file)<=0)
//		Open /D/R/F="*.peaks"/P=$path/T=(ftype) ref
		Open /D/R/F="*.peaks"/P=$path ref
		file= S_fileName
		print file
	endif

	if(strlen(wvname)==0)
		wvname="P"+wname(file)
	endif
	if(strlen(dfname)==0)
#ifdef MACINTOSH
		dfname=ParseFilePath(0, file, ":", 1, 1)
#else
		dfname=ParseFilePath(0, file, "//", 1, 1)
#endif
	endif
	
	String dfname0="root:"+dfname
	String dataFolderSave=GetDataFolder(1)
	NewDataFolder/O/S $dfname0
	Variable index=0
	String wvType,wvCent,wvHght,wvArea,wvFWHM,wvPrms
//	String wvPrm1,wvPrm2,wvPrm3
	wvType=wvname+"_T"
	wvCent=wvname+"_c"
	wvHght=wvname+"_h"
	wvArea = wvname+"_a"
	wvFWHM = wvname+"_w"
	wvPrms=wvname+"_prms"
//	wvPrm1=wvname+"_p1"
//	wvPrm2=wvname+"_p2"
//	wvPrm3=wvname+"_p3"
	Make/O/T $wvType,$wvPrms
	Make/O $wvCent,$wvHght,$wvArea,$wvFWHM
//	Make/O $wvPrm1,$wvPrm2,$wvPrm3
	Wave/T wwvType=$wvType
	Wave wwvCent = $wvCent
	Wave wwvHght = $wvHght
	Wave wwvArea = $wvArea
	Wave wwvFWHM = $wvFWHM
	Wave/T wwvPrms = $wvPrms
//	Wave wwvPrm1 = $wvPrm1
//	Wave wwvPrm2 = $wvPrm2
//	Wave wwvPrm3 = $wvPrm3

	String buffer,buff2
	Variable len
	Open /R/P=$path ref as file
// skip first line
	FReadLine ref,buffer
//
	do
		FReadLine ref,buffer
		len=strlen(buffer)
		if(len==0)
			break
		endif
		wwvType[index] = StringFromList(2,StringFromList(0,buffer,"\t")," ")
		WwvCent[index] = str2num(StringFromList(1,buffer,"\t"))
		wwvHght[index] = str2num(StringFromList(2,buffer,"\t"))
		wwvArea[index] = str2num(StringFromList(3,buffer,"\t"))
		wwvFWHM[index] = str2num(StringFromList(4,buffer,"\t"))
		buff2 = StringFromList(5,buffer,"\t")
		len=strlen(buff2)
		if (CmpStr(buff2[len-1],"\r") == 0)
			wwvPrms[index]=buff2[0,len-2]
		else
			wwvPrms[index]=buff2
		endif
//		wwvPrm1[index] = str2num(StringFromList(5,buffer,"\t"))
//		wwvPrm2[index] = str2num(StringFromList(6,buffer,"\t"))
//		wwvPrm3[index] = str2num(StringFromList(7,buffer,"\t"))
		index+=1
	while (1)
	Close ref
	index-=1
//	Print "number of peaks read: ",index
	Redimension/N=(index) wwvType,wwvPrms
	Redimension/N=(index) wwvCent,wwvHght,wwvArea,wwvFWHM
//	Redimension/N=(index) wwvCent,wwvHght,wwvArea,wwvFWHM,wwvPrm1,wwvPrm2,wwvPrm3
	
	Sort wwvCent wwvCent,wwvType,wwvHght,wwvArea,wwvFWHM,wwvPrms
//	Sort wwvCent wwvCent,wwvType,wwvHght,wwvArea,wwvFWHM,wwvPrm1,wwvPrm2,wwvPrm3
	if(fShowTable==1)
		Edit wwvType,wwvCent,wwvHght,wwvArea,wwvFWHM,wwvPrms
//		Edit wwvType,wwvCent,wwvHght,wwvArea,wwvFWHM,wwvPrm1,wwvPrm2,wwvPrm3
	Endif
	
	SetDataFolder dataFolderSave
	return index
End

Macro ImportFitykPeaksG(path,file,wvname,dfname,fShowTable)
	String path="home",file,wvname
	Variable fShowTable=2
	Prompt path,"path name"
	Prompt file,"file name"
	Prompt wvname,"base wave name"
	Prompt dfname,"data folder name"
	Prompt fShowTable,"show Table ?",popup,"yes;no"
	PauseUpdate;Silent 1

	print "number of peaks read: ",FImportFitykPeaksG(path,file,wvname,dfname,fShowTable)
End

Function DisplayCurves_Fityk(bname,dfname,xwv,orig,fdisp,axisindex)
	String bname,xwv,orig,dfname
	Variable fdisp // no;display;append;appendR;
	Variable axisindex
	
	String saveDataFolder=GetDataFolder(1)
	SetDataFolder root:$(dfname)

	Variable ncurvs	,index=0
	String axisname
	if(axisindex>0)
		if(fdisp==2 || fdisp==3)
			axisname="left"+num2str(axisindex)
		else
			if(fdisp==4)
				axisname="right"+num2str(axisindex)
			endif
		endif
	else
		if(fdisp==2 || fdisp==3)
			axisname="left"
		else
			if(fdisp==4)
				axisname="right"
			endif
		endif
	endif
	
	switch(fdisp)
		case 2:
			Display $orig vs $xwv
			break;
		case 3:
			AppendToGraph/L=$axisname $orig vs $xwv
			break;
		case 4:
			AppendToGraph/R=$axisname $orig vs $xwv
			break;
		default :
			break;
	endswitch
	ModifyGraph mode($orig)=3,marker($orig)=19
	ncurvs=MakeCurves_Fityk(bname,xwv,dfname)
	if(fdisp==2 || fdisp==3)
		Wave dest=$(bname+"_s_1")
		if(fdisp==2 || fdisp==3)
			AppendToGraph/L=$axisname dest vs $xwv
		else
			if(fdisp==4)
				AppendToGraph/R=$axisname dest vs $xwv
			endif
		endif
		ModifyGraph rgb($(bname+"_s_1"))=(0,0,0),lsize($(bname+"_s_1"))=2
		do
			Wave dest = $(bname+"_"+num2str(index)+"_1")			
			if(fdisp==2 || fdisp==3)
				AppendToGraph/L=$axisname dest vs $xwv
			else
				if(fdisp==4)
					AppendToGraph/R=$axisname dest vs $xwv
				endif
			endif
			ModifyGraph rgb($(bname+"_"+num2str(index)+"_1"))=(0,0,65535)
			index+=1
		while(index<ncurvs)
	endif
	
	SetDataFolder saveDataFolder
End

Function MakeCurves_Fityk(bname,xwv,dfname)
	String bname,xwv,dfname
	
	String saveDataFolder = GetDataFolder(1)
	SetDataFolder root:$(dfname)
	
	Variable index=0,ndat,ncrvs
	String wvname
	ndat=DimSize($xwv,0)
	Wave/T wvType=$("P"+bname+"_t")
	Make/N=(ndat)/D/O $(bname+"_s_1")
	Wave target = $(bname+"_s_1")
	target=0

	ncrvs=DimSize(wvType,0)
	do
		wvname=MakeACurve_Fityk_Gaussian(bname,index,xwv)
		Wave wtemp=$wvname
		target+=wtemp
		index+=1
	while(index<ncrvs)

	SetDataFolder saveDataFolder
	return(ncrvs)
End

// make single curves
Function/T MakeACurve_Fityk_Gaussian(bname,index,xwv)
	String bname,xwv
	Variable index
	
	Wave wvx=$xwv
	String target = bname+"_"+num2str(index)+"_1"
	Duplicate/O wvx,$target
	Wave wtarget=$target
	Wave wvCent=$("P"+bname+"_c")
	Wave wvHght=$("P"+bname+"_h")
	Wave wvFWHM=$("P"+bname+"_w")
	wtarget = wvHght[index]*exp(-ln(2)*((wvx-wvCent[index])/wvFWHM[index]*2)^2)

	return(target)
End

// Procedures/Macros
Proc ExportforFityk(bwvname,fev)
	String bwvname
	Variable fev=2
	Prompt bwvname,"base wave name to export"
	Prompt fev,"x axis",popup,"wavelength;photon energy"
	PauseUpdate; silent 1
	
	FExportforFityk(bwvname,fev)
End

// Fityk importer
Function FFitykImportAll(bname)
	String bname
//	PauseUpdate; Silent 1
	
	String ipath,fname,ftype="????",fileList
//	String fpath="Macintosh HD:Users:motohisa:Documents:experiment:20170725:"
	Variable index=0,peaks,gotfile,n,npeaks
	
	GetFileFolderInfo/D/Q
	ipath=S_path
	NewPath/O fityk,S_path
	if(V_flag==0)
		fileList = SortList(IndexedFile(fityk,-1,ftype),";",16)		// get name of next file in path
		n=ItemsInList(fileList,";")
		do
			fname=StringFromList(index,fileList,";")
			peaks = CmpStr(ParseFilePath(4, fname, ":", 0, 0),"peaks",0)
			if(peaks==0)
				npeaks=FImportFitykPeaksG("fityk",fname,"",bname,2)
				Print "file name: ", fname, ", number of peaks read: ",npeaks
			endif
			index+=1
		while(index<n)
	endif
End

Macro DisplayCurves_FitykAll(bname,start,stop)
	String bname
	Variable start,stop
	PauseUpdate; Silent 1
	
	String xwv,ywv
	Variable index=start
	Variable index0=0
	String laxis
	Variable vwidth=floor(100/(stop-start+1))/100
	xwv=bname+"_eV2"
	do
		ywv=bname+"_1_"+num2istr(index)
		if(index0==0)
			DisplayCurves_Fityk(ywv,bname,xwv,ywv,2,index0)
			ModifyGraph axisEnab(left)={0,vwidth}
		else
			DisplayCurves_Fityk(ywv,bname,xwv,ywv,3,index0)
			laxis="left"+num2istr(index0)
			ModifyGraph freePos($laxis)=0
			ModifyGraph axisEnab($laxis)={vwidth*index0,vwidth*(index0+1)}
		endif
		index+=1
		index0+=1
	while(index<=stop)
End

// root:$(Mat) -> $(Mat)_index in the current data folder 
Function FMatrixToWavesDF(Mat,index)
	String Mat
	Variable index
	
	Wave wmat=root:$(Mat)
	String wv
	Variable nrs=DimSize(wmat,0),ncs=DimSize(wmat,1)
	if(index<ncs)
		wv=Mat+"_"+num2str(Index)
		Make/O/N=(nrs) $(wv)
		Wave wwv=$(wv)
		CopyScales wmat,wwv
		wwv[] = wmat[p][Index]
	endif
End

Function FmatrixAllToWavesDF(Mat)
	String Mat
	Variable ncs=DimSize(root:$(Mat),1)
	Variable index=0
//	print nrs,ncs,lrs,lcs
	do
		FMatrixToWavesDF(Mat,index)
		index += 1
	while (Index < ncs)
End