load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/ccm_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/ccm_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/wind_rose.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "$nclfx/addmeta.ncl"
load "$nclfx/substring.ncl"

begin
;*******************************
; specification and data put in 
;******************************* 
  VarName   = "TQV"
  
  outputFlag = True
  plotFlag   = False
  lsmask     = False
     
   yy       = "04"
   mm       = "06"
   pthi     = "/data/srb2/wchen/LST/MERRA2/20"+yy+"/inst1_2d_int_nx/"
   ptho     = "/data/srb2/wchen/LST/GOES_E/input/20"+yy+"/test/20"+yy+mm+"/"    
   filbs    = "MERRA2_300.inst1_2d_int_Nx.20"+yy+mm+"*.nc4"
    
   fils = systemfunc ("ls "+pthi+filbs)
  ;print(fils)  
   f    = addfiles (fils, "r")
   
   VarNames  = getfilevarnames(f[0])
   print(VarNames)    
   indvar    = str_match_ind_ic(VarNames,VarName)
   print(indvar)  
   
   data      =  f[:]->$VarNames(indvar)$  
   data      = where(ismissing(data),-999.0,data)  
   data@_FillValue = -999.
   data      = data/10.0  ;kg/m2->g/cm2
   data@units="g cm-2"
   delete(data@missing_value)
   delete(data@fmissing_value)
   printVarSummary(data)
   printMinMax(data,True)
 
   orig =data(:,{25:50},{-125:-70})
    Opt                = True

    Opt@SrcTitle       = "MERRA2 water"

    Opt@DstGridType    = "0.05deg"         ; Destination grid description
    Opt@DstTitle       = "Global 0.05 degree resolution"
    Opt@DstLLCorner    = (/ 25, -125 /)
    Opt@DstURCorner    = (/ 50, -70 /)

    Opt@SrcGridMask    = where(.not.ismissing(orig),1,0)

    Opt@SrcRegional    = True             ; These are necessary
    Opt@DstRegional    = True

   ;Opt@InterpMethod   = "neareststod";"patch";"conserve"       ; Default is bilinear
    Opt@ForceOverwrite = True
    dataout = ESMF_regrid(orig,Opt)
    printVarSummary(dataout)
    printMinMax(dataout,True)
    geoinfo=(/25,50,-125,-70/)
     if lsmask then
                    lsm = fbindirread("/data/srb1/wchen/tools/mask/lsmask_us_S-N_W-E.dat", \
                          0, dimsizes(dataout), "integer")
                    lsm = addmeta(lsm,dimsizes(dataout),(/"lat","lon"/),geoinfo,"land sea mask"," ",-1,-1)
                    ;printVarSummary(lsm)
                    dataout = mask(dataout,lsm.eq.1,False)
            delete(lsm)
     end if ; lsmask

   if (outputFlag) then
    dataout=dataout(:,::-1,:);convert S->N to N->S
    printVarSummary(dataout)
   ;print(dataout(0:10,0))   
    ofilename = ptho+yy+mm+"pwt.dat"
    print(ofilename)
  ; exit
    system("rm -f "+ofilename)
    fbindirwrite(ofilename,dataout)
    system("ls "+ptho+"*pwt.dat")
   end if
  
    if plotFlag then
                tmp =dataout(689,:,:)
                printMinMax(tmp,True)
                print("Plotting")
                wks = gsn_open_wks("x11", "test")
                gsn_define_colormap(wks,"BlGrYeOrReVi200")  ; choose a color map; MPL_jet
                ;gsn_define_colormap(wks,"BlAqGrYeOrReVi200");

                res                     = True
                res@gsnMaximize         = True
                res@gsnAddCyclic        = False
                res@gsnSpreadColors     = True

                res@cnFillOn            = True
                res@cnFillMode          = "RasterFill"
                res@cnLinesOn           = False
                res@cnInfoLabelOn       = False
                res@cnLineLabelsOn      = False

                 res@cnLevelSelectionMode = "ManualLevels"
                ;res@cnLevelSpacingF      = 5
                ;res@cnMinLevelValF       = 0.945
                ;res@cnMaxLevelValF       = 0.999

                res@pmTickMarkDisplayMode = "Always"

                res@lbBoxLinesOn          = False
                res@lbBoxSeparatorLinesOn = False
               ;res@lbLabelStride         = 5

                res@mpMinLatF             = geoinfo(0)
                res@mpMaxLatF             = geoinfo(1)
                res@mpMinLonF             = geoinfo(2)
                res@mpMaxLonF             = geoinfo(3)

                ; turn on state boundaries; " USStates" ; "National"
                res@mpOutlineBoundarySets = "AllBoundaries"

                res@gsnLeftString         = "MERRA2pwt"
                res@gsnRightString        = "20"+yy+"/"+mm

                plot=gsn_csm_contour_map_ce(wks,tmp,res)
                ;draw(plot)
                ;frame(wks)
        end if

  
   ;tmp = data(0,:,:)
   ;wks = gsn_open_wks("x11", "check")
   ;plot=gsn_csm_contour_map_ce(wks,tmp,False)
           
end


