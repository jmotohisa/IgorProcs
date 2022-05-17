#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// Reduce rank of matrixwaves

Function FFixRank(wvname)
	String wvname
	
	Variable row,col,lay,chn;
	Wave wv=$wvname
	row=DimSize(wv,0)
	col=DimSize(wv,1)
	lay=DimSize(wv,2)
	chn=DimSize(wv,3)
	
	Variable n,rank0,rank
	if(chn==0)
		if(lay==0)
			if(col==0)
				n=row
				rank0=1
			else
				n=row*col
				rank0=2
			endif
		else
			n=row*col*lay
			rank0=3
		endif
	else
		n=row*col*lay*chn
		rank0=4
	endif
	
	if(rank0==4)
		rank0=Frank4to3(wvname,row,col,lay,chn)
		if(rank0==4)
			return rank0
		endif
	endif
	
	row=DimSize(wv,0)
	col=DimSize(wv,1)
	lay=DimSize(wv,2)
	if(rank0==3)
		rank0=Frank3to2(wvname,row,col,lay)
		if(rank0==3)
			return rank0
		endif
	endif
	
	row=DimSize(wv,0)
	col=DimSize(wv,1)
	if(rank0==2)
		rank=Frank2to1(wvname,row,col)
		if(rank0==2)
			return rank0
		else
			return 1
		endif
	endif
	
End

Function Frank4to3(wvname,row,col,lay,chn)
	String wvname
	Variable row,col,lay,chn
	Wave wv=$wvname
	if(row==1)
		Redimension/N=(col,lay,chn) wv
		return 3
	elseif(col==1)
			Redimension/N=(row,lay,chn) wv
			return 3
	elseif(lay==1)
		Redimension/N=(row,col,chn) wv
		return 3
	elseif(chn==1)
		Redimension/N=(row,col,lay) wv
		return 3
	endif
	return 4
End

Function Frank3to2(wvname,row,col,lay)
	String wvname
	Variable row,col,lay
	Wave wv=$wvname
	if(row==1)
		Redimension/N=(col,lay) wv
		return 2
	elseif(col==1)
		Redimension/N=(row,lay) wv
		return 2
	elseif(lay==1)
		Redimension/N=(row,col) wv
		return 2
	endif
	return 3
End

Function Frank2to1(wvname,row,col)
	String wvname
	Variable row,col
	Wave wv=$wvname
	if(row==1)
		Redimension/N=(col) wv
		return 1
	elseif(col==1)
		Redimension/N=(row) wv
		return 1
	endif
	return 2
End

Function FFixRank_DFall(dfname)
	String dfname
	
	DFREF saveDFR=GetDataFolderDFR()
	SetDataFolder dfname
	String wname0,wnames=WaveList("*",";","")
	Variable i
	do
		wname0=StringFromList(i,wnames,";")
		if(strlen(wname0)<=0)
			break
		endif
		FFixRank(wname0)
		i+=1
	while(1)
	
	SetDataFolder saveDFR
End

