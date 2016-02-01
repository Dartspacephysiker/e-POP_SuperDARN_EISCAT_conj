;2016/02/01 Load that new e-POP ephemeris
PRO LOAD_EPOP_EPHEM,epop_ephem, $
                             DBDir=DBDir, $
                             DBFile=DBFile, $
                             FORCE_LOAD=force_load
                             LUN=lun

  COMPILE_OPT idl2

  IF N_ELEMENTS(lun) EQ 0 THEN lun       = -1         ;stdout

  IF KEYWORD_SET(force_load) THEN BEGIN
     PRINTF,lun,"Forcing load of e-POP ephem..."
     force_load                          = 1
  ENDIF

  DefDBDir                               = '/SPENCEdata/Research/Cusp/database/e-POP/'

  DefDBFile                              = 'e-POP_ephemeris--20151129-20151130.sav'

  IF N_ELEMENTS(DBDir) EQ 0 THEN DBDir   = DefDBDir
  IF N_ELEMENTS(DBFile) EQ 0 THEN DBFile = DefDBFile
  
  IF N_ELEMENTS(epop_ephem) EQ 0 OR KEYWORD_SET(force_load) THEN BEGIN
     IF KEYWORD_SET(force_load) THEN BEGIN
        PRINTF,lun,"Forcing load, whether or not we already have epop_ephem..."
     ENDIF
     IF FILE_TEST(DBDir+DBFile) THEN RESTORE,DBDir+DBFile
     IF epop_ephem EQ !NULL THEN BEGIN
        PRINT,"Couldn't load e-POP ephemeris!"
        STOP
     ENDIF
  ENDIF ELSE BEGIN
     PRINTF,lun,"There is already an epop_ephem struct loaded! Not loading " + DBFile
     DBFile                              = 'Previously loaded e-POP ephemeris'
  ENDELSE

END