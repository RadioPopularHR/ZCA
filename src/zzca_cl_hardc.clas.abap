class ZZCA_CL_HARDC definition
  public
  final
  create public .

public section.

  class-methods GET_HARDCODE_RANGE
    importing
      !IV_PROCESSO type PROGNAME
      !IV_PARAMETRO type NAME_FELD
    exporting
      !ER_RANGE type /SDF/E2E_SELOP_TT
    exceptions
      NO_DATA .
  class-methods GET_HARDCODE_VALUE
    importing
      !IV_PROCESSO type PROGNAME
      !IV_PARAMETRO type NAME_FELD
      !IV_ITEM type ZZCA_E_ITEM optional
    exporting
      !EV_VALUE type ZZCA_E_LIM_LOW
    exceptions
      NO_DATA .
protected section.
private section.
ENDCLASS.



CLASS ZZCA_CL_HARDC IMPLEMENTATION.


METHOD get_hardcode_range.

    DATA:
   lt_hardc TYPE STANDARD TABLE OF zzca_t_hardc.

    DATA:
      ls_hardc LIKE LINE OF lt_hardc,
      ls_range LIKE LINE OF er_range.
*

    SELECT *
      FROM zzca_t_hardc
      INTO TABLE lt_hardc
     WHERE processo  = iv_processo
       AND parametro = iv_parametro.
    IF sy-subrc <> 0.
      RAISE no_data.
    ELSE.
      LOOP AT lt_hardc
         INTO ls_hardc.
        ls_range-sign   = ls_hardc-sinal.
        ls_range-option = ls_hardc-opcao.
        ls_range-low    = ls_hardc-inferior.
        ls_range-high   = ls_hardc-superior.
        APPEND ls_range TO er_range.
        CLEAR ls_range.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


METHOD get_hardcode_value.

    DATA: lv_item TYPE zzca_e_item VALUE '001'.

    IF iv_item IS NOT INITIAL.
      lv_item = iv_item.
    ENDIF.

    SELECT SINGLE inferior
      FROM zzca_t_hardc
      INTO ev_value
     WHERE processo  = iv_processo
       AND parametro = iv_parametro
       AND item      = lv_item.
    IF sy-subrc <> 0.
      RAISE no_data.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
