*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZZCA_T_PDFCONF..................................*
DATA:  BEGIN OF STATUS_ZZCA_T_PDFCONF                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZZCA_T_PDFCONF                .
CONTROLS: TCTRL_ZZCA_T_PDFCONF
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZZCA_T_PDFCONF                .
TABLES: ZZCA_T_PDFCONF                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
