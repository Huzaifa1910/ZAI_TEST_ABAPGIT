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
      PurpAddition,
      PurpRepair,
      PurpReplacement,
      PurpExpansion,
      PurpCostReduct,
      PurpNewLine,
      PurpRetirement,
      PurpOther,

      // ── Tax Checkboxes ──
      ChkBeforeTax,
      ChkAfterTax,

      // ── Budget Status ──
      IsBudgeted,
      IsUnbudgeted,

      // ── Requester Information ──
      RequestedBy,
      RequestedDesg,
      RequestedDept,
      SignedBy,

      // ── Project Dates ──
      StartDate,
      EndDate,

      // ── Description & Justification ──
      ProductDesc,
      ReasonExp,
      AltConsidered,

      // ── Financial Amounts ──
      CapitalAmount,
      ExpenseAmount,
      TotalInvestment,
      AnnualEarning,
      ExchangeRate,
      PaybackPeriod,
      Currency,

      // ── Itemized Costs ──
      ItemBuilding,
      ItemProcessLab,
      ItemFurniture,
      ItemItInfra,
      ItemCafeFurn,
      ItemIdFee,
      ItemPmFee,
      ItemAdvisorFee,
      ItemLowValue,
      ItemRiskInfl,
      ItemInsDeduct,
      ItemMisc,
      ItemElectric,
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
