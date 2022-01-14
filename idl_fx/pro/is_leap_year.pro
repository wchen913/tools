;---------------------------------------------------------------------------
; Document name: is_leap_year.pro
; Created by:    Wen Chen, AOSC/UMD, June 16, 2015
;---------------------------------------------------------------------------
;+
; NAME:
;      IS_LEAP_YEAR()
;
; PURPOSE: 
;       Check if a given year number is a leap year
;
; CATEGORY:
;       Utility, time
; 
; SYNTAX: 
;       Result = leap_year(year)
;
; INPUTS:
;       YEAR - Integer scalar, year number
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       RESULT - 1 or 0,  if YEAR is or is not a leap year
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS: 
;       None.
;
; COMMON:
;       None.
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, April 3, 1996, Liyun Wang, GSFC/ARC. Written
;
; CONTACT:
;       Liyun Wang, GSFC/ARC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;***************************************************************************
FUNCTION is_leap_year, year
;***************************************************************************
    yr=uint(year)
   IF ((yr MOD 4 )EQ 0) && (((yr MOD 100) NE 0) || ((yr MOD 400) EQ 0))THEN RETURN,1 ELSE RETURN, 0
END
;---------------------------------------------------------------------------
; End of 'leap_year.pro'.
;---------------------------------------------------------------------------
