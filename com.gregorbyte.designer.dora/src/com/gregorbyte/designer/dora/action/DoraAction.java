package com.gregorbyte.designer.dora.action;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IPath;

import com.gregorbyte.designer.dora.ResourceHandler;
import com.ibm.commons.util.StringUtil;
import com.ibm.designer.domino.ide.resources.project.IDominoDesignerProject;
import com.ibm.designer.domino.team.builder.ISyncOperation;
import com.ibm.designer.domino.team.util.SyncUtil;

public class DoraAction {

	private int defaultAction;
	
	public IDominoDesignerProject designerProject = null;
	
	public DoraAction() {}
	
	public ISyncOperation getSyncOperation(IFile designerFile, IFile diskFile) {

		boolean designerFileModifiedBySync = SyncUtil
				.isModifiedBySync(designerFile);
		boolean diskFileModifiedBySync = SyncUtil.isModifiedBySync(diskFile);

		boolean designerFileUsedForSync = SyncUtil.isUsedForSync(designerFile);
		boolean diskFileUsedForSync = SyncUtil.isUsedForSync(diskFile);

		int i = this.defaultAction == 1 ? 1 : 0;

		boolean bool5 = this.defaultAction == 2;
		if (!canSync(diskFile, designerFile, bool5)) {
			return null;
		}

		IPath designerFilePath = designerFile.getProjectRelativePath();

		if (SyncUtil.isSharedAction(designerFilePath)) {
			return handleSharedActions(designerFile, diskFile,
					this.defaultAction);
		}

		if (bool5) {
			if ((designerFile.exists()) && (!diskFile.exists())) {
				return getDeleteOp(designerFile, diskFile);
			}
			return getExportOp(designerFile, diskFile);
		}
		if (i != 0) {
			if ((!designerFile.exists()) && (diskFile.exists())) {
				return getDeleteOp(designerFile, diskFile);
			}
			return getExportOp(designerFile, diskFile);
		}
		if ((designerFile.exists()) && (!diskFile.exists())) {
			if (designerFileUsedForSync) {
				return getDeleteOp(designerFile, diskFile);
			}
			return getExportOp(designerFile, diskFile);
		}
		if ((diskFile.exists()) && (!designerFile.exists())) {
			if (diskFileUsedForSync) {
				return getDeleteOp(designerFile, diskFile);
			}
			return getExportOp(designerFile, diskFile);
		}
		if ((designerFile.exists()) && (!designerFileModifiedBySync)) {
			if (diskFileModifiedBySync) {
				return getExportOp(designerFile, diskFile);
			}
			if ((diskFile.exists()) && (!diskFileModifiedBySync)) {
				SyncUtil.logToConsole(StringUtil.format(
						ResourceHandler
								.getString("SyncAction.Nsffile0anddiskfile1bothhavebeenu"),
						new Object[] { diskFile.getProjectRelativePath(),
								designerFile.getProjectRelativePath() }));
				if (i != 0) {
					return getExportOp(designerFile, diskFile);
				}
				if (bool5) {
					return getExportOp(designerFile, diskFile);
				}
				if (this.defaultAction == 3) {
					long l1 = designerFile.getLocalTimeStamp();
					long l2 = diskFile.getLocalTimeStamp();
					SyncUtil.logToConsole(ResourceHandler
							.getString("SyncAction.Detectingtherecentfilebycomparing"));
					if (l1 > l2) {
						return getExportOp(designerFile, diskFile);
					}
					return getExportOp(designerFile, diskFile);
				}
				return getConflictOp(designerFile, diskFile);
			}
		}
		if ((diskFile.exists()) && (!diskFileModifiedBySync)) {
			if (designerFileModifiedBySync) {
				return getExportOp(designerFile, diskFile);
			}
		}
		return null;
	}

	private ISyncOperation getConflictOp(IFile paramIFile1, IFile paramIFile2) {
		// TODO Auto-generated method stub
		return null;
	}

	private ISyncOperation getExportOp(IFile paramIFile1, IFile paramIFile2) {
		// TODO Auto-generated method stub
		return null;
	}

	private ISyncOperation getDeleteOp(IFile paramIFile1, IFile paramIFile2) {
		// TODO Auto-generated method stub
		return null;
	}

	private ISyncOperation handleSharedActions(IFile paramIFile1,
			IFile paramIFile2, int defaultAction2) {
		// TODO Auto-generated method stub
		return null;
	}

	private boolean canSync(IFile paramIFile2, IFile paramIFile1, boolean bool5) {

		if (!SyncUtil.canSync(paramIFile1, paramIFile2, this.designerProject)) {
			return false;
		}
		return true;
	}

}
