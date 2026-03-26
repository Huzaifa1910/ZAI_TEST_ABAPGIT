@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CAPEX AFE Item - Interface View'
define view entity ZI_AFE_ITEM
  as select from ztb_afe_itm
  association to parent ZR_CAPEXAFE_001 as _Header on $projection.ParentUuid = _Header.AfeUuid
{
  key item_uuid              as ItemUuid,
      parent_uuid            as ParentUuid,

      item_category          as ItemCategory,
      item_description       as ItemDescription,

      @Semantics.amount.currencyCode: 'Currency'
      item_amount            as ItemAmount,
      quantity               as Quantity,
      @Semantics.amount.currencyCode: 'Currency'
      unit_price             as UnitPrice,
      currency               as Currency,
      notes                  as Notes,

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
      _Header
}
