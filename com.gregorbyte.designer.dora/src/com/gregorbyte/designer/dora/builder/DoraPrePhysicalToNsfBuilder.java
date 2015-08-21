package com.gregorbyte.designer.dora.builder;

import java.util.Map;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceDelta;
import org.eclipse.core.resources.IResourceDeltaVisitor;
import org.eclipse.core.resources.IncrementalProjectBuilder;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.ui.IStartup;

import com.gregorbyte.designer.dora.util.DoraUtil;
import com.ibm.designer.domino.ide.resources.jni.IResourceUpdateListener;
import com.ibm.designer.domino.ide.resources.project.IDominoDesignerProject;
import com.ibm.designer.domino.team.util.SyncUtil;

public class DoraPrePhysicalToNsfBuilder extends IncrementalProjectBuilder {

	public static final String BUILDER_ID = "com.gregorbyte.designer.dora.DoraPrePhysicalToNsfBuilder";
	IDominoDesignerProject designerProject = null;
	IProject diskProject = null;

	public DoraPrePhysicalToNsfBuilder() {
	};

	public DoraPrePhysicalToNsfBuilder(IProject project) {
		this.diskProject = project;
		initialize();
	}

	public void initialize() {

		try {
			this.designerProject = SyncUtil
					.getAssociatedNsfProject(getDiskProject());
		} catch (CoreException e) {
			e.printStackTrace();
		}

		if (this.designerProject != null) {

		}

	}

	public IProject getDiskProject() {
		return this.diskProject != null ? this.diskProject : super.getProject();
	}

	@Override
	protected IProject[] build(int arg0, Map arg1, IProgressMonitor arg2)
			throws CoreException {

		System.out.println("Dora: PrePhysicalToNsfBuilder");

		initialize();
		if (this.designerProject == null) {
			return null;
		}

		try {
			IResourceDelta localIResourceDelta = getDelta(getDiskProject());
		
			if (localIResourceDelta != null) {
//				boolean bool = isRelevant(localIResourceDelta);
//				if (!bool) {
//					return null;
//				}
//				if (!this.designerProject.isProjectInitialized()) {
//					SyncAction localSyncAction = new SyncAction(1);
//					localSyncAction.setSyncProjects(this.designerProject,
//							getProject());
//					localSyncAction.doExecute(paramIProgressMonitor);
//					return null;
//				}
//				SyncUtil.logToConsole("*********");
//				SyncUtil.logToConsole(StringUtil.format(
//						ResourceHandler
//								.getString("PhysicalToNsfSynBuilder.Startingimplicitimportoperationfr"),
//						new Object[] { getProject(),
//								this.designerProject.getProject() }));
//
				localIResourceDelta.accept(new IResourceDeltaVisitor() {
					public boolean visit(
							IResourceDelta paramAnonymousIResourceDelta) {
						switch (paramAnonymousIResourceDelta.getKind()) {
						case 2:
							IResource localIResource = paramAnonymousIResourceDelta
									.getResource();
							if (localIResource.getType() == 1) {
								IFile localIFile = (IFile) paramAnonymousIResourceDelta
										.getResource();
								
								//System.out.println("this is where we would update timestamp DELETED");
								
//								PhysicalToNsfSynBuilder.this
//										.importPhysicalFile(localIFile,
//												paramIProgressMonitor);
							}
							break;
						}
						return true;
					}
				});
				localIResourceDelta.accept(new IResourceDeltaVisitor() {
					public boolean visit(
							IResourceDelta paramAnonymousIResourceDelta) {
						IFile localIFile;
						switch (paramAnonymousIResourceDelta.getKind()) {
						case 1:
							if ((paramAnonymousIResourceDelta.getResource() instanceof IFile)) {
								localIFile = (IFile) paramAnonymousIResourceDelta
										.getResource();
								//System.out.println("this is where we would update ADDED");

//								PhysicalToNsfSynBuilder.this
//										.importPhysicalFile(localIFile,
//												paramIProgressMonitor);
							}
							break;
						case 4:
							if ((paramAnonymousIResourceDelta.getResource() instanceof IFile)) {
								localIFile = (IFile) paramAnonymousIResourceDelta
										.getResource();
								
								//System.out.println("this is where we would update CHANGED");

								IProject nsfProject = DoraPrePhysicalToNsfBuilder.this.designerProject.getProject();
								
								IFile nsfFile = SyncUtil.getMatchingNsfFile(nsfProject, localIFile);								
								DoraUtil.setSyncTimestamp(nsfFile);
								
//								PhysicalToNsfSynBuilder.this
//										.importPhysicalFile(localIFile,
//												paramIProgressMonitor);
							}
							break;
						}
						return true;
					}
				});
//				this.syncAction.performPostImplicitSync(paramIProgressMonitor);
//				ResourcesPlugin.getWorkspace().save(false,
//						paramIProgressMonitor);
			}
		} catch (Exception localException) {
			localException.printStackTrace();
		}
		return null;

	}

}
