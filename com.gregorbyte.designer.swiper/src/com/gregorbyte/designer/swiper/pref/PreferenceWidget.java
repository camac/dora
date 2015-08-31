package com.gregorbyte.designer.swiper.pref;

import java.util.Map;

import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.TableItem;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.widgets.TreeItem;
import org.eclipse.swt.widgets.Widget;

import com.ibm.commons.swt.controls.LookupComboBox;
import com.ibm.commons.util.StringUtil;

public class PreferenceWidget {

	protected Widget widget;
	protected Label label;
	protected String preferenceKey;
	protected DoraPreferenceManager prefMgr;
	protected boolean bNotify = false;
	protected int eventType;
	protected String errorMessage = null;
	protected Map<String, String> extraProps = null;

	public PreferenceWidget() {
	}

	public PreferenceWidget(Widget paramWidget, String paramString) {
		this.widget = paramWidget;
		this.preferenceKey = paramString;
		this.prefMgr = DoraPreferenceManager.getInstance();
	}

	public PreferenceWidget(Widget paramWidget, String paramString,
			Label paramLabel) {
		this.widget = paramWidget;
		this.preferenceKey = paramString;
		this.prefMgr = DoraPreferenceManager.getInstance();
		this.label = paramLabel;
	}

	public void setNotify(boolean paramBoolean, int paramInt) {
		this.bNotify = paramBoolean;
		this.eventType = paramInt;
	}

	public String getPreferenceKey() {
		return this.preferenceKey;
	}

	public Widget getWidget() {
		return this.widget;
	}

	protected String getWidgetStringValue() {
		String str = null;
		if ((this.widget instanceof Button)) {
			str = Boolean.toString(((Button) this.widget).getSelection());
		} else if ((this.widget instanceof Text)) {
			str = ((Text) this.widget).getText();
		} else if ((this.widget instanceof LookupComboBox)) {
			str = ((LookupComboBox) this.widget).getValue();
		} else if ((this.widget instanceof TableItem)) {
			str = Boolean.toString(((TableItem) this.widget).getChecked());
		} else if ((this.widget instanceof TreeItem)) {
			str = Boolean.toString(((TreeItem) this.widget).getChecked());
		} else if ((this.widget instanceof Combo)) {
			int i = ((Combo) this.widget).getSelectionIndex();
			if (i != -1) {
				str = ((Combo) this.widget).getItem(i);
			}
		}
		return str != null ? str : "";
	}

	public String getErrorMessage() {
		return this.errorMessage;
	}

	public boolean save() {
		boolean bool = validate();
		if (bool) {
			this.prefMgr.setValue(this.preferenceKey, getWidgetStringValue(),
					this.bNotify, this.eventType, this.extraProps);
		}
		return bool;
	}

	protected boolean validate() {
		return true;
	}

	public void load(boolean paramBoolean) {
		String str = StringUtil.getNonNullString(this.prefMgr.getValue(
				this.preferenceKey, paramBoolean));
		if ((this.widget instanceof Button)) {
			((Button) this.widget).setSelection(isTrue(str));
		} else if ((this.widget instanceof Text)) {
			((Text) this.widget).setText(str);
		} else if ((this.widget instanceof LookupComboBox)) {
			((LookupComboBox) this.widget).setValue(str);
		} else if ((this.widget instanceof TableItem)) {
			((TableItem) this.widget).setChecked(isTrue(str));
		} else if ((this.widget instanceof TreeItem)) {
			((TreeItem) this.widget).setChecked(isTrue(str));
		} else if ((this.widget instanceof Combo)) {
			Combo localCombo = (Combo) this.widget;
			int i = localCombo.indexOf(str);
			if (i != -1) {
				localCombo.select(i);
			}
		}
	}

	protected boolean isTrue(String paramString) {
		return StringUtil.equals(Boolean.TRUE.toString(), paramString);
	}

	public Label getLabel() {
		return this.label;
	}

}
