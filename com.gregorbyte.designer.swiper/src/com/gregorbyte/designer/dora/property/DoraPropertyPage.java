package com.gregorbyte.designer.dora.property;

import org.eclipse.core.runtime.IAdaptable;
import org.eclipse.ui.IWorkbenchPropertyPage;

import com.gregorbyte.designer.dora.pref.DoraPreferencePage;

public abstract class DoraPropertyPage extends DoraPreferencePage implements
		IWorkbenchPropertyPage {

	private IAdaptable element;
	
	@Override
	public IAdaptable getElement() {
		return this.element;
	}

	@Override
	public void setElement(IAdaptable element) {
		this.element = element;		
	}
	
	public boolean isPropertyPage() {
		return element != null;
	}

}
