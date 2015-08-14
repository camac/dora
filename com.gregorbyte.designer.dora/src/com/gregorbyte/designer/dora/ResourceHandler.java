package com.gregorbyte.designer.dora;

import java.text.MessageFormat;
import java.util.MissingResourceException;
import java.util.ResourceBundle;

public class ResourceHandler {

	private static ResourceBundle _resourceBundle;
	private static ResourceBundle _loggingResourceBundle;

	private static ResourceBundle getResourceBundle(String string) {

		try {
			String str = buildResourcePath(string);
			return ResourceBundle.getBundle(str);
		} catch (MissingResourceException mre) {
			return null;
		}

	}

	private static String buildResourcePath(String string) {

		String str = ResourceHandler.class.getName();
		return str.substring(0, str.lastIndexOf('.') + 1) + string;

	}

	public static String getString(String string) {
		if (_resourceBundle == null) {
			_resourceBundle = getResourceBundle("messages");
		}
		return getResourceBundleString(_resourceBundle, string);
	}

	public static String getLoggingString(String string) {
		if (_loggingResourceBundle == null) {
			_loggingResourceBundle = getResourceBundle("logging");
		}
		return getResourceBundleString(_loggingResourceBundle, string);
	}

	public static String getString(String string, Object[] objects) {
		try {
			return MessageFormat.format(getString(string), objects);
		} catch (IllegalArgumentException e) {
			return getString(string);
		}
	}

	public static String getString(String string, Object[] objects, int myint) {
		return getString(string);
	}

	public static String getLoggingString(String paramString,
			Object[] paramArrayOfObject) {
		try {
			return MessageFormat.format(getLoggingString(paramString),
					paramArrayOfObject);
		} catch (IllegalArgumentException localIllegalArgumentException) {
		}
		return getString(paramString);
	}

	public static String getLoggingString(String paramString,
			Object[] paramArrayOfObject, int paramInt) {
		return getLoggingString(paramString);
	}

	public static String getResourceBundleString(
			ResourceBundle paramResourceBundle, String paramString) {
		if (paramResourceBundle != null) {
			try {
				return paramResourceBundle.getString(paramString);
			} catch (MissingResourceException localMissingResourceException) {
				return "!" + paramString + "!";
			}
		}
		return "!" + paramString + "!";
	}

}
