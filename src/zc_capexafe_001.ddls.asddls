@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'CAPEX AFE Projection View'
@ObjectModel.sapObjectNodeType.name: 'Zcapexafe_001'
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_CAPEXAFE_001
  provider contract transactional_query
  as projection on ZR_CAPEXAFE_001
  association [0..1] to ZI_EP_PROJECT_001 as _ProjectValueHelp
    on $projection.ProjectId = _ProjectValueHelp.ProjectId
{
  key AfeUuid,

  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_EP_PROJECT_001', element: 'ProjectId' }}]
  ProjectId,
  ProjectName,
  ProjectStartDate,

  PurposeAddition,
  PurposeRepair,
  PurposeReplacement,
  PurposeExpansion,
  PurposeCostReduction,
  PurposeNewProduct,
  PurposeRetirement,
  PurposeOther,

  IsBudgeted,
  IsUnbudgeted,
  CapitalAmount,
  ExpenseAmount,
  TotalInvestment,
  AnnualEarning,
  Currency,
  ExchangeRate,
  PaybackPeriod,
  CheckBeforeTax,
  CheckAfterTax,

  RequestedBy,
  RequestedDesignation,
  RequestedDepartment,
  SignedBy,
  StartDate,
  EndDate,
  ProductDescription,
  ReasonForExpenditure,
  AlternativesConsidered,

  ItemBuilding,
  ItemProcessLab,
  ItemFurniture,
  ItemITInfra,
  ItemCafeFurniture,
  ItemIDConsultantFee,
  ItemPMConsultantFee,
  ItemAdvisorFee,
  ItemLowValue,
  ItemRiskInflation,
  ItemInsuranceDeductions,
  ItemMisc,
  ItemElectric,
  ItemizedTotal,

  OverallStatus,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,

  _ProjectValueHelp,
  _Items : redirected to composition child ZC_AFE_ITEM
}
