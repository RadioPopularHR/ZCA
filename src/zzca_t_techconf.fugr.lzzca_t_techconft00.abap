*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZZCA_T_TECHCONF.................................*
DATA:  BEGIN OF STATUS_ZZCA_T_TECHCONF               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZZCA_T_TECHCONF               .
CONTROLS: TCTRL_ZZCA_T_TECHCONF
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZZCA_T_TECHCONF               .
TABLES: ZZCA_T_TECHCONF                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
