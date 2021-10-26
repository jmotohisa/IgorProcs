#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// PrintMarquee: code taken from Marquee2Mask

Proc PrintMarquee() : GraphMarquee

	Silent 1;PauseUpdate
	String list= ImageNameList("",";")
	String imagePlot = StringFromList(0,list, ";")
	
	// here we need to figure out how the image is displayed (what axes to use for the marquee).
	// this is a pain to do because it requires parsing the image information string.
	if (strlen(imagePlot))	// one image
		String info,vaxis,haxis,image,df,xwave,ywave
		Variable i
		info=ImageInfo("",imagePlot,0)
		vaxis=StringByKey("YAXIS",info)
		haxis=StringByKey("XAXIS",info)
		image=StringByKey("ZWAVE",info)
		df=StringByKey("ZWAVEDF",info)
		xwave=StringByKey("XWAVE",info)
		ywave=StringByKey("YWAVE",info)
		if( strlen(xwave)+strlen(ywave) )
			Abort "MarqueeToMask does not work on images with X or Y waves"
		endif
		String winStyle= WinRecreation("",1)
		Variable swapxy= strsearch(winStyle,"swapXY=1",0) >= 0
		GetMarquee $haxis,$vaxis		
		
		// at this point we should have the marquee positions relative to the horizontal and vertical axes.
		// V_left,V_right,V_top,V_bottom
		String  theImage=df+PossiblyQuoteName(image)
		Make/b/u/O/N=(DimSize($theImage,0),DimSize($theImage,1)) M_ROIMask=0
		CopyScales $theImage,M_ROIMask
		
		Variable rowMin,rowMax,colMin,colMax
		if( swapxy )
			if(V_top<V_bottom)
				rowMin=V_top
				rowMax=V_bottom
			else
				rowMin=V_bottom
				rowMax=V_top
			endif
			if(V_left<V_right)
				colMin=V_left
				colMax=V_right
			else
				colMin=V_right
				colMax=V_left
			endif
		else
			if(V_left<V_right)
				rowMin=V_left
				rowMax=V_right
			else
				rowMin=V_right
				rowMax=V_left
			endif
			if(V_top<V_bottom)
				colMin=V_top
				colMax=V_bottom
			else
				colMin=V_bottom
				colMax=V_top
			endif
		endif
		
		variable ax=dimdelta(M_ROIMask,0)
		variable bx=dimoffset(M_ROIMask,0)
		variable ay=dimdelta(M_ROIMask,1)
		variable by=dimoffset(M_ROIMask,1)
		rowMin=(rowMin-bx)/ax
		rowMax=(rowMax-bx)/ax
		colMin=(colMin-by)/ay
		colMax=(colMax-by)/ay
		
		print rowMin,rowMax, colMin,colMax
	endif
End
