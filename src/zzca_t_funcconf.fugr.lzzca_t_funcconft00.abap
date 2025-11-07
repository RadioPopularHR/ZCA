*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZZCA_T_FUNCCONF.................................*
DATA:  BEGIN OF STATUS_ZZCA_T_FUNCCONF               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZZCA_T_FUNCCONF               .
CONTROLS: TCTRL_ZZCA_T_FUNCCONF
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZZCA_T_FUNCCONF               .
TABLES: ZZCA_T_FUNCCONF                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
