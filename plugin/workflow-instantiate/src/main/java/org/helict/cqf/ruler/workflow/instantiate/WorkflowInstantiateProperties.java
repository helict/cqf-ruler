package org.helict.cqf.ruler.workflow.instantiate;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "workflow.instantiate")
public class WorkflowInstantiateProperties {

	private String message = "Foo Bar";

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}
}
