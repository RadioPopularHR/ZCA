*&---------------------------------------------------------------------*
*&  Include           ZZCA_COCKPIT_INTF_SCR
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.

SELECT-OPTIONS: s_id_if FOR gs_scr-id_if,
                s_erro  FOR gs_scr-erro.

SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-t02.

SELECT-OPTIONS: s_exec  FOR gs_scr-id_exec,
                s_data  FOR sy-datum DEFAULT sy-datum TO sy-datum,
                s_hora  FOR sy-uzeit.

SELECTION-SCREEN END OF BLOCK b2.

"Todas as pesquisas devem começar com 'S_KEY_' mais um caracter e devem
"estar parametrizadas na tabela ZZCA_T_IFKEYS
SELECTION-SCREEN BEGIN OF BLOCK key WITH FRAME TITLE text-t03.

SELECT-OPTIONS: s_key_k FOR kna1-kunnr,
                s_key_v FOR vbak-vbeln,
                s_key_m FOR mara-matnr.

SELECTION-SCREEN END OF BLOCK key.

AT SELECTION-SCREEN OUTPUT.
  PERFORM check_selection_fields.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_id_if-low.
  PERFORM f4_if_id CHANGING s_id_if-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_id_if-high.
  PERFORM f4_if_id CHANGING s_id_if-high.
