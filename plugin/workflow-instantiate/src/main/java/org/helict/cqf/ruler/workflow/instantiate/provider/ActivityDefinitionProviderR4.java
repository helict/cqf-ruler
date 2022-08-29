package org.helict.cqf.ruler.workflow.instantiate.provider;

import ca.uhn.fhir.context.FhirContext;
import ca.uhn.fhir.rest.annotation.IdParam;
import ca.uhn.fhir.rest.annotation.Operation;
import ca.uhn.fhir.rest.annotation.OperationParam;
import ca.uhn.fhir.rest.api.server.RequestDetails;
import ca.uhn.fhir.rest.server.exceptions.InternalErrorException;
import org.helict.cqf.ruler.workflow.instantiate.WorkflowInstantiateProperties;
import org.hl7.fhir.exceptions.FHIRException;
import org.hl7.fhir.r4.model.ActivityDefinition;
import org.hl7.fhir.r4.model.IdType;
import org.hl7.fhir.r4.model.Resource;
import org.opencds.cqf.ruler.cr.r4.provider.ActivityDefinitionApplyProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

public class ActivityDefinitionProviderR4 extends ActivityDefinitionApplyProvider {

	private static final Logger logger = LoggerFactory.getLogger(ActivityDefinitionProviderR4.class);

	@Autowired
	private FhirContext fhirContext;

	@Autowired
	WorkflowInstantiateProperties pluginProperties;

	@Operation(name = "$apply", idempotent = true, type = ActivityDefinition.class)
	public Resource apply(RequestDetails theRequest,
						  @IdParam IdType theId,
						  @OperationParam(name = "patient") String patientId,
						  @OperationParam(name = "encounter") String encounterId,
						  @OperationParam(name = "practitioner") String practitionerId,
						  @OperationParam(name = "organization") String organizationId,
						  @OperationParam(name = "userType") String userType,
						  @OperationParam(name = "userLanguage") String userLanguage,
						  @OperationParam(name = "userTaskContext") String userTaskContext,
						  @OperationParam(name = "setting") String setting,
						  @OperationParam(name = "settingContext") String settingContext) throws InternalErrorException, FHIRException, ActivityDefinitionApplyProvider.ActivityDefinitionApplyException {
		// execute default apply operation
		Resource result = super.apply(theRequest, theId, patientId, encounterId, practitionerId, organizationId, userType, userLanguage, userTaskContext, setting, settingContext);

		// Customizations here...

		logger.info(fhirContext.newJsonParser().setPrettyPrint(true).encodeResourceToString(result));

		return result;
	}
}
