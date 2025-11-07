*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZZCA_T_KEYSCONF.................................*
DATA:  BEGIN OF STATUS_ZZCA_T_KEYSCONF               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZZCA_T_KEYSCONF               .
CONTROLS: TCTRL_ZZCA_T_KEYSCONF
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZZCA_T_KEYSCONF               .
TABLES: ZZCA_T_KEYSCONF                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
