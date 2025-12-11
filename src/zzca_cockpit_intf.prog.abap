*&---------------------------------------------------------------------*
*&                  Programa: ZZCA_COCKPIT_INTF                        *
*&---------------------------------------------------------------------*
*& Descrição: Cockpit de interfaces                                    *
*&---------------------------------------------------------------------*
*& Autor..........: Ricardo Cardoso - ROFF SDF                         *
*& Data de Criação: 05.01.2021                                         *
*&---------------------------------------------------------------------*
* Modificações                                                         *
* Data..........:                                                      *
* Autor.........:                                                      *
* Tag...........:                                                      *
* Descrição.....:                                                      *
*----------------------------------------------------------------------*
REPORT zzca_cockpit_intf   MESSAGE-ID zedi.

INCLUDE  zzca_cockpit_intf_top.
INCLUDE  zzca_cockpit_intf_lcl.
INCLUDE  zzca_cockpit_intf_scr.
INCLUDE  zzca_cockpit_intf_f01.
INCLUDE  zzca_cockpit_intf_pbo.
INCLUDE  zzca_cockpit_intf_pai.

INITIALIZATION.
  PERFORM get_slect_param.

START-OF-SELECTION.
  PERFORM get_data.

END-OF-SELECTION.
  PERFORM display_data.
