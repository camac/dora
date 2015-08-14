package com.gregorbyte.designer.dora.pref;

import java.util.Map;
import java.util.Map.Entry;
import java.util.TreeMap;

import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Group;

import com.ibm.commons.swt.SWTLayoutUtils;
import com.ibm.designer.domino.preferences.DominoPreferencePage;

public class DoraMainPreferencePage extends DominoPreferencePage {

	@Override
	protected void createPageContents() {

		Group group = createGroup("Dora");
		addField("dora.prefs.hello", "Something ", 0, group);
		
		createChooseFileTypes();
		createChooseMetadataTypes();
		
	}

	protected void createXslFilePrefs() {

		Group group = createGroup("Xsl Filter");
		
		addField("dora.prefs.xsp.default", "Use Default Xsl Filter", BOOLEAN_PREF, group);
		
		@SuppressWarnings("unused")
		GridLayout g = SWTLayoutUtils.createLayoutDefaultSpacing(3);
		
				
		
		
		
	}
	
	private Map<String, String> getFileExtMap() {
		
		Map<String, String> map = new TreeMap<String, String>();
		
		map.put("aa", "Simple Action Agent");
		map.put("column", "Shared Column");
		map.put("dcr", "Data Connection Resource");
		map.put("fa", "Formula Agent");
		map.put("field", "Shared Field");
		map.put("folder", "Folder");
		map.put("form", "Form");
		map.put("frameset", "Frameset");
		map.put("ija", "Imported Java Agent");
		map.put("ja", "Java Agent");
		map.put("javalib", "Script Library - Java");
		map.put("lsa", "Script Library - Lotusscript");
		map.put("lsdb", "Database Script");
		map.put("navigator", "Navigator");
		map.put("outline", "Outline");
		map.put("page", "Page");
		map.put("subform", "Subform");
		map.put("view", "View");
		
		map.put("about", "About Document");
		map.put("dbprops", "Database Properties");
		map.put("iconnote", "Icon Note");
		map.put("sharedactions", "Shared Actions");
		map.put("using", "Using Document");
		
		return map;
		
	}
	
	@SuppressWarnings("unused")
	private Map<String, String> getMetadataMap() {
				
		Map<String, String> map = new TreeMap<String, String>();
		
		map.put("metadata.xpages", "XPages");
		map.put("metadata.cc", "Custom Controls");
		map.put("metadata.files", "Files");
		map.put("metadata.images", "Images");
		map.put("metadata.css", "Stylesheets");
		map.put("metadata.theme", "Themes");
		map.put("metadata.java", "Java");		
		
		return map;		
		
	}

	protected void createChooseMetadataTypes() {

		Group group = createGroup("Apply Filter to these Metadata files");

		for (Entry<String, String> entry : getFileExtMap().entrySet()) {
			
			String prefkey = "dora.prefs.filetype." + entry.getKey();
			String description = entry.getValue() + " *.metadata";
			addField(prefkey, description, 0, group);
			
			
		}	
		
	}

	
	protected void createChooseFileTypes() {

		Group group = createGroup("Apply Filter to these Design Elements");

		for (Entry<String, String> entry : getFileExtMap().entrySet()) {
			
			String prefkey = "dora.prefs.filetype." + entry.getKey();
			String description = entry.getValue() + " *." + entry.getKey();
			addField(prefkey, description, 0, group);
			
			
		}	
		
	}
	
}
