;2016/02/29 
;;K, RENU II was launched Dec 13 at 0734 UTC. On that day, EISCAT was pulling data 0700--~0831 UT.
PRO JOURNAL__20160229__EPOP_CONJUNCTIONS_WITH_EISCAT_WHEN_EISCAT_ON

  outDir                         = '/SPENCEdata/Research/Cusp/Ideas/e-POP_SuperDARN_EISCAT_conj/data/'
  pref                           = GET_TODAY_STRING(/DO_YYYYMMDD_FMT) + '--e-POP_EISCAT_conjunctions_when_EISCAT+was_on--ephemeris--20151127-1213'
  outFile                        = pref+'.txt'
  outPlot                        = pref+'.png'

  LOAD_EPOP_EPHEM,epop_ephem

  timeRange                      = [[063000,110000], $  ;1127
                                    [063000,110000], $  ;1128
                                    [063000,110000], $  ;1128
                                    [063000,110000], $  ;1129
                                    [060000,103000], $  ;1130
                                    [060000,103000], $  ;1201
                                    [060000,103000], $  ;1202
                                    [000000,000000], $  ;1203, no EISCAT data
                                    [064000,103000], $  ;1204
                                    [060000,103000], $  ;1204
                                    [000000,000000], $  ;1206, no EISCAT data
                                    [060000,103000], $  ;1207
                                    [060000,110000], $  ;1208
                                    [060000,110000], $  ;1209
                                    [060000,110000], $  ;1210
                                    [060000,110000], $  ;1211
                                    [060000,110000], $  ;1212
                                    [070000,083000]]    ;1213, launch day

  latRange                       = [70,88]
  lonRange                       = [6,18]        ;in MLT
  geoLonRange                    = [20,60]
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
  geolon_i                       = WHERE(epop_ephem.geolon GE geoLonRange[0] AND epop_ephem.geolon LE geoLonRange[1])

  ;;start combining
  region_i                       = CGSETINTERSECTION(mlt_i,ilat_i)
  IF region_i[0] EQ -1 THEN BEGIN
     PRINTF,lun,'Nope! e-POP was never in the right region.'
     STOP
  ENDIF
  
  region_i                       = CGSETINTERSECTION(region_i,geolon_i)
  IF region_i[0] EQ -1 THEN BEGIN
     PRINTF,lun,'Nope! e-POP was never in the right region.'
     STOP
  ENDIF
  
  plotNames                      = !NULL
  day_i_list                     = LIST()
  day_nPoints                    = !NULL
  nGoodDays                      = 0
  plotColors                     = !NULL
  FOR i=0,nDays-1 DO BEGIN
     tDay                        = uniq_days[i]
     temp_i                      = WHERE(epop_ephem.ymd EQ tDay)

     time_i                      = GET_EPOP_HMS_INDS(epop_ephem.hms,timeRange[0,i],timeRange[1,i])
     final_i                     = CGSETINTERSECTION(region_i,time_i)
     IF final_i[0] EQ -1 THEN BEGIN
        PRINTF,lun,'Nope! e-POP was never in the right region at the right time on ' + STRCOMPRESS(tDay,/REMOVE_ALL) 
     ENDIF ELSE BEGIN
        candidate_i              = CGSETINTERSECTION(temp_i,final_i)
        IF candidate_i[0] NE -1 THEN BEGIN
           plotNames             = [plotNames,STRCOMPRESS(tDay,/REMOVE_ALL)]
           day_i_list.add,candidate_i
           day_nPoints           = [day_nPoints,N_ELEMENTS(candidate_i)]
           nGoodDays++
           plotColors            = [[plotColors],[FIX(255*RANDOMU(seed,3))]]
        ENDIF
     ENDELSE
  ENDFOR

  PRINTF,lun,FORMAT='("Day",T15,"N points",T25,"min MLT",T35,"max MLT",T45,"min lat",T55,"max lat",T65,"e-POP time in region (m)")'
  statFmtStr                     = '(A11,T15,I0,T25,F0.2,T35,F0.2,T45,F0.2,T55,F0.2,T65,F0.2)'

  ;;open outputfile
  OPENW,outTextLun,outDir+outFile,/GET_LUN
  PRINTF,outTextLun,FORMAT='("YMD",T15,"HMS",T30,"MLT",T40,"MLAT",T50,"GEOLAT",T60,"GEOLON",T70,"ALT")'
  outFmtStr                      = '(I0,T15,I0,T30,F0.2,T40,F0.2,T50,F0.2,T60,F0.2,T70,F0.2)'

  FOR i=0,nGoodDays-1 DO BEGIN
     minMLT                      = MIN(epop_ephem.mlt[day_i_list[i]],MAX=maxMLT)
     minGeoLat                   = MIN(epop_ephem.geolat[day_i_list[i]],MAX=maxGeoLat)
     PRINTF,lun,FORMAT=statFmtStr,plotNames[i],day_nPoints[i],minMLT,maxMLT,minGeoLat,maxGeoLat,day_nPoints[i]*10

     ;;Check to see if it was near Svalbard
     near_Svalbard = WHERE(epop_ephem.geolon[day_i_list[i]] LE 40 AND epop_ephem.geolon[day_i_list[i]] GE 5 $
                           AND epop_ephem.geolat[day_i_list[i]] LE 85 AND epop_ephem.geolat[day_i_list[i]] GE 60)
     IF near_Svalbard[0] NE 0 THEN BEGIN
        PRINTF,lun,"!!!e-POP was near Svalbard on this day: " + plotNames[i]
     ENDIF

     temp_i                      = day_i_list[i]
     FOR j=0,day_nPoints[i]-1 DO BEGIN
        PRINTF,outTextLun,FORMAT=outFmtStr, $
               epop_ephem.ymd[temp_i[j]], $
               epop_ephem.hms[temp_i[j]], $
               epop_ephem.mlt[temp_i[j]], $
               epop_ephem.maglat[temp_i[j]], $
               epop_ephem.geolat[temp_i[j]], $
               epop_ephem.geolon[temp_i[j]], $
               epop_ephem.altitude[temp_i[j]]
     ENDFOR
     PRINTF,outTextLun,''
  ENDFOR

  ;;Get to plotting, but set up map first of all
  plotArr                        = MAKE_ARRAY(nGoodDays,/OBJ)
  map                            = MAP('PolarStereographic', $
                                       FILL_COLOR='light blue', $
                                       TITLE='e-POP overpasses Nov 27 through Dec 13 when EISCAT was ON', $
                                       LIMIT=[60,0,90,90], $
                                       CENTER_LONGITUDE=45)

  grid                           = map.MAPGRID
  grid.LINESTYLE                 = "dotted"
  grid.LABEL_POSITION            = 0
  grid.FONT_SIZE                 =14
  
  mc                             = MAPCONTINENTS(/FILL_BACKGROUND, FILL_COLOR='gray')
  
  plotted                        = 0
  FOR i=0,nGoodDays-1 DO BEGIN
     IF N_ELEMENTS(day_i_list[i]) GT 1 THEN BEGIN
        plotArr[i]               = PLOT(epop_ephem.geolon[day_i_list[i]],epop_ephem.geolat[day_i_list[i]], $
                                        NAME=plotNames[i], $
                                        COLOR=plotColors[*,i], $
                                        THICK=3, $
                                        LINESTYLE=' ', $
                                        SYMBOL="tu", $
                                        SYM_COLOR=plotColors[*,i], $
                                        SYM_FILLED=1, $
                                        /OVERPLOT)
        plotted++
     ENDIF ELSE BEGIN
        PRINTF,lun,"Only" + STRCOMPRESS(N_ELEMENTS(day_i_list[i]),/REMOVE_ALL) + " data points for " + plotNames[i]
     ENDELSE
  ENDFOR
  ephemLegend                    = LEGEND(/NORMAL, $
                                          POSITION=[0.95,0.9], $
                                          TARGET=plotArr, $
                                          /AUTO_TEXT_COLOR)

  IF plotted GT 0 THEN BEGIN
     PRINTF,lun,"Saving plot to " + outPlot
     map.save,outPlot  
  ENDIF

  PRINTF,lun,"Closing " + outDir + outFile + '...'
  CLOSE,outTextLun

END