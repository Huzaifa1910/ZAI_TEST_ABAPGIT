@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CAPEX AFE Item - Consumption Projection'
@Metadata.allowExtensions: true
define view entity ZC_AFE_ITEM
  as projection on ZI_AFE_ITEM
{
  key ItemUuid,
      ParentUuid,

      ItemCategory,
      ItemDescription,
      ItemAmount,
      Quantity,
      UnitPrice,
      Currency,
      Notes,

      // ── Administrative ──
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      // ── Redirected Association ──
      _Header : redirected to parent ZC_CAPEXAFE_001
}
