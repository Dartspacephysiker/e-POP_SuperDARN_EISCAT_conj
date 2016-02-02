;2016/02/02
;Kristina wants to know about possible conjunctions during the rocket windows last winter
PRO JOURNAL__20160202__FIND_POSSIBLE_CONJUNCTIONS_DURING_CAPER_AND_RENU_WINDOWS

  outDir                         = '/SPENCEdata/Research/Cusp/Ideas/e-POP_SuperDARN_EISCAT_conj/data/'
  outFile                        = GET_TODAY_STRING(/DO_YYYYMMDD_FMT) + '--e-POP_cusp_conjunctions--ephemeris--20151127-1213.txt'

  LOAD_EPOP_EPHEM,epop_ephem

  timeRange                      = [060000,120000]
  latRange                       = [72,84]
  lonRange                       = [9,15]        ;in MLT
  hemi                           = 'NORTH'
  
  uniq_days                      = epop_ephem.ymd[UNIQ(epop_ephem.ymd)]
  nDays                          = N_ELEMENTS(uniq_days)

  mlt_i                          = GET_MLT_INDS(!NULL,lonRange[0],lonRange[1], $
                                                ;; DAYSIDE=dayside, $
                                                ;; NIGHTSIDE=nightside, $
                                                N_MLT=n_mlt, $
                                                N_OUTSIDE_MLT=n_outside_MLT, $
                                                DIRECT_MLTS=epop_ephem.mlt, $
                                                LUN=lun)

  ilat_i                         = GET_ILAT_INDS(!NULL,latRange[0],latRange[1], $
                                                 hemi, $
                                                 N_ILAT=n_ilat, $
                                                 N_NOT_ILAT=n_not_ilat, $
                                                 DIRECT_LATITUDES=epop_ephem.geolat, $
                                                 LUN=lun)
  
  time_i                         = GET_EPOP_HMS_INDS(epop_ephem.hms,timeRange[0],timeRange[1])

  

  ;;start combining
  region_i                       = CGSETINTERSECTION(mlt_i,ilat_i)
  IF region_i[0] EQ -1 THEN BEGIN
     PRINTF,lun,'Nope! e-POP was never in the right region.'
     STOP
  ENDIF
  
  time_region_i                  = CGSETINTERSECTION(region_i,time_i)
  IF time_region_i[0] EQ -1 THEN BEGIN
     PRINTF,lun,'Nope! e-POP was never in the right region at the right time.'
     STOP
  ENDIF
  
  final_i                        = time_region_i

  plotNames                      = !NULL
  day_i_list                     = LIST()
  day_nPoints                    = !NULL
  nGoodDays                      = 0
  plotColors                     = !NULL
  FOR i=0,nDays-1 DO BEGIN
     tDay                        = uniq_days[i]
     temp_i                      = WHERE(epop_ephem.ymd EQ tDay)
     candidate_i                 = CGSETINTERSECTION(temp_i,final_i)
     IF candidate_i[0] NE -1 THEN BEGIN
        plotNames                = [plotNames,STRCOMPRESS(tDay,/REMOVE_ALL)]
        day_i_list.add,candidate_i
        day_nPoints              = [day_nPoints,N_ELEMENTS(candidate_i)]
        nGoodDays++
        plotColors               = [[plotColors],[FIX(255*RANDOMU(seed,3))]]
     ENDIF
  ENDFOR

  PRINTF,lun,FORMAT='("Day",T15,"N points",T25,"min MLT",T35,"max MLT",T45,"min lat",T55,"max lat",T65,"e-POP time in region (m)")'
  statFmtStr                     = '(A11,T15,I0,T25,F0.2,T35,F0.2,T45,F0.2,T55,F0.2,T65,F0.2)'

  ;;open outputfile
  OPENW,outTextLun,outDir+outFile,/GET_LUN
  PRINTF,outTextLun,FORMAT='("YMD",T15,"HMS",T30,"MLT",T40,"MLAT",T50,"GEOLAT",T60,"ALT")'
  outFmtStr                      = '(I0,T15,I0,T30,F0.2,T40,F0.2,T50,F0.2,T60,F0.2)'

  FOR i=0,nGoodDays-1 DO BEGIN
     minMLT                      = MIN(epop_ephem.mlt[day_i_list[i]],MAX=maxMLT)
     minGeoLat                   = MIN(epop_ephem.geolat[day_i_list[i]],MAX=maxGeoLat)
     PRINTF,lun,FORMAT=statFmtStr,plotNames[i],day_nPoints[i],minMLT,maxMLT,minGeoLat,maxGeoLat,day_nPoints[i]*10

     temp_i                      = day_i_list[i]
     FOR j=0,day_nPoints[i]-1 DO BEGIN
        PRINTF,outTextLun,FORMAT=outFmtStr, $
               epop_ephem.ymd[temp_i[j]], $
               epop_ephem.hms[temp_i[j]], $
               epop_ephem.mlt[temp_i[j]], $
               epop_ephem.maglat[temp_i[j]], $
               epop_ephem.geolat[temp_i[j]], $
               epop_ephem.altitude[temp_i[j]]
     ENDFOR
     PRINTF,outTextLun,''
  ENDFOR

  ;;Get to plotting, but set up map first of all
  plotArr                        = MAKE_ARRAY(nGoodDays,/OBJ)
  map                            = MAP('PolarStereographic', $
                                       FILL_COLOR='light blue', $
                                       TITLE='e-POP Cusp Crossings', $
                                       LIMIT=[60,-10,90,170], $
                                       CENTER_LONGITUDE=80)

  grid                           = map.MAPGRID
  grid.LINESTYLE                 = "dotted"
  grid.LABEL_POSITION            = 0
  grid.FONT_SIZE                 =14
  
  mc                             = MAPCONTINENTS(/FILL_BACKGROUND, FILL_COLOR='gray')

  FOR i=0,nGoodDays-1 DO BEGIN
     plotArr[i]                  = PLOT(epop_ephem.geolon[day_i_list[i]],epop_ephem.geolat[day_i_list[i]], $
                                        NAME=plotNames[i], $
                                        COLOR=plotColors[*,i], $
                                        THICK=3, $
                                        LINESTYLE=' ', $
                                        SYMBOL="tu", $
                                        SYM_COLOR=plotColors[*,i], $
                                        SYM_FILLED=1, $
                                        /OVERPLOT)
  ENDFOR
  ephemLegend                    = LEGEND(TARGET=plotArr,/AUTO_TEXT_COLOR)

  PRINTF,lun,"Closing " + outDir + outFile + '...'
  CLOSE,outTextLun

END