;Tuesday, Dec 2, 2014: Added line at end so that saving the file is optional
;Ha! It should be ready now...
;Saturday, Oct 17: This thing is not ready at all. I haven't changed anything as of yet to
;reflect the format of files outputted by Alfven_Stats_5
pro rdf_epop_ephemeris,filename,dat,outname

  tmplt_v               = 1.0
  tmplt_datastart       = 2
  tmplt_delimiter       = 32B
  tmplt_missingvalue    = !Values.F_NAN
  tmplt_commentsymbol   = ''
  tmplt_fieldcount      = 21
  tmplt_fieldtypes      = [3,3,4,4,4, $
                           4,4,4,4,4, $
                           4,4,4,4,4, $
                           4,4,4,4,4, $
                           3]
  tmplt_fieldnames      = ["YMD","HMS","XGEI","YGEI","ZGEI", $
                           "VXGEI","VYGEI","VZGEI","XGSM","YGSM", $
                           "ZGSM","GEOLAT","GEOLON","ALTITUDE","MAGLAT", $
                           "MAGLON","MLT","YAW","PITCH","ROLL", $
                           "attAccuracy"]
  tmplt_fieldlocations  = [0,9,17,28,40, $
                           49,58,65,73,85, $
                           95,108,114,120,129, $
                           135,140,147,154,161, $
                           169]
  tmplt_fieldgroups     = [0,1,2,3,4, $
                           5,6,7,8,9, $
                           10,11,12,13,14, $
                           15,16,17,18,19, $
                           20]

  tmplt                 = {VERSION:tmplt_v, $
                           DATASTART:tmplt_datastart, $
                           DELIMITER:tmplt_delimiter, $
                           MISSINGVALUE:tmplt_missingvalue, $
                           COMMENTSYMBOL:tmplt_commentsymbol, $
                           FIELDCOUNT:tmplt_fieldcount, $
                           FIELDTYPES:tmplt_fieldtypes, $
                           FIELDNAMES:tmplt_fieldnames, $
                           FIELDLOCATIONS:tmplt_fieldlocations, $
                           FIELDGROUPS:tmplt_fieldgroups}

  dat=read_ascii(filename,template=tmplt)
  
  IF KEYWORD_SET(outname) THEN save,dat,FILENAME=outname
  
  RETURN
END
  
