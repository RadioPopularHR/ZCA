*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZZCA_T_LOGSCONF.................................*
DATA:  BEGIN OF STATUS_ZZCA_T_LOGSCONF               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZZCA_T_LOGSCONF               .
CONTROLS: TCTRL_ZZCA_T_LOGSCONF
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZZCA_T_LOGSCONF               .
TABLES: ZZCA_T_LOGSCONF                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
