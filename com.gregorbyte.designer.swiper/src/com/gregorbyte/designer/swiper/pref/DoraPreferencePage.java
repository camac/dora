package com.gregorbyte.designer.swiper.pref;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.eclipse.jface.preference.PreferencePage;
import org.eclipse.swt.custom.ScrolledComposite;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.DirectoryDialog;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;

import com.gregorbyte.designer.swiper.Activator;
import com.ibm.commons.iloader.node.validators.IntegerValidator;
import com.ibm.commons.swt.SWTACCUtils;
import com.ibm.commons.swt.SWTLayoutUtils;
import com.ibm.commons.swt.controls.custom.CustomButton;
import com.ibm.commons.swt.controls.custom.CustomCheckBox;
import com.ibm.commons.swt.controls.custom.CustomCombo;
import com.ibm.commons.swt.controls.custom.CustomComposite;
import com.ibm.commons.swt.controls.custom.CustomLabel;
import com.ibm.commons.swt.controls.custom.CustomTable;
import com.ibm.commons.swt.controls.custom.CustomText;
import com.ibm.commons.swt.data.editors.api.CompositeEditor;
import com.ibm.commons.util.StringUtil;

public abstract class DoraPreferencePage extends PreferencePage implements
		IWorkbenchPreferencePage {

	protected Composite pageComposite;
	protected List<PreferenceWidget> preferenceWidgets = new ArrayList<PreferenceWidget>();
	public static final int BOOLEAN_PREF = 0;
	public static final int STRING_PREF = 1;
	public static final int INTEGER_PREF = 2;
	public static final int COMBO_PREF = 3;

	protected DoraPreferencePage() {
		setPreferenceStore(Activator.getDefault().getPreferenceStore());
	}

	protected abstract void createPageContents();

	public void init(IWorkbench paramIWorkbench) {
	}

	protected void setSize(Composite paramComposite) {
		if (paramComposite != null) {
			Point localPoint = paramComposite.computeSize(-1, -1);
			paramComposite.setSize(localPoint);
			if ((paramComposite.getParent() instanceof ScrolledComposite)) {
				ScrolledComposite localScrolledComposite = (ScrolledComposite) paramComposite
						.getParent();
				localScrolledComposite.setMinSize(localPoint);
				localScrolledComposite.setExpandHorizontal(true);
				localScrolledComposite.setExpandVertical(true);
			}
		}
	}

	protected final Control createContents(Composite paramComposite) {
		ScrolledComposite localScrolledComposite = new ScrolledComposite(
				paramComposite, 768);
		localScrolledComposite.setLayoutData(SWTLayoutUtils.createGDFill());

		CustomComposite localCustomComposite = new CustomComposite(
				localScrolledComposite, 0,
				"DominoPreferencePageCustomComposite.id");
		localCustomComposite.setLayout(SWTLayoutUtils
				.createLayoutDefaultSpacing(1));
		localCustomComposite.setLayoutData(SWTLayoutUtils.createGDFill());

		localScrolledComposite.setContent(localCustomComposite);

		this.pageComposite = localCustomComposite;

		createPageContents();

		initialize();

		setSize(localCustomComposite);
		return localScrolledComposite;
	}

	protected void initialize() {
		Iterator<PreferenceWidget> localIterator = this.preferenceWidgets
				.iterator();
		while (localIterator.hasNext()) {
			PreferenceWidget widget = localIterator.next();
			widget.load(false);
		}
		updateComposites();
	}

	protected void updateComposites() {
	}

	protected Group createGroup(String paramString, int paramInt) {
		Group localGroup = new Group(this.pageComposite, 0);
		localGroup.setText(paramString);

		localGroup.setLayoutData(SWTLayoutUtils.createGDFillHorizontal());
		GridLayout localGridLayout = SWTLayoutUtils
				.createLayoutDefaultSpacing(paramInt);
		localGroup.setLayout(localGridLayout);

		return localGroup;
	}

	protected Group createGroup(String paramString) {
		return createGroup(paramString, 1);
	}

	protected void savePreferenceWidget(PreferenceWidget paramPreferenceWidget) {
		this.preferenceWidgets.add(paramPreferenceWidget);
	}

	protected PreferenceWidget addField(String paramString1,
			String paramString2, int paramInt) {
		return addField(paramString1, paramString2, paramInt,
				this.pageComposite);
	}

	protected PreferenceWidget addField(String paramString1,
			String paramString2, int paramInt, Composite paramComposite) {
		PreferenceWidget localPreferenceWidget = null;
		Object localObject1;
		if (paramInt == 0) {
			localObject1 = new CustomCheckBox(paramComposite, 32,
					"DominoPreferencePageCustomCheckbox_" + paramString2
							+ ".id");
			((CustomCheckBox) localObject1).setLayoutData(SWTLayoutUtils
					.createGDFillHorizontal());
			((CustomCheckBox) localObject1).setText(paramString2);
			localPreferenceWidget = new PreferenceWidget((Widget) localObject1,
					paramString1);
		} else {
			Object localObject2;
			if (paramInt == 1) {
				localObject1 = createLabel(paramComposite, paramString2);

				localObject2 = new CustomText(paramComposite, 2048,
						"DominoPreferencePageCustomText.id");
				((CustomText) localObject2).setLayoutData(SWTLayoutUtils
						.createGDFillHorizontal());
				localPreferenceWidget = new PreferenceWidget(
						(Widget) localObject2, paramString1,
						(Label) localObject1);
			} else if (paramInt == 2) {
				localPreferenceWidget = addField(paramString1, paramString2, 1,
						paramComposite);

				localObject1 = (CustomText) localPreferenceWidget.getWidget();
				((CustomText) localObject1)
						.setValidator(IntegerValidator.positiveInstance);
			} else if (paramInt == 3) {
				localObject1 = createLabel(paramComposite, paramString2);

				localObject2 = new CustomCombo(paramComposite, 8,
						"DominoPreferencePageCustomCombo.id");
				((CustomCombo) localObject2).setLayoutData(SWTLayoutUtils
						.createGDFillHorizontal());
				localPreferenceWidget = new PreferenceWidget(
						(Widget) localObject2, paramString1,
						(Label) localObject1);
			}
		}
		if (localPreferenceWidget != null) {
			this.preferenceWidgets.add(localPreferenceWidget);
		}
		return localPreferenceWidget;
	}

	protected PreferenceWidget addField(String paramString1,
			String paramString2, int paramInt1, Composite paramComposite,
			int paramInt2) {
		PreferenceWidget localPreferenceWidget = null;
		GridData localGridData = new GridData(4, 1, true, false, paramInt2, 1);
		Object localObject;
		if (paramInt1 == 0) {
			localObject = new CustomCheckBox(paramComposite, 32,
					"DominoPreferencePageCustomCheckbox_" + paramString2
							+ ".id");
			((CustomCheckBox) localObject).setLayoutData(localGridData);
			((CustomCheckBox) localObject).setText(paramString2);
			localPreferenceWidget = new PreferenceWidget((Widget) localObject,
					paramString1);
		} else if (paramInt1 == 1) {
			createLabel(paramComposite, paramString2);

			localObject = new CustomText(paramComposite, 2048,
					"DominoPreferencePageCustomText.id");
			((CustomText) localObject).setLayoutData(localGridData);
			localPreferenceWidget = new PreferenceWidget((Widget) localObject,
					paramString1);
		} else if (paramInt1 == 2) {
			localPreferenceWidget = addField(paramString1, paramString2, 1,
					paramComposite);

			localObject = (CustomText) localPreferenceWidget.getWidget();
			((CustomText) localObject)
					.setValidator(IntegerValidator.positiveInstance);
		} else if (paramInt1 == 3) {
			createLabel(paramComposite, paramString2);

			localObject = new CustomCombo(paramComposite, 8,
					"DominoPreferencePageCustomCombo.id");
			((CustomCombo) localObject).setLayoutData(localGridData);
			localPreferenceWidget = new PreferenceWidget((Widget) localObject,
					paramString1);
		}
		if (localPreferenceWidget != null) {
			this.preferenceWidgets.add(localPreferenceWidget);
		}
		return localPreferenceWidget;
	}

	protected PreferenceWidget addField(String paramString1,
			String paramString2, int paramInt1, Composite paramComposite,
			int paramInt2, int paramInt3) {
		PreferenceWidget localPreferenceWidget = addField(paramString1,
				paramString2, paramInt1, paramComposite);
		if (paramInt1 == 2) {
			CustomText localCustomText = (CustomText) localPreferenceWidget
					.getWidget();
			localCustomText.setValidator(new IntegerValidator(new Long(
					paramInt2), new Long(paramInt3)));
		}
		return localPreferenceWidget;
	}

	protected PreferenceWidget addField(String paramString1,
			String paramString2, int paramInt, Composite paramComposite,
			String[] paramArrayOfString) {
		PreferenceWidget localPreferenceWidget = addField(paramString1,
				paramString2, paramInt, paramComposite);
		if (paramArrayOfString != null) {
			CustomCombo localCustomCombo = (CustomCombo) localPreferenceWidget
					.getWidget();
			localCustomCombo.setItems(paramArrayOfString);
		}
		return localPreferenceWidget;
	}

	protected CustomLabel createLabel(Composite paramComposite,
			String paramString) {
		CustomLabel localCustomLabel = new CustomLabel(paramComposite, 64,
				"DominoPreferencePageCustomLabel_" + paramString + ".id");
		localCustomLabel.setText(paramString);
		localCustomLabel.setLayoutData(new GridData());

		return localCustomLabel;
	}

	protected void performDefaults() {
		Iterator<PreferenceWidget> localIterator = this.preferenceWidgets
				.iterator();
		while (localIterator.hasNext()) {
			PreferenceWidget localPreferenceWidget = localIterator.next();
			localPreferenceWidget.load(true);
		}
		updateComposites();
	}

	public boolean performOk() {
		boolean bool = true;
		PreferenceWidget widget = null;

		Iterator<PreferenceWidget> it = this.preferenceWidgets.iterator();
		while (it.hasNext()) {
			widget = it.next();
			bool = widget.save();
			if (!bool) {
				break;
			}
		}
		if (!bool) {
			String str = widget.getErrorMessage();
			setErrorMessage(str);
		}
		setValid(bool);
		return bool;
	}

	protected void enableControls(Composite paramComposite, boolean paramBoolean) {
		Control[] arrayOfControl = paramComposite.getChildren();
		for (int i = 0; i < arrayOfControl.length; i++) {
			if (((arrayOfControl[i] instanceof Composite))
					&& (!(arrayOfControl[i] instanceof Combo))) {
				enableControls((Composite) arrayOfControl[i], paramBoolean);
			} else {
				arrayOfControl[i].setEnabled(paramBoolean);
			}
		}
	}

	protected CustomComposite createChildComposite(Composite paramComposite) {
		CustomComposite localCustomComposite = new CustomComposite(
				paramComposite, 0, "DominoPreferencePageCustomComposite.id");
		GridLayout localGridLayout = new GridLayout(2, false);
		localGridLayout.marginHeight = 0;
		localGridLayout.marginLeft = 20;
		localGridLayout.verticalSpacing = 7;
		localGridLayout.horizontalSpacing = 10;
		localCustomComposite.setLayout(localGridLayout);
		localCustomComposite.setLayoutData(SWTLayoutUtils
				.createGDFillHorizontal());

		return localCustomComposite;
	}

	protected CustomTable createCheckTable(Composite paramComposite) {
		CustomTable localCustomTable = new CustomTable(paramComposite, 67616,
				"DominoPreferencePageCustomTable.id");
		GridData localGridData = new GridData();
		localGridData.widthHint = 150;
		localCustomTable.setLayoutData(localGridData);

		return localCustomTable;
	}

	protected CustomText createBrowseText(Composite paramComposite,
			String paramString1, String paramString2, boolean paramBoolean) {
		createLabel(paramComposite, paramString1);

		Composite localComposite = new Composite(paramComposite, 0);
		localComposite.setLayout(SWTLayoutUtils
				.createLayoutNoMarginDefaultSpacing(2));
		localComposite.setLayoutData(SWTLayoutUtils.createGDFillHorizontal());

		final CustomText localCustomText = new CustomText(localComposite, 2048,
				"DominoPreferencePageCustomText.id");
		GridData localGridData = SWTLayoutUtils.createGDFillHorizontal();
		localGridData.verticalAlignment = 16777216;
		localCustomText.setLayoutData(localGridData);
		if (paramBoolean) {
			localCustomText.addModifyListener(new ModifyListener() {
				public void modifyText(ModifyEvent paramAnonymousModifyEvent) {
					DoraPreferencePage.this.setErrorMessage(null);
					DoraPreferencePage.this.setValid(true);
				}
			});
		}
		CustomButton localCustomButton = new CustomButton(localComposite, 8,
				"DominoPreferencePageBrowseButton.id");
		localCustomButton.setImage(CompositeEditor.IMG_BROWSEBUTTON.getImage());
		SWTACCUtils
				.setToolTipAndAccessibleName(localCustomButton, paramString2);
		localCustomButton.addSelectionListener(new SelectionAdapter() {
			public void widgetSelected(
					SelectionEvent paramAnonymousSelectionEvent) {
				DirectoryDialog localDirectoryDialog = new DirectoryDialog(
						DoraPreferencePage.this.getShell());
				String str = localDirectoryDialog.open();
				if (StringUtil.isNotEmpty(str)) {
					if (localCustomText.getText().endsWith(";")) {
						localCustomText.append(str);
					} else if (localCustomText.getText().length() > 1) {
						localCustomText.append(";");
						localCustomText.append(str);
					} else {
						localCustomText.append(str);
					}
				}
			}
		});
		return localCustomText;
	}

}
