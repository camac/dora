package com.gregorbyte.designer.swiper.builder.pre;

import java.util.Map;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceDelta;
import org.eclipse.core.resources.IResourceDeltaVisitor;
import org.eclipse.core.resources.IncrementalProjectBuilder;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.resources.WorkspaceJob;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.ui.IStartup;

import com.gregorbyte.designer.swiper.action.FilterMetadataAction;
import com.gregorbyte.designer.swiper.util.SwiperUtil;
import com.ibm.commons.util.StringUtil;
import com.ibm.designer.domino.ide.resources.DominoResourcesPlugin;
import com.ibm.designer.domino.ide.resources.NsfException;
import com.ibm.designer.domino.ide.resources.ResourceHandler;
import com.ibm.designer.domino.ide.resources.jni.IResourceUpdateListener;
import com.ibm.designer.domino.ide.resources.jni.NResourceUpdateTracker;
import com.ibm.designer.domino.ide.resources.jni.NotesDesignElement;
import com.ibm.designer.domino.ide.resources.project.IDominoDesignerProject;
import com.ibm.designer.domino.preferences.DominoPreferenceManager;
import com.ibm.designer.domino.team.builder.RenameSyncContext;
import com.ibm.designer.domino.team.builder.RenameSyncOperation;
import com.ibm.designer.domino.team.util.SyncUtil;

public class SwiperPreSyncBuilder extends IncrementalProjectBuilder
		implements IResourceUpdateListener, IStartup {

	public static final String BUILDER_ID = "com.gregorbyte.designer.swiper.SwiperPreSyncBuilder";

	IDominoDesignerProject designerProject = null;
	IProject diskProject = null;
	FilterMetadataAction filterAction = null;

	public SwiperPreSyncBuilder() {

	}

	public SwiperPreSyncBuilder(IDominoDesignerProject designerProject) {
		this.designerProject = designerProject;
	}

	public IDominoDesignerProject getDesignerProject() {
		return this.designerProject;
	}
	
	public void initialize() {

		if (this.designerProject != null) {
			try {
				this.diskProject = SyncUtil.getAssociatedDiskProject(
						this.designerProject, false);

				if (this.diskProject != null) {
					this.filterAction = new FilterMetadataAction();
					this.filterAction.setSyncProjects(this.designerProject,
							this.diskProject);
				}
			} catch (CoreException e) {
				e.printStackTrace();
			}
		}

	}


	@SuppressWarnings("rawtypes")
	protected IProject[] build(int kind, Map args, IProgressMonitor monitor)
			throws CoreException {

		SwiperUtil.logInfo("Swiper: PreSyncBuilder");

		try {
			this.designerProject = DominoResourcesPlugin
					.getDominoDesignerProject(getProject());
		} catch (NsfException e) {
			e.printStackTrace();
		}

		if ((this.designerProject == null)
				|| (!this.designerProject.isProjectInitialized())
				|| (!SyncUtil
						.isConfiguredForSourceControl(this.designerProject))) {
			return null;
		}

		if ((!SyncUtil.isSourceControlEnabled()) || (!isAutoExportEnabled())) {
			return null;
		}

		initialize();

		try {
			IResourceDelta delta = getDelta(getProject());

			if (delta != null) {
				boolean isRelevant = isRelevant(delta);

				if (!isRelevant) {
					return null;
				}

				SyncUtil.logToConsole("--GO Swiper---");
				SyncUtil.logToConsole("Starting MetaData filter");
		
				delta.accept(new SwiperPreVisitor(monitor, this));

				ResourcesPlugin.getWorkspace().save(false, monitor);

			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return null;

	}

	private boolean isRelevant(IResourceDelta delta) throws CoreException {
		final boolean[] arrayOfBoolean = new boolean[1];
		delta.accept(new IResourceDeltaVisitor() {
			public boolean visit(IResourceDelta paramAnonymousIResourceDelta) {
				switch (paramAnonymousIResourceDelta.getKind()) {
				case 1:
					if ((paramAnonymousIResourceDelta.getResource() instanceof IFile)) {
						arrayOfBoolean[0] = true;
						return false;
					}
					break;
				case 4:
					if ((paramAnonymousIResourceDelta.getResource() instanceof IFile)) {
						arrayOfBoolean[0] = true;
						return false;
					}
					break;
				case 2:
					IResource localIResource = paramAnonymousIResourceDelta
							.getResource();
					if (localIResource.getType() == 1) {
						arrayOfBoolean[0] = true;
						return false;
					}
					break;
				}
				return true;
			}
		});
		return arrayOfBoolean[0];
	}

	@Override
	public void earlyStartup() {
		NResourceUpdateTracker.getInstance().addListener(this);
	}

	@Override
	public void designerProjectInitialized(
			final IDominoDesignerProject paramIDominoDesignerProject) {

		if (!SyncUtil.isSourceControlEnabled() || (!isAutoExportEnabled())) {
			return;
		}

		if ((paramIDominoDesignerProject == null)
				|| (!SyncUtil
						.isConfiguredForSourceControl(paramIDominoDesignerProject))) {
			return;
		}

		WorkspaceJob local5 = new WorkspaceJob(
				ResourceHandler
						.getString("NsfToPhysicalSynBuilder.SyncingNSFtophysicalproject.1")) {
			public IStatus runInWorkspace(
					IProgressMonitor paramAnonymousIProgressMonitor)
					throws CoreException {
				IProject localIProject = null;
				if (paramIDominoDesignerProject != null) {
					try {
						localIProject = SyncUtil.getAssociatedDiskProject(
								paramIDominoDesignerProject, false);
						if ((localIProject != null) && (localIProject.exists())) {
							FilterMetadataAction filterAction = new FilterMetadataAction();
							filterAction.setSyncProjects(
									paramIDominoDesignerProject, localIProject);
							filterAction
									.doExecute(paramAnonymousIProgressMonitor);
						}
					} catch (CoreException localCoreException) {
						localCoreException.printStackTrace();
					}
				}
				return Status.OK_STATUS;
			}
		};
		local5.setRule(ResourcesPlugin.getWorkspace().getRoot());
		local5.schedule();
	}

	@Override
	public void nestedResourceUpdated(IDominoDesignerProject designerProject,
			final IResource resource, final long time) {

		if (!SyncUtil.isSourceControlEnabled()) {
			return;
		}
		if ((designerProject == null)
				|| (!SyncUtil.isConfiguredForSourceControl(designerProject))) {
			return;
		}
		WorkspaceJob local4 = new WorkspaceJob(
				ResourceHandler
						.getString("NsfToPhysicalSynBuilder.SyncingNSFtophysicalproject.1")) {
			public IStatus runInWorkspace(
					IProgressMonitor paramAnonymousIProgressMonitor)
					throws CoreException {
				boolean bool1 = SyncUtil.isUsedForSync(resource);
				boolean bool2 = SyncUtil.isModifiedBySync(resource);
				if ((bool1) && (bool2)) {
					SyncUtil.setSyncTimestamp(resource, time);
				}
				return Status.OK_STATUS;
			}
		};
		local4.setRule(designerProject.getProject());
		local4.schedule();

	}

	@Override
	public void resourceModified(IDominoDesignerProject designerProject) {

	}

	@SuppressWarnings("unused")
	private boolean isAutoImportEnabled() {
		return DominoPreferenceManager.getInstance().getBooleanValue(
				"domino.prefs.keys.team.import.auto", false);
	}

	public boolean isAutoExportEnabled() {
		return DominoPreferenceManager.getInstance().getBooleanValue(
				"domino.prefs.keys.team.export.auto", false);
	}

	@Override
	public void resourceRenamed(
			final IDominoDesignerProject paramIDominoDesignerProject,
			final IResource paramIResource1, final IResource paramIResource2) {

		if ((!SyncUtil.isSourceControlEnabled()) || (!isAutoExportEnabled())) {
			return;
		}
		if ((paramIDominoDesignerProject == null)
				|| (!SyncUtil
						.isConfiguredForSourceControl(paramIDominoDesignerProject))
				|| (!paramIDominoDesignerProject.isProjectInitialized())) {
			return;
		}
		WorkspaceJob local3 = new WorkspaceJob(
				ResourceHandler
						.getString("NsfToPhysicalSynBuilder.SyncingNSFtophysicalproject.1")) {
			public IStatus runInWorkspace(
					IProgressMonitor paramAnonymousIProgressMonitor)
					throws CoreException {
				Object localObject1 = (paramIResource1 instanceof IFile) ? SyncUtil
						.getPhysicalFile(paramIDominoDesignerProject,
								paramIResource1) : SyncUtil.getPhysicalFolder(
						paramIDominoDesignerProject, paramIResource1);
				Object localObject2 = (paramIResource2 instanceof IFile) ? SyncUtil
						.getPhysicalFile(paramIDominoDesignerProject,
								paramIResource2) : SyncUtil.getPhysicalFolder(
						paramIDominoDesignerProject, paramIResource2);
				if (((paramIResource2 instanceof IFile))
						&& (!SyncUtil.canSync((IFile) paramIResource2,
								(IFile) localObject2,
								paramIDominoDesignerProject))) {
					return Status.OK_STATUS;
				}
				NotesDesignElement localNotesDesignElement = DominoResourcesPlugin
						.getNotesDesignElement(paramIResource1);
				if ((localNotesDesignElement != null)
						&& (StringUtil.equals(
								localNotesDesignElement.getMetaModelID(),
								"metamodel.sharedactions"))) {
					localObject1 = SyncUtil.getPhysicalFile(
							paramIDominoDesignerProject, paramIResource1);
					localObject2 = SyncUtil.getPhysicalFile(
							paramIDominoDesignerProject, paramIResource2);
				}
				RenameSyncOperation localRenameSyncOperation = new RenameSyncOperation();
				localRenameSyncOperation.initContext(new RenameSyncContext(
						paramIDominoDesignerProject, paramIResource1,
						(IResource) localObject1, paramIResource2,
						(IResource) localObject2));
				return localRenameSyncOperation
						.performSync(paramAnonymousIProgressMonitor);
			}
		};
		local3.setRule(ResourcesPlugin.getWorkspace().getRoot());
		local3.schedule();

	}

}
