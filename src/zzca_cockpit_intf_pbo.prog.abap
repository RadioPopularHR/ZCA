*&---------------------------------------------------------------------*
*&  Include           ZZCA_COCKPIT_INTF_PBO
*&---------------------------------------------------------------------*

MODULE status_0001 OUTPUT.

  DATA: ls_buttons TYPE sy-ucomm,
        lt_buttons TYPE STANDARD TABLE OF sy-ucomm.
*

  IF gv_func_view IS NOT INITIAL.
    ls_buttons = gc_fcode_v_func.
    APPEND ls_buttons TO lt_buttons.

    SET PF-STATUS 'STATUS_1' EXCLUDING lt_buttons.
  ELSE.

    ls_buttons = gc_fcode_v_tech.
    APPEND ls_buttons TO lt_buttons.

    SET PF-STATUS 'STATUS_1' EXCLUDING lt_buttons.
  ENDIF.

  REFRESH: lt_buttons.

  CLEAR gv_ok_code.

  "SET PF-STATUS 'STATUS_1'.

  SET TITLEBAR 'TITLE_1'.

  IF go_custom_container1 IS INITIAL.
    PERFORM create_and_init_tree.
  ENDIF.

ENDMODULE.
