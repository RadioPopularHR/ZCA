*&---------------------------------------------------------------------*
*&  Include           ZZCA_COCKPIT_INTF_F01
*&---------------------------------------------------------------------*

FORM get_data .
*

  TYPES:
    BEGIN OF lty_aux,
      key_type TYPE zzca_t_ifkeys-key_type,
      range    TYPE RANGE OF zzca_t_ifsearch-key_val,
    END   OF lty_aux.

  DATA:
    lt_aux   TYPE STANDARD TABLE OF lty_aux,
    lt_ifreg TYPE STANDARD TABLE OF zzca_t_ifreg.

  DATA:
    lr_vals TYPE RANGE OF zzca_t_ifsearch-key_val,
    lr_type TYPE RANGE OF zzca_t_ifsearch-key_type.

  DATA:
    ls_type  LIKE LINE OF lr_type,
    ls_aux   LIKE LINE OF lt_aux,
    ls_ifkey LIKE LINE OF gt_ifkey.

  DATA:
    lv_string TYPE string.

  FIELD-SYMBOLS:
    <lfs_r_any> TYPE STANDARD TABLE,
    <fs_ifconf> TYPE zzca_s_ifconf.

  DATA: lt_objconf  TYPE TABLE OF zzca_t_objconf,
        ls_objconf  LIKE LINE OF lt_objconf,

        lt_logsconf TYPE TABLE OF zzca_t_logsconf,
        ls_logsconf LIKE LINE OF lt_logsconf,

        lt_keysconf TYPE TABLE OF zzca_t_keysconf,
        ls_keysconf LIKE LINE OF lt_keysconf,

        lt_pdfconf  TYPE TABLE OF zzca_t_pdfconf,
        ls_pdfconf  LIKE LINE OF lt_pdfconf,

        lt_objtconf TYPE TABLE OF zzca_t_objtconf,
        ls_objtconf LIKE LINE OF lt_objtconf,

        lt_msgtconf TYPE TABLE OF zzca_t_msgtconf,
        ls_msgtconf LIKE LINE OF lt_msgtconf,

        lt_fileconf TYPE TABLE OF zzca_t_fileconf,
        ls_fileconf LIKE LINE OF lt_fileconf.
*


  IF gv_conf_error = abap_on.
    RETURN.
  ENDIF.

  LOOP AT gt_ifkey INTO ls_ifkey.

    UNASSIGN <lfs_r_any>.
    CLEAR: ls_aux, lv_string, ls_type.
    ls_aux-key_type = ls_ifkey-key_type.
    ls_type-sign    = 'I'.
    ls_type-option  = 'EQ'.
    ls_type-low     = ls_ifkey-key_type.
    APPEND ls_type TO lr_type.

    CONCATENATE ls_ifkey-select_options '[]'
           INTO lv_string.
    ASSIGN (lv_string) TO <lfs_r_any>.
    IF <lfs_r_any> IS ASSIGNED AND
       <lfs_r_any> IS NOT INITIAL.
      ls_aux-range = <lfs_r_any>.
      APPEND LINES OF ls_aux-range TO lr_vals.
      APPEND ls_aux TO lt_aux.

      UNASSIGN <lfs_r_any>.
      CLEAR: ls_aux, lv_string, ls_type.
      ls_aux-key_type = ls_ifkey-key_type.
      ls_type-sign    = 'I'.
      ls_type-option  = 'EQ'.
      ls_type-low     = ls_ifkey-key_type.
      APPEND ls_type TO lr_type.

    ENDIF.

  ENDLOOP.

  IF lt_aux IS NOT INITIAL.

    "Movimentos - Execuções
    SELECT *
      FROM (gs_if_geo-tab_ifsearch)
      INTO TABLE gt_search
     WHERE key_type IN lr_type
       AND key_val  IN lr_vals
       ORDER BY PRIMARY KEY.

    LOOP AT lt_aux INTO ls_aux.
      DELETE gt_search WHERE key_type  =  ls_aux-key_type
                         AND key_val NOT IN ls_aux-range.
    ENDLOOP.

    IF gt_search IS NOT INITIAL.

      SELECT *
        FROM (gs_if_geo-tab_reg_exec)
        INTO TABLE gt_ifreg
         FOR ALL ENTRIES IN gt_search
       WHERE id_if   = gt_search-id_if
         AND id_exec = gt_search-id_exec
        ORDER BY PRIMARY KEY.

      DELETE gt_ifreg WHERE id_if   NOT IN s_id_if
                        AND data    NOT IN s_data
                        AND hora    NOT IN s_hora
                        AND id_exec NOT IN s_exec
                        AND erro    NOT IN s_erro.

      CHECK gt_ifreg IS NOT INITIAL.

      "Mostrar todas as chaves do webservice não
      "só a chave de pesquisa
      REFRESH gt_search.
      SELECT *
        FROM (gs_if_geo-tab_ifsearch)
        INTO TABLE gt_search
         FOR ALL ENTRIES IN gt_ifreg
       WHERE id_if   = gt_ifreg-id_if
         AND id_exec = gt_ifreg-id_exec
         ORDER BY PRIMARY KEY.

      lt_ifreg = gt_ifreg.

      SORT lt_ifreg BY id_if.
      DELETE ADJACENT DUPLICATES FROM lt_ifreg COMPARING id_if.

      "Dados Mestre
      SELECT *
        FROM zzca_t_ifconf
        INTO CORRESPONDING FIELDS OF TABLE gt_ifconf
        FOR ALL ENTRIES IN lt_ifreg
        WHERE id_if  =  lt_ifreg-id_if
          AND active = 'X'
          AND group_if EQ gs_if_tcode-group_if
          ORDER BY PRIMARY KEY.

      CHECK gt_ifconf IS NOT INITIAL.

*     Objetos de Processamento
      SELECT *
      FROM zzca_t_objconf
      INTO CORRESPONDING FIELDS OF TABLE lt_objconf
      FOR ALL ENTRIES IN gt_ifconf
      WHERE id_if  =  gt_ifconf-id_if
        ORDER BY PRIMARY KEY.

      IF sy-subrc = 0.
        LOOP AT gt_ifconf ASSIGNING <fs_ifconf>.
          READ TABLE lt_objconf INTO ls_objconf WITH KEY id_if = <fs_ifconf>-id_if.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING ls_objconf TO <fs_ifconf>.
          ENDIF.
        ENDLOOP.
      ENDIF.

*     Logs
      SELECT *
      FROM zzca_t_logsconf
      INTO CORRESPONDING FIELDS OF TABLE lt_logsconf
      FOR ALL ENTRIES IN gt_ifconf
      WHERE id_if  =  gt_ifconf-id_if
        ORDER BY PRIMARY KEY.

      IF sy-subrc = 0.
        LOOP AT gt_ifconf ASSIGNING <fs_ifconf>.
          READ TABLE lt_logsconf INTO ls_logsconf WITH KEY id_if = <fs_ifconf>-id_if.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING ls_logsconf TO <fs_ifconf>.
          ENDIF.
        ENDLOOP.
      ENDIF.

*     Key search
      SELECT *
      FROM zzca_t_keysconf
      INTO CORRESPONDING FIELDS OF TABLE lt_keysconf
      FOR ALL ENTRIES IN gt_ifconf
      WHERE id_if  =  gt_ifconf-id_if
        ORDER BY PRIMARY KEY.

      IF sy-subrc = 0.
        LOOP AT gt_ifconf ASSIGNING <fs_ifconf>.
          READ TABLE lt_keysconf INTO ls_keysconf WITH KEY id_if = <fs_ifconf>-id_if.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING ls_keysconf TO <fs_ifconf>.
          ENDIF.
        ENDLOOP.
      ENDIF.

*     PDF
      SELECT *
      FROM zzca_t_pdfconf
      INTO CORRESPONDING FIELDS OF TABLE lt_pdfconf
      FOR ALL ENTRIES IN gt_ifconf
      WHERE id_if  =  gt_ifconf-id_if
        ORDER BY PRIMARY KEY.

      IF sy-subrc = 0.
        LOOP AT gt_ifconf ASSIGNING <fs_ifconf>.
          READ TABLE lt_pdfconf INTO ls_pdfconf WITH KEY id_if = <fs_ifconf>-id_if.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING ls_pdfconf TO <fs_ifconf>.
          ENDIF.
        ENDLOOP.
      ENDIF.

*     Tipos de Objeto
      SELECT *
      FROM zzca_t_objtconf
      INTO CORRESPONDING FIELDS OF TABLE lt_objtconf
      FOR ALL ENTRIES IN gt_ifconf
      WHERE id_if  =  gt_ifconf-id_if
        ORDER BY PRIMARY KEY.

      IF sy-subrc = 0.
        LOOP AT gt_ifconf ASSIGNING <fs_ifconf>.
          READ TABLE lt_objtconf INTO ls_objtconf WITH KEY id_if = <fs_ifconf>-id_if.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING ls_objtconf TO <fs_ifconf>.
          ENDIF.
        ENDLOOP.
      ENDIF.

*     Tipos de Mensagem
      SELECT *
      FROM zzca_t_msgtconf
      INTO CORRESPONDING FIELDS OF TABLE lt_msgtconf
      FOR ALL ENTRIES IN gt_ifconf
      WHERE id_if  =  gt_ifconf-id_if
        ORDER BY PRIMARY KEY.

      IF sy-subrc = 0.
        LOOP AT gt_ifconf ASSIGNING <fs_ifconf>.
          READ TABLE lt_msgtconf INTO ls_msgtconf WITH KEY id_if = <fs_ifconf>-id_if.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING ls_msgtconf TO <fs_ifconf>.
          ENDIF.
        ENDLOOP.
      ENDIF.

*     Ficheiros
      SELECT *
      FROM zzca_t_fileconf
      INTO CORRESPONDING FIELDS OF TABLE lt_fileconf
      FOR ALL ENTRIES IN gt_ifconf
      WHERE id_if  =  gt_ifconf-id_if
        ORDER BY PRIMARY KEY.

      IF sy-subrc = 0.
        LOOP AT gt_ifconf ASSIGNING <fs_ifconf>.
          READ TABLE lt_fileconf INTO ls_fileconf WITH KEY id_if = <fs_ifconf>-id_if.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING ls_fileconf TO <fs_ifconf>.
          ENDIF.
        ENDLOOP.
      ENDIF.

      CHECK gt_ifconf IS NOT INITIAL.

      "Textos
      SELECT *
        FROM zzca_t_ifconft
        INTO TABLE gt_ifconft
         FOR ALL ENTRIES IN gt_ifconf
       WHERE id_if = gt_ifconf-id_if
         AND spras = sy-langu
        ORDER BY PRIMARY KEY.

      "Visão Técnica
      SELECT *
        FROM zzca_t_techconf
        INTO TABLE gt_techconf
         FOR ALL ENTRIES IN gt_ifconf
       WHERE id_if = gt_ifconf-id_if
        ORDER BY PRIMARY KEY.

      "Visão Funcional
      SELECT *
        FROM zzca_t_funcconf
        INTO TABLE gt_funcconf
         FOR ALL ENTRIES IN gt_ifconf
       WHERE id_if = gt_ifconf-id_if
        ORDER BY PRIMARY KEY.

      "Objects
      SELECT *
        FROM (gs_if_geo-tab_ifobject)
        INTO TABLE gt_object
         FOR ALL ENTRIES IN gt_ifreg
       WHERE id_if   = gt_ifreg-id_if
         AND id_exec = gt_ifreg-id_exec
         ORDER BY PRIMARY KEY.

      "Message
      SELECT *
        FROM (gs_if_geo-tab_ifmessage)
        INTO TABLE gt_message
         FOR ALL ENTRIES IN gt_ifreg
       WHERE id_if   = gt_ifreg-id_if
         AND id_exec = gt_ifreg-id_exec
         ORDER BY PRIMARY KEY.

      "Functional View Fields
      SELECT *
        FROM (gs_if_geo-tab_iffuncview)
        INTO TABLE gt_func_fields
         FOR ALL ENTRIES IN gt_ifreg
       WHERE id_if   = gt_ifreg-id_if
         AND id_exec = gt_ifreg-id_exec
         ORDER BY PRIMARY KEY.

    ENDIF.

  ELSE.

    "Dados Mestre
    SELECT *
      FROM zzca_t_ifconf
      INTO CORRESPONDING FIELDS OF TABLE gt_ifconf
      WHERE id_if IN s_id_if
       AND active = 'X'
       AND group_if EQ gs_if_tcode-group_if
    ORDER BY PRIMARY KEY.

    CHECK gt_ifconf IS NOT INITIAL.

*   Objetos de Processamento
    SELECT *
     FROM zzca_t_objconf
     INTO CORRESPONDING FIELDS OF TABLE lt_objconf
     FOR ALL ENTRIES IN gt_ifconf
     WHERE id_if = gt_ifconf-id_if
   ORDER BY PRIMARY KEY.

    IF sy-subrc = 0.
      LOOP AT gt_ifconf ASSIGNING <fs_ifconf>.
        READ TABLE lt_objconf INTO ls_objconf WITH KEY id_if = <fs_ifconf>-id_if.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING ls_objconf TO <fs_ifconf>.
        ENDIF.
      ENDLOOP.
    ENDIF.

*   Logs
    SELECT *
     FROM zzca_t_logsconf
     INTO  CORRESPONDING FIELDS OF TABLE lt_logsconf
     FOR ALL ENTRIES IN gt_ifconf
     WHERE id_if = gt_ifconf-id_if
   ORDER BY PRIMARY KEY.

    IF sy-subrc = 0.
      LOOP AT gt_ifconf ASSIGNING <fs_ifconf>.
        READ TABLE lt_logsconf INTO ls_logsconf WITH KEY id_if = <fs_ifconf>-id_if.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING ls_logsconf TO <fs_ifconf>.
        ENDIF.
      ENDLOOP.
    ENDIF.

*   Key search
    SELECT *
    FROM zzca_t_keysconf
    INTO CORRESPONDING FIELDS OF TABLE lt_keysconf
    FOR ALL ENTRIES IN gt_ifconf
    WHERE id_if  =  gt_ifconf-id_if
      ORDER BY PRIMARY KEY.

    IF sy-subrc = 0.
      LOOP AT gt_ifconf ASSIGNING <fs_ifconf>.
        READ TABLE lt_keysconf INTO ls_keysconf WITH KEY id_if = <fs_ifconf>-id_if.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING ls_keysconf TO <fs_ifconf>.
        ENDIF.
      ENDLOOP.
    ENDIF.

*   PDF
    SELECT *
     FROM zzca_t_pdfconf
     INTO  CORRESPONDING FIELDS OF TABLE lt_pdfconf
     FOR ALL ENTRIES IN gt_ifconf
     WHERE id_if = gt_ifconf-id_if
   ORDER BY PRIMARY KEY.

    IF sy-subrc = 0.
      LOOP AT gt_ifconf ASSIGNING <fs_ifconf>.
        READ TABLE lt_pdfconf INTO ls_pdfconf WITH KEY id_if = <fs_ifconf>-id_if.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING ls_pdfconf TO <fs_ifconf>.
        ENDIF.
      ENDLOOP.
    ENDIF.

*   Tipos de Objeto
    SELECT *
     FROM zzca_t_objtconf
     INTO  CORRESPONDING FIELDS OF TABLE lt_objtconf
     FOR ALL ENTRIES IN gt_ifconf
     WHERE id_if = gt_ifconf-id_if
   ORDER BY PRIMARY KEY.

    IF sy-subrc = 0.
      LOOP AT gt_ifconf ASSIGNING <fs_ifconf>.
        READ TABLE lt_objtconf INTO ls_objtconf WITH KEY id_if = <fs_ifconf>-id_if.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING ls_objtconf TO <fs_ifconf>.
        ENDIF.
      ENDLOOP.
    ENDIF.

*   Tipos de Mensagem
    SELECT *
     FROM zzca_t_msgtconf
     INTO CORRESPONDING FIELDS OF TABLE lt_msgtconf
     FOR ALL ENTRIES IN gt_ifconf
     WHERE id_if = gt_ifconf-id_if
   ORDER BY PRIMARY KEY.

    IF sy-subrc = 0.
      LOOP AT gt_ifconf ASSIGNING <fs_ifconf>.
        READ TABLE lt_msgtconf INTO ls_msgtconf WITH KEY id_if = <fs_ifconf>-id_if.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING ls_msgtconf TO <fs_ifconf>.
        ENDIF.
      ENDLOOP.
    ENDIF.

*   Ficheiros
    SELECT *
     FROM zzca_t_fileconf
     INTO CORRESPONDING FIELDS OF TABLE lt_fileconf
     FOR ALL ENTRIES IN gt_ifconf
     WHERE id_if = gt_ifconf-id_if
   ORDER BY PRIMARY KEY.

    IF sy-subrc = 0.
      LOOP AT gt_ifconf ASSIGNING <fs_ifconf>.
        READ TABLE lt_fileconf INTO ls_fileconf WITH KEY id_if = <fs_ifconf>-id_if.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING ls_fileconf TO <fs_ifconf>.
        ENDIF.
      ENDLOOP.
    ENDIF.

    CHECK gt_ifconf IS NOT INITIAL.

    "Textos
    SELECT *
      FROM zzca_t_ifconft
      INTO TABLE gt_ifconft
       FOR ALL ENTRIES IN gt_ifconf
     WHERE id_if = gt_ifconf-id_if
       AND spras = sy-langu
      ORDER BY PRIMARY KEY.

    "Visão Técnica
    SELECT *
      FROM zzca_t_techconf
      INTO TABLE gt_techconf
       FOR ALL ENTRIES IN gt_ifconf
     WHERE id_if = gt_ifconf-id_if
      ORDER BY PRIMARY KEY.

    "Visão Funcional
    SELECT *
      FROM zzca_t_funcconf
      INTO TABLE gt_funcconf
       FOR ALL ENTRIES IN gt_ifconf
     WHERE id_if = gt_ifconf-id_if
      ORDER BY PRIMARY KEY.

    "Movimentos - Execuções
    SELECT *
      FROM (gs_if_geo-tab_reg_exec)
      INTO TABLE gt_ifreg
       FOR ALL ENTRIES IN gt_ifconf
     WHERE id_if = gt_ifconf-id_if
       AND data    IN s_data
       AND hora    IN s_hora
       AND id_exec IN s_exec
       AND erro    IN s_erro
      ORDER BY PRIMARY KEY.

    CHECK gt_ifreg IS NOT INITIAL.

    SELECT *
      FROM (gs_if_geo-tab_ifsearch)
      INTO TABLE gt_search
       FOR ALL ENTRIES IN gt_ifreg
     WHERE id_if   = gt_ifreg-id_if
       AND id_exec = gt_ifreg-id_exec
       ORDER BY PRIMARY KEY.

    "Objects
    SELECT *
      FROM (gs_if_geo-tab_ifobject)
      INTO TABLE gt_object
       FOR ALL ENTRIES IN gt_ifreg
     WHERE id_if   = gt_ifreg-id_if
       AND id_exec = gt_ifreg-id_exec
       ORDER BY PRIMARY KEY.

    "Message
    SELECT *
      FROM (gs_if_geo-tab_ifmessage)
      INTO TABLE gt_message
       FOR ALL ENTRIES IN gt_ifreg
     WHERE id_if   = gt_ifreg-id_if
       AND id_exec = gt_ifreg-id_exec
       ORDER BY PRIMARY KEY.

    "Functional View Fields
    SELECT *
      FROM (gs_if_geo-tab_iffuncview)
      INTO TABLE gt_func_fields
       FOR ALL ENTRIES IN gt_ifreg
     WHERE id_if   = gt_ifreg-id_if
       AND id_exec = gt_ifreg-id_exec
       ORDER BY PRIMARY KEY.

  ENDIF.

ENDFORM.                    "get_data
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM display_data.

  IF gt_ifreg IS INITIAL.
    "Não foram selecionados dados.
    MESSAGE s001 DISPLAY LIKE gc_e.
    RETURN.
  ENDIF.

  CALL SCREEN 1.

ENDFORM.                    "display_data
*&---------------------------------------------------------------------*
*& Form CREATE_AND_INIT_TREE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM create_and_init_tree.
*
  DATA:
    lt_node_table TYPE treev_ntab,
    lt_item_table TYPE gty_item_table,
    lt_iexp       TYPE STANDARD TABLE OF tv_nodekey,
    lt_events     TYPE cntl_simple_events.

  DATA:
    ls_event            TYPE cntl_simple_event,
    ls_node             TYPE treev_node,
    ls_hierarchy_header TYPE treev_hhdr.

  DATA:
    lv_0001 TYPE sydynnr VALUE '0001'.
*

  "Criar classe local para handler
  CREATE OBJECT go_application.

  "Criar container
  PERFORM create_full_dock_container USING sy-repid
                                           lv_0001
                                  CHANGING go_cont.

  "Criar Split
  CREATE OBJECT go_split
    EXPORTING
      parent                  = go_cont
      rows                    = 1
      columns                 = 2
      no_autodef_progid_dynnr = abap_true.

  "Definir zona de split
  go_split->set_column_width( EXPORTING id    = 1
                                        width = 35 ).

  "Criar cabeçalho da hierarquia
  CONCATENATE TEXT-roo gs_if_tcode-land1 INTO ls_hierarchy_header-heading SEPARATED BY space.
  ls_hierarchy_header-width = 35.
  "Criar container para ALV tree
  go_custom_container1 = go_split->get_container( row    = 1
                                                  column = 1 ).

  "Criar ALV Tree
  CREATE OBJECT go_tree
    EXPORTING
      parent                = go_custom_container1
      node_selection_mode   = cl_gui_column_tree=>node_sel_mode_single
      item_selection        = abap_true
      hierarchy_column_name = gc_column-column1
      hierarchy_header      = ls_hierarchy_header.

  "Registar Eventos
  ls_event-eventid = cl_gui_column_tree=>eventid_button_click.
  ls_event-appl_event = abap_true.
  APPEND ls_event TO lt_events.
  ls_event-eventid = cl_gui_column_tree=>eventid_item_double_click.
  ls_event-appl_event = abap_true.
  APPEND ls_event TO lt_events.

  CALL METHOD go_tree->set_registered_events
    EXPORTING
      events                    = lt_events
    EXCEPTIONS
      cntl_error                = 1
      cntl_system_error         = 2
      illegal_event_combination = 3.

* Adicionanar Handler local para os eventos registados
  SET HANDLER go_application->handle_button_click FOR go_tree.
  SET HANDLER go_application->handle_item_double_click FOR go_tree.

  "Definir estrutura e dados da ALV Tree
  PERFORM build_node_and_item_table USING lt_node_table
                                          lt_item_table.

  "Preencher ALV Tree
  CALL METHOD go_tree->add_nodes_and_items
    EXPORTING
      node_table                     = lt_node_table
      item_table                     = lt_item_table
      item_table_structure_name      = gc_struct_name
    EXCEPTIONS
      failed                         = 1
      cntl_system_error              = 3
      error_in_tables                = 4
      dp_error                       = 5
      table_structure_name_not_found = 6.

  REFRESH lt_iexp.

  LOOP AT lt_node_table INTO ls_node WHERE isfolder IS NOT INITIAL.
    APPEND ls_node-node_key TO lt_iexp.
  ENDLOOP.

  "Expandir todos os filhos
  CALL METHOD go_tree->expand_nodes
    EXPORTING
      node_key_table          = lt_iexp
    EXCEPTIONS
      failed                  = 1
      cntl_system_error       = 2
      error_in_node_key_table = 3
      dp_error                = 4
      OTHERS                  = 5.
  IF sy-subrc <> 0.
    CLEAR go_custom_container2.
  ENDIF.

  "Criar container para ALV de Logs
  go_custom_container2 = go_split->get_container( row    = 1
                                                  column = 2 ).

  "Assignar ALV de logs ao container
  CREATE OBJECT go_alv
    EXPORTING
      i_parent = go_custom_container2.

* Criar ALV event handler
  CREATE OBJECT go_alv_toolbar
    EXPORTING
      io_alv_grid = go_alv.

* Adicionanar Handler local para os eventos
  SET HANDLER go_alv_toolbar->on_toolbar           FOR go_alv.
  SET HANDLER go_alv_toolbar->on_hotspot_click     FOR go_alv.
  SET HANDLER go_alv_toolbar->handle_user_command  FOR go_alv.



ENDFORM.                    "create_and_init_tree
*&---------------------------------------------------------------------*
*&      Form  CREATE_FULL_DOCK_CONTAINER
*&---------------------------------------------------------------------*
FORM create_full_dock_container USING uv_repid TYPE syrepid
                                      uv_dynnr TYPE sydynnr
                             CHANGING cv_o_dock TYPE REF TO cl_gui_docking_container.
*
  DATA:
    lo_consumer       TYPE REF TO cl_gui_props_consumer.

  DATA:
    ls_metric_factors TYPE cntl_metric_factors.

  DATA:
    lv_width          TYPE i.
*

  lo_consumer = cl_gui_props_consumer=>create_consumer( ).
  ls_metric_factors = lo_consumer->get_metric_factors( ).

  CREATE OBJECT cv_o_dock
    EXPORTING
      repid                       = uv_repid
      dynnr                       = uv_dynnr
      side                        = cl_gui_docking_container=>dock_at_left
      metric                      = cl_gui_control=>metric_pixel
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.
  IF sy-subrc <> 0.
    CLEAR lv_width.
  ENDIF.

  lv_width = ls_metric_factors-screen-x.

  CALL METHOD cv_o_dock->set_width
    EXPORTING
      width = lv_width.

ENDFORM.                    " CREATE_FULL_DOCK_CONTAINER
*&---------------------------------------------------------------------*
*&      Form  BUILD_NODE_AND_ITEM_TABLE
*&---------------------------------------------------------------------*
FORM build_node_and_item_table  USING ut_node_table TYPE treev_ntab
                                      ut_item_table TYPE gty_item_table.
*
  DATA:
    ls_t001_ifconf  LIKE LINE OF gt_ifconf,
    ls_t001_ifconft LIKE LINE OF gt_ifconft,
    ls_item         LIKE LINE OF ut_item_table,
    ls_node         LIKE LINE OF ut_node_table.

  DATA:
    lv_index TYPE sy-tabix.
*


* Criar nodulo Pai(hierarquia)
  ls_node-node_key = gc_nodekey-root.
  ls_node-hidden   = space.
  ls_node-disabled = space.
  ls_node-isfolder = abap_true.
  APPEND ls_node TO ut_node_table.

* Criar elemento pai(dados)
  ls_item-node_key  = gc_nodekey-root.
  ls_item-item_name = gc_column-column1.
  ls_item-class     = cl_gui_column_tree=>item_class_text.
  ls_item-text      = gs_if_tcode_t-descr.
  APPEND ls_item TO ut_item_table.

* --> Begin of Mod [INETUM-SDF](LCS): #Alt. Cockpit - Nó dependente de obj Log 09.01.2025 10:31:34
*  READ TABLE gt_ifconf TRANSPORTING NO FIELDS WITH KEY type_if = gc_webserv
*                                                       active  = abap_on.
*  IF sy-subrc EQ 0.
*    "Nó WebServices
*    CLEAR ls_node.
*    ls_node-node_key = gc_webserv.
*    ls_node-isfolder = abap_true.
*    ls_node-relatkey  = gc_nodekey-root.
*    ls_node-relatship = cl_gui_column_tree=>relat_last_child.
*    APPEND ls_node TO ut_node_table.
*
**   Nó WebServices(dados)
*    ls_item-node_key  = gc_webserv.
*    ls_item-class     = cl_gui_column_tree=>item_class_text.
*    ls_item-text      = TEXT-006.
*    APPEND ls_item TO ut_item_table.
*  ENDIF.



  DATA(lt_ifconf) = gt_ifconf[].
  SORT lt_ifconf BY log_object ASCENDING.

  DELETE ADJACENT DUPLICATES FROM lt_ifconf COMPARING log_object.

  LOOP AT lt_ifconf INTO DATA(ls_ifconf).
    "Nó = Objeto de Log
    CLEAR ls_node.
    ls_node-node_key = ls_ifconf-log_object.
    ls_node-isfolder = abap_true.
    ls_node-relatkey = gc_nodekey-root.
    ls_node-relatship = cl_gui_column_tree=>relat_last_child.

    APPEND ls_node TO ut_node_table.

    "Texto do Nó
    ls_item-node_key = ls_ifconf-log_object.
    ls_item-class = cl_gui_column_tree=>item_class_text.

    SELECT SINGLE objtxt
      INTO @DATA(lv_objtxt)
      FROM balobjt
      WHERE object = @ls_ifconf-log_object.

    IF sy-subrc IS INITIAL.
      ls_item-text = lv_objtxt.
    ENDIF.

    APPEND ls_item TO ut_item_table.
  ENDLOOP.
* <-- end of mod [inetum-sdf](lcs): #alt. cockpit - nó dependente de obj log 09.01.2025 10:31:34

* --> roffsdf(rjpc): ficheiros
  READ TABLE gt_ifconf TRANSPORTING NO FIELDS WITH KEY type_if = gc_file
                                                       active  = abap_on.
  IF sy-subrc EQ 0.
    "Nó Ficheiros
    CLEAR ls_node.
    ls_node-node_key = gc_file.
    ls_node-isfolder = abap_true.
    ls_node-relatkey  = gc_nodekey-root.
    ls_node-relatship = cl_gui_column_tree=>relat_last_child.
    APPEND ls_node TO ut_node_table.

*   Nó Ficheiros(dados)
    ls_item-node_key  = gc_file.
    ls_item-class     = cl_gui_column_tree=>item_class_text.
    ls_item-text      = TEXT-009.
    APPEND ls_item TO ut_item_table.
  ENDIF.
* <-- ROFFSDF(RJPC): Ficheiros

  LOOP AT gt_ifconf INTO ls_t001_ifconf.

    CLEAR lv_index.
    lv_index = sy-tabix.

    "Criar nodulos filhos(hierarquia)
    CLEAR ls_node.
    ls_node-node_key  = lv_index.
*    ls_node-relatkey  = gc_nodekey-root.
    ls_node-relatship = cl_gui_column_tree=>relat_last_child.
    ls_node-hidden = space.
    ls_node-disabled = space.
    ls_node-isfolder = space.
    CLEAR ls_node-n_image.
    CLEAR ls_node-exp_image.

* --> Begin of Mod [INETUM-SDF](LCS): #alt. cockpit - nó dependente de obj log 09.01.2025 10:44:04
*    CASE ls_t001_ifconf-type_if.
*      WHEN gc_webserv.
*
*        ls_node-relatkey  = gc_webserv.
*
*        CASE ls_t001_ifconf-direction.
*          WHEN gc_in.
*            ls_node-n_image   = icon_incoming_object.
*            ls_node-exp_image = icon_incoming_object.
*          WHEN gc_out.
*            ls_node-n_image   = icon_outgoing_object.
*            ls_node-exp_image = icon_outgoing_object.
*        ENDCASE.
*
*      WHEN gc_file. " ROFFSDF(RJPC): Ficheiros ++
*        ls_node-relatkey  = gc_file.
*        CASE ls_t001_ifconf-direction.
*          WHEN gc_in.
*            ls_node-n_image   = icon_previous_object.
*            ls_node-exp_image = icon_previous_object.
*          WHEN gc_out.
*            ls_node-n_image   = icon_next_object.
*            ls_node-exp_image = icon_next_object.
*        ENDCASE.
*        " ROFFSDF(RJPC): Ficheiros ++
*    ENDCASE.

    ls_node-relatkey = ls_t001_ifconf-log_object.

    CASE ls_t001_ifconf-direction.
      WHEN gc_in.
        ls_node-n_image   = icon_incoming_object.
        ls_node-exp_image = icon_incoming_object.
      WHEN gc_out.
        ls_node-n_image   = icon_outgoing_object.
        ls_node-exp_image = icon_outgoing_object.
    ENDCASE.
* <-- End of Mod [INETUM-SDF](LCS): #alt. cockpit - nó dependente de obj log 09.01.2025 10:44:04

    APPEND ls_node TO ut_node_table.

    "Criar elementos filhos(dados)
    CLEAR ls_item.
    ls_item-node_key  = lv_index.
    ls_item-item_name = gc_column-column1.
    ls_item-class = cl_gui_column_tree=>item_class_text.

    CLEAR ls_t001_ifconft.
    READ TABLE gt_ifconft INTO ls_t001_ifconft
    WITH KEY id_if = ls_t001_ifconf-id_if.
    IF sy-subrc = 0.
      ls_item-text = ls_t001_ifconft-descr.
    ENDIF.

    APPEND ls_item TO ut_item_table.
  ENDLOOP.

ENDFORM.                    " BUILD_NODE_AND_ITEM_TABLE
*&---------------------------------------------------------------------*
*& Form USER_COMMAND_0001
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM user_command_0001 .

  CASE gv_ok_code.
    WHEN gc_ucomm_back. " Terminar programa
      IF NOT go_custom_container1 IS INITIAL.
        CALL METHOD go_custom_container1->free
          EXCEPTIONS
            cntl_system_error = 1
            cntl_error        = 2.
        IF sy-subrc = 0.
          FREE go_custom_container1.
          FREE go_tree.
        ENDIF.
      ENDIF.
      LEAVE TO SCREEN 0.

    WHEN gc_fcode_v_tech.
      CLEAR gv_func_view.
      MESSAGE s034 DISPLAY LIKE 'W'. " Selecione a interface pretendida.
    WHEN gc_fcode_v_func.
      gv_func_view = abap_true.
      MESSAGE s034 DISPLAY LIKE 'W'. " Selecione a interface pretendida.

  ENDCASE.

  CLEAR gv_ok_code.


ENDFORM.                    "user_command_0001
*&---------------------------------------------------------------------*
*& Form MOSTRA_2_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM mostra_2_alv USING p_node_key TYPE any.
*
  DATA:
     ls_t001_ifconf LIKE LINE OF gt_ifconf.

  DATA:
     lv_index TYPE p.
*

  "Obter linha
  CALL FUNCTION 'MOVE_CHAR_TO_NUM'
    EXPORTING
      chr             = p_node_key
    IMPORTING
      num             = lv_index
    EXCEPTIONS
      convt_no_number = 1
      convt_overflow  = 2
      OTHERS          = 3.

  CHECK sy-subrc = 0.

  lv_index  = p_node_key.

  READ TABLE gt_ifconf INTO ls_t001_ifconf INDEX lv_index.
  CHECK sy-subrc = 0.

  CLEAR gv_id_if.
  gv_id_if = ls_t001_ifconf-id_if.

  "Criar tabela de logs
  PERFORM load_2alv USING ls_t001_ifconf.

  "Criar catalogo
  PERFORM load_catalog_2alv USING ls_t001_ifconf.

  TRY.

      "Mostrar ALV
      CALL METHOD go_alv->set_table_for_first_display
        EXPORTING
          is_layout                     = gs_layout
        CHANGING
          it_outtab                     = gt_data_2alv
          it_fieldcatalog               = gt_fielcat[]
        EXCEPTIONS
          invalid_parameter_combination = 1
          program_error                 = 2
          too_many_lines                = 3
          OTHERS                        = 4.
      IF sy-subrc <> 0.
        CLEAR gs_layout.
      ENDIF.

      CALL METHOD go_alv->refresh_table_display.

    CATCH cx_root.                                       "#EC CATCH_ALL

      MESSAGE ID sy-msgid
            TYPE 'S'
          NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
    DISPLAY LIKE 'E'.

  ENDTRY.


ENDFORM.                    "mostra_2_alv
*&---------------------------------------------------------------------*
*& Form LOAD_LOGCENTRAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM load_2alv USING us_tone_ws_001 TYPE zzca_s_ifconf.
*
  CONSTANTS:
    lc_dom     TYPE dd07l-domname VALUE 'ZZCA_INT_SOURCE_KEY_TYPE',
    lc_dom_obj TYPE dd07l-domname VALUE 'ZZCA_INT_OBJECT_TYPE'.

  DATA:
    lt_search  TYPE STANDARD TABLE OF zzca_t_ifsearch,
    lt_object  TYPE STANDARD TABLE OF zzca_t_ifobj,
    lt_message TYPE STANDARD TABLE OF zzca_t_ifmsg.

  DATA:
    ls_ifreg      LIKE LINE OF gt_ifreg,
    ls_ifconf     LIKE LINE OF gt_ifconf,
    ls_search     LIKE LINE OF gt_search,
    ls_object     LIKE LINE OF gt_object,
    ls_message    LIKE LINE OF gt_message,
    ls_dom_values LIKE LINE OF gt_dom_vals,
    ls_data_2alv  LIKE LINE OF gt_data_2alv.

  DATA:
    lv_tabix TYPE sy-tabix.
*

  REFRESH gt_data_2alv.

  IF gt_dom_vals IS INITIAL.
    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname        = lc_dom
        text           = abap_on
        langu          = sy-langu
      TABLES
        dd07v_tab      = gt_dom_vals
      EXCEPTIONS
        wrong_textflag = 1
        OTHERS         = 2.
  ENDIF.

  IF gt_dom_vals_obj[] IS INITIAL.
    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname        = lc_dom_obj
        text           = abap_on
        langu          = sy-langu
      TABLES
        dd07v_tab      = gt_dom_vals_obj
      EXCEPTIONS
        wrong_textflag = 1
        OTHERS         = 2.
  ENDIF.

  SORT gt_ifreg BY id_if.

  READ TABLE gt_ifreg TRANSPORTING NO FIELDS
  WITH KEY id_if = us_tone_ws_001-id_if.
  CHECK sy-subrc = 0.

  lv_tabix = sy-tabix.

  LOOP AT gt_ifreg
     INTO ls_ifreg
     FROM lv_tabix.

    IF ls_ifreg-id_if NE us_tone_ws_001-id_if.
      EXIT.
    ENDIF.

    CLEAR ls_data_2alv.
    MOVE-CORRESPONDING ls_ifreg TO ls_data_2alv.

    CASE ls_ifreg-erro.
      WHEN gc_stat_aviso.
        ls_data_2alv-icon = icon_led_yellow.
      WHEN gc_stat_err.
        ls_data_2alv-icon = icon_led_red.
      WHEN gc_stat_sucesso.
        ls_data_2alv-icon = icon_led_green.
    ENDCASE.

    REFRESH lt_search.
    lt_search[] = gt_search[].
    DELETE lt_search WHERE id_if   NE ls_ifreg-id_if
                        OR id_exec NE ls_ifreg-id_exec.

    READ TABLE gt_ifconf INTO ls_ifconf
                         WITH KEY id_if = ls_ifreg-id_if.
    IF sy-subrc = 0.
      ls_data_2alv-key_type = ls_ifconf-key_type.
      READ TABLE gt_dom_vals INTO ls_dom_values
                       WITH KEY domvalue_l = ls_data_2alv-key_type.
      IF sy-subrc = 0.
        ls_data_2alv-descr = ls_dom_values-ddtext.
      ENDIF.

      IF ls_ifconf-key_mult IS NOT INITIAL AND
         lines( lt_search ) > 1.
        ls_data_2alv-key_val = '*'.
      ELSE.
        READ TABLE lt_search INTO ls_search
                             WITH KEY id_if   = ls_ifreg-id_if
                                      id_exec = ls_ifreg-id_exec.
        IF sy-subrc = 0.
          ls_data_2alv-key_val = ls_search-key_val.
        ENDIF.
      ENDIF.
    ENDIF.

    REFRESH lt_object.
    lt_object[] = gt_object[].
    DELETE lt_object WHERE id_if   NE ls_ifreg-id_if
                        OR id_exec NE ls_ifreg-id_exec.

    READ TABLE gt_ifconf INTO ls_ifconf
                         WITH KEY id_if = ls_ifreg-id_if.
    IF sy-subrc = 0.
      ls_data_2alv-obj_type = ls_ifconf-obj_type.
      READ TABLE gt_dom_vals_obj INTO ls_dom_values
                             WITH KEY domvalue_l = ls_data_2alv-obj_type.
      IF sy-subrc = 0.
        ls_data_2alv-obj_desc = ls_dom_values-ddtext.
      ENDIF.

      READ TABLE lt_object INTO ls_object
                           WITH KEY id_if   = ls_ifreg-id_if
                                    id_exec = ls_ifreg-id_exec.
      IF sy-subrc = 0.
        ls_data_2alv-obj_val = ls_object-obj_val.
      ENDIF.
    ENDIF.

    REFRESH lt_message.
    lt_message[] = gt_message[].
    DELETE lt_message WHERE id_if   NE ls_ifreg-id_if
                         OR id_exec NE ls_ifreg-id_exec.

    READ TABLE gt_ifconf INTO ls_ifconf
                         WITH KEY id_if = ls_ifreg-id_if.
    IF sy-subrc = 0.
      READ TABLE lt_message INTO ls_message
                            WITH KEY id_if   = ls_ifreg-id_if
                                    id_exec = ls_ifreg-id_exec.
      IF sy-subrc = 0.
        ls_data_2alv-msg_type = ls_message-msg_val.
      ENDIF.
    ENDIF.

    APPEND ls_data_2alv TO gt_data_2alv.

  ENDLOOP.

  SORT gt_data_2alv BY id_exec.


ENDFORM.                                                    "load_2alv
*&---------------------------------------------------------------------*
*& Form LOAD_CATALOG_2ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM load_catalog_2alv USING us_ifconf TYPE zzca_s_ifconf.
*
  CONSTANTS:
    lc_id_if    TYPE dfies-fieldname VALUE 'ID_IF',
    lc_log_ext  TYPE dfies-fieldname VALUE 'LOG_EXT',
    lc_key_val  TYPE dfies-fieldname VALUE 'KEY_VAL',
    lc_key_type TYPE dfies-fieldname VALUE 'KEY_TYPE',
    lc_obj_type TYPE dfies-fieldname VALUE 'OBJ_TYPE',
    lc_obj_tran TYPE dfies-fieldname VALUE 'OBJ_TRANSACTION',
    lc_obj_prog TYPE dfies-fieldname VALUE 'OBJ_PROGRAM',
    lc_obj_val  TYPE dfies-fieldname VALUE 'OBJ_VAL',
    lc_obj_desc TYPE dfies-fieldname VALUE 'OBJ_DESC',
    lc_descr    TYPE dfies-fieldname VALUE 'DESCR',
    lc_msg_type TYPE dfies-fieldname VALUE 'MSG_TYPE'.

  DATA
    lo_tabdescr TYPE REF TO cl_abap_structdescr.

  DATA
    lt_dfies    TYPE ddfields.

  DATA
    lv_data     TYPE REF TO data.

  FIELD-SYMBOLS:
    <fs_dfies>    TYPE dfies,
    <fs_fieldcat> TYPE lvc_s_fcat.
*

  FREE gt_fielcat.
  CLEAR gs_layout.

  CREATE DATA lv_data LIKE LINE OF gt_data_2alv.

  lo_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lv_data ).

  lt_dfies = cl_salv_data_descr=>read_structdescr( lo_tabdescr ).


  LOOP AT lt_dfies
    ASSIGNING <fs_dfies>.

    APPEND INITIAL LINE TO gt_fielcat ASSIGNING <fs_fieldcat>.

    MOVE-CORRESPONDING <fs_dfies> TO <fs_fieldcat>.

*   Esconder algumas colunas caso o interface não esteja parametrizado
*   Info dependente de parametrização opcional
    IF <fs_dfies>-fieldname EQ lc_key_type OR
       <fs_dfies>-fieldname EQ lc_key_val  OR
       <fs_dfies>-fieldname EQ lc_descr.
      IF us_ifconf-key_direction IS INITIAL.
        <fs_fieldcat>-no_out = abap_true.
      ENDIF.

    ELSEIF <fs_dfies>-fieldname EQ lc_msg_type.
      IF us_ifconf-msg_direction IS INITIAL.
        <fs_fieldcat>-no_out = abap_true.
      ENDIF.

    ELSEIF <fs_dfies>-fieldname EQ lc_obj_type OR
           <fs_dfies>-fieldname EQ lc_obj_val  OR
           <fs_dfies>-fieldname EQ lc_obj_desc.
      IF us_ifconf-obj_direction IS INITIAL.
        <fs_fieldcat>-no_out = abap_true.
      ENDIF.
    ENDIF.

    "Esconder Campos
    IF <fs_dfies>-fieldname EQ lc_id_if    OR
       <fs_dfies>-fieldname EQ lc_log_ext  OR
       <fs_dfies>-fieldname EQ lc_key_type OR
       <fs_dfies>-fieldname EQ lc_obj_type OR
       <fs_dfies>-fieldname EQ lc_obj_tran OR
       <fs_dfies>-fieldname EQ lc_obj_prog.
      <fs_fieldcat>-no_out = abap_true.
    ENDIF.

    "Hotspot
    IF <fs_dfies>-fieldname EQ lc_key_val OR
       <fs_dfies>-fieldname EQ lc_obj_val.
      <fs_fieldcat>-hotspot = abap_on.
    ENDIF.

  ENDLOOP.

  " Visão Tecnica  RJPC
  LOOP AT gt_techconf INTO DATA(ls_tech_conf) WHERE id_if EQ us_ifconf-id_if
                                                 AND tech_hide IS NOT INITIAL.
    READ TABLE gt_fielcat ASSIGNING <fs_fieldcat> WITH KEY fieldname = ls_tech_conf-field.
    IF sy-subrc EQ 0.
      <fs_fieldcat>-no_out = abap_true. " esconde coluna
    ENDIF.
  ENDLOOP.

  gs_layout-cwidth_opt = abap_true.
  gs_layout-sel_mode = 'A'.

ENDFORM.                    "load_catalog_2alv
*&---------------------------------------------------------------------*
*& Form TOOLBARD_ACTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM toolbard_action USING u_act TYPE i.
*
  DATA:
    lt_rows TYPE lvc_t_row.

  DATA:
    ls_row LIKE LINE OF lt_rows.

  DATA:
    lv_index TYPE sy-tabix.
*

  CALL METHOD go_alv->get_selected_rows
    IMPORTING
      et_index_rows = lt_rows.

  IF gv_func_view IS NOT INITIAL.
    gt_data_2alv = CORRESPONDING #( <ft_data_2alv_func> ).
  ENDIF.

  LOOP AT lt_rows INTO ls_row.
    lv_index = ls_row-index.

    CASE u_act.
      WHEN 1.
        PERFORM mostra_slg1 USING lv_index.
      WHEN 2.
        PERFORM mostra_objeto_in USING lv_index.
      WHEN 3.
        PERFORM mostra_objeto_out USING lv_index.
      WHEN 4.
        IF gs_if_geo-land1 = 'PT'.
          PERFORM repro_evt USING lv_index.
        ENDIF.
      WHEN 5.
        PERFORM mostra_pdf USING lv_index.
    ENDCASE.

    AT LAST.          " Apenas uma única msg no final ++
      IF u_act = 4.   " Apenas uma única msg no final ++
        MESSAGE i013. " Apenas uma única msg no final ++
      ENDIF.          " Apenas uma única msg no final ++
    ENDAT.            " Apenas uma única msg no final ++

  ENDLOOP.

ENDFORM.                    "toolbard_action
*&---------------------------------------------------------------------*
*& Form MOSTRA_SLG1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM mostra_slg1 USING u_index TYPE sy-tabix.
*
  CONSTANTS:
    lc_date TYPE balhdr-aldate VALUE '19000101'.

  DATA:
    ls_data_2alv   LIKE LINE OF gt_data_2alv,
    ls_t001_ifconf LIKE LINE OF gt_ifconf.
*

  CHECK u_index IS NOT INITIAL.

  "Linha de log
  READ TABLE gt_data_2alv INTO ls_data_2alv INDEX u_index.
  CHECK ls_data_2alv-log_ext IS NOT INITIAL.

  "Dados do interface - Objeto/Subobjeto Log
  READ TABLE gt_ifconf INTO ls_t001_ifconf
  WITH KEY id_if = ls_data_2alv-id_if.
  CHECK sy-subrc = 0.

  "Mostrar Log
  CALL FUNCTION 'APPL_LOG_DISPLAY'
    EXPORTING
      object                    = ls_t001_ifconf-log_object
      subobject                 = ls_t001_ifconf-log_subobject
      external_number           = ls_data_2alv-log_ext
      date_from                 = lc_date
      suppress_selection_dialog = abap_on
    EXCEPTIONS
      no_authority              = 1
      OTHERS                    = 2.
  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid
          TYPE 'S'
        NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
  DISPLAY LIKE 'E'.

  ENDIF.

ENDFORM.                    "mostra_slg1
*&---------------------------------------------------------------------*
*& Form MOSTRA_OBJETO_IN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM mostra_objeto_in USING u_index TYPE sy-tabix.
*
  CONSTANTS:
    lc_meth TYPE char20 VALUE 'GET_INFO_IN'.

  DATA:
    lo_ws_obj TYPE REF TO object,
    lo_ref    TYPE REF TO data.

  DATA:
    ls_data_2alv   LIKE LINE OF gt_data_2alv,
    ls_t001_ifconf LIKE LINE OF gt_ifconf.

  DATA:
    lv_xml_obj_in TYPE zzca_t_ifxml-xml_obj.

  FIELD-SYMBOLS:
    <fs_any> TYPE any.
*

  CHECK u_index IS NOT INITIAL.

  "Linha de log
  READ TABLE gt_data_2alv INTO ls_data_2alv INDEX u_index.
  CHECK sy-subrc = 0.

  "Dados do interface - Objeto/Subobjeto Log
  READ TABLE gt_ifconf INTO ls_t001_ifconf
  WITH KEY id_if = ls_data_2alv-id_if.
  CHECK sy-subrc = 0.

  CASE ls_t001_ifconf-type_if.
    WHEN gc_webserv.

      SELECT SINGLE xml_obj
        FROM (gs_if_geo-tab_ifxml)
        INTO lv_xml_obj_in
       WHERE id_if   = ls_data_2alv-id_if
         AND id_exec = ls_data_2alv-id_exec.

      CHECK lv_xml_obj_in IS NOT INITIAL.
      CHECK ls_t001_ifconf-object_type IS NOT INITIAL.

      "Deserializar informação
      CREATE OBJECT lo_ws_obj TYPE (ls_t001_ifconf-object_type).

      CALL METHOD zzca_cl_ws_general=>convert_xml_to_obj
        EXPORTING
          iv_xml              = lv_xml_obj_in
        RECEIVING
          ro_object           = lo_ws_obj
        EXCEPTIONS
          serealization_error = 1
          OTHERS              = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        RETURN.
      ENDIF.


      "Criar variavel com tipo de dados do WS
      CREATE DATA lo_ref TYPE (ls_t001_ifconf-in_struct_name).
      CHECK lo_ref IS BOUND.

      ASSIGN lo_ref->* TO <fs_any>.

      CHECK <fs_any> IS ASSIGNED.

      CALL METHOD lo_ws_obj->(lc_meth)
        CHANGING
          c_info = <fs_any>.

      "Função standard que mostra a informação do WS
      CALL FUNCTION 'RS_COMPLEX_OBJECT_DISPLAY'
        EXPORTING
          object_name          = ls_t001_ifconf-in_struct_name
          object               = <fs_any>
          display_accessible   = 'X'
        EXCEPTIONS                                          "#EC *
          object_not_supported = 1
          OTHERS               = 2.

    WHEN gc_file.
      PERFORM display_file_info USING ls_data_2alv.

  ENDCASE.
ENDFORM.                    "mostra_objeto_in
*&---------------------------------------------------------------------*
*& Form MOSTRA_OBJETO_OUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM mostra_objeto_out USING u_index TYPE sy-tabix.
*
  CONSTANTS:
    lc_meth TYPE char20 VALUE 'GET_INFO_OUT'.

  DATA:
    lo_ws_obj TYPE REF TO object,
    lo_ref    TYPE REF TO data.

  DATA:
    ls_data_2alv   LIKE LINE OF gt_data_2alv,
    ls_t001_ifconf LIKE LINE OF gt_ifconf.

  DATA:
    lv_xml_obj_out TYPE zzca_t_ifxml-xml_obj.

  FIELD-SYMBOLS:
    <fs_any> TYPE any.
*

  CHECK u_index IS NOT INITIAL.

  "Linha de log
  READ TABLE gt_data_2alv INTO ls_data_2alv INDEX u_index.
  CHECK sy-subrc = 0.

  "Dados do interface - Objeto/Subobjeto Log
  READ TABLE gt_ifconf INTO ls_t001_ifconf
  WITH KEY id_if = ls_data_2alv-id_if.
  CHECK sy-subrc = 0.

* --> ROFFSDF(RJPC): Ficheiros
  CASE ls_t001_ifconf-type_if.
    WHEN gc_file.
      PERFORM mostra_objeto_in USING u_index.
      RETURN.
  ENDCASE.
* <-- ROFFSDF(RJPC): Ficheiros

  SELECT SINGLE xml_obj
    FROM (gs_if_geo-tab_ifxml)
    INTO lv_xml_obj_out
   WHERE id_if   = ls_data_2alv-id_if
     AND id_exec = ls_data_2alv-id_exec.

  CHECK lv_xml_obj_out IS NOT INITIAL.
  CHECK ls_t001_ifconf-object_type IS NOT INITIAL.

  "Deserializar informação
  CREATE OBJECT lo_ws_obj TYPE (ls_t001_ifconf-object_type).

  CALL METHOD zzca_cl_ws_general=>convert_xml_to_obj
    EXPORTING
      iv_xml              = lv_xml_obj_out
    RECEIVING
      ro_object           = lo_ws_obj
    EXCEPTIONS
      serealization_error = 1
      OTHERS              = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.


  "Criar variavel com tipo de dados do WS
  CREATE DATA lo_ref TYPE (ls_t001_ifconf-out_struct_name).
  CHECK lo_ref IS BOUND.

  ASSIGN lo_ref->* TO <fs_any>.

  CHECK <fs_any> IS ASSIGNED.

  CALL METHOD lo_ws_obj->(lc_meth)
    CHANGING
      c_info = <fs_any>.

  "Função standard que mostra a informação do WS
  CALL FUNCTION 'RS_COMPLEX_OBJECT_DISPLAY'
    EXPORTING
      object_name          = ls_t001_ifconf-out_struct_name
      object               = <fs_any>
      display_accessible   = 'X'
    EXCEPTIONS                                              "#EC *
      object_not_supported = 1
      OTHERS               = 2.

ENDFORM.                    "mostra_objeto_out
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM refresh_alv .
*
  DATA:
    ls_t001_ifconf LIKE LINE OF gt_ifconf.
*

  REFRESH:
    gt_ifreg,
    gt_ifconf,
    gt_ifconft,
    gt_techconf,
    gt_funcconf,
    gt_func_fields.

  PERFORM get_data.

  READ TABLE gt_ifconf INTO ls_t001_ifconf
  WITH KEY id_if = gv_id_if.
  CHECK sy-subrc = 0.

  "Criar tabela de logs
  PERFORM load_2alv USING ls_t001_ifconf.

*  "Refresh display
*  CALL METHOD go_alv->refresh_table_display.

  PERFORM load_catalog_2alv USING ls_t001_ifconf.

  TRY.

      "Mostrar ALV
      CALL METHOD go_alv->set_table_for_first_display
        EXPORTING
          is_layout                     = gs_layout
        CHANGING
          it_outtab                     = gt_data_2alv
          it_fieldcatalog               = gt_fielcat[]
        EXCEPTIONS
          invalid_parameter_combination = 1
          program_error                 = 2
          too_many_lines                = 3
          OTHERS                        = 4.
      IF sy-subrc <> 0.
        CLEAR gs_layout.
      ENDIF.

      CALL METHOD go_alv->refresh_table_display.

    CATCH cx_root.                                       "#EC CATCH_ALL

      MESSAGE ID sy-msgid
            TYPE 'S'
          NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
    DISPLAY LIKE 'E'.

  ENDTRY.

ENDFORM.                    "refresh_alv
*&---------------------------------------------------------------------*
*& Form REPRO_EVT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM repro_evt USING u_index TYPE sy-tabix.
*
  CONSTANTS:
    lc_meth TYPE char20 VALUE 'GET_INFO_IN'.

  DATA:
    lo_ws_obj TYPE REF TO object,
    lo_ref_i  TYPE REF TO data,
    lo_ref_o  TYPE REF TO data.

  DATA:
    ls_data_2alv   LIKE LINE OF gt_data_2alv,
    ls_t001_ifconf LIKE LINE OF gt_ifconf.

  DATA:
    lv_xml_obj_in TYPE zzca_t_ifxml-xml_obj,
    lv_dummy      TYPE char1.

  FIELD-SYMBOLS:
    <fs_any_i> TYPE any,
    <fs_any_o> TYPE any.
*


  CHECK u_index IS NOT INITIAL.

  "Linha de log
  READ TABLE gt_data_2alv INTO ls_data_2alv INDEX u_index.

  "Dados do interface - Objeto/Subobjeto Log
  READ TABLE gt_ifconf INTO ls_t001_ifconf
  WITH KEY id_if = ls_data_2alv-id_if.
  CHECK sy-subrc = 0.

  SELECT SINGLE xml_obj
    FROM (gs_if_geo-tab_ifxml)
    INTO lv_xml_obj_in
   WHERE id_if   = ls_data_2alv-id_if
     AND id_exec = ls_data_2alv-id_exec.

  CHECK lv_xml_obj_in IS NOT INITIAL.
  CHECK ls_t001_ifconf-object_type IS NOT INITIAL.
  CHECK ls_t001_ifconf-fm_name IS NOT INITIAL.

  "Deserializar informação

  CREATE OBJECT lo_ws_obj TYPE (ls_t001_ifconf-object_type).

  CALL METHOD zzca_cl_ws_general=>convert_xml_to_obj
    EXPORTING
      iv_xml              = lv_xml_obj_in
    RECEIVING
      ro_object           = lo_ws_obj
    EXCEPTIONS
      serealization_error = 1
      OTHERS              = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.

  "Criar variavel com tipo de dados do WS
  CREATE DATA lo_ref_i TYPE (ls_t001_ifconf-in_struct_name).
  CHECK lo_ref_i IS BOUND.

  ASSIGN lo_ref_i->* TO <fs_any_i>.

  CHECK <fs_any_i> IS ASSIGNED.

  CALL METHOD lo_ws_obj->(lc_meth)
    CHANGING
      c_info = <fs_any_i>.

  IF ls_t001_ifconf-po_type = '1'.          " Verifica o tipo de Objeto de Processamento
    CALL FUNCTION ls_t001_ifconf-fm_name
      EXPORTING
        input = <fs_any_i>.
  ELSE.
    TRY.
*        CALL METHOD lo_ws_obj->(ls_t001_ifconf-fm_name)
        CREATE DATA lo_ref_o TYPE (ls_t001_ifconf-out_struct_name).
        CHECK lo_ref_o IS BOUND.
        ASSIGN lo_ref_o->* TO <fs_any_o>.

        CHECK <fs_any_o> IS ASSIGNED.

        CALL METHOD zzca_cl_ws_general=>(ls_t001_ifconf-fm_name)
          EXPORTING
            input  = <fs_any_i>
          IMPORTING
            output = <fs_any_o>
          CHANGING
            co_obj = lo_ws_obj.
      CATCH cx_root INTO DATA(o_root).
        DATA(lv_texto) = o_root->get_text( ).
        MESSAGE lv_texto TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDIF.

  MESSAGE i013 INTO lv_dummy. " Apenas uma única msg no final

  "Refresh display
*  PERFORM refresh_alv.
  IF gv_func_view IS INITIAL.
    PERFORM refresh_alv.
  ELSE.
    PERFORM refresh_alv_func.
  ENDIF.
ENDFORM.                    "repro_evt
*&---------------------------------------------------------------------*
*&      Form  GET_SLECT_PARAM
*&---------------------------------------------------------------------*
FORM get_slect_param .

  CLEAR gv_conf_error.

  "Selecionar campos de pesquisa activos
  SELECT *
    FROM zzca_t_ifkeys
    INTO TABLE gt_ifkey
   WHERE active = abap_on.

  "Grupos de Interface por Transação
  SELECT SINGLE *
    FROM zzca_t_iftcode
    INTO gs_if_tcode
    WHERE tcode = sy-tcode.
  IF sy-subrc IS NOT INITIAL.
    "Transação Inválida - Configuração tabela &.
    MESSAGE i014 WITH 'ZZCA_T_IFTCODE'.
    gv_conf_error = abap_on.
    RETURN.
  ENDIF.


  SELECT SINGLE *
    FROM zzca_t_iftcodet
    INTO gs_if_tcode_t
    WHERE tcode = sy-tcode
      AND spras = sy-langu.


  "Configuração por País
  SELECT SINGLE *
    FROM zzca_t_ifcf_geo
    INTO gs_if_geo
    WHERE land1 = gs_if_tcode-land1.
  IF sy-subrc IS NOT INITIAL.
    "Configuração em falta tabela & para país &.
    MESSAGE w015 WITH 'ZZCA_T_IFCF_GEO' gs_if_tcode-land1.
    gv_conf_error = abap_on.
    RETURN.
  ENDIF.

ENDFORM.                    " GET_SLECT_PARAM
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTION_FIELDS
*&---------------------------------------------------------------------*
FORM check_selection_fields .
*
  CONSTANTS:
    lc_pattern TYPE string VALUE 'S_KEY_'.

  DATA:
    lt_offset TYPE swahitlist.

  DATA:
    ls_offset LIKE LINE OF lt_offset.

  DATA:
    lv_string TYPE string,
    lv_selec  TYPE zzca_t_ifkeys-select_options.
*

  "Ativar/Desativar campos de pesquisa por chave
  IF gt_ifkey IS INITIAL.
    LOOP AT SCREEN.
      IF screen-name CS lc_pattern+2(3).
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-name CS lc_pattern.
        CLEAR lv_string.
        REFRESH lt_offset.
        lv_string = screen-name.
        CALL FUNCTION 'SWA_STRING_REMOVE_SUBSTRING'
          EXPORTING
            input_string   = lv_string
            delete_pattern = lc_pattern
          TABLES
            offset_list    = lt_offset.

        READ TABLE lt_offset INTO ls_offset INDEX 1.
        IF sy-subrc = 0.
          lv_selec = screen-name+ls_offset-stroffset(7).

          READ TABLE gt_ifkey TRANSPORTING NO FIELDS
                              WITH KEY select_options = lv_selec.
          IF sy-subrc NE 0.
            screen-active = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " CHECK_SELECTION_FIELDS
*&---------------------------------------------------------------------*
*&      Form  F4_IF_ID
*&---------------------------------------------------------------------*
FORM f4_if_id CHANGING cv_if_id TYPE srmifid.


*
  DATA:
    lt_values TYPE STANDARD TABLE OF ddshretval.

  DATA:
    ls_shlp   TYPE shlp_descr,
    ls_values LIKE LINE OF lt_values.

  DATA:
    lv_subrc TYPE sy-subrc.

  FIELD-SYMBOLS:
    <fs_interface> LIKE LINE OF ls_shlp-interface.
*


  CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
    EXPORTING
      shlpname = 'ZZCA_SEARCHHELP_ID_IF'
    IMPORTING
      shlp     = ls_shlp.

  READ TABLE ls_shlp-interface ASSIGNING <fs_interface> WITH KEY shlpfield = 'GROUP_IF'.
  IF sy-subrc IS INITIAL.
    <fs_interface>-valfield  = 'X'.
    <fs_interface>-value     = gs_if_tcode-group_if.
  ENDIF.

  READ TABLE ls_shlp-interface ASSIGNING <fs_interface> WITH KEY shlpfield = 'ID_IF'.
  IF sy-subrc IS INITIAL.
    <fs_interface>-valfield  = 'X'.
  ENDIF.


  CALL FUNCTION 'F4IF_START_VALUE_REQUEST'
    EXPORTING
      shlp          = ls_shlp
    IMPORTING
      rc            = lv_subrc
    TABLES
      return_values = lt_values.


  READ TABLE lt_values INTO ls_values INDEX 1.
  IF sy-subrc IS INITIAL.
    cv_if_id = ls_values-fieldval.
  ENDIF.


ENDFORM.                                                    "f4_if_id
*&---------------------------------------------------------------------*
*&      Form  MOSTRA_PDF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_INDEX  text
*----------------------------------------------------------------------*
FORM mostra_pdf USING uv_index TYPE sy-tabix.

  DATA: ls_data_2alv   LIKE LINE OF gt_data_2alv,
        ls_t001_ifconf LIKE LINE OF gt_ifconf.

  "Linha de log
  READ TABLE gt_data_2alv INTO ls_data_2alv INDEX uv_index.
  CHECK sy-subrc = 0.

  "Dados do interface - Objeto/Subobjeto Log
  READ TABLE gt_ifconf INTO ls_t001_ifconf
  WITH KEY id_if = ls_data_2alv-id_if.
  CHECK sy-subrc = 0.


  CALL FUNCTION 'ZZCA_SHOW_PDF'
    EXPORTING
      id_interface = ls_data_2alv-id_if
      id_exec      = ls_data_2alv-id_exec.


ENDFORM.                    "mostra_pdf
*&---------------------------------------------------------------------*
*&      Form  READ_IDOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_OBJECT  text
*----------------------------------------------------------------------*
FORM read_idoc USING pu_data   TYPE zzca_s_int_tone_cockpit_2alv-data
                     pu_object TYPE zzca_t_ifobj.

  DATA:
    lv_docnum TYPE edidc-docnum.


  lv_docnum = pu_object-obj_val.

  IF pu_object-obj_transaction IS NOT INITIAL.
    " Adicionar os parameters ID
    SET PARAMETER ID 'DCN' FIELD lv_docnum.
    CALL TRANSACTION pu_object-obj_transaction AND SKIP FIRST SCREEN.

  ELSEIF pu_object-obj_program IS NOT INITIAL.
    SUBMIT (pu_object-obj_program) WITH credat = pu_data
                                   WITH docnum = lv_docnum
                                   AND RETURN.
  ENDIF.

ENDFORM.                    "read_idoc
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_FILE_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_DATA_2ALV  text
*----------------------------------------------------------------------*
FORM display_file_info  USING us_alv_i TYPE zzca_s_int_tone_cockpit_2alv.

  TYPES:
    BEGIN OF lty_key,
      mandt     TYPE mandt,
      id_if     TYPE srmifid,
      data      TYPE createdate,
      file_name TYPE filename75,
    END OF lty_key.

  DATA:
    lo_struct     TYPE REF TO cl_abap_structdescr,
    lo_strucdescr TYPE REF TO cl_abap_structdescr,
    lo_datadescr  TYPE REF TO cl_abap_datadescr,
    lo_typedescr  TYPE REF TO cl_abap_typedescr,
    lo_dyn_struct TYPE REF TO data,
    lo_dyn_tab    TYPE REF TO data.

  DATA:
    lt_component TYPE cl_abap_structdescr=>component_table,
    lt_sel       TYPE STANDARD TABLE OF se16n_seltab.

  DATA:
    ls_key TYPE lty_key,
    ls_sel LIKE LINE OF lt_sel.

  DATA:
    lv_tab TYPE se16n_tab.

  DATA:
    ls_config TYPE zzca_t_fileconf.

  FIELD-SYMBOLS:
    <fs_tab_h> TYPE any,
    <fs_tab_i> TYPE ANY TABLE.

  "Configuração de Ficheiros
  SELECT SINGLE *
    FROM zzca_t_fileconf
    INTO ls_config
    WHERE id_if = us_alv_i-id_if.

  CHECK sy-subrc IS INITIAL.


  "Tabela cabeçalho de Ficheiro
  TRY.
      lo_struct ?= cl_abap_structdescr=>describe_by_name( ls_config-tabelacab ).
      lt_component = lo_struct->get_components( ).
      lo_strucdescr  = cl_abap_structdescr=>create( p_components = lt_component ).

      CREATE DATA lo_dyn_struct TYPE HANDLE lo_strucdescr.
      IF sy-subrc = 0.
        ASSIGN lo_dyn_struct->* TO <fs_tab_h>.
      ENDIF.

    CATCH cx_root.
      RETURN.
  ENDTRY.

  SELECT SINGLE * FROM (ls_config-tabelacab)
    INTO <fs_tab_h>
    WHERE id_exec = us_alv_i-id_exec.

  IF sy-subrc IS NOT INITIAL.
    RETURN.
  ENDIF.

  "Tabela Item de Ficheiro

  TRY.
      lo_typedescr ?= cl_abap_structdescr=>describe_by_name( ls_config-tabelaitem ).
      lo_strucdescr ?= lo_typedescr.
      lo_datadescr  = cl_abap_tabledescr=>create( p_line_type = lo_strucdescr ).

      CREATE DATA lo_dyn_tab TYPE HANDLE lo_datadescr.
      IF sy-subrc = 0.
        ASSIGN lo_dyn_tab->* TO <fs_tab_i>.
      ENDIF.

    CATCH cx_root.
      RETURN.
  ENDTRY.

  ls_key = <fs_tab_h>.

  SELECT * FROM (ls_config-tabelaitem)
    INTO TABLE <fs_tab_i>
    WHERE id_if     = ls_key-id_if
      AND data      = ls_key-data
      AND file_name = ls_key-file_name
    ORDER BY PRIMARY KEY.

  IF sy-subrc IS NOT INITIAL.
    RETURN.
  ENDIF.

  CLEAR ls_sel.
  ls_sel-field  = 'DATA'.
  ls_sel-sign   = gc_in.
  ls_sel-option = gc_eq.
  ls_sel-low    = ls_key-data.
  APPEND ls_sel TO lt_sel.

  CLEAR ls_sel.
  ls_sel-field  = 'FILE_NAME'.
  ls_sel-sign   = gc_i.
  ls_sel-option = gc_eq.
  ls_sel-low    = ls_key-file_name.
  APPEND ls_sel TO lt_sel.

  lv_tab = ls_config-tabelaitem.

  CALL FUNCTION 'SE16N_INTERFACE'
    EXPORTING
      i_tab        = lv_tab
    TABLES
      it_selfields = lt_sel
    EXCEPTIONS
      no_values    = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.                    " DISPLAY_FILE_INFO
*&---------------------------------------------------------------------*
*& Form read_config_hotspot_key
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_IFCONF
*&      --> GS_ALV_DATA
*&      --> LS_ROW
*&---------------------------------------------------------------------*
FORM read_config_hotspot_key  USING ls_ifconf   TYPE zzca_s_ifconf
                                    ls_alv_data LIKE LINE OF gt_data_2alv
                                    lv_value.

  CONSTANTS:
    lc_meth_in  TYPE char20 VALUE 'GET_INFO_IN',
    lc_meth_out TYPE char20 VALUE 'GET_INFO_OUT'.

  DATA: lv_char    TYPE char80,
        lv_xml_obj TYPE zzca_t_ifxml-xml_obj.

  DATA:
    lo_ws_obj  TYPE REF TO object,
    lo_ref_in  TYPE REF TO data,
    lo_ref_out TYPE REF TO data.

  DATA: lt_hotsconf TYPE TABLE OF zzca_t_hotsconf.

  FIELD-SYMBOLS: <fs_any_in> TYPE any.
  FIELD-SYMBOLS: <fs_any_out> TYPE any.

  DATA: lt_seltab TYPE TABLE OF rsparams,
        ls_seltab LIKE LINE OF lt_seltab.
*

  REFRESH lt_hotsconf[].

  SELECT *
   FROM zzca_t_hotsconf
   INTO CORRESPONDING FIELDS OF TABLE lt_hotsconf
   WHERE id_if = ls_alv_data-id_if.

  CHECK sy-subrc EQ 0.

  SELECT SINGLE xml_obj
         FROM (gs_if_geo-tab_ifxml)
         INTO lv_xml_obj
        WHERE id_if   = ls_alv_data-id_if
          AND id_exec = ls_alv_data-id_exec.

  CHECK lv_xml_obj IS NOT INITIAL.
  CHECK ls_ifconf-object_type IS NOT INITIAL.

  "Deserializar informação
  CREATE OBJECT lo_ws_obj TYPE (ls_ifconf-object_type).

  CALL METHOD zzca_cl_ws_general=>convert_xml_to_obj
    EXPORTING
      iv_xml              = lv_xml_obj
    RECEIVING
      ro_object           = lo_ws_obj
    EXCEPTIONS
      serealization_error = 1
      OTHERS              = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.

  "Criar variavel INPUT com tipo de dados do WS
  CREATE DATA lo_ref_in TYPE (ls_ifconf-in_struct_name).
  CHECK lo_ref_in IS BOUND.

  ASSIGN lo_ref_in->* TO <fs_any_in>.

  CHECK <fs_any_in> IS ASSIGNED.

  CALL METHOD lo_ws_obj->(lc_meth_in)
    CHANGING
      c_info = <fs_any_in>.

  "Criar variavel OUTPUT com tipo de dados do WS
  CREATE DATA lo_ref_out TYPE (ls_ifconf-out_struct_name).
  CHECK lo_ref_out IS BOUND.

  ASSIGN lo_ref_out->* TO <fs_any_out>.

  CHECK <fs_any_out> IS ASSIGNED.

  CALL METHOD lo_ws_obj->(lc_meth_out)
    CHANGING
      c_info = <fs_any_out>.

  CASE ls_ifconf-hotspot_type.
    WHEN '1'. "Programa

      LOOP AT lt_hotsconf INTO DATA(ls_hotsconf).
        CASE ls_hotsconf-hots_direction.
          WHEN 'C'. "Constant
            CHECK ls_hotsconf-hots_value IS NOT INITIAL.
            ls_seltab-selname = ls_hotsconf-hots_param. "Parameter name on selection screen of submitted report
            ls_seltab-sign = 'I'.
            ls_seltab-option = 'EQ'.
            ls_seltab-low = ls_hotsconf-hots_value.
            APPEND ls_seltab TO lt_seltab.
          WHEN 'I'. "Input
            ASSIGN COMPONENT ls_hotsconf-hots_value OF STRUCTURE <fs_any_in> TO FIELD-SYMBOL(<fs_value>).
            CHECK <fs_value> IS ASSIGNED.
            ls_seltab-selname = ls_hotsconf-hots_param.
            ls_seltab-sign = 'I'.
            ls_seltab-option = 'EQ'.
            ls_seltab-low = <fs_value>.
            APPEND ls_seltab TO lt_seltab.
          WHEN 'O'. "Output
            ASSIGN COMPONENT ls_hotsconf-hots_value OF STRUCTURE <fs_any_out> TO <fs_value>.
            CHECK <fs_value> IS ASSIGNED.
            ls_seltab-selname = ls_hotsconf-hots_param.
            ls_seltab-sign = 'I'.
            ls_seltab-option = 'EQ'.
            ls_seltab-low = <fs_value>.
            APPEND ls_seltab TO lt_seltab.
          WHEN 'T'. "Table of values hotspot
            lv_char = lv_value.
            IF lv_value IS INITIAL AND ls_alv_data-key_val IS NOT INITIAL.
              lv_char = ls_alv_data-key_val.
            ENDIF.
            CHECK lv_char IS NOT INITIAL .
            ls_seltab-selname = ls_hotsconf-hots_param.
            ls_seltab-sign = 'I'.
            ls_seltab-option = 'EQ'.
            ls_seltab-low = lv_char.
            APPEND ls_seltab TO lt_seltab.
          WHEN OTHERS.
        ENDCASE.
        CLEAR: ls_seltab.
      ENDLOOP.
      SUBMIT (ls_ifconf-hotspot_source) WITH SELECTION-TABLE lt_seltab AND RETURN.
      REFRESH lt_seltab.

    WHEN '2'. "Transaction

      LOOP AT lt_hotsconf INTO ls_hotsconf.
        CASE ls_hotsconf-hots_direction.
          WHEN 'C'. "Constant
            CHECK ls_hotsconf-hots_value IS NOT INITIAL.
            SET PARAMETER ID ls_hotsconf-hots_param FIELD ls_hotsconf-hots_value.
          WHEN 'I'. "Input
            ASSIGN COMPONENT ls_hotsconf-hots_value OF STRUCTURE <fs_any_in> TO <fs_value>.
            CHECK <fs_value> IS ASSIGNED.
            lv_char = <fs_value>.
            SET PARAMETER ID ls_hotsconf-hots_param FIELD lv_char.
          WHEN 'O'. "Output
            ASSIGN COMPONENT ls_hotsconf-hots_value OF STRUCTURE <fs_any_out> TO <fs_value>.
            CHECK <fs_value> IS ASSIGNED.
            lv_char = <fs_value>.
            SET PARAMETER ID ls_hotsconf-hots_param FIELD lv_char.
          WHEN 'T'. "Table of values hotspot
            lv_char = lv_value.
            IF lv_value IS INITIAL AND ls_alv_data-key_val IS NOT INITIAL.
              lv_char = ls_alv_data-key_val.
            ENDIF.
            CHECK lv_char IS NOT INITIAL.
            SET PARAMETER ID ls_hotsconf-hots_param FIELD lv_char.
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
      CALL TRANSACTION ls_ifconf-hotspot_source AND SKIP FIRST SCREEN.

    WHEN OTHERS.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form load_catalog_2alv_func
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_T001_IFCONF
*&---------------------------------------------------------------------*
FORM load_catalog_2alv_func  USING us_ifconf TYPE zzca_s_ifconf.
*
  CONSTANTS:
    lc_id_if    TYPE dfies-fieldname VALUE 'ID_IF',
    lc_log_ext  TYPE dfies-fieldname VALUE 'LOG_EXT',
    lc_key_val  TYPE dfies-fieldname VALUE 'KEY_VAL',
    lc_key_type TYPE dfies-fieldname VALUE 'KEY_TYPE',
    lc_obj_type TYPE dfies-fieldname VALUE 'OBJ_TYPE',
    lc_obj_tran TYPE dfies-fieldname VALUE 'OBJ_TRANSACTION',
    lc_obj_prog TYPE dfies-fieldname VALUE 'OBJ_PROGRAM',
    lc_obj_val  TYPE dfies-fieldname VALUE 'OBJ_VAL',
    lc_obj_desc TYPE dfies-fieldname VALUE 'OBJ_DESC',
    lc_descr    TYPE dfies-fieldname VALUE 'DESCR',
    lc_msg_type TYPE dfies-fieldname VALUE 'MSG_TYPE'.

  DATA
    lo_tabdescr TYPE REF TO cl_abap_structdescr.

  DATA
    lt_dfies    TYPE ddfields.

  DATA:
    lv_data     TYPE REF TO data,
    ls_fieldcat TYPE lvc_s_fcat.

  FIELD-SYMBOLS:
    <fs_dfies>    TYPE dfies,
    <fs_fieldcat> TYPE lvc_s_fcat.
*

  FREE gt_fielcat_func.
  CLEAR gs_layout.

  CREATE DATA lv_data LIKE LINE OF gt_data_2alv.

  lo_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lv_data ).

  lt_dfies = cl_salv_data_descr=>read_structdescr( lo_tabdescr ).


  LOOP AT lt_dfies
    ASSIGNING <fs_dfies>.

    APPEND INITIAL LINE TO gt_fielcat_func ASSIGNING <fs_fieldcat>.

    MOVE-CORRESPONDING <fs_dfies> TO <fs_fieldcat>.

*   Esconder algumas colunas caso o interface não esteja parametrizado
*   Info dependente de parametrização opcional
    IF <fs_dfies>-fieldname EQ lc_key_type OR
       <fs_dfies>-fieldname EQ lc_key_val  OR
       <fs_dfies>-fieldname EQ lc_descr.
      IF us_ifconf-key_direction IS INITIAL.
        <fs_fieldcat>-no_out = abap_true.
      ENDIF.

    ELSEIF <fs_dfies>-fieldname EQ lc_msg_type.
      IF us_ifconf-msg_direction IS INITIAL.
        <fs_fieldcat>-no_out = abap_true.
      ENDIF.

    ELSEIF <fs_dfies>-fieldname EQ lc_obj_type OR
           <fs_dfies>-fieldname EQ lc_obj_val  OR
           <fs_dfies>-fieldname EQ lc_obj_desc.
      IF us_ifconf-obj_direction IS INITIAL.
        <fs_fieldcat>-no_out = abap_true.
      ENDIF.
    ENDIF.

    "Esconder Campos
    IF <fs_dfies>-fieldname EQ lc_id_if    OR
       <fs_dfies>-fieldname EQ lc_log_ext  OR
       <fs_dfies>-fieldname EQ lc_key_type OR
       <fs_dfies>-fieldname EQ lc_obj_type OR
       <fs_dfies>-fieldname EQ lc_obj_tran OR
       <fs_dfies>-fieldname EQ lc_obj_prog.
      <fs_fieldcat>-no_out = abap_true.
    ENDIF.

    "Hotspot
    IF <fs_dfies>-fieldname EQ lc_key_val OR
       <fs_dfies>-fieldname EQ lc_obj_val.
      <fs_fieldcat>-hotspot = abap_on.
    ENDIF.

  ENDLOOP.

  SORT gt_funcconf BY id_if alv_position.
  LOOP AT gt_funcconf INTO DATA(ls_func_conf) WHERE id_if EQ us_ifconf-id_if.
    DATA lv_text TYPE scrtext_l.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname  = ls_func_conf-field_name.    " Fieldname in the data table
    PERFORM get_text_data_element USING ls_func_conf-field_dataelement CHANGING lv_text.
    ls_fieldcat-scrtext_m  = lv_text.
    APPEND ls_fieldcat TO gt_fielcat_func.
  ENDLOOP.

  " Visão Funcional  RJPC
  LOOP AT gt_techconf INTO DATA(ls_tech_conf) WHERE id_if EQ us_ifconf-id_if
                                                 AND func_hide IS NOT INITIAL.
    READ TABLE gt_fielcat_func ASSIGNING <fs_fieldcat> WITH KEY fieldname = ls_tech_conf-field.
    IF sy-subrc EQ 0.
      <fs_fieldcat>-no_out = abap_true. " esconde coluna
    ENDIF.
  ENDLOOP.

  gs_layout-cwidth_opt = abap_true.
  gs_layout-sel_mode = 'A'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form load_2alv_func
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_T001_IFCONF
*&---------------------------------------------------------------------*
FORM load_2alv_func  USING us_tone_ws_001 TYPE zzca_s_ifconf.

  CONSTANTS:
    lc_dom     TYPE dd07l-domname VALUE 'ZZCA_INT_SOURCE_KEY_TYPE',
    lc_dom_obj TYPE dd07l-domname VALUE 'ZZCA_INT_OBJECT_TYPE'.

  DATA:
    lt_search   TYPE STANDARD TABLE OF zzca_t_ifsearch,
    lt_object   TYPE STANDARD TABLE OF zzca_t_ifobj,
    lt_message  TYPE STANDARD TABLE OF zzca_t_ifmsg,
    lt_func_aux TYPE STANDARD TABLE OF zzca_t_iffunc.

  DATA:
    ls_ifreg      LIKE LINE OF gt_ifreg,
    ls_ifconf     LIKE LINE OF gt_ifconf,
    ls_search     LIKE LINE OF gt_search,
    ls_object     LIKE LINE OF gt_object,
    ls_message    LIKE LINE OF gt_message,
    ls_dom_values LIKE LINE OF gt_dom_vals,
    ls_data_2alv  LIKE LINE OF gt_data_2alv.

  DATA:
    lv_tabix TYPE sy-tabix.

  FIELD-SYMBOLS: <fs_alv>,
                 <fs_field>.

  DATA: dyn_table TYPE REF TO data,
        dyn_line  TYPE REF TO data.
*

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog = gt_fielcat_func
    IMPORTING
      ep_table        = dyn_table.

  ASSIGN dyn_table->* TO <ft_data_2alv_func>.
* Create dynamic work area and assign to Field Symbol
  CREATE DATA dyn_line LIKE LINE OF <ft_data_2alv_func>.
  ASSIGN dyn_line->* TO <fs_alv>.

  REFRESH <ft_data_2alv_func>.

  lt_func_aux[] = gt_func_fields[].
  DELETE lt_func_aux WHERE id_if NE us_tone_ws_001-id_if.
  SORT lt_func_aux BY id_if id_exec contador.

  IF gt_dom_vals IS INITIAL.
    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname        = lc_dom
        text           = abap_on
        langu          = sy-langu
      TABLES
        dd07v_tab      = gt_dom_vals
      EXCEPTIONS
        wrong_textflag = 1
        OTHERS         = 2.
  ENDIF.

  IF gt_dom_vals_obj[] IS INITIAL.
    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname        = lc_dom_obj
        text           = abap_on
        langu          = sy-langu
      TABLES
        dd07v_tab      = gt_dom_vals_obj
      EXCEPTIONS
        wrong_textflag = 1
        OTHERS         = 2.
  ENDIF.

  SORT gt_ifreg BY id_if id_exec.

  READ TABLE gt_ifreg TRANSPORTING NO FIELDS
  WITH KEY id_if = us_tone_ws_001-id_if.
  CHECK sy-subrc = 0.

  lv_tabix = sy-tabix.

  LOOP AT gt_ifreg
     INTO ls_ifreg
     FROM lv_tabix.

    IF ls_ifreg-id_if NE us_tone_ws_001-id_if.
      EXIT.
    ENDIF.

    CLEAR ls_data_2alv.
    MOVE-CORRESPONDING ls_ifreg TO ls_data_2alv.

    CASE ls_ifreg-erro.
      WHEN gc_stat_aviso.
        ls_data_2alv-icon = icon_led_yellow.
      WHEN gc_stat_err.
        ls_data_2alv-icon = icon_led_red.
      WHEN gc_stat_sucesso.
        ls_data_2alv-icon = icon_led_green.
    ENDCASE.

    REFRESH lt_search.
    lt_search[] = gt_search[].
    DELETE lt_search WHERE id_if   NE ls_ifreg-id_if
                        OR id_exec NE ls_ifreg-id_exec.

    READ TABLE gt_ifconf INTO ls_ifconf
                         WITH KEY id_if = ls_ifreg-id_if.
    IF sy-subrc = 0.
      ls_data_2alv-key_type = ls_ifconf-key_type.
      READ TABLE gt_dom_vals INTO ls_dom_values
                       WITH KEY domvalue_l = ls_data_2alv-key_type.
      IF sy-subrc = 0.
        ls_data_2alv-descr = ls_dom_values-ddtext.
      ENDIF.

      IF ls_ifconf-key_mult IS NOT INITIAL AND
         lines( lt_search ) > 1.
        ls_data_2alv-key_val = '*'.
      ELSE.
        READ TABLE lt_search INTO ls_search
                             WITH KEY id_if   = ls_ifreg-id_if
                                      id_exec = ls_ifreg-id_exec.
        IF sy-subrc = 0.
          ls_data_2alv-key_val = ls_search-key_val.
        ENDIF.
      ENDIF.
    ENDIF.

    REFRESH lt_object.
    lt_object[] = gt_object[].
    DELETE lt_object WHERE id_if   NE ls_ifreg-id_if
                        OR id_exec NE ls_ifreg-id_exec.

    READ TABLE gt_ifconf INTO ls_ifconf
                         WITH KEY id_if = ls_ifreg-id_if.
    IF sy-subrc = 0.
      ls_data_2alv-obj_type = ls_ifconf-obj_type.
      READ TABLE gt_dom_vals_obj INTO ls_dom_values
                             WITH KEY domvalue_l = ls_data_2alv-obj_type.
      IF sy-subrc = 0.
        ls_data_2alv-obj_desc = ls_dom_values-ddtext.
      ENDIF.

      READ TABLE lt_object INTO ls_object
                           WITH KEY id_if   = ls_ifreg-id_if
                                    id_exec = ls_ifreg-id_exec.
      IF sy-subrc = 0.
        ls_data_2alv-obj_val = ls_object-obj_val.
      ENDIF.
    ENDIF.

    REFRESH lt_message.
    lt_message[] = gt_message[].
    DELETE lt_message WHERE id_if   NE ls_ifreg-id_if
                         OR id_exec NE ls_ifreg-id_exec.

    READ TABLE gt_ifconf INTO ls_ifconf
                         WITH KEY id_if = ls_ifreg-id_if.
    IF sy-subrc = 0.
      READ TABLE lt_message INTO ls_message
                            WITH KEY id_if   = ls_ifreg-id_if
                                    id_exec = ls_ifreg-id_exec.
      IF sy-subrc = 0.
        ls_data_2alv-msg_type = ls_message-msg_val.
      ENDIF.
    ENDIF.

    LOOP AT lt_func_aux INTO DATA(ls_func_view) WHERE id_if EQ ls_ifreg-id_if AND id_exec EQ ls_ifreg-id_exec.
      ASSIGN COMPONENT ls_func_view-namefield OF STRUCTURE <fs_alv> TO <fs_field>.
      CHECK <fs_field> IS ASSIGNED.
      <fs_field> = ls_func_view-value.
      UNASSIGN <fs_field>.
    ENDLOOP.

    MOVE-CORRESPONDING ls_data_2alv TO <fs_alv>.
    APPEND <fs_alv> TO <ft_data_2alv_func>.

    CLEAR <fs_alv>.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form mostra_2_alv_func
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> NODE_KEY
*&---------------------------------------------------------------------*
FORM mostra_2_alv_func  USING p_node_key TYPE any.

  DATA:
      ls_t001_ifconf LIKE LINE OF gt_ifconf.

  DATA:
     lv_index TYPE p.
*

  "Obter linha
  CALL FUNCTION 'MOVE_CHAR_TO_NUM'
    EXPORTING
      chr             = p_node_key
    IMPORTING
      num             = lv_index
    EXCEPTIONS
      convt_no_number = 1
      convt_overflow  = 2
      OTHERS          = 3.

  CHECK sy-subrc = 0.

  lv_index  = p_node_key.

  READ TABLE gt_ifconf INTO ls_t001_ifconf INDEX lv_index.
  CHECK sy-subrc = 0.

  CLEAR gv_id_if.
  gv_id_if = ls_t001_ifconf-id_if.

  "Criar catalogo
  PERFORM load_catalog_2alv_func USING ls_t001_ifconf.

  "Criar tabela de logs
  PERFORM load_2alv_func USING ls_t001_ifconf.

  TRY.

      "Mostrar ALV
      CALL METHOD go_alv->set_table_for_first_display
        EXPORTING
          is_layout                     = gs_layout
        CHANGING
          it_outtab                     = <ft_data_2alv_func> "gt_data_2alv_func
          it_fieldcatalog               = gt_fielcat_func[]
        EXCEPTIONS
          invalid_parameter_combination = 1
          program_error                 = 2
          too_many_lines                = 3
          OTHERS                        = 4.
      IF sy-subrc <> 0.
        CLEAR gs_layout.
      ENDIF.

      CALL METHOD go_alv->refresh_table_display.

    CATCH cx_root.                                       "#EC CATCH_ALL

      MESSAGE ID sy-msgid
            TYPE 'S'
          NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
    DISPLAY LIKE 'E'.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_text_data_element
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_text_data_element USING uv_de_name TYPE rollname
                           CHANGING cv_text TYPE scrtext_l.

  DATA: lt_dd04t TYPE TABLE OF dd04t.
*

  CLEAR: cv_text.

  CHECK uv_de_name IS NOT INITIAL.

  SELECT * FROM dd04t
    INTO TABLE lt_dd04t
    WHERE rollname EQ uv_de_name
      AND as4local EQ 'A'.

  CHECK sy-subrc EQ 0.

  READ TABLE lt_dd04t INTO DATA(ls_dd04t) WITH KEY ddlanguage = sy-langu.
  IF sy-subrc EQ 0.
    cv_text = ls_dd04t-scrtext_m.
  ELSE.
    READ TABLE lt_dd04t INTO ls_dd04t WITH KEY ddlanguage = 'EN'.
    IF sy-subrc EQ 0.
      cv_text = ls_dd04t-scrtext_m.
    ELSE.
      READ TABLE lt_dd04t INTO ls_dd04t INDEX 1.
      IF sy-subrc EQ 0.
        cv_text = ls_dd04t-scrtext_m.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_alv_func
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_alv_func .

  DATA:
     ls_t001_ifconf LIKE LINE OF gt_ifconf.
*

  REFRESH:
    gt_ifreg,
    gt_ifconf,
    gt_ifconft,
    gt_techconf,
    gt_funcconf,
    gt_func_fields.

  PERFORM get_data.

  READ TABLE gt_ifconf INTO ls_t001_ifconf
  WITH KEY id_if = gv_id_if.
  CHECK sy-subrc = 0.

  "Criar catalogo
  PERFORM load_catalog_2alv_func USING ls_t001_ifconf.

  "Criar tabela de logs
  PERFORM load_2alv_func USING ls_t001_ifconf.

  TRY.

      "Mostrar ALV
      CALL METHOD go_alv->set_table_for_first_display
        EXPORTING
          is_layout                     = gs_layout
        CHANGING
          it_outtab                     = <ft_data_2alv_func>
          it_fieldcatalog               = gt_fielcat_func[]
        EXCEPTIONS
          invalid_parameter_combination = 1
          program_error                 = 2
          too_many_lines                = 3
          OTHERS                        = 4.
      IF sy-subrc <> 0.
        CLEAR gs_layout.
      ENDIF.

      CALL METHOD go_alv->refresh_table_display.

    CATCH cx_root.                                       "#EC CATCH_ALL

      MESSAGE ID sy-msgid
            TYPE 'S'
          NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
    DISPLAY LIKE 'E'.

  ENDTRY.
ENDFORM.
