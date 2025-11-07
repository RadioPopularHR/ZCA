*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZZCA_T_IFCONFT..................................*
DATA:  BEGIN OF STATUS_ZZCA_T_IFCONFT                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZZCA_T_IFCONFT                .
CONTROLS: TCTRL_ZZCA_T_IFCONFT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZZCA_T_IFCONFT                .
TABLES: ZZCA_T_IFCONFT                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
