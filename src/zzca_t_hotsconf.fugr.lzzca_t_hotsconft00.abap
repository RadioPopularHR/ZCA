*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZZCA_T_HOTSCONF.................................*
DATA:  BEGIN OF STATUS_ZZCA_T_HOTSCONF               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZZCA_T_HOTSCONF               .
CONTROLS: TCTRL_ZZCA_T_HOTSCONF
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZZCA_T_HOTSCONF               .
TABLES: ZZCA_T_HOTSCONF                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
