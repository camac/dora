package com.gregorbyte.designer.dora.pref;

import org.eclipse.jface.preference.FieldEditorPreferencePage;
import org.eclipse.jface.preference.FileFieldEditor;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;

import com.gregorbyte.designer.dora.Activator;

public class SwiperPreferencePage extends FieldEditorPreferencePage implements
		IWorkbenchPreferencePage {

	public SwiperPreferencePage() {
		super(FieldEditorPreferencePage.GRID);
	}

	@Override
	public void init(IWorkbench workbench) {

		IPreferenceStore store = Activator.getDefault().getPreferenceStore();
		setPreferenceStore(store);
		setDescription("Swiper Preferences");

	}

	@Override
	protected void createFieldEditors() {

		FileFieldEditor defaultFilter = new FileFieldEditor("defaultFilter",
				"Default XSLT Filter", getFieldEditorParent());		
		addField(defaultFilter);

	}
}
