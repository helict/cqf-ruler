package org.helict.cqf.ruler.workflow.instantiate;

import org.helict.cqf.ruler.workflow.instantiate.provider.ActivityDefinitionProviderR4;
import org.helict.cqf.ruler.workflow.instantiate.provider.PlanDefinitionProviderR4;
import org.opencds.cqf.ruler.cql.CqlConfig;
import org.opencds.cqf.ruler.cr.CrConfig;
import org.opencds.cqf.ruler.external.annotations.OnR4Condition;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Conditional;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.core.annotation.Order;

@Order(-10)
@Configuration
@ConditionalOnBean(CqlConfig.class)
@ConditionalOnProperty(prefix = "hapi.fhir.cr", name = "enabled", havingValue = "true", matchIfMissing = true)
public class WorkflowInstantiateConfig extends CrConfig {

	@Bean
	public WorkflowInstantiateProperties pluginProperties() {
		return new WorkflowInstantiateProperties();
	}

	@Bean
	@Primary
	@Override
	@Conditional(OnR4Condition.class)
	public org.opencds.cqf.ruler.cr.r4.provider.PlanDefinitionApplyProvider r4PlanDefinitionApplyProvider() {
		return new PlanDefinitionProviderR4();
	}

	@Bean
	@Primary
	@Override
	@Conditional(OnR4Condition.class)
	public org.opencds.cqf.ruler.cr.r4.provider.ActivityDefinitionApplyProvider r4ActivityDefinitionApplyProvider() {
		return new ActivityDefinitionProviderR4();
	}
}
