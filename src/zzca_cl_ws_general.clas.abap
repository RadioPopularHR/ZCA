class ZZCA_CL_WS_GENERAL definition
  public
  create public .

public section.

  interfaces IF_SERIALIZABLE_OBJECT .

  constants GC_SEARCH_METHOD type ZZCA_INT_SEARCH_DIR value 'M' ##NO_TEXT.
  constants GC_STAT_AVISO type ZZCA_STATWS value 'W' ##NO_TEXT.
  constants GC_STAT_ERR type ZZCA_STATWS value 'E' ##NO_TEXT.
  constants GC_STAT_SUCESSO type ZZCA_STATWS value 'S' ##NO_TEXT.
  constants GC_DIR_IN type ZZCA_INT_DIRECT value 'I' ##NO_TEXT.
  constants GC_SEARCH_IN type ZZCA_INT_SEARCH_DIR value 'I' ##NO_TEXT.
  constants GC_SEARCH_OUT type ZZCA_INT_SEARCH_DIR value 'O' ##NO_TEXT.
  constants GC_SEARCH_CONSTANT type ZZCA_INT_SEARCH_DIR value 'C' ##NO_TEXT.
  constants GC_GENERAL_HARDC type PROGNAME value 'ZZCA_GERAL' ##NO_TEXT.
  data GV_COUNTRY type LAND1 value 'PT' ##NO_TEXT.
  data GS_IF_CUST_GEO type ZZCA_T_IFCF_GEO .

  class-methods CONVERT_OBJ_TO_XML
    importing
      !IO_OBJECT type ref to OBJECT
    exporting
      !EV_XML type STRING
    exceptions
      SEREALIZATION_ERROR .
  methods ADD_MSG_LOG
    importing
      !US_MSG type BAL_S_MSG
    exceptions
      ERROR_LOG .
  methods SET_INFO_IN
    importing
      !IS_INFO type ANY .
  methods GET_INFO_IN
    changing
      !C_INFO type ANY .
  methods SET_INFO_OUT
    importing
      !IS_INFO type ANY .
  methods GET_INFO_OUT
    changing
      !C_INFO type ANY .
  methods BEGIN_INTERFACE
    exceptions
      NOT_ATIVE
      IF_CONFIG_MISSING
      ERROR_LOG
      SEREALIZATION_ERROR
      NUMBER_RANGE_ERROR .
  methods CONSTRUCTOR
    importing
      !IV_NO_COMMIT type FLAG optional .
  methods END_INTERFACE
    exceptions
      ERROR_LOG
      SEREALIZATION_ERROR .
  methods SET_IF_STAT
    importing
      !IV_STAT type ZZCA_STATWS .
  class-methods CONVERT_XML_TO_OBJ
    importing
      !IV_XML type STRING
    returning
      value(RO_OBJECT) type ref to OBJECT
    exceptions
      SEREALIZATION_ERROR .
  methods SAVE_KEY_FIELDS
    importing
      !IV_DIRECTION type ZZCA_INT_DIRECT .
  methods SAVE_MSG_FIELDS
    importing
      !IV_DIRECTION type ZZCA_INT_DIRECT .
  methods SAVE_OBJ_FIELDS
    importing
      !IV_DIRECTION type ZZCA_INT_DIRECT .
  methods GET_IF_CUST_GEO
    exporting
      !ES_TABS type ZZCA_T_IFCF_GEO
    exceptions
      IF_CONFIG_MISSING .
  methods SET_COUNTRY
    importing
      !IV_EMPRESA type BUKRS optional
      !IV_ORGV type VKORG optional
      !IV_CLIENT type KUNNR optional
      !IV_COUNTRY type LAND1 optional .
  methods GET_ID_EXEC
    changing
      !C_ID_IF type ANY .
  class-methods HANDLE_REQUEST
    importing
      !INPUT type ANY
    exporting
      !OUTPUT type ANY
    changing
      !CO_OBJ type ref to OBJECT .
  methods HANDLE_REQUEST_CHILD
    importing
      !INPUT type ANY
    exporting
      !OUTPUT type ANY .
protected section.

  data GV_INTERFACE_ID type SRMIFID .
  data GO_OBJ_REF type ref to OBJECT .
  data GV_STAT type ZZCA_STATWS .

  methods GET_IF_CUST
    importing
      !IV_ID_IF type SRMIFID
    exporting
      !ES_IF_CONF type ZZCA_S_IFCONF
    exceptions
      IF_CONFIG_MISSING .
  methods SAVE_CALL_EVT
    returning
      value(RV_ACTIVE) type CHAR1
    exceptions
      NUMBER_RANGE_ERROR
      ERROR_LOG
      SEREALIZATION_ERROR
      WRONG_CONFIG .
  methods CRIAR_LOG
    exceptions
      ERROR_LOG .
  methods SAVE_LOG
    exceptions
      ERROR_LOG .
  methods SAVE_END_EVT
    exceptions
      ERROR_LOG
      SEREALIZATION_ERROR .
  methods SEND_EMAIL
    importing
      !IV_ID_IF type SRMIFID
      !IV_ID_EXEC type ZZCA_INT_TONE_ID_EXEC
    exceptions
      NO_EMAIL
      WRONG_EMAIL
      ERROR .
  methods SCHEDULE_EMAIL
    importing
      !IV_ID_IF type SRMIFID
      !IV_ID_EXEC type ZZCA_INT_TONE_ID_EXEC
      !IV_PRIORITY type ZZCA_INT_PROFILE .
  methods SAVE_FUNC_VIEW .
private section.

  data GC_NR_RANGE type INRI-NRRANGENR value '01' ##NO_TEXT.
  data GV_DUM type CHAR1 .
  data GS_INFO_IN type STRING .
  data GS_INFO_OUT type STRING .
  data GS_IF_CONF type ZZCA_S_IFCONF .
  data GV_ID_EXEC type ZZCA_INT_TONE_ID_EXEC .
  data GV_LOG_HANDLE type BALLOGHNDL .
  data GV_EXTERNAL_NUM type BALNREXT .
  data GV_NO_COMMIT type FLAG .
ENDCLASS.



CLASS ZZCA_CL_WS_GENERAL IMPLEMENTATION.


METHOD add_msg_log.

    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = gv_log_handle
        i_s_msg          = us_msg
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
      RAISE error_log.
    ENDIF.

  ENDMETHOD.


METHOD begin_interface.

  DATA:
 lv_active TYPE char1.
*

  "Ler configuração do interface
  CALL METHOD me->get_if_cust
    EXPORTING
      iv_id_if          = gv_interface_id
    IMPORTING
      es_if_conf        = gs_if_conf
    EXCEPTIONS
      if_config_missing = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
    "Configuração em falta para interface &.
    MESSAGE e008(zedi) WITH gv_interface_id RAISING if_config_missing.
  ENDIF.


  "Ler tabelas do interface
  CALL METHOD me->get_if_cust_geo
    EXCEPTIONS
      if_config_missing = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
    "Configuração em falta tabela & para país &.
    MESSAGE x015(zedi) WITH 'ZZCA_T_IFTABGEO' gv_country RAISING if_config_missing.
  ENDIF.



  "Guardar Invocação de Serviço
  CALL METHOD me->save_call_evt
    RECEIVING
      rv_active           = lv_active
    EXCEPTIONS
      number_range_error  = 1
      error_log           = 2
      serealization_error = 3
      wrong_config        = 4
      OTHERS              = 5.
  IF sy-subrc <> 0.

    CASE sy-subrc.
      WHEN 1.
        "Erro na obtenção de proximo registo (intervalo de numeração).
        MESSAGE e009(zedi) RAISING number_range_error.
      WHEN 2.
        "Erro no registo de LOG.
        MESSAGE e010(zedi) RAISING error_log.
      WHEN 3.
        "Erro na serialização.
        MESSAGE e011(zedi) RAISING serealization_error.
      WHEN 4.
        "Erro na serialização.
        MESSAGE e011(zedi) RAISING if_config_missing.
    ENDCASE.

  ELSEIF lv_active IS INITIAL.
    "Interface não ativo (Configuração).
    MESSAGE e012(zedi) RAISING not_ative.
  ENDIF.

ENDMETHOD.


METHOD constructor.
    gv_no_commit = iv_no_commit.
  ENDMETHOD.


METHOD convert_obj_to_xml.

    CONSTANTS:
    lc_encoding TYPE string VALUE 'utf-8'.

*
    DATA:
      lo_ixml           TYPE REF TO if_ixml,
      lo_stream_factory TYPE REF TO if_ixml_stream_factory,
      lo_encoding       TYPE REF TO if_ixml_encoding.
*


    TRY.
        lo_ixml = cl_ixml=>create( ).
        lo_stream_factory = lo_ixml->create_stream_factory( ).
        lo_encoding = lo_ixml->create_encoding( character_set = lc_encoding
                                                byte_order    = 0 ).

        CALL TRANSFORMATION id_indent
                     SOURCE ref = io_object
                 RESULT XML ev_xml.

      CATCH cx_root.
        RAISE serealization_error.
    ENDTRY.

  ENDMETHOD.


METHOD convert_xml_to_obj.

  TRY.
      CALL TRANSFORMATION id_indent
            SOURCE XML iv_xml
                RESULT ref = ro_object.
    CATCH cx_root.
      "Erro na serealização.
      MESSAGE e011(zedi) RAISING serealization_error.
  ENDTRY.

ENDMETHOD.


METHOD criar_log.

    DATA:
    ls_log TYPE bal_s_log.
*

    ls_log-object     = gs_if_conf-log_object.
    ls_log-subobject  = gs_if_conf-log_subobject.
    ls_log-extnumber  = gv_external_num.
    ls_log-aldate     = sy-datum.
    ls_log-altime     = sy-uzeit.
    ls_log-aluser     = sy-uname.
    ls_log-altcode    = sy-tcode.
    ls_log-alprog     = sy-repid.


    CLEAR gv_log_handle.

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log                 = ls_log
      IMPORTING
        e_log_handle            = gv_log_handle
      EXCEPTIONS
        log_header_inconsistent = 1
        OTHERS                  = 2.
    IF sy-subrc <> 0.
      RAISE error_log.
    ENDIF.

  ENDMETHOD.


METHOD end_interface.

  CALL METHOD me->save_end_evt
    EXCEPTIONS
      error_log           = 1
      serealization_error = 2
      OTHERS              = 3.
  IF sy-subrc <> 0.

    CASE sy-subrc.
      WHEN 1.
        "Erro no registo de LOG.
        MESSAGE e010(zedi) RAISING error_log.
      WHEN 2.
        "Erro na serealização.
        MESSAGE e011(zedi) RAISING serealization_error.
    ENDCASE.

    RETURN.

  ENDIF.


ENDMETHOD.


METHOD get_id_exec.
    c_id_if = gv_id_exec.
  ENDMETHOD.


METHOD get_if_cust.

*    SELECT SINGLE *
*        FROM zzca_t_ifconf
*        INTO es_if_conf
*        WHERE id_if = iv_id_if.
*    IF sy-subrc IS NOT INITIAL.
*      RAISE if_config_missing.
*    ENDIF.

  SELECT SINGLE *
   FROM zzca_t_ifconf
   INTO CORRESPONDING FIELDS OF es_if_conf
   WHERE id_if = iv_id_if.

  IF sy-subrc IS NOT INITIAL.
    RAISE if_config_missing.
  ENDIF.

*   Objetos de Processamento
  SELECT SINGLE *
  FROM zzca_t_objconf
  INTO CORRESPONDING FIELDS OF es_if_conf
  WHERE id_if = iv_id_if.

  IF sy-subrc IS NOT INITIAL.
    RAISE if_config_missing.
  ENDIF.

*   Logs
  SELECT SINGLE *
  FROM zzca_t_logsconf
  INTO CORRESPONDING FIELDS OF es_if_conf
  WHERE id_if = iv_id_if.

  IF sy-subrc IS NOT INITIAL.
    RAISE if_config_missing.
  ENDIF.

*   KEYs
  SELECT SINGLE *
  FROM zzca_t_keysconf
  INTO CORRESPONDING FIELDS OF es_if_conf
  WHERE id_if = iv_id_if.

*   PDF
  SELECT SINGLE *
  FROM zzca_t_pdfconf
  INTO CORRESPONDING FIELDS OF es_if_conf
  WHERE id_if = iv_id_if.

*   Tipos de Objeto
  SELECT SINGLE *
  FROM zzca_t_objtconf
  INTO CORRESPONDING FIELDS OF es_if_conf
  WHERE id_if = iv_id_if.

*   Tipos de Mensagem
  SELECT SINGLE *
  FROM zzca_t_msgtconf
  INTO CORRESPONDING FIELDS OF es_if_conf
  WHERE id_if = iv_id_if.

*   Ficheiros
  SELECT SINGLE *
  FROM zzca_t_fileconf
  INTO CORRESPONDING FIELDS OF es_if_conf
  WHERE id_if = iv_id_if.

ENDMETHOD.


METHOD get_if_cust_geo.

    DATA:
      lv_index  TYPE i VALUE 1,
      lv_nomore TYPE char1.

    FIELD-SYMBOLS:
      <fs_value> TYPE any.
*
    CLEAR gs_if_cust_geo.

    IF gv_country IS INITIAL.
      RAISE if_config_missing.
    ENDIF.

    SELECT SINGLE * FROM zzca_t_ifcf_geo
      INTO gs_if_cust_geo
      WHERE land1 = gv_country.
    IF sy-subrc IS NOT INITIAL.
      RAISE if_config_missing.
    ENDIF.


    WHILE lv_nomore IS INITIAL.

      ADD 1 TO lv_index.

      UNASSIGN <fs_value>.
      ASSIGN COMPONENT lv_index OF STRUCTURE gs_if_cust_geo TO <fs_value>.
      IF <fs_value> IS ASSIGNED.
        IF <fs_value> IS INITIAL.
          RAISE if_config_missing.
        ENDIF.
      ELSE.
        lv_nomore = abap_on.
      ENDIF.

    ENDWHILE.


    es_tabs = gs_if_cust_geo.

  ENDMETHOD.


METHOD get_info_in.

    c_info = gs_info_in.

  ENDMETHOD.


METHOD get_info_out.

    c_info = gs_info_out.

  ENDMETHOD.


  METHOD handle_request.
    CALL METHOD co_obj->('HANDLE_REQUEST_CHILD')
      EXPORTING
        input  = input
      IMPORTING
        output = output.
  ENDMETHOD.


  METHOD handle_request_child.

  ENDMETHOD.


METHOD save_call_evt.

    CONSTANTS:
    lc_meth TYPE char20 VALUE 'GET_INFO_IN'.

    DATA:
      lo_ref TYPE REF TO data.

    DATA:
      ls_if_ifreg TYPE zzca_t_ifreg,
      ls_if_xml   TYPE zzca_t_ifxml,
      ls_msg_log  TYPE bal_s_msg.

    DATA:
      lv_xml          TYPE string,
      lv_external_num TYPE balnrext,
      lv_log_handle   TYPE balloghndl,
      lv_key          TYPE zzca_key_value.

    FIELD-SYMBOLS:
      <lfs_in_info> TYPE any,
      <lfs_key>     TYPE any,
      <lfs_ifreg>   TYPE any,
      <lfs_xml>     TYPE any,
      <lfs_obj>     TYPE any.
*


    IF gs_if_conf-active IS INITIAL.
      RETURN.
    ENDIF.

    rv_active = gs_if_conf-active.

*--> Guardar Execução em LOG
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = gc_nr_range
        object                  = gs_if_cust_geo-int_num
      IMPORTING
        number                  = gv_id_exec
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.
    IF sy-subrc IS NOT INITIAL.
      RAISE number_range_error.
    ENDIF.

    IF gv_country IS NOT INITIAL.

      CONCATENATE gv_interface_id
                  gv_country
                  gv_id_exec
             INTO gv_external_num.

    ELSE.

      CONCATENATE gv_interface_id
                  gv_id_exec
             INTO gv_external_num.

    ENDIF.

    CALL METHOD me->criar_log
      EXCEPTIONS
        error_log = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      RAISE error_log.
    ENDIF.

    "Interface ID & invocado.
    MESSAGE s002(zedi) WITH gv_interface_id INTO gv_dum.
    MOVE-CORRESPONDING sy TO ls_msg_log.

    "Adiciona mensagem em LOG
    CALL METHOD me->add_msg_log
      EXPORTING
        us_msg    = ls_msg_log
      EXCEPTIONS
        error_log = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      RAISE error_log.
    ENDIF.

    "Guardar Log
    CALL METHOD me->save_log
      EXCEPTIONS
        error_log = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      RAISE error_log.
    ENDIF.
*<-- Guardar Execução em LOG

*-->Serializar informação
    "Interfaces de Saida SAP: Serealização feita noutra fase
    IF gs_if_conf-direction EQ gc_dir_in.

      CALL METHOD zzca_cl_ws_general=>convert_obj_to_xml
        EXPORTING
          io_object           = go_obj_ref
        IMPORTING
          ev_xml              = lv_xml
        EXCEPTIONS
          serealization_error = 1
          OTHERS              = 2.
      IF sy-subrc <> 0.
        RAISE serealization_error.
      ENDIF.

    ENDIF.
*<--Serializar informação

*-->Atualizar tabela de execução
    CREATE DATA lo_ref TYPE (gs_if_cust_geo-tab_reg_exec).
    IF lo_ref IS NOT BOUND.
      RAISE wrong_config.
    ENDIF.

    ASSIGN lo_ref->* TO <lfs_ifreg>.
    IF <lfs_ifreg> IS NOT ASSIGNED.
      RAISE wrong_config.
    ENDIF.

    CLEAR ls_if_ifreg.
    ls_if_ifreg-id_if        = gv_interface_id.     "Interface - ID
    ls_if_ifreg-id_exec      = gv_id_exec.          "ID do Fluxo de Interface
    ls_if_ifreg-log_ext      = gv_external_num.     "ID Externo de LOG
    ls_if_ifreg-username     = sy-uname.            "Username
    ls_if_ifreg-data         = sy-datum.            "Data
    ls_if_ifreg-hora         = sy-uzeit.            "Hora

    MOVE-CORRESPONDING ls_if_ifreg TO <lfs_ifreg>.
    MODIFY (gs_if_cust_geo-tab_reg_exec) FROM <lfs_ifreg>.
    IF sy-subrc = 0.
      IF gv_no_commit IS INITIAL.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.

    "-->Chave de Pesquisa
    IF gs_if_conf-key_direction EQ gc_search_in.
      CALL METHOD me->save_key_fields
        EXPORTING
          iv_direction = gs_if_conf-key_direction.

    ENDIF.
    "<--Chave de Pesquisa

*<--Atualizar tabela de execução


*-->Atualizar tabela de dados XML
    CREATE DATA lo_ref TYPE (gs_if_cust_geo-tab_ifxml).
    IF lo_ref IS NOT BOUND.
      RAISE wrong_config.
    ENDIF.

    ASSIGN lo_ref->* TO <lfs_xml>.
    IF <lfs_xml> IS NOT ASSIGNED.
      RAISE wrong_config.
    ENDIF.

    CLEAR ls_if_xml.
    ls_if_xml-id_if      = gv_interface_id.  "Interface - ID
    ls_if_xml-id_exec    = gv_id_exec.       "ID do Fluxo de Interface
    ls_if_xml-xml_obj    = lv_xml.           "Conteudo XML - IN
    MOVE-CORRESPONDING ls_if_xml TO <lfs_xml>.
    MODIFY (gs_if_cust_geo-tab_ifxml) FROM <lfs_xml>.
    IF sy-subrc = 0.
      IF gv_no_commit IS INITIAL.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.
*<--Atualizar tabela de dados XML


*--> Atualizar tabela de objetos
    IF gs_if_conf-obj_type IS NOT INITIAL.
      CALL METHOD me->save_obj_fields
        EXPORTING
          iv_direction = gs_if_conf-obj_direction.
    ENDIF.
*<-- Atualizar tabela de objetos


*--> Atualizar tabela de tipo de mensagem
    IF gs_if_conf-msg_direction IS NOT INITIAL.
      CALL METHOD me->save_msg_fields
        EXPORTING
          iv_direction = gs_if_conf-msg_direction.
    ENDIF.
*<-- Atualizar tabela de objetos

  ENDMETHOD.


METHOD save_end_evt.

  CONSTANTS:
  lc_meth TYPE char20 VALUE 'GET_INFO_OUT'.

  DATA:
     lo_ref TYPE REF TO data.

  DATA:
    ls_msg_log  TYPE bal_s_msg.

  DATA:
    lv_key TYPE zzca_key_value,
    lv_xml TYPE string,
    lv_err TYPE zzca_statws.

  FIELD-SYMBOLS:
    <lfs_out_info> TYPE any,
    <lfs_key>      TYPE any.
*


*-->Serializar informação
  CALL METHOD zzca_cl_ws_general=>convert_obj_to_xml
    EXPORTING
      io_object           = go_obj_ref
    IMPORTING
      ev_xml              = lv_xml
    EXCEPTIONS
      serealization_error = 1
      OTHERS              = 2.
  IF sy-subrc <> 0.
    RAISE serealization_error.
  ENDIF.
*<--Serializar informação


*-->Atualizar tabela de execução
  "-->Chave de Pesquisa
  IF gs_if_conf-key_direction EQ gc_search_out.

    CALL METHOD me->save_key_fields
      EXPORTING
        iv_direction = gs_if_conf-key_direction.

  ENDIF.
  "<--Chave de Pesquisa

*--> Atualizar tabela de objetos
  IF gs_if_conf-obj_direction EQ gc_search_out.
    CALL METHOD me->save_obj_fields
      EXPORTING
        iv_direction = gs_if_conf-obj_direction.
  ENDIF.
*<-- Atualizar tabela de objetos

  lv_err = gv_stat.

  IF lv_err IS INITIAL.
    lv_err = gc_stat_sucesso.
  ENDIF.


  UPDATE (gs_if_cust_geo-tab_reg_exec)
     SET erro    = lv_err
   WHERE id_if   = gv_interface_id
     AND id_exec = gv_id_exec.
  IF sy-subrc IS INITIAL.
    IF gv_no_commit IS INITIAL.
      COMMIT WORK.
    ENDIF.
  ENDIF.
*<--Atualizar tabela de execução


*-->Atualizar tabela de dados XML (ZZCA_T_IFXML)
  UPDATE (gs_if_cust_geo-tab_ifxml)
     SET xml_obj = lv_xml
   WHERE id_if   = gv_interface_id
     AND id_exec = gv_id_exec.
  IF sy-subrc = 0.
    IF gv_no_commit IS INITIAL.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.
*<--Atualizar tabela de dados XML (ZZCA_T_IFXML)

*-->   envio de email
  IF gs_if_conf-email IS NOT INITIAL.
    CASE gs_if_conf-email_profile.
      WHEN '1' OR '2'. " Agenda envio e-mail 1x dia

        CALL METHOD me->schedule_email
          EXPORTING
            iv_id_if    = gs_if_conf-id_if
            iv_id_exec  = gv_id_exec
            iv_priority = gs_if_conf-email_profile.

      WHEN '3'." Envia e-mail no momento, em caso de erro
        CHECK gv_stat EQ zzca_cl_ws_general=>gc_stat_err.

        CALL METHOD me->send_email
          EXPORTING
            iv_id_if    = gs_if_conf-id_if
            iv_id_exec  = gv_id_exec
          EXCEPTIONS
            no_email    = 1
            wrong_email = 2
            error       = 3
            OTHERS      = 4.

        IF sy-subrc <> 0.
          CASE sy-subrc.
            WHEN 1.
              "Necessário configurar destinatário(s) email(s).
              MESSAGE w016(zedi) INTO gv_dum.
              MOVE-CORRESPONDING sy TO ls_msg_log.
            WHEN 2.
              "Endereço de email inválido.
              MESSAGE w017(zedi) INTO gv_dum.
              MOVE-CORRESPONDING sy TO ls_msg_log.
            WHEN OTHERS.
              "Erro ao enviar email!
              MESSAGE w018(zedi) INTO gv_dum.
              MOVE-CORRESPONDING sy TO ls_msg_log.
          ENDCASE.

          CALL METHOD me->add_msg_log
            EXPORTING
              us_msg    = ls_msg_log
            EXCEPTIONS
              error_log = 1
              OTHERS    = 2.
          IF sy-subrc <> 0.
            RAISE error_log.
          ENDIF.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.
  ENDIF.
*<--   Envio de Email

  "Fim de Interface
  MESSAGE s003(zedi) INTO gv_dum.
  MOVE-CORRESPONDING sy TO ls_msg_log.

  CALL METHOD me->add_msg_log
    EXPORTING
      us_msg    = ls_msg_log
    EXCEPTIONS
      error_log = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
    RAISE error_log.
  ENDIF.

  "Guardar Log BD
  CALL METHOD me->save_log
    EXCEPTIONS
      error_log = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
    RAISE error_log.
  ENDIF.


ENDMETHOD.


  METHOD save_func_view.

    CONSTANTS:
      lc_meth_in  TYPE char20 VALUE 'GET_INFO_IN',
      lc_meth_out TYPE char20 VALUE 'GET_INFO_OUT'.

    DATA:
      ls_fview       TYPE zzca_t_iffunc,
      lt_func_config TYPE TABLE OF zzca_t_funcconf.

    DATA:
      lv_value    TYPE zzca_t_iffunc-value,
      lv_contador TYPE zzca_contador.

    DATA:
      lo_ref     TYPE REF TO data,
      lo_ref_src TYPE REF TO data.

    FIELD-SYMBOLS:
      <lfs_info_in>  TYPE any,
      <lfs_info_out> TYPE any,
      <lfs_value>    TYPE any,
      <lfs_src>      TYPE any.
*

    SELECT * FROM zzca_t_funcconf
      INTO TABLE lt_func_config
      WHERE id_if EQ gs_if_conf-id_if.

    CHECK lt_func_config IS NOT INITIAL.

    CREATE DATA lo_ref_src TYPE (gs_if_cust_geo-tab_iffuncview).
    IF lo_ref_src IS NOT BOUND.
      RETURN.
    ENDIF.

    ASSIGN lo_ref_src->* TO <lfs_src>.
    CHECK <lfs_src> IS ASSIGNED.

    " Dados de Input
    CREATE DATA lo_ref TYPE (gs_if_conf-in_struct_name).
    CHECK lo_ref IS BOUND.
    ASSIGN lo_ref->* TO <lfs_info_in>.
    IF <lfs_info_in> IS ASSIGNED.

      CALL METHOD go_obj_ref->(lc_meth_in)
        CHANGING
          c_info = <lfs_info_in>.
    ENDIF.
    FREE lo_ref.

    " Dados de Output
    CREATE DATA lo_ref TYPE (gs_if_conf-out_struct_name).
    CHECK lo_ref IS BOUND.
    ASSIGN lo_ref->* TO <lfs_info_out>.
    IF <lfs_info_out> IS ASSIGNED.

      CALL METHOD go_obj_ref->(lc_meth_out)
        CHANGING
          c_info = <lfs_info_out>.
    ENDIF.
    FREE lo_ref.

    LOOP AT lt_func_config INTO DATA(ls_func_config).

      CASE ls_func_config-field_direction.
        WHEN gc_search_in.
          ASSIGN COMPONENT ls_func_config-field_source OF STRUCTURE <lfs_info_in> TO <lfs_value>.
          IF <lfs_value> IS ASSIGNED AND
             <lfs_value> IS NOT INITIAL.
            lv_value = <lfs_value>.
          ENDIF.
        WHEN gc_search_out.
          ASSIGN COMPONENT ls_func_config-field_source OF STRUCTURE <lfs_info_out> TO <lfs_value>.
          IF <lfs_value> IS ASSIGNED AND
             <lfs_value> IS NOT INITIAL.
            lv_value = <lfs_value>.
          ENDIF.
        WHEN gc_search_constant.
          lv_value = ls_func_config-field_source.
        WHEN gc_search_method.
          TRY .
              DATA(p_tab) = VALUE abap_parmbind_tab(
                                  ( name  = 'INPUT'
                                    kind  = cl_abap_objectdescr=>exporting
                                    value =  REF #( <lfs_info_in> ) )
                                  ( name  = 'OUTPUT'
                                    kind  = cl_abap_objectdescr=>exporting
                                    value =  REF #( <lfs_info_out> ) )
                                  ( name  = 'VALUE'
                                    kind  = cl_abap_objectdescr=>returning
                                    value = REF #( lv_value ) ) ).

              CALL METHOD me->(ls_func_config-field_source)
                PARAMETER-TABLE p_tab.
            CATCH cx_sy_dyn_call_illegal_type.
            CATCH cx_sy_dyn_call_illegal_method.

          ENDTRY.
      ENDCASE.

      lv_contador = 1.
      ls_fview-id_if     = gv_interface_id.
      ls_fview-id_exec   = gv_id_exec.
      ls_fview-namefield = ls_func_config-field_name.
      ls_fview-contador  = lv_contador.
      ls_fview-value     = lv_value.
      MOVE-CORRESPONDING ls_fview TO <lfs_src>.
      MODIFY (gs_if_cust_geo-tab_iffuncview) FROM <lfs_src>.
      IF sy-subrc IS INITIAL.
        IF gv_no_commit IS INITIAL.
          COMMIT WORK.
        ENDIF.
      ENDIF.

      CLEAR: ls_fview, lv_value, p_tab[].
      UNASSIGN: <lfs_value>.
    ENDLOOP.

  ENDMETHOD.


METHOD save_key_fields.

    CONSTANTS:
      lc_meth_in  TYPE char20 VALUE 'GET_INFO_IN',
      lc_meth_out TYPE char20 VALUE 'GET_INFO_OUT'.

    TYPES:
      BEGIN OF lty_values,
        val TYPE zzca_key_value,
      END   OF lty_values.

    DATA:
      lo_ref     TYPE REF TO data,
      lo_ref_src TYPE REF TO data.

    DATA:
      lt_vals TYPE STANDARD TABLE OF lty_values.

    DATA:
      ls_val    LIKE LINE OF lt_vals,
      ls_search TYPE zzca_t_ifsearch.

    DATA:
      lv_contador TYPE zzca_contador,
      lv_meth     TYPE char20,
      lv_struct   TYPE char30,
      lv_key      TYPE zzca_key_value.

    FIELD-SYMBOLS:
      <lft_table> TYPE STANDARD TABLE,
      <lfs_line>  TYPE any,
      <lfs_info>  TYPE any,
      <lfs_key>   TYPE any,
      <lfs_src>   TYPE any.
*


    CASE iv_direction.
      WHEN gc_search_in.
        lv_meth   = lc_meth_in.
        lv_struct = gs_if_conf-in_struct_name.
      WHEN gc_search_out.
        lv_meth   = lc_meth_out.
        lv_struct = gs_if_conf-out_struct_name.
    ENDCASE.


    CREATE DATA lo_ref TYPE (lv_struct).
    CHECK lo_ref IS BOUND.
    ASSIGN lo_ref->* TO <lfs_info>.


    IF <lfs_info> IS ASSIGNED.

      CALL METHOD go_obj_ref->(lv_meth)
        CHANGING
          c_info = <lfs_info>.

      IF gs_if_conf-key_mult        IS NOT INITIAL AND
         gs_if_conf-key_source_mult IS NOT INITIAL.

        IF gs_if_conf-key_source IS NOT INITIAL.

          ASSIGN COMPONENT gs_if_conf-key_source_mult OF STRUCTURE <lfs_info> TO <lft_table>.
          IF sy-subrc = 0 AND <lft_table> IS ASSIGNED.

            LOOP AT <lft_table> ASSIGNING <lfs_line>.

              ASSIGN COMPONENT gs_if_conf-key_source OF STRUCTURE <lfs_line> TO <lfs_key>.
              IF <lfs_key> IS ASSIGNED AND
                 <lfs_key> IS NOT INITIAL.
                CLEAR ls_val.
                ls_val-val = <lfs_key>.
                APPEND ls_val TO lt_vals.
              ENDIF.

            ENDLOOP.

          ENDIF.

        ENDIF.

      ELSE.

        IF gs_if_conf-key_source IS NOT INITIAL.

          ASSIGN COMPONENT gs_if_conf-key_source OF STRUCTURE <lfs_info> TO <lfs_key>.
          IF <lfs_key> IS ASSIGNED AND <lfs_key> IS NOT INITIAL.
            lv_key = <lfs_key>.
          ENDIF.

        ENDIF.

      ENDIF.

    ENDIF.



    CREATE DATA lo_ref_src TYPE (gs_if_cust_geo-tab_ifsearch).
    IF lo_ref_src IS NOT BOUND.
      RETURN.
    ENDIF.

    ASSIGN lo_ref_src->* TO <lfs_src>.
    IF <lfs_src> IS NOT ASSIGNED.
      RETURN.
    ENDIF.


    IF lv_key IS NOT INITIAL.

      SELECT MAX( contador )
        FROM (gs_if_cust_geo-tab_ifsearch)
        INTO lv_contador
       WHERE id_if    = gv_interface_id
         AND id_exec  = gv_id_exec
         AND key_type = gs_if_conf-key_type.
      IF sy-subrc NE 0.
        lv_contador = 1.
      ELSE.
        ADD 1 TO lv_contador.
      ENDIF.

      ls_search-id_if    = gv_interface_id.
      ls_search-id_exec  = gv_id_exec.
      ls_search-contador = lv_contador.
      ls_search-key_type = gs_if_conf-key_type.
      ls_search-key_val  = lv_key.
      MOVE-CORRESPONDING ls_search TO <lfs_src>.
      MODIFY (gs_if_cust_geo-tab_ifsearch) FROM <lfs_src>.
      IF sy-subrc IS INITIAL.
        IF gv_no_commit IS INITIAL.
          COMMIT WORK.
        ENDIF.
      ENDIF.

    ELSEIF lt_vals IS NOT INITIAL.

      SORT lt_vals.
      DELETE ADJACENT DUPLICATES FROM lt_vals.

      SELECT MAX( contador )
        FROM (gs_if_cust_geo-tab_ifsearch)
        INTO lv_contador
       WHERE id_if    = gv_interface_id
         AND id_exec  = gv_id_exec
         AND key_type = gs_if_conf-key_type.
      IF sy-subrc NE 0.
        lv_contador = 1.
      ELSE.
        ADD 1 TO lv_contador.
      ENDIF.

      LOOP AT lt_vals INTO ls_val.

        CLEAR ls_search.
        ls_search-id_if    = gv_interface_id.
        ls_search-id_exec  = gv_id_exec.
        ls_search-contador = lv_contador.
        ls_search-key_type = gs_if_conf-key_type.
        ls_search-key_val  = ls_val-val.
        MOVE-CORRESPONDING ls_search TO <lfs_src>.
        MODIFY (gs_if_cust_geo-tab_ifsearch) FROM <lfs_src>.
        IF sy-subrc IS INITIAL.
          IF gv_no_commit IS INITIAL.
            COMMIT WORK.
            ADD 1 TO lv_contador.
          ENDIF.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.


METHOD save_log.

    DATA:
    lt_log_handle TYPE bal_t_logh.
*

    APPEND gv_log_handle TO lt_log_handle.

    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        i_t_log_handle   = lt_log_handle
      EXCEPTIONS
        log_not_found    = 1
        save_not_allowed = 2
        numbering_error  = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
      RAISE error_log.
    ENDIF.

  ENDMETHOD.


METHOD save_msg_fields.

*
    CONSTANTS:
      lc_meth_in  TYPE char20 VALUE 'GET_INFO_IN',
      lc_meth_out TYPE char20 VALUE 'GET_INFO_OUT'.

    DATA:
      lo_ref     TYPE REF TO data,
      lo_ref_src TYPE REF TO data.

    DATA:
      ls_message TYPE zzca_t_ifmsg.

    DATA:
      lv_meth    TYPE char20,
      lv_struct  TYPE char30,
      lv_message TYPE zzca_message_value.

    FIELD-SYMBOLS:
      <lft_table> TYPE STANDARD TABLE,
      <lfs_line>  TYPE any,
      <lfs_info>  TYPE any,
      <lfs_msg>   TYPE any,
      <lfs_src>   TYPE any.
*


    CASE iv_direction.
      WHEN gc_search_in.
        lv_meth   = lc_meth_in.
        lv_struct = gs_if_conf-in_struct_name.
      WHEN gc_search_out.
        lv_meth   = lc_meth_out.
        lv_struct = gs_if_conf-out_struct_name.
      WHEN gc_search_constant.
        lv_message = gs_if_conf-msg_source.
    ENDCASE.


    IF lv_message IS INITIAL.
      CREATE DATA lo_ref TYPE (lv_struct).
      CHECK lo_ref IS BOUND.
      ASSIGN lo_ref->* TO <lfs_info>.


      IF <lfs_info> IS ASSIGNED.

        CALL METHOD go_obj_ref->(lv_meth)
          CHANGING
            c_info = <lfs_info>.

        IF gs_if_conf-msg_source IS NOT INITIAL.
          ASSIGN COMPONENT gs_if_conf-msg_source OF STRUCTURE <lfs_info> TO <lfs_msg>.
          IF <lfs_msg> IS ASSIGNED AND
             <lfs_msg> IS NOT INITIAL.
            lv_message = <lfs_msg>.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.


    CREATE DATA lo_ref_src TYPE (gs_if_cust_geo-tab_ifmessage).
    IF lo_ref_src IS NOT BOUND.
      RETURN.
    ENDIF.

    ASSIGN lo_ref_src->* TO <lfs_src>.
    IF <lfs_src> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    IF lv_message IS NOT INITIAL.
      ls_message-id_if   = gv_interface_id.
      ls_message-id_exec = gv_id_exec.
      ls_message-msg_val = lv_message.

      CHECK ls_message IS NOT INITIAL.

      MOVE-CORRESPONDING ls_message TO <lfs_src>.
      MODIFY (gs_if_cust_geo-tab_ifmessage) FROM <lfs_src>.
      IF sy-subrc IS INITIAL.
        IF gv_no_commit IS INITIAL.
          COMMIT WORK.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDMETHOD.


METHOD save_obj_fields.

*
    CONSTANTS:
      lc_meth_in  TYPE char20 VALUE 'GET_INFO_IN',
      lc_meth_out TYPE char20 VALUE 'GET_INFO_OUT'.

    TYPES:
      BEGIN OF lty_values,
        val TYPE zzca_object_value,
      END   OF lty_values.

    DATA:
      lo_ref     TYPE REF TO data,
      lo_ref_src TYPE REF TO data.

    DATA:
      lt_vals TYPE STANDARD TABLE OF lty_values.

    DATA:
      ls_val    LIKE LINE OF lt_vals,
      ls_object TYPE zzca_t_ifobj.

    DATA:
      lv_meth   TYPE char20,
      lv_struct TYPE char30,
      lv_object TYPE zzca_object_value.

    FIELD-SYMBOLS:
      <lft_table> TYPE STANDARD TABLE,
      <lfs_line>  TYPE any,
      <lfs_info>  TYPE any,
      <lfs_obj>   TYPE any,
      <lfs_src>   TYPE any.
*


    CASE iv_direction.
      WHEN gc_search_in.
        lv_meth   = lc_meth_in.
        lv_struct = gs_if_conf-in_struct_name.
      WHEN gc_search_out.
        lv_meth   = lc_meth_out.
        lv_struct = gs_if_conf-out_struct_name.
      WHEN gc_search_constant.
    ENDCASE.


    CREATE DATA lo_ref TYPE (lv_struct).
    CHECK lo_ref IS BOUND.
    ASSIGN lo_ref->* TO <lfs_info>.


    IF <lfs_info> IS ASSIGNED.

      CALL METHOD go_obj_ref->(lv_meth)
        CHANGING
          c_info = <lfs_info>.

      IF gs_if_conf-obj_type IS NOT INITIAL.
        ASSIGN COMPONENT gs_if_conf-obj_source OF STRUCTURE <lfs_info> TO <lfs_obj>.
        IF <lfs_obj> IS ASSIGNED AND
           <lfs_obj> IS NOT INITIAL.
          lv_object = <lfs_obj>.
        ENDIF.
      ENDIF.
    ENDIF.


    CREATE DATA lo_ref_src TYPE (gs_if_cust_geo-tab_ifobject).
    IF lo_ref_src IS NOT BOUND.
      RETURN.
    ENDIF.

    ASSIGN lo_ref_src->* TO <lfs_src>.
    IF <lfs_src> IS NOT ASSIGNED.
      RETURN.
    ENDIF.


    IF lv_object IS NOT INITIAL.

      CASE gs_if_conf-obj_type.
        WHEN '1'.
          CLEAR ls_object.

          ls_object-id_if        = gv_interface_id.
          ls_object-id_exec      = gv_id_exec.
          ls_object-obj_type     = gs_if_conf-obj_type.
          ls_object-obj_val      = lv_object.
          ls_object-obj_program  = 'RSEIDOC2'.

        WHEN OTHERS.
      ENDCASE.
      CHECK ls_object IS NOT INITIAL.

      MOVE-CORRESPONDING ls_object TO <lfs_src>.
      MODIFY (gs_if_cust_geo-tab_ifobject) FROM <lfs_src>.
      IF sy-subrc IS INITIAL.
        IF gv_no_commit IS INITIAL.
          COMMIT WORK.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDMETHOD.


METHOD schedule_email.


  DATA: lv_process TYPE progname,
        lv_param   TYPE name_feld.

  DATA: lv_job_name         TYPE tbtcjob-jobname,
        lv_job_time         TYPE tbtcjob-sdlstrttm,
        lv_job_date         TYPE tbtcjob-sdlstrtdt,
        lv_job_count        TYPE tbtcjob-jobcount,
        lv_job_ret          TYPE i,
        lv_job_exist        TYPE flag,
        lv_job_was_released TYPE btch0000-char1,
        lv_time             TYPE zzca_t_hardc-inferior,
        ls_job              TYPE tbtco,
        lt_list_jobs        TYPE TABLE OF tbtco.


  CONCATENATE iv_priority iv_id_if INTO lv_job_name SEPARATED BY '_'.

  " Check if the job is already scheduled
  SELECT * FROM tbtco
    INTO TABLE lt_list_jobs
    WHERE jobname  EQ lv_job_name
      AND sdldate  GE sy-datum.

*SAP Job Status
*SCHEDULED          tbtco-status #P#
*RELEASED           tbtco-status #S#
*READY              tbtco-status #Y#
*ACTIVE             tbtco-status #Z#
*RUNNING            tbtco-status #R#
*CANCELED/ABORTED   tbtco-status #A#
*FINISHED           tbtco-status #F#

  LOOP AT lt_list_jobs INTO ls_job WHERE status = 'S' OR
                                         status = 'P' OR
                                         status = 'Y' OR
                                         status = 'Z' OR
                                         status = 'R'.
    lv_job_exist = abap_on.
    EXIT.
  ENDLOOP.

  IF lv_job_exist IS NOT INITIAL.
    RETURN.
  ENDIF.

  lv_process = iv_id_if.
  CONCATENATE 'JOB' iv_priority INTO lv_param SEPARATED BY '_'.

  CALL METHOD zzca_cl_hardc=>get_hardcode_value
    EXPORTING
      iv_processo  = lv_process
      iv_parametro = lv_param
    IMPORTING
      ev_value     = lv_time
    EXCEPTIONS
      no_data      = 1
      OTHERS       = 2.

  IF sy-subrc = 0.
    lv_job_time = lv_time.
    IF lv_job_time < sy-uzeit.
      lv_job_date = sy-datum + 1.
    ENDIF.
  ELSE.
    GET TIME.
    lv_job_time = sy-uzeit + 60. "seconds
    lv_job_date = sy-datum.
  ENDIF.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname          = lv_job_name
      sdlstrtdt        = lv_job_date
      sdlstrttm        = lv_job_time
    IMPORTING
      jobcount         = lv_job_count
    CHANGING
      ret              = lv_job_ret
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 4.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  SUBMIT zzca_schedule_email WITH pa_id_if = iv_id_if
                             WITH pa_prof  = iv_priority
                             WITH pa_jobn  = lv_job_name
                             WITH pa_jobc  = lv_job_count
                             VIA JOB lv_job_name NUMBER lv_job_count AND RETURN.

  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      jobcount             = lv_job_count
      jobname              = lv_job_name
      sdlstrtdt            = sy-datum
      sdlstrttm            = lv_job_time
    IMPORTING
      job_was_released     = lv_job_was_released
    CHANGING
      ret                  = lv_job_ret
    EXCEPTIONS
      cant_start_immediate = 1
      invalid_startdate    = 2
      jobname_missing      = 3
      job_close_failed     = 4
      job_nosteps          = 5
      job_notex            = 6
      lock_failed          = 7
      invalid_target       = 8
      OTHERS               = 9.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

ENDMETHOD.


METHOD send_email.

  DATA: lt_emails  TYPE TABLE OF zzca_t_emailconf,
        ls_email   TYPE zzca_t_emailconf,
        ls_address TYPE sx_address.

  DATA:  o_request       TYPE REF TO cl_bcs,
         o_message       TYPE REF TO cl_document_bcs,
         o_recipient     TYPE REF TO if_recipient_bcs,
         lv_subject      TYPE string,
         lv_subject_desc TYPE so_obj_des,
         lv_email        TYPE adr6-smtp_addr,
         lt_body         TYPE soli_tab,
         lv_body         TYPE string,
         lv_result       TYPE xfeld.

  DATA: ls_msg_hand   TYPE balmsghndl,
        ls_bal_s_msg  TYPE bal_s_msg,
        lt_log_handle TYPE bal_t_logh.

  DATA: bal_t_logh    TYPE bal_t_logh,
        bal_t_msgh    TYPE bal_t_msgh,
        ls_bal_t_msgh TYPE balmsghndl.


  APPEND gv_log_handle TO lt_log_handle.


  SELECT * FROM zzca_t_emailconf
    INTO TABLE lt_emails
    WHERE id_if EQ iv_id_if.

  IF sy-subrc <> 0.
    RAISE no_email.
  ENDIF.


  LOOP AT lt_emails INTO ls_email.
    ls_address-type    = 'INT'.
    ls_address-address = ls_email-email.

    CALL FUNCTION 'SX_INTERNET_ADDRESS_TO_NORMAL'
      EXPORTING
        address_unstruct    = ls_address
        complete_address    = 'X'
      EXCEPTIONS
        error_address_type  = 1
        error_address       = 2
        error_group_address = 3
        OTHERS              = 4.

    IF sy-subrc <> 0.
      RAISE wrong_email.
    ENDIF.
  ENDLOOP.

  TRY.

      CALL METHOD cl_bcs=>create_persistent
        RECEIVING
          result = o_request.

      "Assunto do email
      lv_subject = text-001.

      CALL METHOD o_request->set_message_subject
        EXPORTING
          ip_subject = lv_subject.

      CALL METHOD o_request->set_send_immediately
        EXPORTING
          i_send_immediately = abap_on.

****************** ALTERAR O REMETENTE DO EMAIL ****************************************************
*      DATA: o_sender TYPE REF TO if_sender_bcs.
*
*      lv_email = 'teste_sender@roff.pt'.
*
*      TRY.
*          CALL METHOD cl_cam_address_bcs=>create_internet_address
*            EXPORTING
*              i_address_string = lv_email
*            RECEIVING
*              result           = o_sender.
*
*          CALL METHOD o_request->set_sender
*            EXPORTING
*              i_sender = o_sender.
*
*        CATCH cx_send_req_bcs .
*
*      ENDTRY.
*      CLEAR lv_email.
*********************** FIM ***********************************************

      " Destinatários de e-mail
      LOOP AT lt_emails INTO ls_email.
        lv_email = ls_email-email.

        TRY .
            CALL METHOD cl_cam_address_bcs=>create_internet_address
              EXPORTING
                i_address_string = lv_email
              RECEIVING
                result           = o_recipient.

          CATCH cx_address_bcs.
            CONTINUE.
        ENDTRY.

        CHECK o_recipient IS BOUND.

        TRY .
            CALL METHOD o_request->add_recipient
              EXPORTING
                i_recipient = o_recipient.

          CATCH cx_send_req_bcs.
            CONTINUE.
        ENDTRY.
      ENDLOOP.


      APPEND INITIAL LINE TO lt_body.
      CLEAR: lv_body.
      "Informamos que a execução da interface & gerou um aviso de erro:
      lv_body = text-002.
      REPLACE '&' IN lv_body WITH iv_id_if.
      APPEND lv_body TO lt_body.
      APPEND INITIAL LINE TO lt_body.

      CLEAR: lv_body.
      "ID Interface:
      CONCATENATE text-003 iv_id_if INTO lv_body SEPARATED BY space.
      APPEND lv_body TO lt_body.

      CLEAR: lv_body.
      "ID Execução:
      CONCATENATE text-004 iv_id_exec INTO lv_body SEPARATED BY space.
      APPEND lv_body TO lt_body.
      APPEND INITIAL LINE TO lt_body.
      APPEND INITIAL LINE TO lt_body.

      CLEAR: lv_body.
      "Log:
      lv_body = text-005.
      APPEND lv_body TO lt_body.

      CALL FUNCTION 'BAL_GLB_SEARCH_MSG'
        EXPORTING
          i_t_log_handle = lt_log_handle
        IMPORTING
          e_t_log_handle = bal_t_logh
          e_t_msg_handle = bal_t_msgh
        EXCEPTIONS
          msg_not_found  = 1
          OTHERS         = 2.

      LOOP AT bal_t_msgh INTO ls_bal_t_msgh.

        ls_msg_hand-log_handle = ls_bal_t_msgh-log_handle.
        ls_msg_hand-msgnumber  = ls_bal_t_msgh-msgnumber.

        CALL FUNCTION 'BAL_LOG_MSG_READ'
          EXPORTING
            i_s_msg_handle = ls_msg_hand
            i_langu        = sy-langu
          IMPORTING
            e_s_msg        = ls_bal_s_msg
          EXCEPTIONS
            log_not_found  = 1
            msg_not_found  = 2
            OTHERS         = 3.

        IF sy-subrc = 0.
          MESSAGE ID ls_bal_s_msg-msgid TYPE ls_bal_s_msg-msgty NUMBER ls_bal_s_msg-msgno
             WITH ls_bal_s_msg-msgv1 ls_bal_s_msg-msgv2 ls_bal_s_msg-msgv3 ls_bal_s_msg-msgv4 INTO lv_body.

          APPEND lv_body TO lt_body.
        ENDIF.

      ENDLOOP.

      lv_subject_desc = lv_subject.
      CALL METHOD cl_document_bcs=>create_document
        EXPORTING
          i_type    = 'RAW'
          i_subject = lv_subject_desc
          i_text    = lt_body
        RECEIVING
          result    = o_message.

      "Associa a mensagem ao pedido de comunicação SAP
      CALL METHOD o_request->set_document
        EXPORTING
          i_document = o_message.

      CALL METHOD o_request->send
        RECEIVING
          result = lv_result.

      IF lv_result IS NOT INITIAL.
        COMMIT WORK AND WAIT.
      ENDIF.

    CATCH cx_send_req_bcs.
      RAISE error.
    CATCH cx_document_bcs.
      RAISE error.
    CATCH cx_root.
      RAISE error.
  ENDTRY.

ENDMETHOD.


METHOD set_country.

    DATA:
      lv_bukrs   TYPE bukrs,
      lv_country TYPE land1.
*

    IF iv_country IS NOT INITIAL.

      lv_country = iv_country.

    ELSEIF iv_empresa IS NOT INITIAL.

      SELECT SINGLE land1
          FROM t001
          INTO lv_country
          WHERE bukrs = iv_empresa.

    ELSEIF iv_orgv IS NOT INITIAL.

      SELECT SINGLE bukrs
       FROM tvko
       INTO lv_bukrs
       WHERE vkorg = iv_orgv.

      SELECT SINGLE land1
          FROM t001
          INTO lv_country
          WHERE bukrs = lv_bukrs.

    ELSEIF iv_client IS NOT INITIAL.

      SELECT SINGLE land1
          FROM kna1
          INTO lv_country
          WHERE kunnr = iv_client.

    ENDIF.


    IF lv_country IS NOT INITIAL.
      gv_country = lv_country.
    ENDIF.

  ENDMETHOD.


METHOD set_if_stat.

    gv_stat = iv_stat.

  ENDMETHOD.


METHOD set_info_in.

    gs_info_in = is_info.
    go_obj_ref = me.

  ENDMETHOD.


METHOD set_info_out.

    gs_info_out = is_info.
    go_obj_ref = me.

  ENDMETHOD.
ENDCLASS.
