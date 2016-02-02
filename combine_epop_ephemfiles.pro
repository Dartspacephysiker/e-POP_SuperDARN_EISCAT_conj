;2016/02/01
;Kristina wants e-POP tracks from the day of the CAPER launch, which I believe was 2015/11/30
PRO COMBINE_EPOP_EPHEMFILES,epop_ephem

  ;;Input stuff
  ePOPDataDir           = '/SPENCEdata/Research/Cusp/database/e-POP/'
  ephemDir              = ePOPDataDir+'ASCII_ephemeris/'
  ephemFiles            = ['CAS_ephemeris_20151127_000000_235959.txt', $
                           'CAS_ephemeris_20151128_000000_235959.txt', $
                           'CAS_ephemeris_20151129_000000_235959.txt', $
                           'CAS_ephemeris_20151130_000000_235959.txt', $
                           'CAS_ephemeris_20151201_000000_235959.txt', $
                           'CAS_ephemeris_20151202_000000_235959.txt', $
                           'CAS_ephemeris_20151203_000000_235959.txt', $
                           'CAS_ephemeris_20151204_000000_235959.txt', $
                           'CAS_ephemeris_20151205_000000_235959.txt', $
                           'CAS_ephemeris_20151206_000000_235959.txt', $
                           'CAS_ephemeris_20151207_000000_235959.txt', $
                           'CAS_ephemeris_20151208_000000_235959.txt', $
                           'CAS_ephemeris_20151209_000000_235959.txt', $
                           'CAS_ephemeris_20151210_000000_235959.txt', $
                           'CAS_ephemeris_20151211_000000_235959.txt', $
                           'CAS_ephemeris_20151212_000000_235959.txt', $
                           'CAS_ephemeris_20151213_000000_235959.txt']
  nFiles                = N_ELEMENTS(ephemFiles)

  ;;Outputstuff
  hoyDia                = GET_TODAY_STRING(/DO_YYYYMMDD_FMT)
  outDir                = '/SPENCEdata/Research/Cusp/database/e-POP/'
  outEphem              = ePOPDataDir+'e-POP_ephemeris--' + STRMID(ephemFiles[0],14,8) + '-' + STRMID(ephemFiles[-1],14,8) + '.sav'
  
  gotFirst              = 0
  FOR i=0,nFiles-1 DO  BEGIN
     IF FILE_TEST(ephemDir+ephemFiles[i]) THEN BEGIN
        IF gotFirst THEN BEGIN
           RDF_EPOP_EPHEMERIS,ephemDir+ephemFiles[i],dat
           epop_ephem        = {YMD:[epop_ephem.YMD,dat.YMD], $
                                HMS:[epop_ephem.HMS,dat.HMS], $
                                XGEI:[epop_ephem.XGEI,dat.XGEI], $
                                YGEI:[epop_ephem.YGEI,dat.YGEI], $
                                ZGEI:[epop_ephem.ZGEI,dat.ZGEI], $
                                VXGEI:[epop_ephem.VXGEI,dat.VXGEI], $
                                VYGEI:[epop_ephem.VYGEI,dat.VYGEI], $
                                VZGEI:[epop_ephem.VZGEI,dat.VZGEI], $
                                XGSM:[epop_ephem.XGSM,dat.XGSM], $
                                YGSM:[epop_ephem.YGSM,dat.YGSM], $
                                ZGSM:[epop_ephem.ZGSM,dat.ZGSM], $
                                GEOLAT:[epop_ephem.GEOLAT,dat.GEOLAT], $
                                GEOLON:[epop_ephem.GEOLON,dat.GEOLON], $
                                ALTITUDE:[epop_ephem.ALTITUDE,dat.ALTITUDE], $
                                MAGLAT:[epop_ephem.MAGLAT,dat.MAGLAT], $
                                MAGLON:[epop_ephem.MAGLON,dat.MAGLON], $
                                MLT:[epop_ephem.MLT,dat.MLT], $
                                YAW:[epop_ephem.YAW,dat.YAW], $
                                PITCH:[epop_ephem.PITCH,dat.PITCH], $
                                ROLL:[epop_ephem.ROLL,dat.ROLL], $
                                ATTACCURACY:[epop_ephem.ATTACCURACY,dat.ATTACCURACY]}
        ENDIF ELSE BEGIN
           RDF_EPOP_EPHEMERIS,ephemDir+ephemFiles[i],epop_ephem
           gotFirst     = 1
        ENDELSE
     ENDIF ELSE BEGIN
        
     ENDELSE
  ENDFOR
  
  PRINT,'Saving e-POP ephemeris data to ' + outEphem + '...'
  SAVE,epop_ephem,FILENAME=outEphem
  
END