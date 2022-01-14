;***********************************************
; csv_3.ncl
;
; Concepts illustrated:
;   - Reading a CSV file
;   - Using str_get_field to parse a string
;   - Reading an ASCII file with delimiters
;   - Removing quotes from a string
;
;***********************************************
;
; This is an example of reading a CSV file (comma separated values)
; that has quotes around every field.
;
begin
;;----- Parameters
  UNDEF     = -999.
  DataSet   = "MODIS.TERRA";"MODIS.AQUA";"AATSR";
  Site      = "Center-JPL500";"Spectacle-JPL503";"B45008-JPL502";"B45003-JPL501";
  if DataSet.eq."AATSR" then
       fields_use  =(/"ATSRDate","ATSRTime","ATSRDayNightFlag","ATSRSensorZenithNV",\
          "ATSR12000nmGoodNV","ATSR11000nmGoodNV","JPLCloudMaskFV","IWbSTMeanNVC",\
          "JPLDubiousDataMask"/)
       
        filename    = str_lower(DataSet)+".envisat.v000.iwb.3x3.LakeHuron"+Site+".csv"
  end if
  if DataSet.eq."MODIS.AQUA" .or. DataSet.eq."MODIS.TERRA" then
    fields_use  =(/"MOD02Date","MOD02Time","MOD02DayNightFlag", "MOD02SensorZenith",\
                   "MOD02B31NGood", "MOD02B32NGood", "JPLCloudMask","IWbSTMeanC",\
                   "JPLDubiousDataMask"/)
    filename    = str_lower(DataSet)+".005.iwb.3x3.LakeHuron"+Site+".csv"
  end if
  nfields     = dimsizes(fields_use) 
  ;print(nfields)
;;----- Read in file as array of strings so we can parse each line
  lines  = asciiread(filename,-1,"string")
  nlines = dimsizes(lines)-1   ; First line is a header
  
;;------ First line is name of each field
  delim       = ","
  field_names = str_split(lines(0),delim) 
 ;print(field_names)
  inds = new(nfields,integer)
  do nf = 0,nfields-1
    inds(nf) = ind(field_names.eq.fields_use(nf))
   ;print(inds(nf))
  end do
 
;;----- Read the whole file as a 2D array of strings
  fields = new((/nfields,nlines/),string)

;;----- Fields start at 1, not 0.
  do nf=0,nfields-1
    fields(nf,:) = str_get_field(lines(1:),inds(nf)+1,delim)    
  end do
 ;print(fields(7,1:10))
  printVarSummary(fields)
  delete(inds)
  print("======================")
;;----- Extract data
    fields!0="fldnm"  
    fields&fldnm=fields_use
    fields!1="time"
    fields&time= fields(0,:)
    printVarSummary(fields)
    DyNgt= fields(2,:)
    ;print(DyNgt)
    ; extract daytime data
    inds = ind(DyNgt.eq."D") 
    ;print(inds)
    if .not.all(ismissing(inds)) then
        DyData = fields(:,inds)
       ;printVarSummary(DyData)
       ;print(DyData(3,:))
        delete(inds)
        T      = tofloat(DyData(7,:))
        Date   = DyData(0,:)
        Time   = DyData(1,:)
        CldMsk = toint(DyData(6,:))
        QC     = toint(DyData(8,:))
        View   = tofloat(DyData(3,:))
        T@_FillValue = UNDEF
        indmis=ind(T.le.-99.)
        if .not.all(ismissing(indmis)) then
            T(indmis)=UNDEF
        end if
        T=T+273
        printMinMax(T,True)
       ;printMinMax(View,True)
        print(Date+" "+Time+" "+T)
        
;;----- Output data
        alist = [/Date,Time,T,View,CldMsk,QC/]
        write_table(str_lower(DataSet)+"."+Site+".txt", "w", alist, "%s,%s,%7.3f,%6.2f,%i,%i")
  
    end if
    
end
