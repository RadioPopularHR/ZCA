*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZZCA_T_IFCF_GEO.................................*
DATA:  BEGIN OF STATUS_ZZCA_T_IFCF_GEO               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZZCA_T_IFCF_GEO               .
CONTROLS: TCTRL_ZZCA_T_IFCF_GEO
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZZCA_T_IFCF_GEO               .
TABLES: ZZCA_T_IFCF_GEO                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
