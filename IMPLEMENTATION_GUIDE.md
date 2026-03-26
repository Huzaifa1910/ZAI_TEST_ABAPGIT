# CAPEX AFE Form - Complete RAP Implementation Guide

## Project Overview
This implementation provides a complete CAPEX AFE (Authorization for Expenditure) Form system for SAP S/4HANA Public Cloud Project Systems (PS) using Restful ABAP Programming (RAP).

## Implementation Structure

### Phase 1: Database Tables (Persistence Layer)
✅ **Header Table**: `ZCAPEXAFE_001`
- Key Fields: `CLIENT` (clnt), `AFE_UUID` (sysuuid_x16)
- Contact Info: `PROJECT_ID`, `PROJECT_NAME`, `PROJECT_START_DATE`
- Purpose: Multiple checkboxes (Addition, Repair, Replacement, Expansion, Cost Reduction, New Product, Retirement, Other)
- Budget Status: `IS_BUDGETED`, `IS_UNBUDGETED`
- Amounts: Capital, Expense, Total Investment, Annual Earning (all in CURR with currency ref)
- Itemized Costs: Building Work, Lab Equipment, Furniture, IT Infrastructure, various Fees, etc.
- Status: `OVERALL_STATUS` (Draft/Submitted)
- Admin Fields: Created/Modified by/at

✅ **Item Table**: `ZTB_AFE_ITM`
- Key Fields: `CLIENT`, `ITEM_UUID` (sysuuid_x16)
- Link: `PARENT_UUID` (sysuuid_x16) → Links to Header's AFE_UUID
- Fields: Category, Description, Amount (DEC 15,3), Quantity, Unit Price, Currency, Notes
- Admin Fields: Created/Modified by/at

✅ **Draft Table**: `ZCAPEXAFE_001_D` (Auto-created for draft support)

---

### Phase 2: CDS Data Modeling

#### Interface Layer (Base Views)
✅ **Root Header View**: `ZR_CAPEXAFE_001`
- Selects from `ZCAPEXAFE_001`
- **Composition**: `[0..*] of ZI_AFE_ITEM as _Items`
- Exposes all header fields with proper semantics
- Association to Project master data

✅ **Item View**: `ZI_AFE_ITEM`
- Selects from `ZTB_AFE_ITM`
- **Association**: `[1..1] to ZR_CAPEXAFE_001 as _Header`
- Exposes all item fields

#### Consumption Layer (Projection Views)
✅ **Header Projection**: `ZC_CAPEXAFE_001`
- Provider contract: `transactional_query`
- Includes: Via ValueHelp for Project lookup
- Composition: `_Items : redirected to composition child ZC_AFE_ITEM`
- Authorization: `#MANDATORY`

✅ **Item Projection**: `ZC_AFE_ITEM`
- Projection on `ZI_AFE_ITEM`
- Parent link: `_Header : redirected to ZC_CAPEXAFE_001`

---

### Phase 3: Behavior Definition & Pool

#### Root Behavior Definition: `ZR_CAPEXAFE_001.bdef`
- **Persistence**: Table `ZCAPEXAFE_001`, Draft Table `ZCAPEXAFE_001_D`
- **Implementation**: `ZBP_R_CAPEXAFE_001` (unique)
- **Strict Mode**: 2
- **Authorization**: `master( global )`
- **Readonly Fields**: AfeUuid, CreatedBy, CreatedAt, LastChangedBy, LastChangedAt, LocalLastChangedAt, ProjectName, ProjectStartDate, TotalInvestment, ItemizedTotal
- **Numbering**: Managed UUID
- **Operations**: Create, Update, Delete
- **Draft Actions**: Activate (optimized), Discard, Edit, Resume, Prepare
- **Validations**:
  - `checkProject`: Ensures Project ID is mandatory
  - `checkBudgetFlags`: Ensures exactly one budget flag is selected
- **Determinations**:
  - `deriveProjectDetails`: Fetches Project Description & Start Date from I_EnterpriseProject
  - `calculateTotals`: Computes TotalInvestment and ItemizedTotal
- **Custom Actions**: Submit, Reopen
- **Composition**: `_Items { create; }`

#### Item Behavior Definition: `ZI_AFE_ITEM.bdef`
- **Implementation**: `ZBP_AFE_ITEM` (unique)
- **Persistence**: Table `ZTB_AFE_ITM`, Draft Table `ZCAPEXAFE_001_D`
- **Lock**: Dependent by `_Header`
- **Authorization**: Dependent by `_Header`
- **Operations**: Create, Update, Delete

#### Root Behavior Pool: `ZBP_R_CAPEXAFE_001.clas.locals_imp`
**Key Method**: `get_global_authorizations`
```abap
METHOD get_global_authorizations.
  AUTHORITY-CHECK OBJECT 'S_TABUAUTH' ID 'TABLE' FIELD 'ZCAPEXAFE_001' ID 'ACTIVITY' FIELD '02'.
  IF sy-subrc = 0.
    result-%create = if_abap_behv=>auth-allowed.
    result-%update = if_abap_behv=>auth-allowed.
    result-%delete = if_abap_behv=>auth-allowed.
    result-%read = if_abap_behv=>auth-allowed.
    result-Submit = if_abap_behv=>auth-allowed.
    result-Reopen = if_abap_behv=>auth-allowed.
  ELSE.
    result-%create = if_abap_behv=>auth-denied.
    result-%update = if_abap_behv=>auth-denied.
    result-%delete = if_abap_behv=>auth-denied.
    result-%read = if_abap_behv=>auth-denied.
    result-Submit = if_abap_behv=>auth-denied.
    result-Reopen = if_abap_behv=>auth-denied.
  ENDIF.
ENDMETHOD.
```

**Custom Methods**:
- `deriveProjectDetails`: Auto-fetches project data from I_EnterpriseProject
- `calculateTotals`: Sums all itemized costs into ItemizedTotal
- `checkProject`: Validates ProjectId is not empty
- `checkBudgetFlags`: Validates exactly one budget option is selected
- `Submit`: Changes status to "Submitted"
- `Reopen`: Changes status back to "Draft"

---

### Phase 4: Service Exposure (OData V4)

✅ **Service Definition**: `ZUI_CAPEXAFE_001_O4.srvd`
```
define service ZUI_CAPEXAFE_001_O4 provider contracts odata_v4_ui {
  expose ZC_CAPEXAFE_001 as AFEHeader
    {
      expose _Items as AFEItems;
    };
  expose ZC_AFE_ITEM as AFEItems;
  expose ZI_EP_PROJECT_001;
}
```

✅ **Service Binding**: `ZUI_CAPEXAFE_001_O4.srvb`
- Type: `OData V4 - UI`
- Service Definition: `ZUI_CAPEXAFE_001_O4`

---

### Phase 5: Communication Scenario (External Integration)

✅ **Communication Scenario**: `ZUI_CAPEXAFE_001_CSC.sco2`
- Purpose: Enable external tools (e.g., Adobe Forms) to access AFE data
- Inbound Service: `ZUI_CAPEXAFE_001_O4`
- Authentication: Basic Authentication

---

## ⚠️ ACTIVATION & GO-LIVE CHECKLIST

### Step 1: Activate Database Tables (Circular Reference Fix)
1. **Activate Item Table**: `ZTB_AFE_ITM` (referenced by header composition)
2. **Activate Header Table**: `ZCAPEXAFE_001`
3. **Draft Table** (`ZCAPEXAFE_001_D`) created automatically

### Step 2: Activate CDS Views (Composition Dependencies)
1. **Comment out Composition** in Root View
   - Edit `ZR_CAPEXAFE_001.ddls.asddls`
   - Comment out: `//composition [0..*] of ZI_AFE_ITEM as _Items`
   - **Activate**

2. **Activate Item Interface View**
   - Activate `ZI_AFE_ITEM.ddls.asddls`

3. **Reactivate Root View with Composition**
   - Edit `ZR_CAPEXAFE_001.ddls.asddls`
   - Uncomment the composition line
   - **Re-activate**

4. **Activate Consumption Views** (in order)
   - Activate `ZC_AFE_ITEM.ddls.asddls`
   - Activate `ZC_CAPEXAFE_001.ddls.asddls`

### Step 3: Activate DCLS (Data Control Language Security)
- `ZI_AFE_ITEM.dcls.asdcls`
- `ZC_AFE_ITEM.dcls.asdcls`
- `ZR_CAPEXAFE_001.dcls.asdcls` (existing)
- `ZC_CAPEXAFE_001.dcls.asdcls` (existing)

### Step 4: Activate Behavior Entities (Critical: Authorization Code Must Be Present)
1. **Activate Item Behavior Definition**: `ZI_AFE_ITEM.bdef.asbdef`
2. **Activate Item Behavior Pool**: `ZBP_AFE_ITEM.clas` and `ZBP_C_AFE_ITEM.clas`
3. **Activate Root Behavior Definition**: `ZR_CAPEXAFE_001.bdef.asbdef`
4. **Activate Root Behavior Pool**: `ZBP_R_CAPEXAFE_001.clas`
   - ⚠️ **CRITICAL**: Ensure `get_global_authorizations` is implemented in locals_imp!

### Step 5: Activate Service Components
1. **Activate Service Definition**: `ZUI_CAPEXAFE_001_O4.srvd`
2. **Publish Service Binding**: Right-click → Publish (wait for green status)
3. **Activate Communication Scenario**: `ZUI_CAPEXAFE_001_CSC.sco2`

### Step 6: Configure Communication Arrangement (Fiori Launchpad)
1. Create **Communication User** (technical user for API)
2. Create **Communication System** (Inbound Only)
3. Create **Communication Arrangement**
   - Link Communication User + System
   - Service: `ZUI_CAPEXAFE_001_O4`

---

## 🧪 TESTING & POSTMAN VERIFICATION

### Get X-CSRF Token
```
GET /sap/opu/odata4/sap/zui_capexafe_001_o4/default/0/$metadata
Header: x-csrf-token: fetch
```
Copy the token from response header.

### Create AFE Form with Items (Deep Insert)
```
POST /sap/opu/odata4/sap/zui_capexafe_001_o4/default/0/AFEHeader
Authorization: Basic <base64(user:password)>
Content-Type: application/json
X-CSRF-Token: <token>

{
  "ProjectId": "PROJECT_001",
  "IsBudgeted": true,
  "Currency": "USD",
  "CapitalAmount": 10000,
  "ExpenseAmount": 5000,
  "_Items": [
    {
      "ItemCategory": "Building Work",
      "ItemDescription": "Foundation Construction",
      "ItemAmount": 50000,
      "Quantity": 1,
      "UnitPrice": 50000,
      "Currency": "USD"
    },
    {
      "ItemCategory": "IT Infrastructure",
      "ItemDescription": "Server Setup",
      "ItemAmount": 25000,
      "Quantity": 1,
      "UnitPrice": 25000,
      "Currency": "USD"
    }
  ]
}
```

### Expected Response
- Status: 201 Created
- Body: Created record with generated UUIDs

---

## 📁 File Structure Summary
```
src/
├── ZCAPEXAFE_001.tabl.xml           (Header Table)
├── ZTB_AFE_ITM.tabl.xml            (Item Table) ✨ NEW
├── ZCAPEXAFE_001_D.tabl.xml        (Draft Table)
├── ZR_CAPEXAFE_001.ddls.asddls     (Root Header View)
├── ZI_AFE_ITEM.ddls.asddls         (Item View) ✨ NEW
├── ZC_CAPEXAFE_001.ddls.asddls     (Header Consumption)
├── ZC_AFE_ITEM.ddls.asddls         (Item Consumption) ✨ NEW
├── ZR_CAPEXAFE_001.bdef.asbdef     (Header Behavior Definition)
├── ZI_AFE_ITEM.bdef.asbdef         (Item Behavior Definition) ✨ NEW
├── ZC_CAPEXAFE_001.bdef.asbdef     (Header Consumption Behavior)
├── ZC_AFE_ITEM.bdef.asbdef         (Item Consumption Behavior) ✨ NEW
├── ZBP_R_CAPEXAFE_001.clas         (Header Behavior Pool)
├── ZBP_R_CAPEXAFE_001.clas.locals_imp (with get_global_authorizations) ✨ UPDATED
├── ZBP_AFE_ITEM.clas               (Item Behavior Pool) ✨ NEW
├── ZBP_C_AFE_ITEM.clas             (Item Consumption Behavior Pool) ✨ NEW
├── ZI_AFE_ITEM.dcls.asdcls         (Item DCLS) ✨ NEW
├── ZC_AFE_ITEM.dcls.asdcls         (Item Consumption DCLS) ✨ NEW
├── ZUI_CAPEXAFE_001_O4.srvd.srvdsrv (Service Definition) ✨ UPDATED
├── ZUI_CAPEXAFE_001_O4.srvb        (Service Binding)
└── ZUI_CAPEXAFE_001_CSC.sco2       (Communication Scenario)
```

---

## ✨ Key Enhancements Made
1. **Master-Detail Pattern**: Separated items into dedicated table `ZTB_AFE_ITM`
2. **Proper Composition**: Root view exposes items as composition `_Items`
3. **Authorization Control**: Added `get_global_authorizations` for full access control
4. **Deep Insert Support**: Service definition exposes nested Items for deep create operations
5. **Project Integration**: Auto-fetches project master data on ProjectId entry
6. **Total Calculations**: Automatic computation of TotalInvestment and ItemizedTotal
7. **Status Management**: Custom Submit/Reopen actions for workflow
8. **Budget Validation**: Ensures exactly one budget flag is selected

---

## 🔔 Important Notes
- ⚠️ **Authorization Code is Critical**: Without `get_global_authorizations`, Postman requests will fail with authorization errors
- ⚠️ **Circular Reference Fix**: Must comment/uncomment composition during CDS activation
- ⚠️ **Draft Support**: All operations support draft versions; publish/activate required
- ⚠️ **Public Cloud**: Deployment tested for S/4HANA Public Cloud; verify SMS endpoints match your system

---

**Status**: ✅ Ready for Activation

**Next Steps**:
1. Start activation sequence from Step 1
2. Test each phase before proceeding to the next
3. Use Postman for API testing (refer to testing section)
4. Monitor activation logs for errors
