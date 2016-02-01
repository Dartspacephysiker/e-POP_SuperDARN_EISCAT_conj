;2016/02/01
;Kristina wants e-POP tracks from the day of the CAPER launch, which I believe was 2015/11/30
PRO JOURNAL__20160201__PLOT_EPOP_EPHEMERIS_DATA

  LOAD_EPOP_EPHEM,epop_ephem

  mMoll                          = MAP('Geographic', FILL_COLOR='light blue', $
                                       TITLE='Mollweide Projection')
  ;; conts                          = MAPCONTINENTS(/COUNTRIES, FILL_COLOR='beige')

  inds_29                        = WHERE(epop_ephem.ymd EQ 20151129 AND epop_ephem.hms GE 060000 AND epop_ephem.hms LE 120000)
  inds_30                        = WHERE(epop_ephem.ymd EQ 20151130 AND epop_ephem.hms GE 060000 AND epop_ephem.hms LE 120000)
  ephemPlot_29                   = PLOT(epop_ephem.geolon[inds_29],epop_ephem.geolat[inds_29], $
                                        NAME='November 29', $
                                        COLOR='BLUE', $
                                        THICK=3, $
                                        /OVERPLOT)
  ephemPlot_30                   = PLOT(epop_ephem.geolon[inds_30],epop_ephem.geolat[inds_30], $
                                        NAME='November 30', $
                                        COLOR='BLUE', $
                                        THICK=3, $
                                        /OVERPLOT)
  ephemLegend                    = LEGEND(TARGET=[ephemPlot_29,ephemPlot_30],/AUTO_TEXT_COLOR)
END