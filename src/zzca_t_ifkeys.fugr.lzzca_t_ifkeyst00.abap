*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZZCA_T_IFKEYS...................................*
DATA:  BEGIN OF STATUS_ZZCA_T_IFKEYS                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZZCA_T_IFKEYS                 .
CONTROLS: TCTRL_ZZCA_T_IFKEYS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZZCA_T_IFKEYS                 .
TABLES: ZZCA_T_IFKEYS                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
