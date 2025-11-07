*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZZCA_T_MSGTCONF.................................*
DATA:  BEGIN OF STATUS_ZZCA_T_MSGTCONF               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZZCA_T_MSGTCONF               .
CONTROLS: TCTRL_ZZCA_T_MSGTCONF
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZZCA_T_MSGTCONF               .
TABLES: ZZCA_T_MSGTCONF                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
