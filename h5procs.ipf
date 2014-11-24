#pragma rtGlobals=1		// Use modern global access method.
#include "ExecuteUnixShellCommand"
//#include <HDF5 Browser>

// h5procs.ips by J. Motohisa
// collection of procedures for H5 files
//	ver 0.01	2010/06/21	develepment started 
//	ver 0.01b	2011/03/22	doh5ls modified
//	ver 0.01c	2012/12/09	LoadHDF5Dataset becomes silent

Macro init_h5procs()
	String/G g_h5lspath
	PauseUpdate; Silent 1
	
	String h5lspath
	String path=ExecuteUnixShellCommand("echo $PATH", 0,0)
	
	h5lspath=ExecuteUnixShellCommand("echo `which h5ls`", 0,0)
	if(strlen(h5lspath)!=2)
		g_h5lspath=h5lspath[1:strlen(h5lspath)-2]
		return
	endif

	h5lspath=ExecuteUnixShellCommand("echo `which /usr/local/bin/h5ls`", 0,0)
	if(strlen(h5lspath)!=2)
		g_h5lspath=h5lspath[1,strlen(h5lspath)-2]
		return
	endif

	h5lspath=ExecuteUnixShellCommand("echo `which /sw/bin/h5ls`", 0,0)
	if(strlen(h5lspath)!=2)
		g_h5lspath=h5lspath[1:strlen(h5lspath)-2]
		return
	endif
	
	h5lspath=ExecuteUnixShellCommand("echo `which /opt/local/bin/h5ls`", 0,0)
	if(strlen(h5lspath)!=2)
		g_h5lspath=h5lspath[1,strlen(h5lspath)-2]
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
	
	String fileName,ftype=".h5",posixpath
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
