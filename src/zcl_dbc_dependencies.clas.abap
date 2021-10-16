class ZCL_DBC_DEPENDENCIES definition
  public
  final
  create public .

public section.

  interfaces ZIF_APACK_MANIFEST .

  methods CONSTRUCTOR .
protected section.
private section.
ENDCLASS.



CLASS ZCL_DBC_DEPENDENCIES IMPLEMENTATION.


  METHOD constructor.

    zif_apack_manifest~descriptor = VALUE #(
      group_id        = 'hardyp'
      artifact_id     = 'DesignByContract'
      version         = '0.1'
      repository_type = zif_apack_manifest~co_abap_git
      git_url         = 'https://github.com/hardyp/DesignByContract'
      dependencies    = VALUE #(
        ( group_id    = 'abaplogger'
          artifact_id = 'abaplogger'
          git_url     = 'https://github.com/ABAP-Logger/ABAP-Logger' ) ) ).

  ENDMETHOD.
ENDCLASS.
