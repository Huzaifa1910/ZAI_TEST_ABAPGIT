@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CAPEX AFE Header - Root Interface View'
define root view entity ZR_CAPEXAFE_001
  as select from zcapexafe_001
  composition [0..*] of ZI_AFE_ITEM as _Items
  association [0..1] to I_EnterpriseProject as _Project on $projection.ProjectId = _Project.ProjectInternalID
{
  key afe_uuid              as AfeUuid,
      project_id            as ProjectId,
      project_name          as ProjectName,
      project_start_date    as ProjectStartDate,

      // ── Purpose of Expenditure (Checkboxes) ──
      purp_addition          as PurpAddition,
      purp_repair            as PurpRepair,
      purp_replacement       as PurpReplacement,
      purp_expansion         as PurpExpansion,
      purp_cost_reduct       as PurpCostReduct,
      purp_new_line          as PurpNewLine,
      purp_retirement        as PurpRetirement,
      purp_other             as PurpOther,

      // ── Tax Checkboxes ──
      chk_before_tax         as ChkBeforeTax,
      chk_after_tax          as ChkAfterTax,

      // ── Budget Status ──
      is_budgeted            as IsBudgeted,
      is_unbudgeted          as IsUnbudgeted,

      // ── Requester Information ──
      requested_by           as RequestedBy,
      requested_desg         as RequestedDesg,
      requested_dept         as RequestedDept,
      signed_by              as SignedBy,

      // ── Project Dates ──
      start_date             as StartDate,
      end_date               as EndDate,

      // ── Description & Justification ──
      product_desc           as ProductDesc,
      reason_exp             as ReasonExp,
      alt_considered         as AltConsidered,

      // ── Financial Amounts ──
      @Semantics.amount.currencyCode: 'Currency'
      capital_amount         as CapitalAmount,
      @Semantics.amount.currencyCode: 'Currency'
      expense_amount         as ExpenseAmount,
      @Semantics.amount.currencyCode: 'Currency'
      total_investment       as TotalInvestment,
      @Semantics.amount.currencyCode: 'Currency'
      annual_earning         as AnnualEarning,

      exchange_rate          as ExchangeRate,
      payback_period         as PaybackPeriod,
      currency               as Currency,

      // ── Itemized Costs (Header-Level) ──
      @Semantics.amount.currencyCode: 'Currency'
      item_building          as ItemBuilding,
      @Semantics.amount.currencyCode: 'Currency'
      item_process_lab       as ItemProcessLab,
      @Semantics.amount.currencyCode: 'Currency'
      item_furniture         as ItemFurniture,
      @Semantics.amount.currencyCode: 'Currency'
      item_it_infra          as ItemItInfra,
      @Semantics.amount.currencyCode: 'Currency'
      item_cafe_furn         as ItemCafeFurn,
      @Semantics.amount.currencyCode: 'Currency'
      item_id_fee            as ItemIdFee,
      @Semantics.amount.currencyCode: 'Currency'
      item_pm_fee            as ItemPmFee,
      @Semantics.amount.currencyCode: 'Currency'
      item_advisor_fee       as ItemAdvisorFee,
      @Semantics.amount.currencyCode: 'Currency'
      item_low_value         as ItemLowValue,
      @Semantics.amount.currencyCode: 'Currency'
      item_risk_infl         as ItemRiskInfl,
      @Semantics.amount.currencyCode: 'Currency'
      item_ins_deduct        as ItemInsDeduct,
      @Semantics.amount.currencyCode: 'Currency'
      item_misc              as ItemMisc,
      @Semantics.amount.currencyCode: 'Currency'
      item_electric          as ItemElectric,
      @Semantics.amount.currencyCode: 'Currency'
      itemized_total         as ItemizedTotal,

      // ── Status ──
      overall_status         as OverallStatus,

      // ── Administrative Fields ──
      @Semantics.user.createdBy: true
      created_by             as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at             as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by        as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at        as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at  as LocalLastChangedAt,

      // ── Associations ──
      _Items,
      _Project
}
