*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZZCA_T_OBJTCONF.................................*
DATA:  BEGIN OF STATUS_ZZCA_T_OBJTCONF               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZZCA_T_OBJTCONF               .
CONTROLS: TCTRL_ZZCA_T_OBJTCONF
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZZCA_T_OBJTCONF               .
TABLES: ZZCA_T_OBJTCONF                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
