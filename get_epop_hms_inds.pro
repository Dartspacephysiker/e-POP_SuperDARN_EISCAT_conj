;2016/02/02  Attempting this e-POP conjunctive thing with Kristina, from the CAPER/RENU season last winter
FUNCTION GET_EPOP_HMS_INDS,hms_time,minT,maxT, $
                       N_TIME=n_time, $
                       N_NOT_TIME=n_not_time, $
                       LUN=lun

  COMPILE_OPT idl2

  IF N_ELEMENTS(lun) EQ 0 THEN lun = -1 ;;stdout

  time_i                           = WHERE(hms_time GE minT AND hms_time LE maxT,n_time,NCOMPLEMENT=n_not_time)

  IF time_i[0] EQ -1 THEN BEGIN
     PRINTF,lun,'No HMS entries found for the specified HMS time range!'
     STOP
  ENDIF

  PRINTF,lun,FORMAT='("N outside time range",T30,":",T35,I0)',n_not_time
  PRINTF,lun,'Losing ' + STRCOMPRESS(n_not_time,/REMOVE_ALL) + ' events due to time restriction'
  PRINTF,lun,''

  RETURN,time_i

END