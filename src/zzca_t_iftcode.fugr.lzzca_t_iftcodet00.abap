*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZZCA_T_IFTCODE..................................*
DATA:  BEGIN OF STATUS_ZZCA_T_IFTCODE                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZZCA_T_IFTCODE                .
CONTROLS: TCTRL_ZZCA_T_IFTCODE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZZCA_T_IFTCODE                .
TABLES: *ZZCA_T_IFTCODET               .
TABLES: ZZCA_T_IFTCODE                 .
TABLES: ZZCA_T_IFTCODET                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
