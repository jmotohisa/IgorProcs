// for Transform axis: reciprocal axis in wavelength <-> eV
Function TransAx_myReciprocal(w, val)
              Wave/Z w
              Variable val
              
              if ( (val <= 0) )
                            return NaN
              endif
              
              return 1239.8/val
end
