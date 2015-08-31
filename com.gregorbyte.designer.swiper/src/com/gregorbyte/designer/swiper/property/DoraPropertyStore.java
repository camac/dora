package com.gregorbyte.designer.swiper.property;

import org.eclipse.core.resources.IResource;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.preference.PreferenceStore;

public class DoraPropertyStore extends PreferenceStore {

	// http://www.eclipse.org/articles/Article-Mutatis-mutandis/overlay-pages.html

	@SuppressWarnings("unused")
	private IResource resource;
	@SuppressWarnings("unused")
	private IPreferenceStore workbenchStore;
	@SuppressWarnings("unused")
	private String pageId;

	public DoraPropertyStore(IResource resource,
			IPreferenceStore workbenchStore, String pageId) {
		this.resource = resource;
		this.workbenchStore = workbenchStore;
		this.pageId = pageId;
	}

}
