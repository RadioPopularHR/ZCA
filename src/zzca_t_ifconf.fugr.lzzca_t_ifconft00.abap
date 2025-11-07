*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZZCA_T_IFCONF...................................*
DATA:  BEGIN OF STATUS_ZZCA_T_IFCONF                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZZCA_T_IFCONF                 .
CONTROLS: TCTRL_ZZCA_T_IFCONF
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZZCA_T_IFCONF                 .
TABLES: *ZZCA_T_IFCONFT                .
TABLES: ZZCA_T_IFCONF                  .
TABLES: ZZCA_T_IFCONFT                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
