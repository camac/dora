package com.gregorbyte.designer.dora.property;

import org.eclipse.swt.widgets.Group;


public class DoraProjectPropertyPage extends DoraPropertyPage {

	public DoraProjectPropertyPage() {
		// TODO Auto-generated constructor stub
	}

	@SuppressWarnings("unused")
	@Override
	protected void createPageContents() {
		// TODO Auto-generated method stub

		System.out.println("Creating Contents");

		Group g = createGroup("DXL Filter");
		
		createBrowseText(g, "a", "b", false);
		createBrowseText(g, "c", "d", true);
		
	}

}
