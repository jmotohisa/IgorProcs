#pragma rtGlobals=1		// Use modern global access method.// DataSetOperations.ipf// by J. Motohisa// ver 0.2a:	13/06/15:	Some of the Proc and global names are modified to start with DSO// ver 0.1a: 12/04/07: some macros are rewritten for functions// ver 0.01c: 11/07/08 slight modification to escape from error// ver 0.01b: 04/10/03 bug removed// ver 0.01a: 04/03/14 first commitment//#include <Strings as Lists>#include "wname"Macro InitDataSetOperations(dsetnm)	String dsetnm="data"	PauseUpdate; Silent 1// initialize global variables	if(strsearch(StringList("*", ";"),"g_DSOname",0)<0)//		SVAR g_DSO_name		String/G g_DSOname	endif	if(strsearch(VariableList("*", ";",0),"g_DSOindex",0)<0)//		NVAR g_DSOindex		Variable/G g_DSOindex	endif	// initialize data set name prefix and index	if(strlen(dsetnm)==0)		dsetnm="data"	endif	g_DSOname=dsetnm	g_DSOindex=DSOscanDSindex()	DSODisplayTable(dsetnm)//	EditEndFunction DSOinitFunc(dsetnm,prefix,suffixlist)	String dsetnm,prefix,suffixlist	String/G g_DSO_name	String/G g_DSO_prefix	String/G g_DSO_suffixlist	Variable/G g_DSOindex	if(strlen(dsetnm)==0)		dsetnm="data"	endif//	if(strlen(prefix)==0)//		prefix="W"//	endif	g_DSO_name=dsetnm	g_DSO_prefix=prefix	g_DSO_suffixlist=g_DSO_suffixlist	g_DSOindex=DSOscanDSindex()	DSODisplayTable(dsetnm)EndMacro DSOInit(dsetnm,prefix,suffixlist)	String dsetnm="data",prefix="W",suffixlist=""	PauseUpdate; Silent 1//	DSOinitFunc(dsetnm,prefix,suffixlist)// initialize global variables	if(strsearch(StringList("*", ";"),"g_DSO_name",0)<0)//		SVAR g_destnum		String/G g_DSO_name	endif	if(strsearch(StringList("*", ";"),"g_DSO_prefix",0)<0)//		SVAR g_destnum		String/G g_DSO_prefix	endif	if(strsearch(StringList("*", ";"),"g_DSO_suffixlist",0)<0)//		SVAR g_destnum		String/G g_DSO_suffixlist	endif		if(strsearch(VariableList("*", ";",4),"g_DSOindex",0)<0)//		NVAR g_DSOindex		Variable/G g_DSOindex	endif// initialize data set name prefix and index	if(strlen(dsetnm)==0)		dsetnm="data"	endif	if(strlen(prefix)==0)		prefix="W"	endif	g_DSO_name=dsetnm	g_DSOindex=DSOscanDSindex()	DSODisplayTable(dsetnm)End// Formarly DSOChangeDSBaseNameFunction DSOChangeDSBaseName(dsetnm)	String dsetnm	SVAR g_DSO_name	g_DSO_name=dsetnmend// formerly DisplayDataSetTableFunction DSODisplayTable(dsetnm)	String dsetnm		If(strlen(WinList("DataSetTable",";",""))==0)			Edit		DoWindow/C DataSetTable	else		DoWindow/F DataSetTable	endif	if(WaveExists($dsetnm))		AppendToTable $dsetnm	endifEnd// formerly CreateDataSet0Function DSOCreate0(index,overwrite)	Variable index,overwrite	Prompt index, "enter index"	Prompt overwrite,"overwrite existing data set ?",popup "yes;no"	PauseUpdate;Silent 1		Variable i0	String ds	SVAR g_DSO_name	NVAR g_DSOindex	if(overwrite==1) // do not overwrite		i0=DSOscanDSindex()		ds=g_DSO_name+num2istr(i0)		Make/N=2000/T $ds	else		ds=g_DSO_name+num2istr(index)		i0=index		Make/N=2000/T/O $ds	endif	DoWindow/F DataSetTable	AppendToTable $ds	g_DSOindex+=1	return (i0)End// formerly ScanDataSetIndexFunction DSOscanDSindex()	SVAR g_DSO_name	String s,s0	Variable i0=0	s=WaveList(g_DSO_name+"*",";","")	do		s0=StringFromList(i0,s,";")		if(strlen(s0)==0)			break		endif		if(stringmatch(s0,g_DSO_name+num2istr(i0))==0)			break		endif		i0+=1	while(1)	return(i0)End// Plot waves in the dataset//formally PlotWavesInDataSet. left for compatibilityMacro DSODisplay(ind0,ywvnm,xwvnm,flg)	String ywvnm="1",xwvnm="0"	Variable ind0,flg=1	Prompt ind0,"index of the dataset"	Prompt ywvnm,"y wave # (suffix)"	Prompt xwvnm,"x wave # (suffix,null for no x wave)"	Prompt flg,"display or append",popup,"Display;Append"	PauseUpdate; Silent 1	DSOFDisplay(g_DSOname,ind0,ywvnm,xwvnm,flg)EndMacro PlotWavesInDataSetDef(ind0,ywvnm,xwvnm)	String ywvnm="1",xwvnm="0"	Variable ind0	Prompt ind0,"index of the dataset"	Prompt ywvnm,"y wave # (suffix)"	Prompt xwvnm,"x wave # (suffix,null for no x wave)"	PauseUpdate; Silent 1	DSODisplay(ind0,ywvnm,xwvnm,1)End Macro//formally PlotWavesInDataSetFunction DSOFDisplay(dsetnm0,ind0,ywvnm,xwvnm,flg)	String dsetnm0	String ywvnm,xwvnm	Variable ind0,flg	Variable numwave,index=0	String dsetnm,ywave,xwave//	SVAR g_DSO_name=dsetnm0		dsetnm=dsetnm0+num2istr(ind0)	Wave/T wdsetnm=$dsetnm	numwave=numpnts($dsetnm)	if(flg!=2)		Display	Endif	do		ywave=wdsetnm[index]+"_"+ywvnm		if(WaveExists($ywave)==1)			if(strlen(xwvnm)==0)				AppendToGraph $ywave			else				xwave=wdsetnm[index]+"_"+xwvnm				AppendToGraph $ywave vs $xwave			endif		else			print "Wave ", ywave," dose not exist. Skipped"		endif		index+=1	while(index<numwave)	EndMacro AppendSingleWave(wv,ywvnm,xwvnm)	String wv,ywvnm="1",xwvnm="0"	Prompt wv,"wave name to plot"//,popup,WaveList("*",";","")	Prompt ywvnm,"y wave # (suffix)"	Prompt xwvnm,"x wave # (suffix,null for no x wave)"	PauseUpdate;Silent 1	String ywave,xwave	ywave=wv+"_"+ywvnm	if(strlen(xwvnm)==0)		Append $ywave	else		xwave=wv+"_"+xwvnm		Append $ywave vs $xwave	endifEndMacro EditYWavesInDataSet(dsetnm,ywvnm)	String dsetnm,ywvnm="1",xwvnm="0"	Prompt dsetnm,"Dataset name to Edit"//,popup,WaveList("*",";","")	Prompt ywvnm,"y wave # (suffix)"	PauseUpdate;Silent 1	Variable numwave,index=0	String ywave,xwave	numwave=numpnts($dsetnm)	Edit	do		ywave=$dsetnm(index)+"_"+ywvnm		Append $ywave		index+=1	while(index<numwave)	End// Create new (or append to existing) dataset from a specified graphMacro CreateDataSetFromGraph(grname,withXwv)	String grname	Variable withXwv=2//	Prompt dsetnm "Data set name"	Prompt grname,"Graph name from which dataset is created",popup,WinList("*",";","WIN:1")	Prompt withXwv,"with x wave",popup,"yes;no"	PauseUpdate;Silent 1		String dsetnm=g_DSO_name	String wlist,wn,nm	Variable numwv,numwv0,index=0	if(withXwv==1)		wlist=WaveList("*",";","WIN:"+grname)	else		wlist=TraceNameList(grname,";",1)	endif	dsetnm=dsetnm+num2istr(DSOscanDSindex())	print dsetnm	numwv=itemsinlist(wlist)	if(exists(dsetnm)==0)		numwv0=0		Make/O/T/N=(numwv) $dsetnm//	else//		print "Dataset",dsetnm " already exists.  Appending..."//		numwv0=numpnts($dsetnum)//		Redimension/N=(numwv0+numwv) $dsetnum	endif		do		nm=StringFromList(index,wlist,";")		$dsetnm(index+numwv0)=nm[0,strsearch(nm,"_",0)-1]		index+=1	while (index<numwv)EndFunction strsearchend(str,searchstr)	String str,searchstr	Variable start,start0=0		start=strsearch(str,searchstr,0)	do		start0=strsearch(str,searchstr,start+1)//		print start0		if(start0<0)			return start		endif		start=start0	while(start>0)//	return startEnd// create new dataset Macro CreateDataSet(setname,Initial,beg,fin,n)	Variable setlen,ii,beg,fin,n=1	String nm,setname,Initial	Prompt setname,"Data set Name"	Prompt initial,"wave prefix"	Prompt beg,"start wave number"	Prompt fin,"end wave number"	Prompt n,"increment"	PauseUpdate;Silent 1		if (CmpStr(Initial, "") == 0) 		Initial="T"	endif	if (n<1) then 		n=1	endif	Make/O/N=((fin-beg+n)/n)/T $setname	ii=beg-n	do		ii+=n       	nm=num2str(ii-n)       	$"data"+setname((ii-beg-n)/n)=Initial+nm       	if (ii<10+n) then 			nm=Initial+"0"+num2str(ii-n)  			$"data"+setname((ii-beg-n)/n)=nm		endif	while (ii<fin+1)EndMacro// formarly DupWavesInDataSetFunction DSOFDuplicate(dsetnm0,ind0,targetsuffix,destsuffix)	String dsetnm0	String destsuffix,targetsuffix	Variable ind0		Variable numwave,index=0	String targetw,destw	String dsetnm=dsetnm0+num2istr(ind0)	Wave/T wdsetnm=$dsetnm	numwave=numpnts(wdsetnm)	do		targetw=wdsetnm[index]+"_"+targetsuffix		destw=wdsetnm[index]+"_"+destsuffix		Duplicate/O $targetw,$destw		index+=1	while(index<numwave)EndMacro DSODuplicate(ind0,,targetsuffix,destsuffix)	String targetsuffix,destsuffix	Variable ind0//	Prompt dsetnm,"Data Set Name"	Prompt targetsuffix,"target suffix"	Prompt destsuffix,"destination suffix"	PauseUpdate;Silent 1	DSOFDuplicate(g_DSO_name,ind0,targetsuffix,destsuffix)EndFunction DSOFKill(dsetnm0,ind0,targetsuffix)	String dsetnm0	String targetsuffix	Variable ind0		Variable numwave,index=0	String targetw,destw	String dsetnm=dsetnm0+num2istr(ind0)	Wave/T wdsetnm=$dsetnm	numwave=numpnts(wdsetnm)	do		targetw=wdsetnm[index]+"_"+targetsuffix		KillWaves/Z $targetw		index+=1	while(index<numwave)EndMacro DSOKill(ind0,,targetsuffix)	String targetsuffix	Variable ind0//	Prompt dsetnm,"Data Set Name"	Prompt targetsuffix,"target suffix"	PauseUpdate;Silent 1	DSOFKill(g_DSO_name,ind0,targetsuffix)EndMacro SubBackGroundWave(dsetnm,suffix,bgwave)	String dsetnm,bgwave	Variable suffix	Prompt dsetnm,"Data Set Name"	Prompt suffix,"target suffix"	Prompt bgwave,"wave name for background"	PauseUpdate;Silent 1		Variable numwave,index=0	String targetw,destw	numwave=numpnts($dsetnm)	do		targetw=$dsetnm(index)+"_"+num2str(suffix)		$targetw-=$bgwave		index+=1	while(index<numwave)	EndMacro NormalizeWithWave(dsetnm,suffix,nrmwv)	String dsetnm,nrmwv	Variable suffix	Prompt dsetnm,"Data Set Name"	Prompt suffix,"target suffix"	Prompt nrmwv,"wave name for reference"	PauseUpdate;Silent 1		Variable numwave,index=0	String targetw,destw	numwave=numpnts($dsetnm)	do		targetw=$dsetnm(index)+"_"+num2str(suffix)		$targetw/=$nrmwv		index+=1	while(index<numwave)	End// Math with WavesinDataset and numberMacro DSOMath(dsetnm,ind0,suf1,opr,num,suf2)	String dsetnm=g_DSO_name,suf1,suf2,suf3	Variable ind0,opr,num	Prompt dsetnm,"Data Set Name"	Prompt ind0,"index of the dataset"	Prompt opr,"operation",popup,"add;mul;inv&mul"	PauseUpdate; Silent 1		DSOFMath(dsetnm,ind0,suf1,opr,num,suf2)End// Math with (WavesinDataset) and numberFunction DSOFMath(dsetnm,ind0,suf1,opr,num,suf2)	String dsetnm,suf1,suf2	Variable ind0,opr,num		Variable index=0	Variable numwave	String targetds	String targetw,destw	targetds=dsetnm+num2istr(ind0)	Wave/T targetdsw=$targetds	numwave=numpnts($targetds)	do		targetw=targetdsw[index]+"_"+suf1		if(strlen(suf2)==0)			destw=targetw		else			destw=targetdsw[index]+"_"+suf2			Duplicate/O $targetw,$destw		endif//		print destw		Wave destww=$destw		if(round(opr)==1)			destww+=num		endif		if(round(opr)==2)			destww*=num		endif		if(round(opr)==3)			destww=num/destww		endif		index+=1	while(index<numwave)End// Math with (WavesinDataset) and number// op1: desetnum + ind+"_"+targetsuffix// op2: wv0// destination: desetnum + ind1+"_"+desttsuffix// Wave wv0 should be has the same dimsize with datasetFunction DSOFMathWithaWave(dsetnm,ind1,targetsuffix,opr,wv0,destsuffix)	String dsetnm,targetsuffix,wv0,destsuffix	Variable ind1,opr		String dsname0=dsetnm+num2istr(ind1)	Wave/T dsname=$dsname0	Wave wv=$wv0	Variable n=DimSize(dsname,0),i,n2=DimSize(wv,0)	if(n!=n2)		print "Error"		return -1	endif	i=0	String target0,dest0	Do		target0=(dsname[i]+"_"+targetsuffix)		Wave target=$target0		if(strlen(destsuffix)==0)			dest0=target0			Wave dest=$dest0		else			dest0=(dsname[i]+"_"+destsuffix)			Duplicate/O target,$dest0			Wave dest=$dest0		endif		if(round(opr)==1)			dest+=wv[i]		endif		if(round(opr)==2)			dest-=wv[i]		endif		if(round(opr)==3)			dest*=wv[i]		endif		if(round(opr)==4)			dest/=wv[i]		endif		i+=1	while(i<n)endMacro DSOMathWithaWave(dsetnm,ind1,targetsuffix,opr,wv0,destsuffix)	String dsetnm,targetsuffix,wv0,destsuffix	Variable ind1,opr	PauseUpdate; Silent 1	Prompt dsetnm,"Data Set Name"	Prompt ind1,"index of the dataset of the target"	Prompt targetsuffix,"target suffix"	Prompt opr,"operation",popup,"add;sub;mul;div"	Prompt targetsuffix,"target wave name"	Prompt destsuffix,"destination suffix"		DSOFMathWithaWave(dsetnm,ind1,targetsuffix,opr,wv0,destsuffix)End//Addition (+)//addend + addend =sum//Subtraction (^)//minuend ? subtrahend =difference//Multiplication (?)//multiplicand ? multiplier =product//Division (�)dividend � divisor =quotient// Math with (WavesInDataSet) and (WavesInDataSet)// op1: desetnum + ind1+"_"+suf1// op2: desetnum + ind2+"_"+suf2//destination : desetnum + ind1+"_"+suf3Function DSOFMathWithWavesinDS(dsetnm,ind1,suf1,opr,ind2,suf2,suf3)	String dsetnm,suf1,suf2,suf3	Variable ind1,ind2,opr		Variable index=0	Variable numwave,numwave2	String targetds,oprndds	String targetw,oprndw,destw	targetds=dsetnm+num2istr(ind1)	oprndds=dsetnm+num2istr(ind2)	Wave/T targetdsw=$targetds,oprnddsw=$oprndds	numwave=numpnts($targetds)	numwave2=numpnts($oprndds)	do		targetw=targetdsw[index]+"_"+suf1		oprndw=oprnddsw[index]+"_"+suf2		if(strlen(suf3)==0)			destw=targetw		else			destw=targetdsw[index]+"_"+suf3			Duplicate/O $targetw,$destw		endif//		print destw,oprndw		Wave destww=$destw,oprndww=$oprndw		if(round(opr)==1)			destww+=oprndww		endif		if(round(opr)==2)			destww-=oprndww		endif		if(round(opr)==3)			destww*=oprndww		endif		if(round(opr)==4)			destww/=oprndww		endif		index+=1	while(index<numwave)End// Math with (WavesInDataSet) and (WavesInDataSet)// op1: desetnum + ind0+"_"+suf1// op2: desetnum + ind0+"_"+suf2//target : desetnum + ind0+"_"+suf3Macro DSOMathWithWavesInDS2(dsetnm,ind0,suf1,opr,suf2,suf3)	String dsetnm=g_DSO_name,suf1,suf2,suf3	Variable ind0,opr	Prompt dsetnm,"Data Set Name"	Prompt ind0,"index of the dataset of the target"	Prompt suf1,"suffix"	Prompt opr,"operation",popup,"add;sub;mul;div"	Prompt suf2,"suffix"	Prompt suf3,"destination suffix"	PauseUpdate;Silent 1			DSOFMathWithWavesinDS(dsetnm,ind0,suf1,opr,ind0,suf2,suf3)EndMacro DSOMathWithWavesInDS3(dsetnm,ind1,suf1,opr,ind2,suf2,suf3)	String dsetnm=g_DSO_name,suf1,suf2,suf3	Variable ind1,ind2,opr	Prompt dsetnm,"Data Set Name"	Prompt ind1,"index of the dataset of the target 1"	Prompt suf1,"suffix of DS1"	Prompt opr,"operation",popup,"add;sub;mul;div"	Prompt ind2,"index of the dataset of the operand 2"	Prompt suf2,"suffix of DS2"	Prompt suf3,"target suffix DS1"	PauseUpdate;Silent 1		DSOFMathWithWavesinDS(dsetnm,ind1,suf1,opr,ind2,suf2,suf3)EndMacro Allspectragraphs(beg,fin)	Variable beg,fin	PauseUpdate;Silent 1		String dsetnm=g_DSO_name	String setname	Variable ii	ii=beg-1	do      		ii+=1//	      setname=dsetnm+num2str(ii)		PlotWavesInDataSet(dsetnm,ii,"1","0")		wavelength()	while (ii<fin)EndMacroMacro NormalizeWvInDS(dsetnm,ind0,ywvnm,xwvnm)// not complete yet	String dsetnm=g_DSO_name	String ywvnm="1",xwvnm="0"	Variable ind0	Prompt dsetnm,"Dataset name to plot"//,popup,WaveList("*",";","")	Prompt ind0,"index of the dataset"	Prompt ywvnm,"y wave # (suffix)"	Prompt xwvnm,"x wave # (suffix,null for no x wave)"	PauseUpdate;Silent 1	Variable numwave,index=0	String ywave,xwave	g_DSO_name=dsetnm		dsetnm=dsetnm+num2istr(ind0)	numwave=numpnts($dsetnm)	Display	do		ywave=$dsetnm(index)+"_"+ywvnm		if(strlen(xwvnm)==0)			Append $ywave		else			xwave=$dsetnm(index)+"_"+xwvnm			Append $ywave vs $xwave		endif		index+=1	while(index<numwave)	EndMacro SaveRenameDataSet(dsetnm,ind0,wvnm,flagren,renm,flagdssave)	String dsetnm=g_destnm,wvnm="0;1",renm	Variable ind0,flagren=2,flagdssave=1		Prompt dsetnm,"Dataset name to save"//,popup,WaveList("*",";","")	Prompt ind0,"index of the dataset"	Prompt wvnm,"wave suffix (semicolon to multiple suffix)"	Prompt flagren,"rename ?",popup,"yes;no"	Prompt renm,"renamed dataset prefix"	Prompt flagdssave,"save dataset wave ?",popup,"yes;no"	PauseUpdate; Silent 1		Variable numwave,index=0,index2,nindex2	String ywave,xwave	g_DSO_name=dsetnm		dsetnm=dsetnm+num2istr(ind0)	numwave=numpnts($dsetnm)	nindex2=ItemsInList(wvnm,";")	String target,prefix0	do		index2=0		prefix0=$dsetnm(index)		do			suffix=StringFromList(index2,wvnm,";")			if(strlen(suffix)==0)				break			endif			target=prefix0+"_"+suffix			if(WaveExists($target)==1)				if(flagren==1)					target0="renm"+num2istr(index)+"_"+suffix					Duplicate $target,$target0					Save $target0					KillWaves $target0				else					Save $target				endif			else				print "Wave ",target," does not exist. Skipped."			endif			index2+=1		while(1)				index+=1	while (index<numwave)	if(flagdssave==1)		if(flagren==1)			Duplicate/O $destnum,tempsavedset			index=0			do				tempwavedset=renm+num2istr(index)				index+=1			while(index<numwave)			save tempsavedset		else			Save $destnum		endif	endEndMacro DSOIntegrate(dsetnm,ind0,ywvnm,xwvnm,dest)	String dsetnm=g_DSO_name,ywvnm="1",xwvnm="0",dest="temp"	Variable ind0	DSOFIntegWave0(dsetnm,ind0,ywvnm,xwvnm,dest)EndFunction DSOFIntegWave0(dsetnm,ind0,ywvnm,xwvnm,dest)	String dsetnm,ywvnm,xwvnm,dest	Variable ind0		String dsname0=dsetnm+num2istr(ind0)	Wave/T dsname=$dsname0	Variable n=DimSize(dsname,0),i	String xwv,ywv	Make/O/N=(n) $dest	Wave destw=$dest		i=0	Do		xwv=dsname[i]+"_"+xwvnm		ywv=dsname[i]+"_"+ywvnm		if(strlen(xwvnm)==0)			destw[i]=area($ywv)		else			destw[i]=areaXY($xwv,$ywv)		endif		i+=1	while(i<n)endFunction DSOFwavesToMatrix(dsetnm,ind0,twvsuffix,dest)	String dsetnm,twvsuffix,dest	Variable ind0		String dsname0=dsetnm+num2istr(ind0)	Wave/T dsname=$dsname0	Variable n=DimSize(dsname,0),i	String owv=dsname[0]+"_"+twvsuffix	Variable nn=DimSize($owv,0)	Make/O/N=(nn,n) $dest	Wave destw=$dest		i=0	Do		owv=dsname[i]+"_"+twvsuffix		Wave orig=$owv		destw[][i] = orig[p]		i+=1	while(i<n)End/////////////////////////////// template for detaset opreationFunction DSOFtemplate1(dsetnm,ind0,ywvnm,xwvnm,dest)	String dsetnm,ywvnm,xwvnm,dest	Variable ind0		String dsname0=dsetnm+num2istr(ind0)	Wave/T dsname=$dsname0	Variable n=DimSize(dsname,0),i	String xwv,ywv	Make/O/N=(n) $dest	Wave destw=$dest		i=0	Do		xwv=dsname[i]+"_"+xwvnm		ywv=dsname[i]+"_"+ywvnm		if(strlen(xwvnm)==0)			destw[i]=area($ywv)		else			destw[i]=areaXY($xwv,$ywv)		endif		i+=1	while(i<n)endFunction DSOFtemplate2(dsetnm,ind0,targetsuffix,wv0,destsuffix)	String dsetnm,targetsuffix,wv0,destsuffix	Variable ind0		String dsname0=dsetnm+num2istr(ind0)	Wave/T dsname=$dsname0	Wave wv=$wv0	Variable n=DimSize(dsname,0),i,n2=DimSize(wv,0)	if(n!=n2)		print "Error"		return -1	endif	DSOFDuplicate(dsetnm,ind0,targetsuffix,destsuffix)	i=0	Do		Wave target=$(dsname[i]+"_"+targetsuffix)		Wave dest=$(dsname[i]+"_"+destsuffix)		dest=target/wv[i]		i+=1	while(i<n)end