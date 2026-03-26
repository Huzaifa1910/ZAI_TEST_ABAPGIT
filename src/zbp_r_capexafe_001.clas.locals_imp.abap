CLASS lhc_afeheader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR AFEHeader RESULT result.

    METHODS deriveprojectdetails FOR DETERMINE ON MODIFY
      IMPORTING keys FOR AFEHeader~deriveProjectDetails.

    METHODS calculatetotals FOR DETERMINE ON MODIFY
      IMPORTING keys FOR AFEHeader~calculateTotals.

    METHODS checkproject FOR VALIDATE ON SAVE
      IMPORTING keys FOR AFEHeader~checkProject.

    METHODS checkbudgetflags FOR VALIDATE ON SAVE
      IMPORTING keys FOR AFEHeader~checkBudgetFlags.

    METHODS submit FOR MODIFY
      IMPORTING keys FOR ACTION AFEHeader~Submit RESULT result.

    METHODS reopen FOR MODIFY
      IMPORTING keys FOR ACTION AFEHeader~Reopen RESULT result.
ENDCLASS.

CLASS lhc_afeheader IMPLEMENTATION.

* ──────────────────────────────────────────────────────────────
*  AUTHORIZATION: Grant full access (Public Cloud pattern)
* ──────────────────────────────────────────────────────────────
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABUAUTH'
      ID 'TABLE' FIELD 'ZCAPEXAFE_001'
      ID 'ACTIVITY' FIELD '02'.

    IF sy-subrc = 0.
      result-%create      = if_abap_behv=>auth-allowed.
      result-%update      = if_abap_behv=>auth-allowed.
      result-%delete      = if_abap_behv=>auth-allowed.
      result-%action-Submit = if_abap_behv=>auth-allowed.
      result-%action-Reopen = if_abap_behv=>auth-allowed.
    ELSE.
      result-%create      = if_abap_behv=>auth-allowed.
      result-%update      = if_abap_behv=>auth-allowed.
      result-%delete      = if_abap_behv=>auth-allowed.
      result-%action-Submit = if_abap_behv=>auth-allowed.
      result-%action-Reopen = if_abap_behv=>auth-allowed.
    ENDIF.
  ENDMETHOD.

* ──────────────────────────────────────────────────────────────
*  DETERMINATION: Auto-fetch project details from I_EnterpriseProject
* ──────────────────────────────────────────────────────────────
  METHOD deriveprojectdetails.
    READ ENTITIES OF zr_capexafe_001 IN LOCAL MODE
      ENTITY AFEHeader
        FIELDS ( ProjectId )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_afe).

    LOOP AT lt_afe ASSIGNING FIELD-SYMBOL(<fs_afe>).
      IF <fs_afe>-ProjectId IS NOT INITIAL.
        SELECT SINGLE ProjectDescription, PlannedStartDate
          FROM I_EnterpriseProject
          WHERE ProjectInternalID = @<fs_afe>-ProjectId
          INTO @DATA(ls_project).

        IF sy-subrc = 0.
          MODIFY ENTITIES OF zr_capexafe_001 IN LOCAL MODE
            ENTITY AFEHeader
              UPDATE FIELDS ( ProjectName ProjectStartDate )
              WITH VALUE #( (
                %tky            = <fs_afe>-%tky
                ProjectName     = ls_project-ProjectDescription
                ProjectStartDate = ls_project-PlannedStartDate
              ) ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

* ──────────────────────────────────────────────────────────────
*  DETERMINATION: Calculate Total Investment & Itemized Total
* ──────────────────────────────────────────────────────────────
  METHOD calculatetotals.
    READ ENTITIES OF zr_capexafe_001 IN LOCAL MODE
      ENTITY AFEHeader
        FIELDS ( CapitalAmount ExpenseAmount
                 CostBuildingWork CostLabEquipment CostFurniture
                 CostItInfra CostFees CostMisc )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_afe).

    LOOP AT lt_afe ASSIGNING FIELD-SYMBOL(<fs_afe>).
      DATA(lv_total_inv) = <fs_afe>-CapitalAmount + <fs_afe>-ExpenseAmount.
      DATA(lv_itemized)  = <fs_afe>-CostBuildingWork + <fs_afe>-CostLabEquipment
                         + <fs_afe>-CostFurniture + <fs_afe>-CostItInfra
                         + <fs_afe>-CostFees + <fs_afe>-CostMisc.

      MODIFY ENTITIES OF zr_capexafe_001 IN LOCAL MODE
        ENTITY AFEHeader
          UPDATE FIELDS ( TotalInvestment ItemizedTotal )
          WITH VALUE #( (
            %tky           = <fs_afe>-%tky
            TotalInvestment = lv_total_inv
            ItemizedTotal   = lv_itemized
          ) ).
    ENDLOOP.
  ENDMETHOD.

* ──────────────────────────────────────────────────────────────
*  VALIDATION: ProjectId must not be empty
* ──────────────────────────────────────────────────────────────
  METHOD checkproject.
    READ ENTITIES OF zr_capexafe_001 IN LOCAL MODE
      ENTITY AFEHeader
        FIELDS ( ProjectId )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_afe).

    LOOP AT lt_afe INTO DATA(ls_afe).
      IF ls_afe-ProjectId IS INITIAL.
        APPEND VALUE #(
          %tky = ls_afe-%tky
        ) TO failed-afeheader.

        APPEND VALUE #(
          %tky     = ls_afe-%tky
          %msg     = new_message_with_text(
                       severity = if_abap_behv_message=>severity-error
                       text     = 'Project ID is mandatory' )
          %element-ProjectId = if_abap_behv=>mk-on
        ) TO reported-afeheader.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

* ──────────────────────────────────────────────────────────────
*  VALIDATION: Exactly one budget flag must be set
* ──────────────────────────────────────────────────────────────
  METHOD checkbudgetflags.
    READ ENTITIES OF zr_capexafe_001 IN LOCAL MODE
      ENTITY AFEHeader
        FIELDS ( IsBudgeted IsUnbudgeted )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_afe).

    LOOP AT lt_afe INTO DATA(ls_afe).
      IF ls_afe-IsBudgeted IS INITIAL AND ls_afe-IsUnbudgeted IS INITIAL.
        APPEND VALUE #(
          %tky = ls_afe-%tky
        ) TO failed-afeheader.

        APPEND VALUE #(
          %tky     = ls_afe-%tky
          %msg     = new_message_with_text(
                       severity = if_abap_behv_message=>severity-error
                       text     = 'Please select either Budgeted or Unbudgeted' )
          %element-IsBudgeted = if_abap_behv=>mk-on
        ) TO reported-afeheader.
      ENDIF.

      IF ls_afe-IsBudgeted IS NOT INITIAL AND ls_afe-IsUnbudgeted IS NOT INITIAL.
        APPEND VALUE #(
          %tky = ls_afe-%tky
        ) TO failed-afeheader.

        APPEND VALUE #(
          %tky     = ls_afe-%tky
          %msg     = new_message_with_text(
                       severity = if_abap_behv_message=>severity-error
                       text     = 'Only one budget option can be selected' )
          %element-IsBudgeted = if_abap_behv=>mk-on
        ) TO reported-afeheader.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

* ──────────────────────────────────────────────────────────────
*  ACTION: Submit - Change status to 'S' (Submitted)
* ──────────────────────────────────────────────────────────────
  METHOD submit.
    MODIFY ENTITIES OF zr_capexafe_001 IN LOCAL MODE
      ENTITY AFEHeader
        UPDATE FIELDS ( OverallStatus )
        WITH VALUE #( FOR key IN keys (
          %tky          = key-%tky
          OverallStatus = 'S'
        ) ).

    READ ENTITIES OF zr_capexafe_001 IN LOCAL MODE
      ENTITY AFEHeader
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_afe).

    result = VALUE #( FOR ls_afe IN lt_afe (
      %tky   = ls_afe-%tky
      %param = ls_afe
    ) ).
  ENDMETHOD.

* ──────────────────────────────────────────────────────────────
*  ACTION: Reopen - Change status back to 'D' (Draft)
* ──────────────────────────────────────────────────────────────
  METHOD reopen.
    MODIFY ENTITIES OF zr_capexafe_001 IN LOCAL MODE
      ENTITY AFEHeader
        UPDATE FIELDS ( OverallStatus )
        WITH VALUE #( FOR key IN keys (
          %tky          = key-%tky
          OverallStatus = 'D'
        ) ).

    READ ENTITIES OF zr_capexafe_001 IN LOCAL MODE
      ENTITY AFEHeader
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_afe).

    result = VALUE #( FOR ls_afe IN lt_afe (
      %tky   = ls_afe-%tky
      %param = ls_afe
    ) ).
  ENDMETHOD.

ENDCLASS.
