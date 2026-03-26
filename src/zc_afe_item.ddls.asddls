@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'Item CAPEX AFE Projection View'
@AccessControl.authorizationCheck: #MANDATORY
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
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,
  _Header : redirected to ZC_CAPEXAFE_001
}
