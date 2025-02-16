package org.opencds.cqf.ruler.cql.dstu2;

import org.hl7.fhir.dstu3.model.ValueSet;
import org.hl7.fhir.instance.model.api.IBaseResource;

import ca.uhn.fhir.context.support.ValueSetExpansionOptions;
import ca.uhn.fhir.jpa.term.TermReadSvcDstu2;

public class PreExpandedTermReadSvcDstu2 extends TermReadSvcDstu2 {
	@Override
	public IBaseResource expandValueSet(ValueSetExpansionOptions theExpansionOptions, IBaseResource theInput) {
		ValueSet vs = (ValueSet) theInput;
		if (vs != null && vs.hasExpansion()) {
			return vs;
		}

		return super.expandValueSet(theExpansionOptions, theInput);
	}
}
