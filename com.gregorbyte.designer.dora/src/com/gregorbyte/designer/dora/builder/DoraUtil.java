package com.gregorbyte.designer.dora.builder;

import java.util.HashSet;
import java.util.Set;

import org.eclipse.core.resources.IResource;

import com.gregorbyte.designer.dora.pref.DoraPreferenceManager;
import com.ibm.designer.domino.ide.resources.DominoResourcesPlugin;
import com.ibm.designer.domino.ide.resources.jni.NotesDesignElement;
import com.ibm.designer.domino.ide.resources.metamodel.IMetaModelConstants;
import com.ibm.designer.domino.team.util.SyncUtil;
import com.ibm.designer.prj.resources.commons.IMetaModelDescriptor;

public class DoraUtil {

	public static Set<String> getCanFilterIds() {

		HashSet<String> things = new HashSet<String>();

		things.add(IMetaModelConstants.AGENTS);
		things.add(IMetaModelConstants.SHARED_ELEMENTS);
		things.add(IMetaModelConstants.DATACONNS);
		things.add(IMetaModelConstants.FOLDERS);
		things.add(IMetaModelConstants.FIELDS);
		things.add(IMetaModelConstants.FRAMESET);
		things.add(IMetaModelConstants.JAVAJARS);
		things.add(IMetaModelConstants.DBSCRIPT);
		// Metadata
		things.add(IMetaModelConstants.XSPPAGES);
		things.add(IMetaModelConstants.XSPCCS);
		things.add(IMetaModelConstants.NAVIGATORS);
		things.add(IMetaModelConstants.OUTLINES);
		things.add(IMetaModelConstants.PAGES);
		things.add(IMetaModelConstants.SUBFORMS);
		things.add(IMetaModelConstants.VIEWS);

		things.add(IMetaModelConstants.ABOUTDOC);
		things.add(IMetaModelConstants.DBPROPS);
		things.add(IMetaModelConstants.ICONNOTE);
		things.add(IMetaModelConstants.ACTIONS);
		things.add(IMetaModelConstants.USINGDOC);

		return things;
	}

	public static String getPreferenceKey(IMetaModelDescriptor mmd) {
		return "dora.filter." + mmd.getID();
	}
	
	public static String getPreferenceKey(String id) {
		return "dora.filter." + id;
	}
	
	public static boolean isSetToFilter(IMetaModelDescriptor mmd) {
		
		String prefKey = getPreferenceKey(mmd);
		
		System.out.println("Checking preference for " + mmd.getName());
		
		boolean isset = DoraPreferenceManager.getInstance().getBooleanValue(prefKey, false);
		
		if (isset) {
			System.out.println(prefKey + " is currently set to True");
		} else {
			System.out.println(prefKey + " is currently set to False");
		}
		
		return isset;
	}
	
	public static boolean shouldFilter(IResource resource) {

		NotesDesignElement element = DominoResourcesPlugin
				.getNotesDesignElement(resource);

		if (element == null) {
			return false;
		}

		System.out.println("Design Element Name: " + element.getName());

		boolean hasMetadata = SyncUtil.hasMetadataFile(element);

		if (hasMetadata) {
			System.out.println("Has Metadata");
		} else {
			System.out.println("Does not have metadata");
		}

		IMetaModelDescriptor mmd = element.getMetaModel();

		if (mmd == null) {
			return false;
		}

		String id = mmd.getID();

		if (getCanFilterIds().contains(id)) {
			System.out.println("Yes we can filter" + mmd.getName());
			
			return isSetToFilter(mmd);			

		} else {
			System.out.println("No we don't filter" + mmd.getName());
			return false;

		}

	}

}
