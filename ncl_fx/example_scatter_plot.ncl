load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/ccm_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/wind_rose.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/calendar_decode2.ncl"
load "$nclfx/addmeta.ncl"
load "$nclfx/scatterplot.ncl"
begin
;*******************************
; specification and data put in 
;*******************************  

;++++ Head +++++
    vName    = "ssda" 
    Sat      = "DX" 
    version  = "v3.4"

    St       = "TAO"
    
    timeStep  = "day";"day";
    if timeStep.eq."mon"
		 nSt       = 17
         timestep  = "mon"
		 ymdStrt   = toint(20000101)
		 ymdEnd    = toint(20091231)
    else if timeStep.eq."day" then 
    	nSt      = 2 ;    
   		timestep  = "dy";"mon";
   		ymdStrt   = toint(20060101)
   		ymdEnd    = toint(20091231)
   end if
   end if

   pth	= "/data/crash/wchen/merge_cut_data/"

   file2= vName+"_"+Sat+version+"_4_"+St+"_"+nSt+"st"+"_"+\
		  timeStep+"_"+ymdStrt+"_"+ymdEnd+".nc" 
   file1 = vName+"_"+St+"_"+nSt+"st_"+\
		   timestep+"_"+ymdStrt+"_"+ymdEnd+".nc"

	scatterFlag = True
    if scatterFlag then
		
		optOutlier = True

	    pltpth  = "~/tmp/"
		wkstype = "eps"
		wksname = "testscatter"+"_"+vName+"_"+St+"_vs_"+Sat+version+"_"+\
				  nSt+"st"+"_"+timeStep+"_"+ymdStrt+"_"+ymdEnd
		if optOutlier then
			wksname = wksname+"outlierY"
		end if
    	 xlim	= (/0,500/)
         ylim	= xlim
        
          
         
         xlabel = "Observed"
         ylabel = "Estimated"
         
         capStr = Sat+version+". "+St+" : "+nSt+" Sites. "+\
				  "Time Res: "+timeStep+". Period: "+ymdStrt+" - "+ymdEnd	
         
    end if
;++++ Read Ground truth ++++ 
    print("Read Data")  
    fid		= 	addfile(pth+file1,"r")
       
	data1	= fid->$vName$
    data1   = (/tofloat(data1)/)
    data1@_FillValue = 1e+35
    ;printVarSummary(data)
    TIME	= fid->time
    x		= ndtooned(data1)
        
    lonst       = fid->lonst
    latst       = fid->latst
	delete(fid)

	
;++++ Read Estimated Data ++++   
	fid		= 	addfile(pth+file2,"r")
    data2	= fid->$vName$
    data2   = (/tofloat(data2)/)
	data2@_FillValue = -1000.
    y		= ndtooned(data2)

;************************************************
; plotting 
;************************************************
 if scatterFlag then
	
    scatter_bestfit_s5(x,y,(/wkstype,pltpth+wksname/),\
					  (/xlim,ylim/),(/capStr,xlabel,ylabel,"",""/),\
                      "circle",(/0.03,0.95,0.07/),optOutlier)



end

