package com.gregorbyte.designer.dora.builder.pre;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IResourceDelta;
import org.eclipse.core.resources.IResourceDeltaVisitor;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;

import com.gregorbyte.designer.dora.util.DoraUtil;
import com.ibm.designer.domino.ide.resources.project.IDominoDesignerProject;
import com.ibm.designer.domino.team.util.SyncUtil;

public class SwiperPreVisitor implements IResourceDeltaVisitor {

	@SuppressWarnings("unused")
	private SwiperPreSyncBuilder builder;
	@SuppressWarnings("unused")
	private IProgressMonitor monitor = null;
	private IDominoDesignerProject designerProject = null;

	public SwiperPreVisitor(IProgressMonitor monitor,
			SwiperPreSyncBuilder builder) {
		this.monitor = monitor;
		this.builder = builder;
		this.designerProject = builder.getDesignerProject();
	}

	private boolean processAdded(IResourceDelta delta) {

		DoraUtil.logInfo("Processing Added");

		/*
		 * If the physical file is not found, then save the current timestamp
		 */
		
		if ((delta.getResource() instanceof IFolder)) {
			IFolder folder = (IFolder) delta.getResource();

			if (SyncUtil.isSharedAction(folder.getParent()
					.getProjectRelativePath())) {
				return false;
			}
		} else if (delta.getResource() instanceof IFile) {

			@SuppressWarnings("unused")
			IFile file = (IFile) delta.getResource();

		}
		return true;
	}

	private boolean processChanged(IResourceDelta delta) throws CoreException {

		DoraUtil.logInfo("Processing Changed");

		if ((delta.getResource() instanceof IFolder)) {
			
			IFolder folder = (IFolder) delta.getResource();

			if (SyncUtil.isSharedAction(folder.getParent()
					.getProjectRelativePath())) {
				return false;
			}
			
		} else if (delta.getResource() instanceof IFile) {

			IFile designerFile = (IFile) delta.getResource();
			
			if (designerFile.getName().contains("CustomControl.xsp")) {
				System.out.println(designerFile.getName());
			}
			
			IFile diskFile = DoraUtil.getRelevantDiskFile(designerProject, designerFile);
			
			if (diskFile != null && diskFile.exists()) {
				DoraUtil.setSyncTimestamp(diskFile);
			}

		}
		return true;
	}

	@Override
	public boolean visit(IResourceDelta delta) throws CoreException {

		DoraUtil.logInfo("Visiting: " + delta.getResource().getName());

		switch (delta.getKind()) {
		case IResourceDelta.ADDED:
			if (!processAdded(delta)) {
				return false;
			}
			break;
		case IResourceDelta.CHANGED:
			if (!processChanged(delta)) {
				return false;
			}
			break;

		}

		return true;
	}

}
