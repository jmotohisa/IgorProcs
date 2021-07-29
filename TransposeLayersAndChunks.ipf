#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


// taken From https://www.wavemetrics.com/code-snippet/transpose-layers-and-chunks-4d-wave

//  TransposeLayersAndChunks(w4DIn)
//  Transposes the layer and chunk dimensions of a 4D wave.
//  NOTE: Overwrites output wave.
Function TransposeLayersAndChunks(w4DIn, nameOut)
    Wave w4DIn
    String nameOut          // Desired name for new wave
    
    // Get information about input wave
    Variable rows = DimSize(w4DIn, 0)
    Variable columns = DimSize(w4DIn, 1)
    Variable layers = DimSize(w4DIn, 2)
    Variable chunks = DimSize(w4DIn, 3)
    Variable type = WaveType(w4DIn)
    
    // Make output wave. Note that numLayers and numChunks are swapped
    Make/O/N=(rows,columns,chunks,layers)/Y=(type) $nameOut
    Wave w4DOut = $nameOut
    
    // Copy scaling and units
    CopyScales w4DIn, w4DOut
    
    // Swap layer and chunk scaling
    Variable v0, dv
    String units
    v0 = DimOffset(w4DIn, 2)
    dv = DimDelta(w4DIn, 2)
    units = WaveUnits(w4DIn, 2)
    SetScale t, v0, dv, units,  w4DOut  // Copy layer dimensions and units to chunk dimension
    v0 = DimOffset(w4DIn, 3)
    dv = DimDelta(w4DIn, 3)
    units = WaveUnits(w4DIn, 3)
    SetScale z, v0, dv, units,  w4DOut  // Copy chunk dimensions and units to layer dimension
    
    // Transfer data
    w4DOut = w4DIn[p][q][s][r]          // s and r are reversed from normal
End

Function Demo()
    // Clean up from previous demo
    DoWindow /K DemoTable0
    DoWindow /K DemoTable1

    // Make demo input 4D wave
    Make/O/N=(5,4,3,2) w4D = p + 10*q + 100*r + 1000*s
    SetScale d 0, 0, "d" , w4D
    SetScale x 1, 2, "x" , w4D
    SetScale y 2, 3, "y" , w4D
    SetScale z 3, 4, "z" , w4D
    SetScale t 4, 5, "t" , w4D
    
    // Create output 4D transposed wave
    TransposeLayersAndChunks(w4D, "w4D_t")
    
    Edit /N=DemoTable0 /W=(8,49,513,256) w4D
    Edit /N=DemoTable1 /W=(517,48,1022,255) w4D_t
End