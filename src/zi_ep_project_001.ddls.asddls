@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Enterprise Project Value Help for AFE'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_EP_PROJECT_001
  as select from I_EnterpriseProject
{
  key EnterpriseProject    as ProjectId,
      ProjectDescription   as ProjectName,
      PlannedStartDate     as ProjectStartDate
}
