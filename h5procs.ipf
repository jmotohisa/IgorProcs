#pragma rtGlobals=3		// Use modern global access method.
#include "ExecuteUnixShellCommand"
//#include <HDF5 Browser>
#include "strrpl"

#include "HDF5Gateway"
#include "wname"

// h5procs.ips by J. Motohisa
// collection of procedures for H5 files
//	ver 0.01	2010/06/21	develepment started 
//	ver 0.01b	2011/03/22	doh5ls modified
//	ver 0.01c	2012/12/09	LoadHDF5Dataset becomes silent
// ver 0.2     2021/04/30  bug fixed, Matlab Mat file
//             requires HDF5gateway https://github.com/prjemian/hdf5gateway.git
// H5GW_ReadHDF5(parentFolder, fileName, [hdf5Path])

Macro init_h5procs()
	String/G g_h5lspath
	PauseUpdate; Silent 1
	
	String h5lspath
	String path=ExecuteUnixShellCommand("echo $PATH", 0,0)
	
	h5lspath=ExecuteUnixShellCommand("echo `which h5ls`", 0,0)
	if(strlen(h5lspath)!=0)
		g_h5lspath=h5lspath
		return
	endif

	h5lspath=ExecuteUnixShellCommand("echo `which /usr/local/bin/h5ls`", 0,0)
	if(strlen(h5lspath)!=0)
		g_h5lspath=h5lspath
		return
	endif

	h5lspath=ExecuteUnixShellCommand("echo `which /sw/bin/h5ls`", 0,0)
	if(strlen(h5lspath)!=0)
		g_h5lspath=h5lspath
		return
	endif
	
	h5lspath=ExecuteUnixShellCommand("echo `which /opt/local/bin/h5ls`", 0,0)
	if(strlen(h5lspath)!=0)
		g_h5lspath=h5lspath
		return
	endif
	
	print "Error: h5ls was not found in ",path,":/usr/local/bin:/sw/bin:/opt/local/bin"
	g_h5lspath=""
End

Function LoadHDF5Dataset(pathName, fileName, datasetName)
	String pathName	// Name of symbolic path
	String fileName	// Name of HDF5 file
	String datasetName	// Name of dataset to be loaded
	
	Variable fileID	// HDF5 file ID will be stored here

	Variable result = 0	// 0 means no error
	
	// Open the HDF5 file.
	HDF5OpenFile /P=$pathName /R /Z fileID as fileName
	if (V_flag != 0)
		Print "HDF5OpenFile failed"
		return -1
	endif
	
	// Load the HDF5 dataset.
	HDF5LoadData/O /Z/Q fileID, datasetName
	if (V_flag != 0)
		Print "HDF5LoadData failed"
		result = -1
	endif

	// Close the HDF5 file.
	HDF5CloseFile fileID

	return result
End

Macro doh5ls(pathname)
	String pathname="meep"
//	String fnamebase,datasetNameBase="ez"
	Prompt pathname, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"
//	Prompt fnamebase,"base file name"
//	Prompt datasetNameBase,"dataset name"
	PauseUpdate; Silent 1
	
	h5ls(pathname)
End


Function h5ls(pathname)
	String pathname
	
	h5ls0(pathname,"h5")
End

Function lsMat(pathname)
	string pathname
	
	h5ls0(pathname,"mat")
End

Function h5ls0(pathname,extname)
	String pathname,extname

	String fileName,ftype="."+extname,posixpath
	String uCommand,res
	SVAR g_h5lspath
	String h5lspath=g_h5lspath //"/opt/local/bin/h5ls"
	if(strlen(h5lspath)==0)
		print "no h5ls found"
		return 0
	endif
	
	Variable fileIndex=0,filenum=0,gotFile,gotFile2
	String fname
	
	if (CmpStr(pathname, "_New Path_") == 0)		// user selected new path ?
		NewPath/O meep			// this brings up dialog and creates or overwrites path
		pathname = "meep"
	endif
	Pathinfo $pathname
	posixpath=ParseFilePath(5, S_path, "/", 0, 0)
	
	do
		fileName = IndexedFile($pathname,fileIndex,ftype)			// get name of next file in path
		gotFile = strlen(fileName)
		if (gotFile >0)
			uCommand = h5lspath + " " + "'"+posixpath +"/"+filename+"'"
			res=ExecuteUnixShellCommand(uCommand, 0,0)
			print filename + ":" +res
		endif
		fileIndex += 1
	while (gotFile)									// until TextFile runs out of files

End

Function FJMH5open(fname,pname,wvname,dsname)
	String fname,pname,wvname,dsname
	
	Wave dummy
	Variable FileID
	if (strlen(fname)<=0)
		if(strlen(pname)<=0)
			HDF5OpenFile/I/R fileID as fname
			fname= S_fileName
			HDF5CloseFile fileID
			fname=S_path+fname
			print fname
		else
			HDF5OpenFile/I/R/P=pname fileID as fname
			HDF5CloseFile fileID
			fname=S_path+fname
			HDF5OpenFile/R/P=$pname  fileID as fname
		endif
	endif

	if(strlen(pname)<=0)
		HDF5OpenFile/R fileID as fname
	else
		HDF5OpenFile/R/P=$pname fileID as fname
	endif

	HDF5LoadData/N=dummy/O fileID,dsname
	HDF5CloseFile fileID
		
	if(strlen(wvname)<=0)
		wvname=strrpl(dsname,".","_")
	endif
	Duplicate/O dummy,$wvname
	
End

Function FJMH5load(fname,pname,parentFolder)
	String fname,pname,parentFolder
	
	Variable FileID
	String pathToFolderStr
//	if (CmpStr(pathName, "_New Path_") == 0 || strlen(pathName)==0)		// user selected new path ?
//		NewPath/O data			// this brings up dialog and creates or overwrites path
//		thePath = "data"
//	endif

	if(strlen(pname)<=0)
		// use default path "data"
		pname = "data"
	endif
	PathInfo $pname

	if(V_flag == 1) // Path is valid
		if(strlen(fname)<=0)
			HDF5OpenFile/I/R/P=$pname fileID as fname
			HDF5CloseFile fileID
			fname=S_fileName
		else
			HDF5OpenFile/R/P=$pname/Z fileID as fname
			if(V_Flag!=0)
				print "File not found in specified data folder."
				return 1
			endif
			HDF5CloseFile fileID
		endif
	else
		if (strlen(fname)<=0)
			HDF5OpenFile/I/R fileID as fname
			fname= S_fileName
			pathToFolderStr = S_path
			HDF5CloseFile fileID
			NewPath/C $pname,pathToFolderStr 
			print fname
			print pathToFolderStr
		else
			HDF5OpenFile/R/Z fileID as fname
			if(V_Flag!=0)
				print "File not found."
				return 1
			endif			
			fname= S_fileName
			pathToFolderStr = S_path
			HDF5CloseFile fileID
			NewPath/C $pname,pathToFolderStr 
			print fname
			print pathToFolderStr
		endif
	endif

	print H5GW_ReadHDF5(parentFolder, fname, pathName=pname)
	
//	if(strlen(pname)<=0)
//		HDF5OpenFile/R fileID as fname
//	else
//		HDF5OpenFile/R/P=$pname fileID as fname
//	endif

//	HDF5LoadData/N=dummy/O fileID,dsname
//	HDF5CloseFile fileID
		
//	if(strlen(wvname)<=0)
//		wvname=strrpl(dsname,".","_")
//	endif
//	Duplicate/O dummy,$wvname
	
End

