#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// loadSPEheader.ipf
// 	read header information of SPE files
//	16/12/06 ver. 0.1 by J. Motohisa
//
//	revision history
//		16/12/06		ver 0.1	first version based on old header file reader and winxhed25.h

#include "loadSPEsub"

// should be used as a skelton
Function SPEReadHeader1(ref)
	Variable ref
	Variable DATEMAX=10,TIMEMAX=7,COMMENTMAX=80
	Variable LABELMAX=16,FILEVERMAX=16,HDRNAMEMAX=120
	Variable ROIMAX=10

	Variable   ControllerVersion=SPEReadBin(ref, 0,1) // Hardware Version
	Variable   LogicOutput     =SPEReadBin(ref,  2,1) // Definition of Output BNC
	Variable   AmpHiCapLowNoise=SPEReadBin(ref,  4,6) //  Amp Switching Mode
	Variable   xDimDet         =SPEReadBin(ref,  6,6) //  Detector x dimension of chip.
	Variable   mode            =SPEReadBin(ref,  8,1) //  timing mode
	Variable   exp_sec         =SPEReadBin(ref, 10,3) //  alternitive exposure, in sec.
	Variable   VChipXdim       =SPEReadBin(ref, 14,1) //  Virtual Chip X dim
	Variable   VChipYdim       =SPEReadBin(ref, 16,1) //  Virtual Chip Y dim
	Variable   yDimDet         =SPEReadBin(ref, 18,6) //  y dimension of CCD or detector.
	String     datestr           =SPEReadStr(ref, 20,DATEMAX) //  date
	Variable   VirtualChipFlag =SPEReadBin(ref, 30,1) //  On/Off
//	String    Spare_1      =SPEReadstr(ref, 32,2) //
	Variable   noscan          =SPEReadBin(ref, 34,1) //  Old number of scans - should always be -1
	Variable   DetTemperature  =SPEReadBin(ref, 36,3) //  Detector Temperature Set
	Variable   DetType         =SPEReadBin(ref, 40,1) //  CCD/DiodeArray type
	Variable   xdim            =SPEReadBin(ref, 42,6) //  actual # of pixels on x axis
	Variable   stdiode         =SPEReadBin(ref, 44,1) //  trigger diode
	Variable   DelayTime       =SPEReadBin(ref, 46,3) //  Used with Async Mode
	Variable   ShutterControl  =SPEReadBin(ref, 50,6) //  Normal, Disabled Open, Disabled Closed
	Variable   AbsorbLive      =SPEReadBin(ref, 52,1) //  On/Off
	Variable   AbsorbMode      =SPEReadBin(ref, 54,6) //  Reference Strip or File
	Variable   CanDoVirtualChipFlag=SPEReadBin(ref,56,1) //  T/F Cont/Chip able to do Virtual Chip
	Variable   ThresholdMinLive=SPEReadBin(ref, 58,1) //  On/Off
	Variable   ThresholdMinVal =SPEReadBin(ref, 60,3) //  Threshold Minimum Value
	Variable   ThresholdMaxLive=SPEReadBin(ref, 64,1) //  On/Off
	Variable   ThresholdMaxVal =SPEReadBin(ref, 66,3) //  Threshold Maximum Value
	Variable   SpecAutoSpectroMode=SPEReadBin(ref,70,1) //  T/F Spectrograph Used
	Variable   SpecCenterWlNm  =SPEReadBin(ref, 72,3) //  Center Wavelength in Nm
	Variable   SpecGlueFlag    =SPEReadBin(ref, 76,1) //  T/F File is Glued
	Variable   SpecGlueStartWlNm=SPEReadBin(ref, 78,3) // Starting Wavelength in Nm
	Variable   SpecGlueEndWlNm =SPEReadBin(ref, 82,3) // Starting Wavelength in Nm
	Variable   SpecGlueMinOvrlpNm=SPEReadBin(ref, 86,3) //  Minimum Overlap in Nm
	Variable   SpecGlueFinalResNm=SPEReadBin(ref, 90,3) //  Final Resolution in Nm
	Variable   PulserType      =SPEReadBin(ref, 94,1) //  0=None, PG200=1, PTG=2, DG535=3
	Variable   CustomChipFlag  =SPEReadBin(ref, 96,1) //  T/F Custom Chip Used
	Variable   XPrePixels      =SPEReadBin(ref, 98,1) //  Pre Pixels in X direction
	Variable   XPostPixels     =SPEReadBin(ref,100,1) //  Post Pixels in X direction
	Variable   YPrePixels      =SPEReadBin(ref,102,1) //  Pre Pixels in Y direction 
	Variable   YPostPixels     =SPEReadBin(ref,104,1) //  Post Pixels in Y direction
	Variable   asynen          =SPEReadBin(ref,106,1) //  asynchron enable flag  0 = off
	Variable   datatype        =SPEReadBin(ref,108,1) //  experiment datatype
	//                 0 =   float (4 bytes)
	//                 1 =   long (4 bytes)
	//                 2 =   short (2 bytes)
	//                 3 =   unsigned short (2 bytes)
	Variable   PulserMode      =SPEReadBin(ref,110,1) //  Repetitive/Sequential
	Variable   PulserOnChipAccums=SPEReadBin(ref,112,6) //  Num PTG On-Chip Accums
	Variable   PulserRepeatExp =SPEReadBin(ref,114,7) //  Num Exp Repeats (Pulser SW Accum)
	Variable   PulseRepWidth   =SPEReadBin(ref,118,3) //  Width Value for Repetitive pulse (usec)
	Variable   PulseRepDelay   =SPEReadBin(ref,122,3) //  Width Value for Repetitive pulse (usec)
	Variable   PulseSeqStartWidth=SPEReadBin(ref,126,3) //  Start Width for Sequential pulse (usec)
	Variable   PulseSeqEndWidth=SPEReadBin(ref,130,3) //  End Width for Sequential pulse (usec)
	Variable   PulseSeqStartDelay=SPEReadBin(ref,134,3) //  Start Delay for Sequential pulse (usec)
	Variable   PulseSeqEndDelay=SPEReadBin(ref,138,3) //  End Delay for Sequential pulse (usec)
	Variable   PulseSeqIncMode =SPEReadBin(ref,142,1) //  Increments: 1=Fixed, 2=Exponential
	Variable   PImaxUsed       =SPEReadBin(ref,144,1) // PI-Max type controller flag
	Variable   PImaxMode       =SPEReadBin(ref,146,1) // PI-Max mode
	Variable   PImaxGain       =SPEReadBin(ref,148,1) //  PI-Max Gain
	Variable   BackGrndApplied =SPEReadBin(ref,150,1) //  1 if background subtraction done
	Variable   PImax2nsBrdUsed =SPEReadBin(ref,152,1) //  T/F PI-Max 2ns Board Used
	Variable   minblk          =SPEReadBin(ref,154,6) //  min. # of strips per skips
	Variable   numminblk       =SPEReadBin(ref,156,6) //  # of min-blocks before geo skps
	Variable   SpecMirrorLocation1=SPEReadBin(ref,158,1) // Spectro Mirror Location, 0=Not Present
	Variable   SpecMirrorLocation2=SPEReadBin(ref,160,1) //  Spectro Mirror Location, 0=Not Present
//	Variable   SpecSlitLocation[4]=SPEReadBin(ref,162,1) //          162,1) //  Spectro Slit Location, 0=Not Present
	Variable   CustomTimingFlag=SPEReadBin(ref, 170,1) //  T/F Custom Timing Used
	String     ExperimentTimeLocal=SPEReadStr(ref, 172,TIMEMAX) //  Experiment Local Time as hhmmss\0
	String     ExperimentTimeUTC=SPEReadStr(ref, 179,TIMEMAX) // Experiment UTC Time as hhmmss\0
	Variable   ExposUnits      =SPEReadBin(ref, 186,1) //  User Units for Exposure
	Variable   ADCoffset       =SPEReadBin(ref, 188,6) //  ADC offset
	Variable   ADCrate         =SPEReadBin(ref, 190,6) //  ADC rate
	Variable   ADCtype         =SPEReadBin(ref, 192,6) //  ADC type
	Variable   ADCresolution   =SPEReadBin(ref, 194,6) //  ADC resolution
	Variable   ADCbitAdjust    =SPEReadBin(ref, 196,6) //  ADC bit adjust
	Variable   gain            =SPEReadBin(ref, 198,6) //  gain
	String     Comments1       =SPEReadStr(ref, 200,     COMMENTMAX) //  File Comments
	String     Comments2       =SPEReadStr(ref, 200+80,  COMMENTMAX) //  File Comments
	String     Comments3       =SPEReadStr(ref, 200+80*2,COMMENTMAX) //  File Comments
	String     Comments4       =SPEReadStr(ref, 200+80*3,COMMENTMAX) //  File Comments
	String     Comments5       =SPEReadStr(ref, 200+80*4,COMMENTMAX) //  File Comments
	Variable   geometric       =SPEReadBin(ref, 600,6) //  geometric ops: rotate 0x01,reverse 0x02, flip 0x04
	String     xlabel=SPEReadStr(ref,602 ,LABELMAX) // intensity display string
	Variable   cleans          =SPEReadBin(ref, 618,6) // cleans
	Variable   NumSkpPerCln    =SPEReadBin(ref, 620,6) // number of skips per clean.
	Variable   SpecMirrorPos1  =SPEReadBin(ref, 622,1) // Spectrograph Mirror Positions
	Variable   SpecMirrorPos2  =SPEReadBin(ref, 624,1) // Spectrograph Mirror Positions
	Variable   SpecSlitPos1    =SPEReadBin(ref, 626,3) // Spectrograph Slit Positions
	Variable   SpecSlitPos2    =SPEReadBin(ref, 630,3) // Spectrograph Slit Positions
	Variable   SpecSlitPos3    =SPEReadBin(ref, 634,3) // Spectrograph Slit Positions
	Variable   SpecSlitPos4    =SPEReadBin(ref, 638,3) // Spectrograph Slit Positions
	Variable   AutoCleansActive=SPEReadBin(ref, 642,1) // T/F
	Variable   UseContCleansInst=SPEReadBin(ref, 644,1) // T/F
	Variable   AbsorbStripNum  =SPEReadBin(ref, 646,1) // Absorbance Strip Number
	Variable   SpecSlitPosUnits=SPEReadBin(ref, 648,1) // Spectrograph Slit Position Units
	Variable   SpecGrooves     =SPEReadBin(ref, 650,3) //Spectrograph Grating Grooves
	Variable   srccmp          =SPEReadBin(ref, 654,1) //number of source comp. diodes
	Variable   ydim            =SPEReadBin(ref, 656,6) //y dimension of raw data.
	Variable   scramble        =SPEReadBin(ref, 658,1) //0=scrambled,1=unscrambled
	Variable   ContinuousCleansFlag=SPEReadBin(ref, 660,1) //T/F Continuous Cleans Timing Option
	Variable   ExternalTriggerFlag=SPEReadBin(ref, 662,1) //T/F External Trigger Timing Option
	Variable   lnoscan         =SPEReadBin(ref, 664,2) //Number of scans (Early WinX)
	Variable   lavgexp         =SPEReadBin(ref, 668,2) //Number of Accumulations
	Variable   ReadoutTime     =SPEReadBin(ref, 672,3) //Experiment readout time
	Variable   TriggeredModeFlag=SPEReadBin(ref, 676,1) //T/F Triggered Timing Option
//	String    Spare_2      =SPEReadStr(ref, 678,10) //
	String     sw_version      =SPEReadStr(ref, 688,FILEVERMAX) //Version of SW creating this file
	Variable   type            =SPEReadBin(ref, 704  ,1)
	//                 1 = new120 (Type II)
	//                 2 = old120 (Type I )           
	//                 3 = ST130                      
	//                 4 = ST121                      
	//                 5 = ST138                      
	//                 6 = DC131 (PentaMax)           
	//                 7 = ST133 (MicroMax/SpectroMax)
	//                 8 = ST135 (GPIB)               
	//                 9 = VICCD                      
	//                10 = ST116 (GPIB)               
	//                11 = OMA3 (GPIB)                
	//                12 = OMA4                       
	Variable   flatFieldApplied=SPEReadBin(ref, 706 ,1) // if flat field was applied.
//	String Spare_3         =SPEReadStr(ref, 708 ,16) // 
	Variable   kin_trig_mode   =SPEReadBin(ref, 724 ,1) //Kinetics Trigger Mode
	String     dlabel          =SPEReadStr(ref, 726 ,LABELMAX) //Data label.
	
	return(0)
End

Function SPEReadHeader2(ref)
	Variable ref

	Variable DATEMAX=10,TIMEMAX=7,COMMENTMAX=80
	Variable LABELMAX=16,FILEVERMAX=16,HDRNAMEMAX=120
	Variable ROIMAX=10
	
	Variable i
	
//	String    Spare_4    =SPEReadstr(ref, 742 ,436) //
	String     PulseFileName   =SPEReadStr(ref,1178,HDRNAMEMAX) //  Name of Pulser File with Pulse Widths/Delays (for Z-Slice)
	String     AbsorbFileName  =SPEReadStr(ref,1298,HDRNAMEMAX) // Name of Absorbance File (if File Mode)
	Variable   NumExpRepeats   =SPEReadBin(ref,1418,7) //  Number of Times experiment repeated
	Variable   NumExpAccums    =SPEReadBin(ref,1422,7) //  Number of Time experiment accumulated
	Variable   YT_Flag         =SPEReadBin(ref,1426,1) //  Set to 1 if this file contains YT data
	Variable   clkspd_us       =SPEReadBin(ref,1428,3) //  Vert Clock Speed in micro-sec
	Variable   HWaccumFlag     =SPEReadBin(ref,1432,1) //  set to 1 if accum done by Hardware.
	Variable   StoreSync       =SPEReadBin(ref,1434,1) //  set to 1 if store sync used
	Variable   BlemishApplied  =SPEReadBin(ref,1436,1) // set to 1 if blemish removal applied
	Variable   CosmicApplied   =SPEReadBin(ref,1438,1) //  set to 1 if cosmic ray removal applied
	Variable   CosmicType      =SPEReadBin(ref,1440,1) //  if cosmic ray applied, this is type
	Variable   CosmicThreshold =SPEReadBin(ref,1442,3) // Threshold of cosmic ray removal.  
	Variable   NumFrames       =SPEReadBin(ref,1446,2) //  number of frames in file.         
	Variable   MaxIntensity    =SPEReadBin(ref,1450,3) //  max intensity of data (future)    
	Variable   MinIntensity    =SPEReadBin(ref,1454,3) //  min intensity of data (future)    
	String     ylabel          =SPEReadStr(ref,1458,LABELMAX) //  y axis label.         
	Variable   ShutterType     =SPEReadBin(ref,1474,6) //  shutter type.         
	Variable   shutterComp     =SPEReadBin(ref,1476,3) //  shutter compensation time.        
	Variable   readoutMode     =SPEReadBin(ref,1480,6) //  readout mode, full,kinetics, etc  
	Variable   WindowSize      =SPEReadBin(ref,1482,6) //  window size for kinetics only.    
	Variable   clkspd          =SPEReadBin(ref,1484,6) //  clock speed for kinetics & frame transfer
	Variable   interface_type  =SPEReadBin(ref,1486,6) //  computer interface (isa-taxi, pci, eisa, etc.) 
	Variable   NumROIsInExperiment=SPEReadBin(ref,1488,1) //  May be more than the 10 allowed in this header (if 0, assume 1)
//	String    Spare_5      =SPEReadBin(ref,1490 ,16) //           
	Variable   controllerNum   =SPEReadBin(ref,1506,6) //  if multiple controller system will
	//     have controller number data came from.  
	//     this is a future item.      
	Variable   SWmade          =SPEReadBin(ref,1508,6) //  Which software package created this file 

	return(0)
End

Function SPEReadHeader3(ref)
	Variable ref

	Variable DATEMAX=10,TIMEMAX=7,COMMENTMAX=80
	Variable LABELMAX=16,FILEVERMAX=16,HDRNAMEMAX=120
	Variable ROIMAX=10
	
	Variable i
	Variable startx,endx,groupx,starty,endy,groupy

	Variable   NumROI          =SPEReadBin(ref,1510,1) //  number of ROIs used. if 0 assume 1.

	// ROI entries   (1512 - 1631)
	i=0
	do
		startx =SPEReadBin(ref,1512*i+12,6) //     left x start value.               
		endx   =SPEReadBin(ref,1514*i+12,6) //    right x value.                    
		groupx =SPEReadBin(ref,1516*i+12,6) //     amount x is binned/grouped in hw. 
		starty =SPEReadBin(ref,1518*i+12,6) //     top y start value.                
		endy   =SPEReadBin(ref,1520*i+12,6) //     bottom y value.                   
		groupy =SPEReadBin(ref,1522*i+12,6) //     amount y is binned/grouped in hw. 
		i+=1
	while(i<ROIMAX)
	//
	
	String     FlatField      =SPEReadStr(ref,1632,HDRNAMEMAX) //  Flat field file name.       
	String     background      =SPEReadStr(ref,1752,HDRNAMEMAX) //  background sub. file name.  
	String     blemish         =SPEReadStr(ref,1872,HDRNAMEMAX) //  blemish file name.          
	Variable   file_header_ver =SPEReadBin(ref,1992,3) //  version of this file header 
	// String     YT_Info         =SPEReadBin(ref,1996,1000) //  Reserved for YT information
	Variable   WinView_id      =SPEReadBin(ref,2996,2) //  == 0x01234567L if file created by WinX

	//                       START OF X CALIBRATION STRUCTURE (3000 - 3488)

	Variable/D offset_x        =SPEReadBin(ref,3000,4) //  offset for absolute data scaling
	Variable/D factor_x        =SPEReadBin(ref,3008,4) //  factor for absolute data scaling
	Variable     current_unit_x  =SPEReadBin(ref,3016,0) //  selected scaling unit           
//	Variable     reserved1_x     =SPEReadBin(ref,3017,0) //  reserved                        
	String    string_x         =SPEReadStr(ref,3018,40) //  special string for scaling      
//	String    reserved2_x      =SPEReadStr(ref,3058,40) //  reserved                        
	Variable    calib_valid_x    =SPEReadBin(ref,3098,0) //  flag if calibration is valid    
	Variable    input_unit_x     =SPEReadBin(ref,3099,0) //  current input units for "calib_value"
	Variable    polynom_unit_x   =SPEReadBin(ref,3100,0) //  linear UNIT and used in the "polynom_coeff"
	Variable    polynom_order_x  =SPEReadBin(ref,3101,0) //  ORDER of calibration POLYNOM    
	Variable    calib_count_x    =SPEReadBin(ref,3102,0) //  valid calibration data pairs    
//	Variable/D pixel_position_x[10]    =SPEReadBin(ref,3103,4) //  pixel pos. of calibration data  
//	Variable/D calib_value_x[10]       =SPEReadBin(ref,3183,4) //  calibration VALUE at above pos  
//	Variable/D polynom_coeff_x[6]      =SPEReadBin(ref,3263,4) //  polynom COEFFICIENTS            
	Variable/D laser_position_x=SPEReadBin(ref,3311,4) //  laser wavenumber for relativ WN 
//	String     reserved3_x     =SPEReadBin(ref,3319,0) //  reserved                        
	Variable   new_calib_flag_x=SPEReadBin(ref,3320,5) //  If set to 200, valid label below
	String     calib_label_x   =SPEReadStr(ref,3321,81) //  Calibration label (NULL term'd) 
	String     expansion_x     =SPEReadStr(ref,3402,87) //  Calibration Expansion area      
	
	//                         START OF Y CALIBRATION STRUCTURE (3489 - 3977)
	Variable/D offset_y        =SPEReadBin(ref,3489,4) //  offset for absolute data scaling
	Variable/D factor_y        =SPEReadBin(ref,3497,4) //  factor for absolute data scaling
	Variable     current_unit_y  =SPEReadBin(ref,3505,0) //  selected scaling unit           
//	Variable     reserved1_y     =SPEReadBin(ref,3506,0) //  reserved                        
	String     string_y        =SPEReadStr(ref,3507,40) //  special string for scaling      
//	String     reserved2_y     =SPEReadStr(ref,3547,40) //  reserved                        
	Variable     calib_valid_y   =SPEReadBin(ref,3587,0) //  flag if calibration is valid    
	Variable     input_unit_y    =SPEReadBin(ref,3588,0) //  current input units for "calib_value"
	Variable     polynom_unit_y  =SPEReadBin(ref,3589,0) //  linear UNIT and used in the "polynom_coeff"
	Variable     polynom_order_y =SPEReadBin(ref,3590,0) //  ORDER of calibration POLYNOM    
	Variable     calib_count_y   =SPEReadBin(ref,3591,0) //  valid calibration data pairs    
//	Variable/D pixel_position_y[10]    =SPEReadBin(ref,       3592,4) //  pixel pos. of calibration data  
//	Variable/D calib_value_y[10]       =SPEReadBin(ref,       3672,4) //  calibration VALUE at above pos  
//	Variable/D polynom_coeff_y[6]      =SPEReadBin(ref,       3752,4) //  polynom COEFFICIENTS            
	Variable/D laser_position_y=SPEReadBin(ref,3800,4) //  laser wavenumber for relativ WN 
//	Variable     reserved3_y     =SPEReadBin(ref,3808 ,0) // reserved                        
	Variable   new_calib_flag_y=SPEReadBin(ref,3809,5) //  If set to 200, valid label below
	String     calib_label_y   =SPEReadStr(ref,3810,81) //  Calibration label (NULL term'd) 
	String     expansion_y     =SPEReadStr(ref,3891,87) //  Calibration Expansion area      
	
	// //                          END OF CALIBRATION STRUCTURES
	
	String     Istring           =SPEReadStr(ref,3978,40) //  special intensity scaling string
//	String     Spare_6           =SPEReadStr(ref,4018,25) //  
	Variable   SpecType          =SPEReadBin(ref,4043,5) //  spectrometer type (acton, spex, etc.)
	Variable   SpecModel         =SPEReadBin(ref,4044,5) //  spectrometer model (type dependent)
	Variable   PulseBurstUsed    =SPEReadBin(ref,4045,5) //  pulser burst mode on/off
	Variable   PulseBurstCount   =SPEReadBin(ref,4046,7) //  pulser triggers per burst
	Variable/D ulseBurstPeriod   =SPEReadBin(ref,4050,4) //  pulser burst period (in usec)
	Variable   PulseBracketUsed  =SPEReadBin(ref,4058,5) //  pulser bracket pulsing on/off
	Variable   PulseBracketType  =SPEReadBin(ref,4059,5) //  pulser bracket pulsing type
	Variable/D PulseTimeConstFast=SPEReadBin(ref,4060,4) //  pulser slow exponential time constant (in usec)
	Variable/D PulseAmplitudeFast=SPEReadBin(ref,4068,4) //  pulser fast exponential amplitude constant
	Variable/D PulseTimeConstSlow=SPEReadBin(ref,4076,4) //  pulser slow exponential time constant (in usec)
	Variable/D PulseAmplitudeSlow=SPEReadBin(ref,4084,4) //  pulser slow exponential amplitude constant
	Variable   AnalogGain        =SPEReadBin(ref,4092,1) //  analog gain
	Variable   AvGainUsed        =SPEReadBin(ref,4094,1) //  avalanche gain was used
	Variable   AvGain            =SPEReadBin(ref,4096,1) // avalanche gain value
	Variable   lastvalue         =SPEReadBin(ref,4098,1) // Always the LAST value in the header
	// end of WINXHEADER_STRUCT
	
	return(0)
End
