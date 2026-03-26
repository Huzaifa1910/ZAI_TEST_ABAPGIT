@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CAPEX AFE Header - Consumption Projection'
@Metadata.allowExtensions: true
define root view entity ZC_CAPEXAFE_001
  provider contract transactional_query
  as projection on ZR_CAPEXAFE_001
{
  key AfeUuid,
      ProjectId,
      ProjectName,
      ProjectStartDate,

      // ── Purpose of Expenditure (Checkboxes) ──
      PurposeAddition,
      PurposeRepair,
      PurposeReplacement,
      PurposeExpansion,
      PurposeCostReduction,
      PurposeNewProduct,
      PurposeRetirement,
      PurposeOther,
      PurposeOtherDesc,

      // ── Budget Status ──
      IsBudgeted,
      IsUnbudgeted,

      // ── Financial Amounts ──
      CapitalAmount,
      ExpenseAmount,
      TotalInvestment,
      AnnualEarning,
      ExchangeRate,
      PaybackPeriod,
      Currency,

      // ── Itemized Costs ──
      CostBuildingWork,
      CostLabEquipment,
      CostFurniture,
      CostItInfra,
      CostFees,
      CostMisc,
      ItemizedTotal,

      // ── Status ──
      OverallStatus,

      // ── Administrative ──
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      // ── Redirected Associations ──
      _Items : redirected to composition child ZC_AFE_ITEM,
      _Project
}
