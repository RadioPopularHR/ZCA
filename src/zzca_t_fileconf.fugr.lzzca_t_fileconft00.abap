*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZZCA_T_FILECONF.................................*
DATA:  BEGIN OF STATUS_ZZCA_T_FILECONF               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZZCA_T_FILECONF               .
CONTROLS: TCTRL_ZZCA_T_FILECONF
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZZCA_T_FILECONF               .
TABLES: ZZCA_T_FILECONF                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
