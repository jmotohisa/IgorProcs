// David Dana, 2011-3-16
// Creates a Folder menu for selecting among data folders, as an alternative to the Data Browser.
// Supports hierarchical folder structures, but somewhat kludgily since we can't make dynamic menus
// truly hierarchical.  See FolderMenuItems() description for complete description of menu behavior.
// Menu also includes a command for creating new folders (but not deleting).
 
//
// Run MakeTestFolders() to quickly create some sample folders for experimentation.
 
#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.00
 
Menu "Folder", dynamic
	FolderMenuItems(), FolderItemHandler()
	"-"
	"New Folder...", FolderPromptNewFolder()
End Menu
 
//--------------------------------------------------------------------------
//	Constructs a menu listing the current data folder, its parent, siblings, and children if any.
//	The first menu item is always the parent of the current folder, or root: if root: is current.
//	Then are listed all folders with the same parent as the current folder.
//	If the current folder has folders below it, these are also listed, indented below the current folder.
//
//	If the current folder has siblings with their own children (the current folder's nieces and nephews ;-) ),
//	those children are not shown, but their parents are marked with a '>'.   The user can view those children
//	by selecting the parent.
//
//	The currently active data folder is marked with a check, and disabled (since there is no point to
//	selecting it again).
//	
//	David Dana, HOBI Labs, Inc. 2011-3-16
Function/S FolderMenuItems()
 
	string itemStr
	string currentDF = GetDataFolder(1)	// Get complete folder path
	string parent = CurrentFolderParent(1)
 
	//	First menu item is the full path of the parent folder
	if (strlen(parent) == 0)	//  the current folder is root, there is no parent
		itemStr = DisablePrefix() + CheckMarkPrefix() + "root:;"
		parent = "root:"
	else
		itemStr = parent + ";"	
	endif
 
//	Find all children of parent (possibly including the current folder)
	variable i, itemCount = CountObjects(parent, 4)
	if (itemCount)
		itemStr = itemStr + "-;"
	//	Add each child to menu item list
		string child
		for (i = 0; i < itemCount; i += 1)
			child = getIndexedObjName(parent, 4, i)
			string childFullPath = parent + possiblyQuoteName(child) + ":"
			variable grandchildCount = CountObjects(childFullPath,4)
	// if this is the current folder, prefix checkmark and see if it has children
			if (stringmatch(currentDF, childFullPath))
				itemStr = itemStr + DisablePrefix() + CheckMarkPrefix() + child + ";"
				if (grandChildCount)
					variable j
					for (j = 0; j < grandChildCount; j+=1)
						string grandChild = getIndexedObjName(childFullPath,4,j)
						itemStr =  itemStr + "  " + grandChild + ";"  // prefix subfolders with 2 spaces for clarity
					endfor
				endif
			else
				if (grandChildCount)
					itemStr = itemStr + ParentPrefix() + child + ";"
				else
					itemStr = itemStr + child + ";"
				endif
			endif
		endfor
	endif
	return itemStr
End Function  //--------------------------------------------------------------
 
//--------------------------------------------------------------------------
//	Responds to a selection from the menu constructed by FolderMenuItems().
//	Extracts the path of a folder and sets that as the current data folder.
Function FolderItemHandler()
	GetLastUserMenuInfo
	String folderPath = S_Value
	Variable itemNumber = v_value
 
	variable isChild = StringMatch(folderPath, ChildPrefix() + "*")
	folderPath = StripPrefix(folderPath)
	string parentPath = StringFromList (0, FolderMenuItems(), ";")
	parentPath = StripPrefix(parentPath)
 
	if (itemNumber == 1)			// first item is the parent folder
		folderPath = "::"			// Go up one level
	else
		if (!isChild)	// if child, folderPath is already correct
			folderPath = parentPath + possiblyquotename(folderPath)
		endif
	endif
	print folderPath
	SetDataFolder folderPath
End Function  //--------------------------------------------------------------
 
//--------------------------------------------------------------------------
// Append this to the front of a menu item to indicate the folder is child of a folder above it
Function/S ChildPrefix()
	Return "  "
End Function  //--------------------------------------------------------------
 
//--------------------------------------------------------------------------
// Append this to the front of a menu item to indicate the folder has children
Function/S ParentPrefix()
	Return "!>"
End Function  //--------------------------------------------------------------
 
//--------------------------------------------------------------------------
// Append this to the front of a menu item to disable it.  Can be added in front of other marks.
Function/S DisablePrefix()
	Return "("
End Function  //--------------------------------------------------------------
 
//--------------------------------------------------------------------------
// Append this to the front of a menu item to give it a check mark
Function/S CheckMarkPrefix()
	return "!" + num2Char(18)
End Function  //--------------------------------------------------------------
 
//--------------------------------------------------------------------------
// Removes special characters such as check marks, etc. from the front of a menu item name
Function/S StripPrefix(s)
string s
	if (stringmatch(s, "(*"))		// an open parenthesis makes the item inactive
		s = s[1,inf]
	endif
	if (stringmatch(s, "!!*") == 0)		// the initial ! is a logic inversion operator.
		s = s[2,inf]
	endif
	if (stringmatch(s, ChildPrefix() + "*"))
		s = s[strlen(ChildPrefix()), inf]
	endif
	return s
End Function  //--------------------------------------------------------------
 
//--------------------------------------------------------------------------
// Asks for the user for the name of a new folder.  Returns 0 if user cancelled or error.
Function FolderPromptNewFolder()
 
	string name
	prompt name, "Name for new folder in " + GetDataFolder (0)
	string promptStr = "New Data Folder"
	DoPrompt/HELP="" promptStr, name
	if (v_flag == 1)	// user cancelled
		return 0
	endif
	if (CheckName(name, 11))
		DoAlert 0, "\"" + name + "\" is not a legal folder name or is already in use."
		return 0
	endif
	NewDataFolder $name
	return 1
End Function  //--------------------------------------------------------------
 
//--------------------------------------------------------------------------
// Returns the name of the parent of the current folder, or empty string if the current folder is root:.
// If fullSpec is zero, returns only the base name of the parent, otherwise returns its full path
Function/S CurrentFolderParent(fullSpec)
variable fullSpec
 
	string folder = GetDataFolder(1) 
	if (stringmatch(folder, "root:"))
		return ""
	else
		variable items = ItemsInList (folder, ":")
		if (fullSpec)
			folder = RemoveListItem (items - 1, folder, ":")
			return folder
		else
			return StringFromList (items-2, folder, ":")
		endif
	endif
End Function  //--------------------------------------------------------------
 
 
//--------------------------------------------------------------------------
// Just for testing
Function MakeTestFolders()
	NewDataFolder/O root:Folder1
	NewDataFolder/O root:Folder2
	NewDataFolder/O root:Folder3
	NewDataFolder/O root:Folder4
	NewDataFolder/O root:Folder5
	NewDataFolder/O root:Folder6
	NewDataFolder/O root:Folder7
	NewDataFolder/O root:Folder3:Child1
	NewDataFolder/O root:Folder3:Child2
	NewDataFolder/O root:Folder3:Child3
	NewDataFolder/O root:Folder3:Child4
	NewDataFolder/O root:Folder3:Child5
	NewDataFolder/O root:Folder3:Child6
End Function  //--------------------------------------------------------------
