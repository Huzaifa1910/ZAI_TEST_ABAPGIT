@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'Zcapexafe_001'
@EndUserText.label: 'Root CAPEX AFE View Entity'
define root view entity ZR_CAPEXAFE_001
  as select from ZCAPEXAFE_001
  composition [0..*] of ZI_AFE_ITEM as _Items
{
  key afe_uuid             as AfeUuid,
      project_id           as ProjectId,
      project_name         as ProjectName,
      project_start_date   as ProjectStartDate,

      purp_addition        as PurposeAddition,
      purp_repair          as PurposeRepair,
      purp_replacement     as PurposeReplacement,
      purp_expansion       as PurposeExpansion,
      purp_cost_reduct     as PurposeCostReduction,
      purp_new_line        as PurposeNewProduct,
      purp_retirement      as PurposeRetirement,
      purp_other           as PurposeOther,

      is_budgeted          as IsBudgeted,
      is_unbudgeted        as IsUnbudgeted,

      @Semantics.amount.currencyCode: 'Currency'
      capital_amount       as CapitalAmount,
      @Semantics.amount.currencyCode: 'Currency'
      expense_amount       as ExpenseAmount,
      @Semantics.amount.currencyCode: 'Currency'
      total_investment     as TotalInvestment,
      @Semantics.amount.currencyCode: 'Currency'
      annual_earning       as AnnualEarning,
      currency             as Currency,
      exchange_rate        as ExchangeRate,
      payback_period       as PaybackPeriod,
      chk_before_tax       as CheckBeforeTax,
      chk_after_tax        as CheckAfterTax,

      requested_by         as RequestedBy,
      requested_desg       as RequestedDesignation,
      requested_dept       as RequestedDepartment,
      signed_by            as SignedBy,
      start_date           as StartDate,
      end_date             as EndDate,
      product_desc         as ProductDescription,
      reason_exp           as ReasonForExpenditure,
      alt_considered       as AlternativesConsidered,

      @Semantics.amount.currencyCode: 'Currency'
      item_building        as ItemBuilding,
      @Semantics.amount.currencyCode: 'Currency'
      item_process_lab     as ItemProcessLab,
      @Semantics.amount.currencyCode: 'Currency'
      item_furniture       as ItemFurniture,
      @Semantics.amount.currencyCode: 'Currency'
      item_it_infra        as ItemITInfra,
      @Semantics.amount.currencyCode: 'Currency'
      item_cafe_furn       as ItemCafeFurniture,
      @Semantics.amount.currencyCode: 'Currency'
      item_id_fee          as ItemIDConsultantFee,
      @Semantics.amount.currencyCode: 'Currency'
      item_pm_fee          as ItemPMConsultantFee,
      @Semantics.amount.currencyCode: 'Currency'
      item_advisor_fee     as ItemAdvisorFee,
      @Semantics.amount.currencyCode: 'Currency'
      item_low_value       as ItemLowValue,
      @Semantics.amount.currencyCode: 'Currency'
      item_risk_infl       as ItemRiskInflation,
      @Semantics.amount.currencyCode: 'Currency'
      item_ins_deduct      as ItemInsuranceDeductions,
      @Semantics.amount.currencyCode: 'Currency'
      item_misc            as ItemMisc,
      @Semantics.amount.currencyCode: 'Currency'
      item_electric        as ItemElectric,
      @Semantics.amount.currencyCode: 'Currency'
      itemized_total       as ItemizedTotal,

      overall_status       as OverallStatus,
      @Semantics.user.createdBy: true
      created_by           as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at           as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by      as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at      as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _Items
}
