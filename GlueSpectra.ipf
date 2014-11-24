#pragma rtGlobals=1		// Use modern global access method.
#include "ModifyWaves"

// GlueSpectra.ipf
//	Glue multiple spectra
//	11/02/27 ver. 0.1a by J. Motohisa
//
//	revision history
//		12/02/13 ver 0.1b: error in creating data folder fixed, Macro "AutoGlueSpectraFromTmpnm" added
//		11/02/27	ver 0.1a first version

Macro GlueSpectraInGraph(grname,dest,res,flag)
	String grname,dest="glued"
	Variable res=0.2,flag=2
	Prompt grname,"Graph Name",popup,WinList("*",";","WIN:1")
	Prompt dest,"Destination file name"
	Prompt res,"Resolution"
	Prompt flag,"append glued spectra to graph",popup,"yes;no"
	PauseUpdate; Silent 1
	
	Variable ret
	ret=GlueSpectraInGraphFunc(grname,dest,res)
	// error check
	if(ret == 1)
		Print "GlueSpectra Error : no overlap in some of the spectra"
	endif

	if(ret==0 && flag==1)
		DoWindow/F $grname
		Append $dest
		ModifyGraph rgb($dest)=(0,0,65535)
	endif
End

Macro GlueSpectraInListInWave(wvname,dest,xsuffix,ysuffix,res,flag)
	String wvname,dest,xsuffix="0",ysuffix="1"
	Variable res,flag=1
	Prompt wvname,"Name of a wave containts wave list to glue spectra"
	Prompt dest,"destination wave name"
	Prompt res,"Resolution"
	Prompt flag,"Display glued spectra ?",popup,"yes;no;with original spectra"
	PauseUpdate; Silent 1
	
End

Macro AutoGlueSpectraFromTmpnm(wn_tmpwv,wn_datawv,wn_destwvlist,destwv_prefix,flag_display,res,flag,numright)
	String wn_tmpwv="tmpnm",wn_datawv="data0"
	String wn_destwvlist="toGlue",destwv_prefix="GluedSpectra"
	Variable flag_display,res=0.4,flag=1,numright=4
	Prompt wn_tmpwv,"tmpwv name"
	Prompt wn_datawv,"data set name"
	Prompt wn_destwvlist,"wave name of the list"
	Prompt destwv_prefix,"prefix for glued wave name"
	Prompt flag_display,"display spectra (always)"
	Prompt res,"Resolution"
	Prompt flag,"append glued spectra to graph",popup,"yes;no"
	Prompt numright,"number of chars to ignore from list in tmpwv"
	PauseUpdate; Silent 1
	
	Variable n=DimSize($wn_tmpwv,0),i=0,j,k
	String wn0,wn_data,wn_base,wn_base_prev="",wn_dest,wnlist="",dest
	
// create list of wave starting with same name
	j=-1
	do
		wnlist=""
		wn0=$wn_tmpwv[i]
		wn_data=$wn_datawv[i]
		wn_base=wn0[0,strlen(wn0)-numright-1]
		if(j==-1 || cmpstr(wn_base,wn_base_prev)!=0)
			j+=1
			k=0
			wn_dest=wn_destwvlist+num2str(j)
			dest=destwv_prefix+num2str(j)
			Make/O/T/N=1 $wn_dest
			print "seriese ", wn_base,"is stored into wave ",wn_dest, " and  is going to glued into ",dest
			$wn_dest[k]=wn_data
		else
			k+=1
			ReDimension/N=(k) $wn_dest
			$wn_dest[k-1]=wn_data
		endif
		wn_base_prev=wn_base	
		i+=1
	while(i<n)

	n=j+1
	i=0
// Display spectra and glue
	String gluewvlist,winnameglue
	do
		gluewvlist=wn_destwvlist+num2str(i)
		k=DimSize($gluewvlist,0)
		if(k>1)
			PlotWavesInDataSet(wn_destwvlist,i,"1","0")
			DoUpdate
			winnameglue="gluedGraph"+num2str(i)
			dest=destwv_prefix+num2str(i)
			DoWindow/C $winnameglue
			GlueSpectraInGraph(winnameglue,dest,res,flag)
		endif
		i+=1
	while(i<n)
End

Function GlueSpectraInGraphFunc(grname,dest,res)
	String grname,dest
	Variable res
	
	String trlistwave=TraceNameList(grname,";",1)
	String xwave,ywave,temp,tempdest="temp"+dest
	Variable i,nlist,ret,num
	DFREF saveDFR = GetDataFolderDFR()
	if(! DataFolderExists("root:Packages"))
		NewDataFolder root:Packages
	Endif
	if(! DataFolderExists("root:Packages:GlueSpectra"))
		NewDataFolder/O root:Packages:GlueSpectra
	Endif
	
	// linearize all spectra in a graph
	i=0
	do
		ywave=StringFromList(i, trlistwave ,";")
		if(strlen(ywave)==0)
			break;
		endif
		xwave=XWaveName(grname,ywave)
		temp="temp"+num2istr(i)
		if(strlen(xwave)!=0)
			LinearizeSpectrum(xwave,ywave,temp,"",res)
		else // make temp wave with resolution res, assume it is linearized or waveform data
			SetDataFolder root:Packages:GlueSpectra
			num=floor(DimSize(root:$ywave,0)*abs(DimDelta(root:$ywave,0))/res+0.5)
			Interpolate2/Y=$temp/N=(num) root:$ywave
			SetDataFolder saveDFR
		endif
		i+=1
	while(1)
	nlist=i
	if(nlist<=1)
		return(-1) // only one wave in a graph, cannot glued
	endif
	
	SetDataFolder root:Packages:GlueSpectra
	Wave destw=$dest
	GlueSpectraFunc(dest,nlist)
	SetDataFolder saveDFR
	Duplicate/O destw,saveDFR:$dest
	
	return(0)
End

Function GlueSpectraFunc(dest,nlist)
	String dest
	Variable nlist

	Variable i,ret
	Make/O $dest
	Wave destw=$dest
	Wave tempdestw=$("temp"+num2istr(0))
	Wave ywv2=$("temp"+num2istr(1))
	i=1
	do
		ret=GlueSpectra2(tempdestw,ywv2,dest)
		if(ret!=0)
			SetDataFolder saveDFR
			return(1) // gluing unsuccessful
		endif
		i+=1
		if(i >= nlist)
			break
		endif
		Duplicate/O destw,tempdestw
		Wave ywv2=$("temp"+num2istr(i))
	while(1)
	
	return(0)
End

Function GlueSpectra(origwvlistwv,destwv,start,stop,res)
	Wave origwvlistwv,destwv
	Variable start,stop,res
	
	DFREF saveDFR = GetDataFolderDFR()
	Variable i,n
	Wave ywv
	String xwvst
	
	n=round(start-stop)/res+1
	Make/O/N=(n) dest
	SetScale/I x start,stop,"nm",dest

	NewDataFolder/O/S root:Packages:GlueSpectra

	// linearize each spectra
	n=numpnts(origwavelistwv)
	i=0
	do
		ywv=origwvlistwv[i]
		xwvst=NameOfWave(ywv)
		i+=1
	while(i<n)
	SetDataFolder saveDFR
End

// glue two spectra: x-points of both ywv1 and ywv2 are assmed to be linearlized
Function GlueSpectra2(ywv1,ywv2,dest0)
	Wave ywv1,ywv2
	String dest0
	
	Variable x1l,x1r,x2l,x2r,xstart,xend,dx1,dx2
	Variable nd

	dx1=DimDelta(ywv1,0)
	dx2=DimDelta(ywv2,0)
	if(abs(dx1-dx2)>1e-3)
		printf "resolution does not much for two waves ", NameOfWave(ywv1)," and ",NameOfWave(ywv2)
		print "delta=",dx1,dx2
		return(-1) // error
	endif
	
	x1l=DimOffset(ywv1,0)
	x1r=DimOffset(ywv1,0)+dx1*(numpnts(ywv1)-1)
	x2l=DimOffset(ywv2,0)
	x2r=DimOffset(ywv2,0)+DimDelta(ywv2,0)*(numpnts(ywv2)-1)
	if(x1l<x2l && x2l<x1r)
		GlueSpectra2sub1(ywv1,ywv2,dest0)
	else
		if(x2l< x1l && x1l<x2r)
			GlueSpectra2sub1(ywv2,ywv1,dest0)
		else
			if(x1l<x2l && x2r<x1r)
				GlueSpectra2sub1(ywv1,ywv2,dest0)
			else
				if(x2l<x1l && x1r<x2r)
					GlueSpectra2sub2(ywv2,ywv1,dest0)
				else
					return(-1) // error due to no overlap
				endif
			endif
		endif
	endif
	return(0)
End

// xl1 < xl2 < xr1 <  xr2
Function GlueSpectra2sub1(ywv1,ywv2,dest0)
	Wave ywv1,ywv2
	String dest0

	Variable x1l,x1r,x2l,x2r,xstart,xend,dx1,dx2
	Variable nd,no,n1,n2,i

	dx1=DimDelta(ywv1,0)
	dx2=DimDelta(ywv2,0)
	n1=numpnts(ywv1)
	n2=numpnts(ywv2)	
	x1l=DimOffset(ywv1,0)
	x1r=DimOffset(ywv1,0)+dx1*(n1-1)
	x2l=DimOffset(ywv2,0)
	x2r=DimOffset(ywv2,0)+dx2*(n2-1)
	xstart=x1l
	xend=x2r
	nd=floor((xend-xstart)/dx1+0.5)+1
	Make/O/N=(nd) $dest0
	Wave dest=$dest0
	SetScale/I x,xstart,xend,"nm",dest
	
	no=n1+n2-nd
	dest=ywv1
	i=0
	do
		dest[n1-no+i]=dest[n1-no+i]*(1-(i+1)/(no+1))+ywv2[i]*(i+1)/(no+1)
		i+=1
	while(i<no)
	i=no
	do
		dest[n1-no+i]=ywv2[i]
		i+=1
	while(i<n2)
End

// xl1 < xl2 < xr2 <  xr1
Function GlueSpectra2sub2(ywv1,ywv2,dest0)
	Wave ywv1,ywv2
	String dest0

	Variable x1l,x1r,x2l,x2r,xstart,xend,dx1,dx2
	Variable nd,no,n1,n2,i
	Wave dest=$dest0

	dx1=DimDelta(ywv1,0)
	dx2=DimDelta(ywv2,0)
	n1=numpnts(ywv1)
	n2=numpnts(ywv2) // should be n1>n2
	x1l=DimOffset(ywv1,0)
	x1r=DimOffset(ywv1,0)+dx1*(n1-1)
	x2l=DimOffset(ywv2,0)
	x2r=DimOffset(ywv2,0)+dx2*(n2-1)
	xstart=x1l
	xend=x1r
	nd=floor((xend-xstart)/dx1+0.5)+1
	Make/O/N=(n1) dest
	SetScale/I x,xstart,xend,"nm",dest
	
	no=n1+n2-nd
	dest=ywv1
	i=0
	do
		dest[n1-no+i]=dest[n1-no+i]*(1-i/(no+1))+ywv2[i]*(i)/(no+1)
		i+=1
	while(i<=no)
	i=no+1
	do
		dest[n1-no+i]=ywv2[i]
		i+=1
	while(i<n2)
End

// linearize x-points of spectra
Function LinearizeSpectrum(xwv,ywv,dest,calibwv,res)
	String xwv,ywv,dest,calibwv
	Variable res
	
	Variable i,j,nw,xwstart,xwend,xdstart,xdend,nd,xd
	DFREF saveDFR = GetDataFolderDFR()
	Wave xwv0=saveDFR:$xwv,ywv0=saveDFR:$ywv
	Variable xdl,xdr,il,ir,ii,iii
//	Wave destwv=$dest
	
	SetDataFolder root:Packages:GlueSpectra
	nw=numpnts(xwv0)
	xwstart=xwv0[0]+res/2
	xwend=xwv0[nw-1]-res/2
	xdstart=ceil(xwstart/res)*res
	xdend=floor(xwend/res)*res
	nd=floor(xwend/res)-ceil(xwstart/res)+1
	Make/O/N=(nd) $dest
	Wave destwv=$dest
	SetScale/I x xdstart,xdend,"nm",destwv
	
	CreateXLXRwave(xwv0,calibwv)
	Wave xlwave,xrwave
// serach for xl
	i=0
	j=0
	do
		xd=DimOffset(destwv,0)+j*DimDelta(destwv,0)
		xdl=xd - res/2
		xdr=xd + res/2
		ii=i
		do
			if(xlwave[ii] <= xdl && xdl <= xrwave[ii])
				il=ii
				i=ii
			endif
			if(xlwave[ii] <=xdr && xdr <=xrwave[ii])
				ir=ii
				break
			endif
			ii+=1
		while(1)
		if(il==ir)
			destwv[j]=ywv0[il]*res/(xrwave[il]-xlwave[il])
		else
			destwv[j]=(xrwave[il]-xdl)/(xrwave[il]-xlwave[il])*ywv0[il]+(xdr-xlwave[ir])/(xrwave[ir]-xlwave[ir])*ywv0[ir]
			iii=il+1
			do
				if(iii>=ir)
					break
				endif
				destwv[j]+=ywv0[iii]
				iii+=1
			while(1)
		endif
		j+=1
	while(j<nd)
	
	SetDataFolder saveDFR
End

// create waves for xl and xr: data folder is assumed to be root:Packages:GlueSpectra
Function CreateXLXRwave(xwv0,calibwv)
	Wave xwv0
	String calibwv
	
	Variable i,nw=numpnts(xwv0)
	Duplicate/O xwv0,xlwave,xrwave
//	Wave xlwave,xrwave
	if(strlen(calibwv)>0 && WaveExists($calibwv))
		xlwave=poly($calibwv, x-1/2)
		xrwave=poly($calibwv, x+1/2)
	else
		i=0
		do
			if(i==0)
				xlwave[i]=xwv0[0]-(xwv0[1]-xwv0[0])/2
			else
				xlwave[i]=(xwv0[i]+xwv0[i-1])/2
			endif
			if(i==nw-1)
				xrwave[i]=xwv0[nw-1]+(xwv0[nw-1]-xwv0[nw-2])/2
			else
				xrwave[i]=(xwv0[i]+xwv0[i+1])/2
			endif
			i+=1
		while(i<nw)
	endif
End


