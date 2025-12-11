*&---------------------------------------------------------------------*
*&  Include           ZZCA_COCKPIT_INTF_LCL
*&---------------------------------------------------------------------*

CLASS lcl_application DEFINITION FINAL.

  PUBLIC SECTION.

    METHODS:
      handle_button_click FOR EVENT button_click OF cl_gui_column_tree IMPORTING node_key,

      handle_item_double_click FOR EVENT item_double_click OF cl_gui_column_tree IMPORTING node_key.

ENDCLASS.                    "LCL_APPLICATION DEFINITION
*----------------------------------------------------------------------*
*       CLASS lcl_application IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_application IMPLEMENTATION.

  METHOD  handle_button_click.

    IF gv_func_view IS INITIAL.
      PERFORM mostra_2_alv USING node_key.
    ELSE.
      PERFORM mostra_2_alv_func USING node_key.
    ENDIF.

  ENDMETHOD.                    "HANDLE_BUTTON_CLICK

  METHOD handle_item_double_click.

    IF gv_func_view IS INITIAL.
      PERFORM mostra_2_alv USING node_key.
    ELSE.
      PERFORM mostra_2_alv_func USING node_key.
    ENDIF.

  ENDMETHOD.                    "HANDLE_ITEM_DOUBLE_CLICK

ENDCLASS.                    "LCL_APPLICATION IMPLEMENTATION

CLASS: lcl_alv_toolbar DEFINITION DEFERRED.

DATA: go_alv_toolbar        TYPE REF TO lcl_alv_toolbar,
      go_alv_toolbarmanager TYPE REF TO cl_alv_grid_toolbar_manager.

*---------------------------------------------------------------------*
*       CLASS lcl_alv_toolbar DEFINITION
*---------------------------------------------------------------------*
*       ALV event handler
*---------------------------------------------------------------------*
CLASS lcl_alv_toolbar DEFINITION FINAL.
  PUBLIC SECTION.

    METHODS:
      constructor IMPORTING io_alv_grid TYPE REF TO cl_gui_alv_grid,

      on_toolbar FOR EVENT toolbar OF cl_gui_alv_grid IMPORTING e_object,

      on_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id
                  e_column_id
                  es_row_no,

      on_hotspot_click_table_values FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row
                  column,

      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid IMPORTING e_ucomm.

ENDCLASS.                    "lcl_alv_toolbar DEFINITION
*---------------------------------------------------------------------*
*       CLASS lcl_alv_toolbar IMPLEMENTATION
*---------------------------------------------------------------------*
*       ALV event handler
*---------------------------------------------------------------------*
CLASS lcl_alv_toolbar IMPLEMENTATION.

  METHOD constructor.
*   Create ALV toolbar manager instance
    CREATE OBJECT go_alv_toolbarmanager
      EXPORTING
        io_alv_grid = io_alv_grid.

  ENDMETHOD.                    "constructor

  METHOD handle_user_command.

    CASE e_ucomm.
      WHEN gc_fcode_log.
        PERFORM toolbard_action USING 1.
      WHEN gc_fcode_obj_in.
        PERFORM toolbard_action USING 2.
      WHEN gc_fcode_obj_out.
        PERFORM toolbard_action USING 3.
      WHEN gc_fcode_ref.
        IF gv_func_view IS INITIAL.
          PERFORM refresh_alv.
        ELSE.
          PERFORM refresh_alv_func.
        ENDIF.
      WHEN gc_fcode_rep.
        PERFORM toolbard_action USING 4.
      WHEN gc_fcode_pdf.
        PERFORM toolbard_action USING 5.
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.                    "handle_user_command

  METHOD on_hotspot_click.

    CONSTANTS:
      lc_dom     TYPE dd07l-domname VALUE 'ZZCA_INT_SOURCE_KEY_TYPE',
      lc_dom_obj TYPE dd07l-domname VALUE 'ZZCA_INT_OBJECT_TYPE'.

    DATA:
      lr_table     TYPE REF TO cl_salv_table,
      lr_functions TYPE REF TO cl_salv_functions_list,
      lr_display   TYPE REF TO cl_salv_display_settings,
      lr_columns   TYPE REF TO cl_salv_columns_table,
      lr_column    TYPE REF TO cl_salv_column_table,
      lr_events    TYPE REF TO cl_salv_events_table.

    DATA:
      ls_alv_data   LIKE LINE OF gt_data_2alv,
      ls_object     TYPE         zzca_t_ifobj,
      ls_dom_values LIKE LINE OF gt_dom_vals,
      ls_search     LIKE LINE OF gt_search,
      ls_value      LIKE LINE OF gt_values_hotspot.

    DATA:
      lv_index TYPE sy-tabix,
      lv_val   TYPE dd07v-domvalue_l,
      lv_title TYPE lvc_title.

    IF gv_func_view IS NOT INITIAL.
      gt_data_2alv = CORRESPONDING #( <ft_data_2alv_func> ).
    ENDIF.

    READ TABLE gt_data_2alv INTO ls_alv_data INDEX es_row_no-row_id.
    IF sy-subrc = 0.

      CASE e_column_id.
        WHEN 'KEY_VAL'.
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

*          CHECK ls_alv_data-key_val EQ '*'.
          IF ls_alv_data-key_val EQ '*'.   "Tabela de Valores

            REFRESH gt_values_hotspot.
            READ TABLE gt_search TRANSPORTING NO FIELDS
                                 WITH KEY id_if   = ls_alv_data-id_if
                                          id_exec = ls_alv_data-id_exec.
            IF sy-subrc = 0.

              CLEAR lv_index.
              lv_index = sy-tabix.

              LOOP AT gt_search
                 INTO ls_search
                 FROM lv_index.

                IF ls_search-id_if   NE ls_alv_data-id_if OR
                   ls_search-id_exec NE ls_alv_data-id_exec.
                  EXIT.
                ENDIF.

                IF lv_val IS INITIAL.
                  lv_val = ls_search-key_type.
                ENDIF.
                CLEAR ls_value.
                ls_value-val = ls_search-key_val.
                APPEND ls_value TO gt_values_hotspot.

              ENDLOOP.

              IF gt_values_hotspot IS NOT INITIAL.

                TRY.
                    cl_salv_table=>factory(
                      IMPORTING
                        r_salv_table = lr_table
                      CHANGING
                        t_table      = gt_values_hotspot ).
                  CATCH cx_salv_msg.                    "#EC NO_HANDLER
                ENDTRY.

                "Ativar função de filtro
                lr_functions = lr_table->get_functions( ).
                CALL METHOD lr_functions->set_filter
                  EXPORTING
                    value = if_salv_c_bool_sap=>true.

                " Hostpot na tabela de valores
                lr_columns = lr_table->get_columns( ).
                lr_column ?= lr_columns->get_column( 'VAL' ).
                lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

                lr_table->set_screen_popup(
                          start_column = 1
                          end_column   = 50
                          start_line   = 1
                          end_line     = 10 ).

                READ TABLE gt_dom_vals INTO ls_dom_values
                                       WITH KEY domvalue_l = lv_val.
                IF sy-subrc = 0.
                  lv_title = ls_dom_values-ddtext.
                  lr_display = lr_table->get_display_settings( ).
                  lr_display->set_list_header( lv_title ).
                ENDIF.

                gs_alv_data = ls_alv_data.
                " Adicionar Handler para os eventos
                lr_events = lr_table->get_event( ).
                SET HANDLER go_alv_toolbar->on_hotspot_click_table_values FOR lr_events.

                lr_table->display( ).

              ENDIF.
            ENDIF.

          ELSEIF ls_alv_data-key_val IS NOT INITIAL. "Hostpot para a configuração

            READ TABLE gt_ifconf INTO DATA(ls_ifconf) WITH KEY id_if = ls_alv_data-id_if.
            CHECK sy-subrc = 0.
            CHECK ls_ifconf-hotspot_type IS NOT INITIAL AND ls_ifconf-hotspot_source IS NOT INITIAL.

            PERFORM read_config_hotspot_key USING ls_ifconf ls_alv_data ''.
          ENDIF.

        WHEN 'OBJ_VAL'.
          IF gt_dom_vals_obj IS INITIAL.
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

          CHECK ls_alv_data-obj_val NE space.

          READ TABLE gt_object INTO ls_object
                               WITH KEY id_if    = ls_alv_data-id_if
                                        id_exec  = ls_alv_data-id_exec
                                        obj_type = ls_alv_data-obj_type
                                        obj_val  = ls_alv_data-obj_val.
          CHECK sy-subrc IS INITIAL.

          CHECK ls_object-obj_transaction NE space OR
                ls_object-obj_program     NE space.

          CASE ls_object-obj_type.
            WHEN '1'. " IDoc
              PERFORM read_idoc USING ls_alv_data-data ls_object.

            WHEN OTHERS.
              "DO NOTHING
          ENDCASE.

        WHEN OTHERS.
      ENDCASE.

    ENDIF.

  ENDMETHOD.                    "on_hotspot_click

  METHOD on_toolbar.

    DATA:
      ls_toolbar     TYPE stb_button,
      ls_t001_ifconf LIKE LINE OF gt_ifconf.

    "REFRESH e_object->mt_toolbar.
    READ TABLE gt_ifconf INTO ls_t001_ifconf WITH KEY id_if = gv_id_if.
    CHECK sy-subrc = 0.


    ls_toolbar-icon      = icon_refresh.
    ls_toolbar-butn_type = 0.
    ls_toolbar-text      = TEXT-003.
    ls_toolbar-function  = gc_fcode_ref.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    ls_toolbar-icon      = icon_protocol.
    ls_toolbar-butn_type = 0.
    ls_toolbar-text      = TEXT-001.
    ls_toolbar-function  = gc_fcode_log.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CASE ls_t001_ifconf-type_if.
      WHEN gc_webserv.

        ls_toolbar-icon      = icon_display.
        ls_toolbar-butn_type = 0.
        ls_toolbar-text      = TEXT-002.
        ls_toolbar-function  = gc_fcode_obj_in.
        APPEND ls_toolbar TO e_object->mt_toolbar.

        ls_toolbar-icon      = icon_display.
        ls_toolbar-butn_type = 0.
        ls_toolbar-text      = TEXT-004.
        ls_toolbar-function  = gc_fcode_obj_out.
        APPEND ls_toolbar TO e_object->mt_toolbar.

        IF ls_t001_ifconf-reproc IS NOT INITIAL.
          ls_toolbar-icon      = icon_execute_object.
          ls_toolbar-butn_type = 0.
          ls_toolbar-text      = TEXT-007.
          ls_toolbar-function  = gc_fcode_rep.
          APPEND ls_toolbar TO e_object->mt_toolbar.
        ENDIF.

        IF ls_t001_ifconf-pdf_fieldname IS NOT INITIAL.
          ls_toolbar-icon      = icon_pdf.
          ls_toolbar-butn_type = 0.
          ls_toolbar-text      = TEXT-008.
          ls_toolbar-function  = gc_fcode_pdf.
          APPEND ls_toolbar TO e_object->mt_toolbar.
        ENDIF.

      WHEN gc_file.

        CASE ls_t001_ifconf-direction.
          WHEN gc_in.
            ls_toolbar-icon      = icon_display.
            ls_toolbar-butn_type = 0.
            ls_toolbar-text      = TEXT-002.
            ls_toolbar-function  = gc_fcode_obj_in.
            APPEND ls_toolbar TO e_object->mt_toolbar.
          WHEN gc_out.
            ls_toolbar-icon      = icon_display.
            ls_toolbar-butn_type = 0.
            ls_toolbar-text      = TEXT-004.
            ls_toolbar-function  = gc_fcode_obj_out.
            APPEND ls_toolbar TO e_object->mt_toolbar.
        ENDCASE.

        IF ls_t001_ifconf-reproc IS NOT INITIAL.
          ls_toolbar-icon      = icon_execute_object.
          ls_toolbar-butn_type = 0.
          ls_toolbar-text      = TEXT-007.
          ls_toolbar-function  = gc_fcode_rep.
          APPEND ls_toolbar TO e_object->mt_toolbar.
        ENDIF.

    ENDCASE.

    CALL METHOD go_alv_toolbarmanager->reorganize
      EXPORTING
        io_alv_toolbar = e_object.

  ENDMETHOD.                    "on_toolbar

  METHOD on_hotspot_click_table_values.

    CASE column.
      WHEN 'VAL'.

        READ TABLE gt_values_hotspot INTO DATA(ls_row) INDEX row.
        CHECK sy-subrc = 0.

        READ TABLE gt_ifconf INTO DATA(ls_ifconf) WITH KEY id_if = gs_alv_data-id_if.
        CHECK sy-subrc = 0.
        CHECK ls_ifconf-hotspot_type IS NOT INITIAL AND ls_ifconf-hotspot_source IS NOT INITIAL.

        PERFORM read_config_hotspot_key USING ls_ifconf gs_alv_data ls_row.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                     "on_hotspot_click_table_values

ENDCLASS.                    "lcl_alv_toolbar IMPLEMENTATION
