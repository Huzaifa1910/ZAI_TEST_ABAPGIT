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
      purpose_addition       as PurposeAddition,
      purpose_repair         as PurposeRepair,
      purpose_replacement    as PurposeReplacement,
      purpose_expansion      as PurposeExpansion,
      purpose_cost_reduction as PurposeCostReduction,
      purpose_new_product    as PurposeNewProduct,
      purpose_retirement     as PurposeRetirement,
      purpose_other          as PurposeOther,
      purpose_other_desc     as PurposeOtherDesc,

      // ── Budget Status ──
      is_budgeted            as IsBudgeted,
      is_unbudgeted          as IsUnbudgeted,

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

      // ── Itemized Costs (Header-Level Summaries) ──
      @Semantics.amount.currencyCode: 'Currency'
      cost_building_work     as CostBuildingWork,
      @Semantics.amount.currencyCode: 'Currency'
      cost_lab_equipment     as CostLabEquipment,
      @Semantics.amount.currencyCode: 'Currency'
      cost_furniture         as CostFurniture,
      @Semantics.amount.currencyCode: 'Currency'
      cost_it_infra          as CostItInfra,
      @Semantics.amount.currencyCode: 'Currency'
      cost_fees              as CostFees,
      @Semantics.amount.currencyCode: 'Currency'
      cost_misc              as CostMisc,
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
