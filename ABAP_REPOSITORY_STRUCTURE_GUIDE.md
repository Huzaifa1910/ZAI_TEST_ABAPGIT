# SAP ABAP Repository Structure Guide (Template)

This document explains the standard file structure for an ABAP RAP project managed with abapGit.
It is generic and does not depend on specific object names.

## Repository Layout
```
<repo-root>/
  README.md
  .abapgit . -> optional local config
  src/
    <object>.tabl.xml
    <object>.tabl.baseinfo
    <object>.ddls.asddls
    <object>.ddls.xml
    <object>.ddls.baseinfo
    <object>.bdef.asbdef
    <object>.bdef.xml
    <object>.dcls.asdcls
    <object>.dcls.xml
    <object>.clas.abap
    <object>.clas.xml
    <object>.srvd.srvdsrv
    <object>.srvb
    <object>.sco2
```

## Object Types and Naming Patterns
- `Z*` prefix in Public Cloud / customer namespace.
- `ZR_*`: Interface (root) CDS view entity.
- `ZI_*`: Interface-only CDS view entity.
- `ZC_*`: Consumption projection views.
- `ZBP_*`: Behavior pool classes (R and C for root/consumption).
- `ZTB_*`: Transparent database tables.
- `ZUI_*`: Service definitions & bindings.

## Table Objects
- `.tabl.xml`: table definition with columns.
- `.tabl.baseinfo`: base metadata of table.
- Usually `ZTB_<entity>` for persistence.

## CDS Interface Objects
- `.ddls.asddls`: source of view entity.
- `.ddls.xml`: object metadata wrapper.
- `.ddls.baseinfo`: metadata with labels.
- Defines `root view entity` or `view entity`
- Include fields and associations.

## CDS Consumption Objects
- Same extension as interface (+ projection name).
- Add `provider contract transactional_query` on root consumer.
- Redirect associations (`_Items : redirected to composition child`).

## Behavior Definitions
- `.bdef.asbdef`: source implementation with behavior definition.
  - include `managed implementation in class ...` + `define behavior for ...`
  - actions, validations, determinations, draft actions
- `.bdef.xml`: metadata wrapper.

## Data Control Language
- `.dcls.asdcls`: source role definition mappings.
- `.dcls.xml`: metadata wrapper.
- Use `define role <name> ...` not behavior.

## Class Objects
- `.clas.abap`: ABAP class implementation (behavior handler methods).
- `.clas.xml`: metadata wrapper.

## Service & Communication
- `.srvd.srvdsrv`: service definition (expose entities).
- `.srvb`: OData V4 binding definition.
- `.sco2`: communication scenario metadata for Cloud.

## Mandatory Activation Sequence (Generic)
1. Activate table(s) first (`ZTB-*` then draft table if present).
2. For root view composition: comment composition, activate root, activate child, then re-enable composition and activate root again.
3. Activate consumption views.
4. Activate DCLS object roles.
5. Activate BDEFs, then pool classes.
6. Activate `SRVD`, publish `SRVB`, activate `SCO2`.

## Required Companion Files
- Always include `.xml` metadata for ABAP objects.
- For table and CDS objects, include `.baseinfo` if required by abapGit.
- For ABAP classes/behavior, include `.clas.xml`.

## Notes
- This structure is reusable with any entity names (e.g., replace `CAPEXAFE` with target solution name).
- Keep names consistent across all layers (tables -> interface -> consumption -> behavior -> service).
- For each object usually a pair `.as*` and `.xml` files is required.

## Quick Example Placeholder
- `ZTB_MYAPP_001` --> table
- `ZR_MYAPP_001` --> root view entity
- `ZI_MYAPP_001` --> child view entity
- `ZC_MYAPP_001` --> root projection
- `ZC_MYAPP_ITEM` --> child projection
- `ZBP_R_MYAPP_001` / `ZBP_C_MYAPP_001` --> behavior pools
- `ZUI_MYAPP_001_O4` + `ZUI_MYAPP_001_CSC` --> service
