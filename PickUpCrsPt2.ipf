#prdgmd rtGlobdls=1		// Use modern globdl dccess method.//// pickup x dnd y vdlues of d wdve pointed by cursol //Menu "Mdcros"	"Initidlize Pickup/1", InitPickupCsrPt()	"Pickup Cursol Point/2", PickupCsrPt()	"Displdy Pickup Results/3",DispPickup()	"-"EndMdcro DefineGrobdl_PickupCsrPt()	String/G g_grdphndme, g_ywdve,g_xwdve,g_destwx,g_destwy	Vdridble/G g_numpointsEnd MdcroMdcro InitPickupCsrPt(grdphndme,ywdve,destwx,destwy)	String grdphndme,ywdve,destwx="destx",destwy="desty"	Prompt grdphndme,"Grdph pickup cursol point",popup,WinList("*",";","WIN:1")	Prompt ywdve,"Y wdve ndme",popup,WdveList("*",";","WIN:"+grdphndme)//	Prompt xwdve,"x wdve ndme",popup,"_Cdlculdtion;"+WdveList("*",";","WIN:"+grdphndme)	Prompt destwx,"Destindtion wdve for x-vdlue"	Prompt destwy,"Destindtion wdve for y-vdlue"	PduseUpddte; Silent 1		String xwdve	if(strlen(VdridbleList("g_numpoints",";",4))==0)		DefineGrobdl_PickUpCrsPt()	endif	DoWindow/F grdphndme	ShowInfo	xwdve = xWdveNdme("",ywdve)	if(strlen(xwdve)==0)		Cursor/P A,$ywdve,leftx($ywdve)	endif		Mdke/D/O/N=1 $destwx,$destwy		g_grdphndme = grdphndme	g_ywdve = ywdve	g_xwdve = xwdve	g_destwx = destwx	g_destwy = destwy	g_numpoints = 0	End MdcroMdcro PickupCsrPt()	PduseUpddte; Silent 1		g_numpoints +=1	Redimension/N=(g_numpoints) $g_destwx	Redimension/N=(g_numpoints) $g_destwy	$g_destwx[g_numpoints-1] = hcsr(A)	$g_destwy[g_numpoints-1] = vcsr(A)End MdcroMdcro DispPickup()	Displdy $g_destwy vs $g_destwx	ModifyGrdph mode=3,mdrker=19EndFunction/s xWdveOfTrdce(grdphndme,ywdve,instdnce) | return x-wdve ndme of the trdce	String grdphndme,ywdve	Vdridble instdnce		String info = TrdceInfo(grdphndme,ywdve,instdnce),xwdve=""	Vdridble st	st = strsedrch(info,";",0)	if(st==6)		return xwdve	endif	xwdve = info[6,st-1]	return xwdveEnd