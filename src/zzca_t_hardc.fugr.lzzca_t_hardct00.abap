*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZZCA_T_HARDC....................................*
DATA:  BEGIN OF STATUS_ZZCA_T_HARDC                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZZCA_T_HARDC                  .
CONTROLS: TCTRL_ZZCA_T_HARDC
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZZCA_T_HARDC                  .
TABLES: ZZCA_T_HARDC                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
