#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#include "MatrixOperations2"
#include "JMColorize"

// Procedures for fityk

// Data folder root:$(bwvname) is created
// Original data are duplicated into root:$(dfname)
// data are sort according to x-wave (wavelength or photon energy)
// $(wvname)_1 and $(bwvname)_eV2 are exported
// fev: 1...x is wavelengh (nm), 2...x is photon energy (eV)

Menu "Fityk"
	"Export data...",ExportforFityk()
	"Import peaks...",FitykImportAll()
	"Display fit results...",DisplayCurves_Fitykall()
	"Plot peaks...",DisplayPeaks_fityk()
	"initialize...",InitFitykProcs()
End

Proc InitFitykProcs(bname)
	String bname
	String/G g_bname=bname
End
 
// data exporter
Function FExportforFityk(bwvname,fev)
	String bwvname
	Variable fev
	
	String wvname=bwvname+"_1"
	String xwvname
	String suffix="++"
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
	Save/G/M="\r\n"/B wvlist as wvname+suffix+".txt"
// Save/G/M="\n"/W/P=home Wil79_eV2,Wil79_1_1,Wil79_1_2,Wil79_1_3 as "wil79/test.txt"

	SetDataFolder saveDataFolder
End

Function FExportforFityk2(path,bwvname,suf,fev,ffold)
	String path,bwvname,suf
	Variable fev,ffold
	
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
	String fname=wvname+suf+".txt"
	if(strlen(path)==0)
		Save/G/M="\r\n"/B wvlist as fname 
	else
		PathInfo $path
		if(V_flag==0) // invalid path
			Save/G/M="\r\n"/B wvlist as fname
		else // path exists, create directory under $path
			String temppath=S_path+":"+bwvname
			PathInfo $temppath
			if(V_flag==0)
				NewPath/C $temppath
			else
				NewPath $temppath
			endif
			Save/G/P=$temppath/M="\r\n"/B wvlist as fname
			KillPath $temppath
		endif
	endif
			
// Save/G/M="\n"/W/P=home Wil79_eV2,Wil79_1_1,Wil79_1_2,Wil79_1_3 as "wil79/test.txt"

	SetDataFolder saveDataFolder
End

// Data importer
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

Proc ImportFitykPeaksG(path,file,wvname,dfname,fShowTable)
	String path="home",file,wvname,dfname
	Variable fShowTable=2
	Prompt path,"path name"
	Prompt file,"file name"
	Prompt wvname,"base wave name"
	Prompt dfname,"data folder name"
	Prompt fShowTable,"show Table ?",popup,"yes;no"
	PauseUpdate;Silent 1

	print "number of peaks read: ",FImportFitykPeaksG(path,file,wvname,dfname,fShowTable)
End

// Display data
// display original and fitted curves
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
// AppendToGraph $wvHght vs $wvCent
// ModifyGraph mode($wvHght)=3
// ModifyGraph rgb($wvHght)=(0,0,0)
	endif
	
	SetDataFolder saveDataFolder
End

// Display peaks y vs x
Proc DisplayPeaks_fityk(bname,start,stop)
	String bname=g_bname
	Variable start,stop
	PauseUpdate; Silent 1
	
	g_bname=bname
	FDisplayPeaks_fityk(bname,start,stop)
End

Function FDisplayPeaks_fityk(bname0,start,stop)
	String bname0
	Variable start,stop
	
	String bname,dfname
	dfname=bname0
	bname=dfname+"_1"
	String saveDataFolder=GetDataFolder(1)
	SetDataFolder root:$(dfname)
	Variable index=start
	Display
	do
		FDisplayPeaks_fityk0(bname,dfname,index,2)
		index+=1
	while(index<=stop)
	ShowInfo
	
	SetDataFolder saveDataFolder
End

Function FDisplayPeaks_fityk0(bname,dfname,index,fdisp)
	String bname,dfname
	Variable fdisp // display;append;
	Variable index
	
	String saveDataFolder=GetDataFolder(1)
	SetDataFolder root:$(dfname)

	String wvCent="P"+bname+"_"+num2str(index)+"_c"
	String wvHght="P"+bname+"_"+num2str(index)+"_h"
	
	if(fdisp==1)
		Display
	Endif
	
	if(WaveExists($wvHght))
		AppendToGraph $wvHght vs $wvCent
		ModifyGraph mode($wvHght)=3
		ModifyGraph rgb($wvHght)=(0,0,0)
		ModifyGraph msize($wvHght)=8
	Endif
	
	SetDataFolder saveDataFolder
End

// Calculate curves
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
Function/S MakeACurve_Fityk_Gaussian(bname,index,xwv)
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
Proc ExportforFityk(bname,fev)
	String bname
	Variable fev=2
	Prompt bname,"base wave name to export"
	Prompt fev,"x axis",popup,"wavelength;photon energy"
	PauseUpdate; silent 1
	
	String/G g_bname=bname
	FExportforFityk(bname,fev)
End

// Fityk importer
Proc FitykImportAll(bname)
	String bname=g_bname
	Prompt bname,"base wave name to import"
	PauseUpdate; silent 1
	
	g_bname=bname
	FFitykImportAll(bname)
End

Function FFitykImportAll(bname)
	String bname
//	PauseUpdate; Silent 1
	
	String ipath,fname,ftype="????",fileList
//	String fpath="Macintosh HD:Users:motohisa:Documents:experiment:20170725:"
	Variable index=0,peaks,gotfile,n,npeaks
	
	GetFileFolderInfo/D/Q
	ipath=S_path
	print ipath
	NewPath/O fityk,ipath
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

// display fit results
Proc DisplayCurves_FitykAll(bname,start,stop)
	String bname=g_bname
	Variable start,stop
	Prompt bname,"base wave name"
	Prompt start, "starting curve index"
	Prompt stop, "ending curve index"
	PauseUpdate; Silent 1

	g_bname=bname
	FDisplayCurves_FitykAll(bname,start,stop)
End

Function FDisplayCurves_FitykAll(bname,start,stop)
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

Function FitykDupPeaks0(bname,index,idup)
	string bname
	Variable index,idup
	
	String saveDF=GetDataFolder(1)
	SetDataFolder root:$bname
	
	String wvname,wvname0,wvorig
	String wvType,wvCent,wvHght,wvArea,wvFWHM,wvPrms
	wvname="P"+bname+"_"+num2str(index)
	wvname0=wvname+"_"+num2str(idup)
//	String wvPrm1,wvPrm2,wvPrm3
	wvorig=wvname+"_T"; wvname0=wvorig+"_"+num2istr(idup);Duplicate/O $wvorig,$wvname0
	wvorig=wvname+"_c"; wvname0=wvorig+"_"+num2istr(idup);Duplicate/O $wvorig,$wvname0
	wvorig=wvname+"_h"; wvname0=wvorig+"_"+num2istr(idup);Duplicate/O $wvorig,$wvname0
	wvorig=wvname+"_a"; wvname0=wvorig+"_"+num2istr(idup);Duplicate/O $wvorig,$wvname0
	wvorig=wvname+"_w"; wvname0=wvorig+"_"+num2istr(idup);Duplicate/O $wvorig,$wvname0
	wvorig=wvname+"_prms"; wvname0=wvorig+"_"+num2istr(idup);Duplicate/O $wvorig,$wvname0

	SetDataFolder $saveDF
End

Function ArrangePeaks(bname,start,stop,imax)
	String bname
	Variable start,stop,imax
	
	// count number of peaks
	String orig0,dest,wvname
	Variable npeaks=0,n,index=start
	do
		orig0="P"+bname+"_"+num2istr(index)+"_c"
		n=DimSize($orig0,0)
		if(n>npeaks)
			npeaks=n
		endif
		index+=1
	while(index<=stop)

	wvname="P"+bname+"_peaks"
// initialize waves
	String wvType,wvCent,wvHght,wvArea,wvFWHM,wvPrms
	wvType=wvname+"_T"
	wvCent=wvname+"_c"
	wvHght=wvname+"_h"
	wvArea = wvname+"_a"
	wvFWHM = wvname+"_w"
	wvPrms=wvname+"_prms"
	Make/O/D/N=(stop+1,npeaks) $wvCent,$wvHght,$wvArea,$wvFWHM
	Make/T/O/D/N=(stop+1,npeaks) $wvType,$wvPrms
	Wave wwvCent=$wvcent
	Wave wwvHght=$wvHght
	Wave wwvArea=$wvArea
	Wave wwvFWHM=$wvFWHM
	Wave/T wwvType=$wvType
	Wave/T wwvPrms=$wvPrms
	wwvCent=NaN
	wwvHght=NaN
	wwvArea=NaN
	wwvFWHM=NaN
//	wwvType=""
//	wwvPrms=""

// substitution	
	index=start
	Variable npts
	do
		wvname="P"+bname+"_"+num2str(index)
		wvType=wvname+"_T"
		wvCent=wvname+"_c"
		wvHght=wvname+"_h"
		wvArea = wvname+"_a"
		wvFWHM = wvname+"_w"
		wvPrms=wvname+"_prms"
		Wave wvCent0=$wvCent
		Wave wvHght0=$wvHght
		Wave wvArea0=$wvArea
		Wave wvFWHM0=$wvFWHM
		npts=DimSize(wvCent0,0)
//		wwvCent[index][0,npts-1]=wvCent0[q*(DimSize(wvCent0,0)-1)/(DimSize(wwvCent,1)-1)]
		wwvCent[index][0,npts-1]=wvCent0[q]
		wwvHght[index][0,npts-1]=wvHght0[q]
		wwvArea[index][0,npts-1]=wvArea0[q]
		wwvFWHM[index][0,npts-1]=wvFWHM0[q]
		index+=1
	while(index<=stop)
	
// Display center
	FDisplayPeaks0(wvCent)
End

Function FDisplayPeaks0(wvname)
	String wvname
	
	Wave wwv=$wvname
	Variable index,npeaks
	npeaks=DimSize(wwv,1)
	Display
	Do
		AppendToGraph wwv[][index]
		index+=1
	while(index<npeaks)
	FJMColorize()
	ModifyGraph mode=4,marker=19
	
End

Function ArrangePeaksSub(orig,suffix,dest,index_orig,index_dest)
	String orig,suffix,dest
	Variable index_orig,index_dest
	
	String orig0=orig+"_"+suffix
	String dest0=dest+"_"+suffix
	Wave worig=$orig0
	Wave wdest=$dest0
	wdest[index_dest]=worig[index_orig]
end

Function FCheckPeakIndex(bname)
	String bname
	
	String bname0
	bname0=bname+"_1"
	FCheckPaekIndex0(bname0,bname)
	return 0
End

Function FCheckPaekIndex0(bname0,dfname)
	String bname0,dfname
	
	String saveDataFolder = GetDataFolder(1)
	SetDataFolder root:$(dfname)
	
	String bname="P"+bname0
	String wvlist=WaveList(bname+"*"+"_c",";","")
	
	Variable index=0,nlist,imin,imax
	nlist=ItemsInList(wvlist,";")
//	Print wvlist
	Print StringFromList(0,wvlist,";"),StringFromList(nlist-1,wvlist,";")
	SetDataFolder saveDataFolder
	return 0
End


// below can be replace by PickUpCsrPnt2
Function FInitArrangePeaks0(bname0,dfname,bnm_dest)
	String bname0,dfname,bnm_dest
	
	// dfindex: index of wave (data file)
	// cindex : index of curve in a wave
	// pindex : index of peak in a curve
	
	Variable/G g_aindex // peak index after arrangements
	String/G g_bnm=bnm_dest // base name for peaks
	String/G g_dfm=dfname // data set name
	Variable/G g_ipeak=0
	String bname="P"+bname0
	Variable dfindex,cindex,pindex
	
	String saveDF=GetDataFolder(1)
	SetDataFolder root:$dfname

	String wvCent,wvHght,wvFWHM,wvArea,wvPind,wvCind,wvWind
	wvCent=bnm_dest+"_c"
	wvHght=bnm_dest+"_h"
	wvFWHM=bnm_dest+"_w"
	wvArea=bnm_dest+"_a"
	wvPind=bnm_dest+"_iP"
	wvCind=bnm_dest+"_iC"
	wvWind=bnm_dest+"_iW"
	Make/O/D/N=1 $wvCent,$wvHght,$wvFWHM,$wvArea
	Make/O/N=1 $wvPind,$wvCind,$wvWind
	Wave wwvCent=$wvCent
	Wave wwvHght=$wvHght
	Wave wwvFWHM=$wvFWHM
	Wave wwvArea=$wvArea
	Wave wwvPind=$wvPind
	Wave wwvCind=$wvCind
	Wave wwvWind=$wvWind
	
	String ywv=Csrwave(A)
	String xwv=CsrXwave(A)
	String prefix="Wil"
	Variable sl1=strlen(prefix),sl=strlen(ywv)	
	pindex=pcsr(A)
	String s0=ywv[strlen(bname)+1,sl-1]
	cindex=str2num(StringFromList(0,ywv[strlen(bname)+1,sl-1],"_"))
	dfindex=str2num(dfname[sl1,sl-1])

	String bname00=bname+"_"+num2str(cindex)
	String wvFWHM0=bname00+"_w"
	String wvArea0=bname00+"_a"
	Wave wwvCent0=$xwv
	Wave wwvHght0=$ywv
	Wave wwvFWHM0=$wvFWHM0
	Wave wwvArea0=$wvArea0
	wwvHght[g_ipeak]=wwvHght0[pindex]
	wwvCent[g_ipeak]=wwvCent0[pindex]
	wwvFWHM[g_ipeak]=wwvFWHM0[pindex]
	wwvArea[g_ipeak]=wwvArea0[pindex]
	wwvPind[g_ipeak]=pindex
	wwvCind[g_ipeak]=cindex
	wwvWind[g_ipeak]=dfindex
	g_ipeak+=1
	
	AppendToGraph wwvHght vs WwvCent
	ModifyGraph mode($wvHght)=4,marker($wvHght)=19,msize($wvHght)=3,rgb($wvHght)=(65535,0,0)
	
	Edit wwvHght,wwvCent,wwvFWHM,wwvPind,wwvCind,wwvWind
	SetDataFolder saveDF
End

Function FInitArrangePeaksAppend0(bname0,dfname,bnm_dest)
	String bname0,dfname,bnm_dest

	NVAR g_ipeak

	String saveDF=GetDataFolder(1)
	SetDataFolder root:$dfname

	String bname="P"+bname0
	Variable dfindex,cindex,pindex
	String wvCent,wvHght,wvFWHM,wvArea,wvPind,wvCind,wvWind
	wvCent=bnm_dest+"_c"
	wvHght=bnm_dest+"_h"
	wvFWHM=bnm_dest+"_w"
	wvArea=bnm_dest+"_a"
	wvPind=bnm_dest+"_iP"
	wvCind=bnm_dest+"_iC"
	wvWind=bnm_dest+"_iW"
	Wave wwvCent=$wvCent
	Wave wwvHght=$wvHght
	Wave wwvFWHM=$wvFWHM
	Wave wwvArea=$wvArea
	Wave wwvPind=$wvPind
	Wave wwvCind=$wvCind
	Wave wwvWind=$wvWind
	
	String ywv=Csrwave(A)
	String xwv=CsrXwave(A)
	String prefix="Wil"
	Variable sl1=strlen(prefix),sl=strlen(ywv)	
	pindex=pcsr(A)
	String s0=ywv[strlen(bname)+1,sl-1]
	cindex=str2num(StringFromList(0,ywv[strlen(bname)+1,sl-1],"_"))
	dfindex=str2num(dfname[sl1,sl-1])
	
	String bname00=bname+"_"+num2str(cindex)
	String wvFWHM0=bname00+"_w"
	String wvArea0=bname00+"_a"
	Wave wwvCent0=$xwv
	Wave wwvHght0=$ywv
	Wave wwvFWHM0=$wvFWHM0
	Wave wwvArea0=$wvArea0
	Redimension/N=(g_ipeak+1) wwvCent,wwvHght,wwvFWHM,wwvArea,wwvPind,wwvCind,wwvWind
	wwvHght[g_ipeak]=wwvHght0[pindex]
	wwvCent[g_ipeak]=wwvCent0[pindex]
	wwvFWHM[g_ipeak]=wwvFWHM0[pindex]
	wwvArea[g_ipeak]=wwvArea0[pindex]
	wwvPind[g_ipeak]=pindex
	wwvCind[g_ipeak]=cindex
	wwvWind[g_ipeak]=dfindex
	g_ipeak+=1

	SetDataFolder saveDF

End

// assume peak format is P(dfindex)_(peakno)_{c;h;w;a;prms;T}

Function RetreivePeakIndexAll(dfindex,peakno)
	Variable dfindex,peakno
	
	String saveDF=GetDataFolder(1)
	String dfname="WiL"+num2str(dfindex)
	SetDataFolder root:$dfname
	
	String bname="P"+num2str(dfindex)+"_"+num2str(peakno)
	String wvname=bname+"_name"
	String wvCent=bname+"_c"
	String wvHght=bname+"_h"
	String wvFWHM=bname+"_w"
	String wvArea=bname+"_a"
	String wvWind=bname+"_Wi"
	String wvCind=bname+"_Ci"
	String wvPind=bname+"_Pi"
	
	Wave/T wwvn=$wvname
	String wvn
	Variable n=DimSize(wwvn,0),i
	Make/O/N=(n) $wvFWHM,$wvArea,$wvWind,$wvCind,$wvPind
	Wave wwvCent=$wvCent,wwvHght=$wvHght,wwvFWHM=$wvFWHM,wwvArea=$wvArea
	Wave wwvWind=$wvWind,wwvCind=$wvCind,wwvPind=$wvPind
	
	String prefix="PWil"+num2str(dfindex)+"_1"
	String wvArea_orig,wvFWHM_orig
	Variable cindex,pindex

	do
		wvn=wwvn[i]
//		height=wwvCent[i]
		cindex=RetrieveCindex(wvn,prefix)
		pindex=SeekPindexFromCH(wvn,wwvHght[i])

		wvArea_orig=prefix+"_"+num2str(cindex)+"_a"
		wvFWHM_orig=prefix+"_"+num2str(cindex)+"_w"
		Wave wwvA_orig=$wvArea_orig,wwvF_orig=$wvFWHM_orig
		if(pindex>=0)
			wwvFWHM[i]=wwvF_orig[pindex]
			wwvArea[i]=wwvA_orig[pindex]
		endif
		wwvWind[i]=dfindex
		wwvCind[i]=cindex
		wwvPind[i]=pindex

		i+=1
	while(i<n)

	SetDataFolder saveDF
End

// Wavname is format of : (prefix)_(cindex)_{c;h;w;a;T}
Function RetrieveCindex(wvname,prefix)
	String wvname,prefix
	
	String s=wvname[strlen(prefix),strlen(wvname)-1]
	return(str2num(StringFromList(1,s,"_")))
End

Function SeekPindexFromCH(wvCH,valCH)
	String wvCH
	Variable valCH
	
	Wave wv=$wvCH
	Variable eps=1e-9,n=DimSize(wv,0),i,ind=-1
	do
		if(abs(wv[i]-valCH)<eps)
			ind=i
		endif
		i+=1
	while(i<n)
	return ind
End

Function ShowArrangedPeakTable(dfindex,peakno)
	Variable dfindex,peakno

	String saveDF=GetDataFolder(1)
	String dfname="WiL"+num2str(dfindex)
	SetDataFolder root:$dfname
	
	String bname="P"+num2str(dfindex)+"_"+num2str(peakno)
	String wvname=bname+"_name"
	String wvCent=bname+"_c"
	String wvHght=bname+"_h"
	String wvFWHM=bname+"_w"
	String wvArea=bname+"_a"
	String wvWind=bname+"_Wi"
	String wvCind=bname+"_Ci"
	String wvPind=bname+"_Pi"
	
	Edit $wvname,$wvCent,$wvHght
	RetreivePeakIndexAll(dfindex,peakno)
	AppendToTable $wvFWHM,$wvArea,$wvWind,$wvCind,$wvPind

End

Function mergePeakInfo(bname,start)
	String bname
	Variable start
//	SVAR g_bname
	
	String saveDF=GetDataFolder(1)
	String dfname=bname
	SetDataFolder root:$dfname
	
	String pbname="P"+bname
	String wvname0,wvname=pbname+"_name"
	String wvcent0,wvCent=pbname+"_c"
	String wvHght0,wvHght=pbname+"_h"
	String wvFWHM0,wvFWHM=pbname+"_w"
	String wvArea0,wvArea=pbname+"_a"
//	String wvWind=pbname+"_Wi"
//	String wvCind=pbname+"_Ci"
//	String wvPind=pbname+"_Pi"
	Variable i,n0,ntot
	
	i=start
	ntot=0
	do
		wvcent0=pbname+"_"+num2istr(i)+"_c"
		if(waveExists($wvcent0)==1)
			ntot+=DimSize($wvcent0,0)
		else
			break
		endif
		i+=1
	while(1)	
//	print ntot
	Variable iend=i

	i=start
	Make/T/O/N=(ntot) $wvname
	Make/O/N=(0) $wvCent,$wvHght,$wvFWHM,$wvArea
	Wave/T wwvname=$wvname
	Wave wwvCent=$wvCent
	Wave wwvHght=$wvHght
	Wave wwvFWHM=$wvFWHM
	Wave wwvArea=$wvArea
	Edit wwvname,wwvCent,wwvHght,wwvFWHM,wwvArea
	
	Variable nstart=0,n
	do
		wvcent0=pbname+"_"+num2istr(i)+"_c"
		wvHght0=pbname+"_"+num2istr(i)+"_h"
		wvFWHM0=pbname+"_"+num2istr(i)+"_w"
		wvArea0=pbname+"_"+num2istr(i)+"_a"

		Wave wwvcent0=$wvCent0
		Wave wwvHght0=$wvHght0
		Wave wwvFWHM0=$wvFWHM0
		Wave wwvArea0=$wvArea0
		
		n=DimSize($wvcent0,0)
		print nstart,n
		wwvname[nstart,nstart+n-1]=bname+"_"+num2istr(i)
		Concatenate {wwvcent0},WwvCent
		Concatenate {wwvHght0},WwvHght
		Concatenate {wwvFWHM0},WwvFWHM
		Concatenate {wwvArea0},WwvArea

		nstart+=n
		i+=1
	while(i<iend)

	SetDataFolder saveDF
End

Function FilterMergedPeakInfo(bname,xmin,xmax,index)
	String bname
	Variable xmin,xmax,index
	
	String saveDF=GetDataFolder(1)
	String dfname=bname
	SetDataFolder root:$dfname
	
	String pbname="P"+bname
	String wvname0,wvname=pbname+"_name"
	String wvcent0,wvCent=pbname+"_c"
	String wvHght0,wvHght=pbname+"_h"
	String wvFWHM0,wvFWHM=pbname+"_w"
	String wvArea0,wvArea=pbname+"_a"
//	String wvWind=pbname+"_Wi"
//	String wvCind=pbname+"_Ci"
//	String wvPind=pbname+"_Pi"

	wvname0=pbname+"_P"+num2istr(index)+"_name"
 	wvcent0=pbname+"_P"+num2istr(index)+"_c"
	wvHght0=pbname+"_P"+num2istr(index)+"_h"
	wvFWHM0=pbname+"_P"+num2istr(index)+"_w"
	wvArea0=pbname+"_P"+num2istr(index)+"_a"
	
	Duplicate/O $wvname,$wvname0
	Duplicate/O $wvcent,$wvcent0
	Duplicate/O $wvHght,$wvHght0
	Duplicate/O $wvFWHM,$wvFWHM0
	Duplicate/O $wvArea,$wvArea0
	Wave/T wwvname0=$wvname0
	Wave wwvcent0=$wvCent0
	Wave wwvHght0=$wvHght0
	Wave wwvFWHM0=$wvFWHM0
	Wave wwvArea0=$wvArea0

	Edit wwvname0,wwvcent0, wwvHght0,wwvFWHM0,wwvArea0
	Variable n=DimSize(wwvcent0,0)
	Variable i
	do
		if(wwvcent0[i]<xmin || wwvcent0[i]>xmax)
			Deletepoints i,1, wwvname0
			DeletePoints i,1, wwvcent0
			DeletePoints i,1, wwvHght0
			DeletePoints i,1, wwvFWHM0
			DeletePoints i,1, wwvArea0
		else
			i+=1
		endif
	while(i<DimSize(wwvcent0,0))

	SetDataFolder saveDF
End
	