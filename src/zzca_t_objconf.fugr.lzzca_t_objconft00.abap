*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZZCA_T_OBJCONF..................................*
DATA:  BEGIN OF STATUS_ZZCA_T_OBJCONF                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZZCA_T_OBJCONF                .
CONTROLS: TCTRL_ZZCA_T_OBJCONF
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZZCA_T_OBJCONF                .
TABLES: ZZCA_T_OBJCONF                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
