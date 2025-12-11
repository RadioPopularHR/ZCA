*&---------------------------------------------------------------------*
*&  Include           ZZCA_COCKPIT_INTF_TOP
*&---------------------------------------------------------------------*

TABLES:
  kna1,
  vbak,
  mara.

CONSTANTS:
  gc_i             TYPE char1               VALUE 'I',  " ROFFSDF(RJPC): Ficheiros ++
  gc_eq            TYPE char2               VALUE 'EQ', " ROFFSDF(RJPC): Ficheiros ++
  gc_e             TYPE char1               VALUE 'E',
  gc_struct_name   TYPE x030l-tabname       VALUE 'MTREEITM',
  gc_ucomm_back    TYPE sy-ucomm            VALUE 'BACK',
  gc_in            TYPE zzca_int_direct     VALUE 'IN',
  gc_out           TYPE zzca_int_direct     VALUE 'OUT',
  gc_fcode_log     TYPE stb_button-function VALUE 'LOG',
  gc_fcode_obj_in  TYPE stb_button-function VALUE 'OBJETO_IN',
  gc_fcode_obj_out TYPE stb_button-function VALUE 'OBJETO_OUT',
  gc_fcode_rep     TYPE stb_button-function VALUE 'REP',
  gc_fcode_ref     TYPE stb_button-function VALUE 'REFRESH',
  gc_fcode_pdf     TYPE stb_button-function VALUE 'SHOW_PDF',
  gc_fcode_v_func  TYPE stb_button-function VALUE '&FUNC_VIEW', "RJPC
  gc_fcode_v_tech  TYPE stb_button-function VALUE '&TECH_VIEW',
  gc_webserv       TYPE zzca_int_type       VALUE 'W',
  gc_file          TYPE zzca_int_type       VALUE 'F', " ROFFSDF(RJPC): Ficheiros ++
  gc_stat_aviso    TYPE zzca_statws         VALUE 'W',
  gc_stat_err      TYPE zzca_statws         VALUE 'E',
  gc_stat_sucesso  TYPE zzca_statws         VALUE 'S'.


CONSTANTS:
  BEGIN OF gc_column,
    column1 TYPE tv_itmname VALUE 'Column1',
  END OF gc_column,
  BEGIN OF gc_nodekey,
    root   TYPE tv_nodekey VALUE 'Root',
    child1 TYPE tv_nodekey VALUE 'Child1',
  END OF gc_nodekey.

CLASS lcl_application DEFINITION DEFERRED.
CLASS cl_gui_cfw      DEFINITION LOAD.

TYPES:
  gty_item_table LIKE STANDARD TABLE OF mtreeitm WITH DEFAULT KEY,

  BEGIN OF gty_sel_scr,
    id_if   TYPE zzca_t_ifreg-id_if,
    id_exec TYPE zzca_t_ifreg-id_exec,
    erro    TYPE zzca_t_ifreg-erro,
  END OF gty_sel_scr,

  BEGIN OF lty_values,
    val TYPE zzca_key_value,
  END   OF lty_values.

DATA:
  gs_if_tcode   TYPE zzca_t_iftcode,
  gs_if_tcode_t TYPE zzca_t_iftcodet,
  gs_if_geo     TYPE zzca_t_ifcf_geo.


DATA:
  go_application       TYPE REF TO lcl_application,
  go_custom_container1 TYPE REF TO cl_gui_container,
  go_custom_container2 TYPE REF TO cl_gui_container,
  go_split             TYPE REF TO cl_gui_splitter_container,
  go_cont              TYPE REF TO cl_gui_docking_container,
  go_tree              TYPE REF TO cl_gui_column_tree,
  go_alv               TYPE REF TO cl_gui_alv_grid.

DATA:
  gt_ifconf         TYPE STANDARD TABLE OF zzca_s_ifconf,
  gt_ifconft        TYPE STANDARD TABLE OF zzca_t_ifconft,
  gt_ifreg          TYPE STANDARD TABLE OF zzca_t_ifreg,
  gt_search         TYPE STANDARD TABLE OF zzca_t_ifsearch,
  gt_ifkey          TYPE STANDARD TABLE OF zzca_t_ifkeys,
  gt_object         TYPE STANDARD TABLE OF zzca_t_ifobj,
  gt_message        TYPE STANDARD TABLE OF zzca_t_ifmsg,
  gt_func_fields    TYPE STANDARD TABLE OF zzca_t_iffunc,     "RJPC
  gt_techconf       TYPE STANDARD TABLE OF zzca_t_techconf,   "RJPC
  gt_funcconf       TYPE STANDARD TABLE OF zzca_t_funcconf,   "RJPC
  gt_data_2alv      TYPE STANDARD TABLE OF zzca_s_int_tone_cockpit_2alv,
  gt_dom_vals       TYPE STANDARD TABLE OF dd07v,
  gt_dom_vals_obj   TYPE STANDARD TABLE OF dd07v,
  gt_values_hotspot TYPE TABLE OF lty_values,
  gt_fielcat        TYPE lvc_t_fcat,
  gt_fielcat_func   TYPE lvc_t_fcat.                          "RJPC

DATA:
  gs_scr      TYPE gty_sel_scr,
  gs_layout   TYPE lvc_s_layo,
  gs_alv_data LIKE LINE OF gt_data_2alv.

DATA:
  gv_ok_code    TYPE sy-ucomm,
  gv_id_if      TYPE zzca_t_ifconf-id_if,
  gv_conf_error TYPE char1,
  gv_func_view  TYPE flag.                                    "RJPC

FIELD-SYMBOLS: <ft_data_2alv_func> TYPE STANDARD TABLE.       "RJPC
