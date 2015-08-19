package com.gregorbyte.designer.dora.pref;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;

import org.eclipse.jface.viewers.CheckStateChangedEvent;
import org.eclipse.jface.viewers.CheckboxTreeViewer;
import org.eclipse.jface.viewers.ICheckStateListener;
import org.eclipse.jface.viewers.ILabelProviderListener;
import org.eclipse.jface.viewers.ITableLabelProvider;
import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.widgets.TreeItem;
import org.eclipse.swt.widgets.Widget;

import com.gregorbyte.designer.dora.ResourceHandler;
import com.gregorbyte.designer.dora.builder.DoraUtil;
import com.gregorbyte.designer.dora.property.DoraPropertyPage;
import com.ibm.commons.iloader.node.lookups.api.StringLookup;
import com.ibm.commons.swt.SWTLayoutUtils;
import com.ibm.commons.swt.controls.LookupComboBox;
import com.ibm.commons.swt.controls.custom.CustomComposite;
import com.ibm.commons.swt.controls.custom.CustomTree;
import com.ibm.commons.swt.controls.custom.CustomTreeColumn;
import com.ibm.commons.util.StringUtil;
import com.ibm.designer.domino.ide.resources.metamodel.IMetaModelConstants;
import com.ibm.designer.domino.ide.resources.metamodel.MetaModelRegistry;
import com.ibm.designer.domino.ide.resources.metamodel.MetamodelSorter;
import com.ibm.designer.prj.resources.commons.IMetaModelCategory;

public class DoraDesignElementPreferencePage extends DoraPropertyPage {

	private static final MetaModelRegistry metaModelRegistry = MetaModelRegistry.getInstance();
	private CheckboxTreeViewer cbViewer = null;
	private HashMap<String, DoraPreferenceWidget> idToWidget = new HashMap<String, DoraPreferenceWidget>();
	private String currentPerspectiveId = "com.ibm.designer.domino.perspective";

	private class DoraPreferenceWidget extends PreferenceWidget {
		private String existingValue = null;

		public DoraPreferenceWidget(Widget widget, String paramString) {
			super(widget, paramString);
		}

		public void load(boolean paramBoolean) {
			if ((paramBoolean)
					&& (StringUtil.isNotEmpty(getPreferenceKey()))
					&& (getPreferenceKey()
							.indexOf(
									DoraDesignElementPreferencePage.this.currentPerspectiveId) == -1)) {
				return;
			}
			super.load(paramBoolean);
		}

		public void softSave() {
			this.existingValue = getWidgetStringValue();
		}

		public void softLoad() {
			if (StringUtil.isNotEmpty(this.existingValue)) {
				if ((this.widget instanceof TreeItem)) {
					((TreeItem) this.widget)
							.setChecked(isTrue(this.existingValue));
				}
			}
			this.existingValue = null;
		}

		protected String getWidgetStringValue() {
			if (StringUtil.isNotEmpty(this.existingValue)) {
				return this.existingValue;
			}
			return super.getWidgetStringValue();
		}
	}

	protected void createPageContents()
	  {
		
	    createLabel(this.pageComposite, ResourceHandler.getString("DoraDesignElementPreferencePage.Hello"));
	    
	    if (metaModelRegistry != null)
	    {
	      CustomComposite localCustomComposite = new CustomComposite(this.pageComposite, 0, "tree.parent.id");
	      localCustomComposite.setLayout(SWTLayoutUtils.createLayoutNoMarginDefaultSpacing(2));
	      GridData localGridData1 = SWTLayoutUtils.createGDFill();
	      localGridData1.verticalIndent = 10;
	      localCustomComposite.setLayoutData(localGridData1);
	      
	      createLabel(localCustomComposite, ResourceHandler.getString("DoraDesignElementPreferencePage.Perspective"));
	      
	      final LookupComboBox localLookupComboBox = new LookupComboBox(localCustomComposite, 12, "perspectives.id");
	      StringLookup localStringLookup = new StringLookup(new String[] { "com.ibm.designer.domino.perspective", "com.ibm.designer.domino.classic.perspective", "com.ibm.designer.domino.xsp.perspective" }, 
	        new String[] { ResourceHandler.getString("DoraDesignElementPreferencePage.DominoDesigner"), ResourceHandler.getString("DoraDesignElementPreferencePage.ClassicDominoDesigner"), ResourceHandler.getString("DoraDesignElementPreferencePage.XPage") });
	      
	      localLookupComboBox.setLookup(localStringLookup);
	      localLookupComboBox.setId("perspectives.id");
	      localLookupComboBox.addSelectionListener(new SelectionAdapter()
	      {
	        public void widgetSelected(SelectionEvent paramAnonymousSelectionEvent)
	        {
	          Collection<DoraPreferenceWidget> widgetCollection = DoraDesignElementPreferencePage.this.idToWidget.values();
	          Iterator<DoraPreferenceWidget> widgetIterator;
	          if (widgetCollection != null) {
	            for (widgetIterator = widgetCollection.iterator(); widgetIterator.hasNext();)
	            {
	             DoraPreferenceWidget widget = widgetIterator.next();
	              if ((StringUtil.isNotEmpty(widget.getPreferenceKey())) && (widget.getPreferenceKey().indexOf(DoraDesignElementPreferencePage.this.currentPerspectiveId) != -1)) {
	                widget.softSave();
	              }
	            }
	          }
	          DoraDesignElementPreferencePage.this.currentPerspectiveId = localLookupComboBox.getValue();
	          TreeItem[] treeItems = DoraDesignElementPreferencePage.this.cbViewer.getTree().getItems();
	          if (treeItems != null) {
	            for (TreeItem treeItem : treeItems) {
	              DoraDesignElementPreferencePage.this.recurseTree(treeItem);
	            }
	          }
	        }
	      });
	      CustomTree localCustomTree = new CustomTree(localCustomComposite, 2080, "nav.tree.id");
	      GridData localGridData2 = SWTLayoutUtils.createGDFill();
	      localGridData2.horizontalSpan = 2;
	      
	      CustomTreeColumn localCustomTreeColumn = new CustomTreeColumn(localCustomTree, 0, "nav.col.id");
	      localCustomTreeColumn.setWidthUnit(3);
	      
	      localCustomTree.setLayoutData(localGridData2);
	      
	      this.cbViewer = new CheckboxTreeViewer(localCustomTree);
	      
	      this.cbViewer.setLabelProvider(new ITableLabelProvider()
	      {
	        public void removeListener(ILabelProviderListener paramAnonymousILabelProviderListener) {}
	        
	        public boolean isLabelProperty(Object paramAnonymousObject, String paramAnonymousString)
	        {
	          return paramAnonymousObject instanceof IMetaModelCategory;
	        }
	        
	        public void dispose() {}
	        
	        public void addListener(ILabelProviderListener paramAnonymousILabelProviderListener) {}
	        
	        public String getColumnText(Object paramAnonymousObject, int paramAnonymousInt)
	        {
	          if ((paramAnonymousObject instanceof IMetaModelCategory)) {
	            return ((IMetaModelCategory)paramAnonymousObject).getName();
	          }
	          return null;
	        }
	        
	        public Image getColumnImage(Object paramAnonymousObject, int paramAnonymousInt)
	        {
	          if (((paramAnonymousObject instanceof IMetaModelCategory)) && (((IMetaModelCategory)paramAnonymousObject).getImageDescriptor() != null)) {
	            return ((IMetaModelCategory)paramAnonymousObject).getImageDescriptor().createImage();
	          }
	          return null;
	        }
	      });
	      this.cbViewer.setUseHashlookup(true);
	      
	      this.cbViewer.addCheckStateListener(new ICheckStateListener()
	      {
	        public void checkStateChanged(CheckStateChangedEvent paramAnonymousCheckStateChangedEvent)
	        {
	          Object localObject1 = paramAnonymousCheckStateChangedEvent.getElement();
	          if ((localObject1 instanceof IMetaModelCategory))
	          {
	            IMetaModelCategory localIMetaModelCategory1 = ((IMetaModelCategory)localObject1).getParent();
	            IMetaModelCategory[] arrayOfIMetaModelCategory1;
	            if (((IMetaModelCategory)localObject1).getChildren() != null)
	            {
	              arrayOfIMetaModelCategory1 = ((IMetaModelCategory)localObject1).getChildren();
	              for (IMetaModelCategory localIMetaModelCategory2 : arrayOfIMetaModelCategory1) {
	                DoraDesignElementPreferencePage.this.cbViewer.setChecked(localIMetaModelCategory2, paramAnonymousCheckStateChangedEvent.getChecked());
	              }
	            }
	            DoraDesignElementPreferencePage.this.cbViewer.setGrayChecked(localObject1, false);
	            DoraDesignElementPreferencePage.this.cbViewer.setChecked(localObject1, paramAnonymousCheckStateChangedEvent.getChecked());
	            if ((localIMetaModelCategory1 != null) && (localIMetaModelCategory1.getChildren() != null))
	            {
	              arrayOfIMetaModelCategory1 = localIMetaModelCategory1.getChildren();
	              int i = 0;
	              int k = 0;
	              for (Object localObject2 : arrayOfIMetaModelCategory1)
	              {
	                if (DoraDesignElementPreferencePage.this.cbViewer.getChecked(localObject2)) {
	                  i = 1;
	                }
	                if (!DoraDesignElementPreferencePage.this.cbViewer.getChecked(localObject2)) {
	                  k = 1;
	                }
	              }
	              if ((i != 0) && (k != 0)) {
	                DoraDesignElementPreferencePage.this.cbViewer.setGrayChecked(localIMetaModelCategory1, true);
	              }
	              if ((i != 0) && (k == 0))
	              {
	                DoraDesignElementPreferencePage.this.cbViewer.setGrayChecked(localIMetaModelCategory1, false);
	                DoraDesignElementPreferencePage.this.cbViewer.setChecked(localIMetaModelCategory1, true);
	              }
	              if ((i == 0) && (k != 0))
	              {
	                DoraDesignElementPreferencePage.this.cbViewer.setGrayChecked(localIMetaModelCategory1, false);
	                DoraDesignElementPreferencePage.this.cbViewer.setChecked(localIMetaModelCategory1, false);
	              }
	            }
	          }
	        }
	      });
	      this.cbViewer.setContentProvider(new ITreeContentProvider()
	      {
	        public Object[] getChildren(Object paramAnonymousObject)
	        {
	          if ((paramAnonymousObject instanceof IMetaModelCategory)) {
	            return ((IMetaModelCategory)paramAnonymousObject).getChildren();
	          }
	          return null;
	        }
	        
	        public Object getParent(Object paramAnonymousObject)
	        {
	          return null;
	        }
	        
	        public boolean hasChildren(Object paramAnonymousObject)
	        {
	          if ((paramAnonymousObject instanceof IMetaModelCategory)) {
	            return ((IMetaModelCategory)paramAnonymousObject).getChildren() != null;
	          }
	          return false;
	        }
	        
	        public Object[] getElements(Object paramAnonymousObject)
	        {
	          if ((paramAnonymousObject instanceof IMetaModelCategory[]))
	          {
	            IMetaModelCategory[] arrayOfIMetaModelCategory1 = (IMetaModelCategory[])paramAnonymousObject;
	            ArrayList<IMetaModelCategory> localArrayList = new ArrayList<IMetaModelCategory>();
	            for (IMetaModelCategory localIMetaModelCategory : arrayOfIMetaModelCategory1) {
	              if ((!StringUtil.equals("metamodel.webcontent", localIMetaModelCategory.getID())) && (!StringUtil.equals("com.ibm.designer.domino.ide.metamodel.local", localIMetaModelCategory.getID()))) {
	                localArrayList.add(localIMetaModelCategory);
	              }
	            }
	            return localArrayList.toArray(new IMetaModelCategory[0]);
	          }
	          return new String[] { "" };
	        }
	        
	        public void dispose() {}
	        
	        public void inputChanged(Viewer paramAnonymousViewer, Object paramAnonymousObject1, Object paramAnonymousObject2) {}
	      });
	      // TODO this.cbViewer.setComparator(new DesignerNavResourceComparator(1));
	      this.cbViewer.setInput(getInput());
	      this.cbViewer.expandAll();
	      this.cbViewer.collapseAll();
	      localLookupComboBox.setValue(this.currentPerspectiveId);
	      TreeItem[] arrayOfTreeItem1 = localCustomTree.getItems();
	      if (arrayOfTreeItem1 != null)
	      {
	        for (TreeItem localTreeItem : arrayOfTreeItem1) {
	          recurseTree(localTreeItem);
	        }
	        setGreyed(arrayOfTreeItem1);
	      }
	    }
	  }

	private IMetaModelCategory[] getInput() {


		List<IMetaModelCategory> list = new ArrayList<IMetaModelCategory>();
		
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
		things.add(IMetaModelConstants.FORMS);

		things.add(IMetaModelConstants.SCRIPTLIB);
		
		things.add(IMetaModelConstants.ABOUTDOC);
		things.add(IMetaModelConstants.DBPROPS);
		things.add(IMetaModelConstants.ICONNOTE);
		things.add(IMetaModelConstants.ACTIONS);
		things.add(IMetaModelConstants.USINGDOC);
		
		for (Object o : metaModelRegistry.getFlatMetaModelCategories()) {
			
			if (o instanceof IMetaModelCategory) {
				
				IMetaModelCategory m = (IMetaModelCategory)o;

				if (things.contains(m.getID())) {
					list.add(m);					
				}
								
			}
			
		}
		
		MetamodelSorter.sort(list);
		
		IMetaModelCategory[] arr = list.toArray(new IMetaModelCategory[list.size()]);
		
		return arr;
		
	}
	
	private void recurseTree(TreeItem paramTreeItem) {

		if (paramTreeItem != null) {
			
			Object data = paramTreeItem.getData();
			String metaModelId = "";
			
			if ((data instanceof IMetaModelCategory)) {
				metaModelId = ((IMetaModelCategory) data).getID();
			}
			
			DoraPreferenceWidget widget = null;
						
			metaModelId = DoraUtil.getPreferenceKey(metaModelId);
			
			widget = (DoraPreferenceWidget) this.idToWidget
					.get(metaModelId);
			
			if (widget == null) {
				
				widget = new DoraPreferenceWidget(
						paramTreeItem, metaModelId);
				widget.load(false);
				widget.setNotify(true, 96);
				savePreferenceWidget(widget);
				this.idToWidget.put(metaModelId, widget);
				
			} else {
				widget.softLoad();
			}
			
			TreeItem[] arrayOfTreeItem1 = paramTreeItem.getItems();
			if (arrayOfTreeItem1 != null) {
				for (TreeItem localTreeItem : arrayOfTreeItem1) {
					recurseTree(localTreeItem);
				}
			}
		}
	}

	private boolean setGreyed(TreeItem[] treeItems) {

		boolean bool1 = false;

		if (treeItems != null) {

			boolean bool2 = false;
			
			int i = 1;
			
			for (TreeItem treeItem : treeItems) {
			
				TreeItem[] childTreeItems = treeItem.getItems();
				
				if ((childTreeItems != null) && (childTreeItems.length > 0)
						&& (setGreyed(childTreeItems))) {
					treeItem.setGrayed(true);
					bool1 = true;
				}
				boolean bool3 = treeItem.getChecked();
				if (bool3 != bool2) {
					if (i != 0) {
						bool2 = bool3;
						i = 0;
					} else {
						bool1 = true;
					}
				} else {
					i = 0;
				}
			}
		}
		return bool1;
	}

}
