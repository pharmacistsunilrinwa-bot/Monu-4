from app.projects.models.project import Project
from app.projects.stores.project_store import (
    ProjectStore,
)


class ProjectService:
    def __init__(
        self,
        store: ProjectStore | None = None,
    ) -> None:
        self.store = store or ProjectStore()

    def create(
        self,
        title: str,
        description: str,
        client: str,
    ) -> Project:
        project = Project(
            title=title,
            description=description,
            client=client,
        )

        return self.store.add(project)

    def start(
        self,
        project: Project,
    ) -> Project:
        project.status = "active"

        return project

    def add_task(
        self,
        project: Project,
        task: str,
    ) -> Project:
        project.tasks.append(task)

        return project

    def update_progress(
        self,
        project: Project,
        progress: int,
    ) -> Project:
        if progress < 0 or progress > 100:
            raise ValueError(
                "Progress must be between "
                "0 and 100"
            )

        project.progress = progress

        return project

    def deliver(
        self,
        project: Project,
        deliverable: str,
    ) -> Project:
        project.deliverables.append(
            deliverable
        )

        return project

    def complete(
        self,
        project: Project,
    ) -> Project:
        if project.progress < 100:
            raise ValueError(
                "Project must reach 100 percent "
                "before completion"
            )

        project.status = "completed"

        return project

    def list_projects(self) -> list[Project]:
        return self.store.list_all()
