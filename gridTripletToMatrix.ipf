#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma rtGlobals=1		// Use modern global access method.
#include <MatrixToXYZ>
 
//-----------------------------------------------------------------------------------------------------------------
//  The input must be an (N,3) triplet wave, whose x and y components are on a 
//   rectangular grid, so each (x,y) pair is unique.	The dim-0 ordering of each triplet can
//   be arbitrary, since the function will sort the row order and find the grid dimensions.
//   The resulting 2D wave containing the 'z' values on a scaled x-y grid is 'wz2D'.	
//    Internal waves are created as /FREE; change this if you wish to inspect them later.
//    There is no error checking on the input wave to ensure the triplet criteria ! ! !
function gridTripletToMatrix(triplet_wave)    //    sort the triplet order, and grid the data
    wave triplet_wave                                 //    triplet input wave in arbitray order
    variable Npts = DimSize(triplet_wave,0)
    Make/O/N=(Npts)/FREE wxR, wyR, wzR   //    convert to x,y,z
    MatrixOP/O wxR = col(triplet_wave,0)
    MatrixOP/O wyR = col(triplet_wave,1)
    MatrixOP/O wzR = col(triplet_wave,2)
    sort wyR, wxR, wyR, wzR                   //    sort all waves by y values
    variable Nx, Ny, i
    variable tol = 1e-6
    for(i=0;i<Npts;i+=1)                            //    find the dimension boundary
        if ( wyR[i+1]> (wyR[i] + tol* abs(wyR[i])) )  //  allow for numeric error
            Nx = i+1                                   //    Nx is the x dimension size
            break
        endif
    endfor
    Ny = Npts / Nx	                                     //    Ny is the y dimension size
    Make/O/N=0/FREE	    wxB, wyB, wzB    //    initial 'big' target wave for concatenating chunks
    Make/O/N=(Nx)/FREE wxS, wyS, wzS   //    Nx chunks ('S' for 'small')
    for(i=0; i<Ny; i+=1)
        wxS = wxR[p+i*Nx];    wyS = wyR[p+i*Nx];    wzS = wzR[p+i*Nx]	
        Sort wxS, wxS, wzS                         //    sort x and z in each chunk wave by x values
        Concatenate/NP  {wxS}, wxB;  Concatenate/NP  {wyS}, wyB;  Concatenate/NP  {wzS}, wzB
    endfor
    Make/O/N=((Nx*Ny), 3 )/FREE wSortedTriplet    //    triplet wave, grid sorted
    wSortedTriplet[][0]  =  wxB[p]
    wSortedTriplet[][1]  =  wyB[p]
    wSortedTriplet[][2]  =  wzB[p]
 
    MatrixOP/O wz2D = col(wSortedTriplet,2)    //    sorted z-values in a 1D wave
    Redimension/N=(Nx,Ny) wz2D
//   Make/O/N=(Nx, Ny) wz2D   //  alternate method:set up the rectangular gridded wave
//   wz2D  =  wz1D[p+Nx*q]      //  for 'z' values, and"unfold" 'z' values from 1D wave into 2D wave
    variable dx = wSortedTriplet[1][0]   - wSortedTriplet[0][0]
    variable dy = wSortedTriplet[Nx][1] - wSortedTriplet[0][1]
    variable FirstX = wSortedTriplet[0][0] ,  LastX = wSortedTriplet[Nx-1][0]    + dx
    variable FirstY = wSortedTriplet[0][1] , LastY = wSortedTriplet[Npts-1][1] + dy
    SetScale x, FirstX, LastX, ""  wz2D  //  using SetScale/I or/P gives scale precision errors
    SetScale y, FirstY, LastY,""  wz2D	
end	
//-----------------------------------------------------------------------------------------------------------------
function shuffle(Npts)    //    perform a random permutation of indices 0...Npts-1
    variable Npts
    make/O/N=(Npts) wPerm = p    //   will be used as sort key; initialize it
    variable i, j, temp
    for(i=Npts-1; i>0; i-=1)
        temp = wPerm[i]
        j = round(  i/2+enoise(i/2)  )   //   pick random index from remaining choices
        wPerm[i] = wPerm[j]             //  swap entries
        wPerm[j] = temp 
    endfor                                     //   wPerm is the final random sort key wave
end