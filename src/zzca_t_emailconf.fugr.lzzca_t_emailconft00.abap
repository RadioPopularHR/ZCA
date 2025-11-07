*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZZCA_T_EMAILCONF................................*
DATA:  BEGIN OF STATUS_ZZCA_T_EMAILCONF              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZZCA_T_EMAILCONF              .
CONTROLS: TCTRL_ZZCA_T_EMAILCONF
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZZCA_T_EMAILCONF              .
TABLES: ZZCA_T_EMAILCONF               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
