package com.gregorbyte.designer.swiper.property;

import org.eclipse.swt.widgets.Group;


public class DoraProjectPropertyPage extends DoraPropertyPage {

	public DoraProjectPropertyPage() {
		// TODO Auto-generated constructor stub
	}

	@Override
	protected void createPageContents() {

		Group g = createGroup("DXL Filter");
		
		createBrowseText(g, "a", "b", false);
		createBrowseText(g, "c", "d", true);
		
	}

}
