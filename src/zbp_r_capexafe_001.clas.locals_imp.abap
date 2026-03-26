CLASS lhc_capexafe DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF status,
        draft     TYPE string VALUE 'Draft',
        submitted TYPE string VALUE 'Submitted',
      END OF status.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_auth FOR CapexAfe
      RESULT result.

    METHODS deriveProjectDetails FOR DETERMINE ON MODIFY
      IMPORTING keys FOR CapexAfe~deriveProjectDetails.

    METHODS calculateTotals FOR DETERMINE ON MODIFY
      IMPORTING keys FOR CapexAfe~calculateTotals.

    METHODS checkProject FOR VALIDATE ON SAVE
      IMPORTING keys FOR CapexAfe~checkProject.

    METHODS checkBudgetFlags FOR VALIDATE ON SAVE
      IMPORTING keys FOR CapexAfe~checkBudgetFlags.

    METHODS Submit FOR MODIFY
      IMPORTING keys FOR ACTION CapexAfe~Submit RESULT result.

    METHODS Reopen FOR MODIFY
      IMPORTING keys FOR ACTION CapexAfe~Reopen RESULT result.
ENDCLASS.

CLASS lhc_capexafe IMPLEMENTATION.

  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABUAUTH' ID 'TABLE' FIELD 'ZCAPEXAFE_001' ID 'ACTIVITY' FIELD '02'.
    IF sy-subrc = 0.
      result-%create = if_abap_behv=>auth-allowed.
      result-%update = if_abap_behv=>auth-allowed.
      result-%delete = if_abap_behv=>auth-allowed.
      result-%read = if_abap_behv=>auth-allowed.
      result-Submit = if_abap_behv=>auth-allowed.
      result-Reopen = if_abap_behv=>auth-allowed.
    ELSE.
      result-%create = if_abap_behv=>auth-denied.
      result-%update = if_abap_behv=>auth-denied.
      result-%delete = if_abap_behv=>auth-denied.
      result-%read = if_abap_behv=>auth-denied.
      result-Submit = if_abap_behv=>auth-denied.
      result-Reopen = if_abap_behv=>auth-denied.
    ENDIF.
  ENDMETHOD.

  METHOD deriveProjectDetails.
    READ ENTITIES OF ZR_CAPEXAFE_001 IN LOCAL MODE
      ENTITY CapexAfe
      FIELDS ( ProjectId ProjectName ProjectStartDate OverallStatus Currency )
      WITH CORRESPONDING #( keys )
      RESULT DATA(capex_rows).

    LOOP AT capex_rows ASSIGNING FIELD-SYMBOL(<capex_row>).
      IF <capex_row>-ProjectId IS INITIAL.
        CONTINUE.
      ENDIF.

      SELECT SINGLE
        EnterpriseProject,
        ProjectDescription,
        PlannedStartDate
        FROM I_EnterpriseProject
        WHERE EnterpriseProject = @<capex_row>-ProjectId
        INTO @DATA(project_data).

      IF sy-subrc = 0.
        <capex_row>-ProjectName = project_data-ProjectDescription.
        <capex_row>-ProjectStartDate = project_data-PlannedStartDate.
      ENDIF.

      IF <capex_row>-OverallStatus IS INITIAL.
        <capex_row>-OverallStatus = status-draft.
      ENDIF.

      IF <capex_row>-Currency IS INITIAL.
        <capex_row>-Currency = 'PKR'.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF ZR_CAPEXAFE_001 IN LOCAL MODE
      ENTITY CapexAfe
      UPDATE FIELDS ( ProjectName ProjectStartDate OverallStatus Currency )
      WITH VALUE #( FOR row IN capex_rows (
        %tky             = row-%tky
        ProjectName      = row-ProjectName
        ProjectStartDate = row-ProjectStartDate
        OverallStatus    = row-OverallStatus
        Currency         = row-Currency
      ) ).
  ENDMETHOD.

  METHOD calculateTotals.
    READ ENTITIES OF ZR_CAPEXAFE_001 IN LOCAL MODE
      ENTITY CapexAfe
      FIELDS (
        CapitalAmount ExpenseAmount
        ItemBuilding ItemProcessLab ItemFurniture ItemITInfra ItemCafeFurniture
        ItemIDConsultantFee ItemPMConsultantFee ItemAdvisorFee ItemLowValue
        ItemRiskInflation ItemInsuranceDeductions ItemMisc ItemElectric
      )
      WITH CORRESPONDING #( keys )
      RESULT DATA(capex_rows).

    LOOP AT capex_rows ASSIGNING FIELD-SYMBOL(<capex_row>).
      <capex_row>-TotalInvestment = <capex_row>-CapitalAmount + <capex_row>-ExpenseAmount.

      <capex_row>-ItemizedTotal =
          <capex_row>-ItemBuilding
        + <capex_row>-ItemProcessLab
        + <capex_row>-ItemFurniture
        + <capex_row>-ItemITInfra
        + <capex_row>-ItemCafeFurniture
        + <capex_row>-ItemIDConsultantFee
        + <capex_row>-ItemPMConsultantFee
        + <capex_row>-ItemAdvisorFee
        + <capex_row>-ItemLowValue
        + <capex_row>-ItemRiskInflation
        + <capex_row>-ItemInsuranceDeductions
        + <capex_row>-ItemMisc
        + <capex_row>-ItemElectric.
    ENDLOOP.

    MODIFY ENTITIES OF ZR_CAPEXAFE_001 IN LOCAL MODE
      ENTITY CapexAfe
      UPDATE FIELDS ( TotalInvestment ItemizedTotal )
      WITH VALUE #( FOR row IN capex_rows (
        %tky            = row-%tky
        TotalInvestment = row-TotalInvestment
        ItemizedTotal   = row-ItemizedTotal
      ) ).
  ENDMETHOD.

  METHOD checkProject.
    READ ENTITIES OF ZR_CAPEXAFE_001 IN LOCAL MODE
      ENTITY CapexAfe
      FIELDS ( ProjectId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(capex_rows).

    LOOP AT capex_rows INTO DATA(capex_row).
      IF capex_row-ProjectId IS INITIAL.
        APPEND VALUE #( %tky = capex_row-%tky ) TO failed-CapexAfe.
        APPEND VALUE #(
          %tky                = capex_row-%tky
          %msg                = new_message_with_text(
                                  severity = if_abap_behv_message=>severity-error
                                  text     = 'Project ID (AFE Number) is mandatory' )
          %element-ProjectId  = if_abap_behv=>mk-on )
          TO reported-CapexAfe.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD checkBudgetFlags.
    READ ENTITIES OF ZR_CAPEXAFE_001 IN LOCAL MODE
      ENTITY CapexAfe
      FIELDS ( IsBudgeted IsUnbudgeted )
      WITH CORRESPONDING #( keys )
      RESULT DATA(capex_rows).

    LOOP AT capex_rows INTO DATA(capex_row).
      IF capex_row-IsBudgeted = capex_row-IsUnbudgeted.
        APPEND VALUE #( %tky = capex_row-%tky ) TO failed-CapexAfe.
        APPEND VALUE #(
          %tky                = capex_row-%tky
          %msg                = new_message_with_text(
                                  severity = if_abap_behv_message=>severity-error
                                  text     = 'Select exactly one option: Budgeted or Unbudgeted' )
          %element-IsBudgeted = if_abap_behv=>mk-on
          %element-IsUnbudgeted = if_abap_behv=>mk-on )
          TO reported-CapexAfe.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD Submit.
    MODIFY ENTITIES OF ZR_CAPEXAFE_001 IN LOCAL MODE
      ENTITY CapexAfe
      UPDATE FIELDS ( OverallStatus )
      WITH VALUE #( FOR key IN keys (
        %tky          = key-%tky
        OverallStatus = status-submitted
      ) )
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF ZR_CAPEXAFE_001 IN LOCAL MODE
      ENTITY CapexAfe
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(rows).

    result = VALUE #( FOR row IN rows (
      %tky   = row-%tky
      %param = row ) ).
  ENDMETHOD.

  METHOD Reopen.
    MODIFY ENTITIES OF ZR_CAPEXAFE_001 IN LOCAL MODE
      ENTITY CapexAfe
      UPDATE FIELDS ( OverallStatus )
      WITH VALUE #( FOR key IN keys (
        %tky          = key-%tky
        OverallStatus = status-draft
      ) )
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF ZR_CAPEXAFE_001 IN LOCAL MODE
      ENTITY CapexAfe
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(rows).

    result = VALUE #( FOR row IN rows (
      %tky   = row-%tky
      %param = row ) ).
  ENDMETHOD.

ENDCLASS.
