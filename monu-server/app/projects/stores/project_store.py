from app.projects.models.project import Project


class ProjectStore:
    def __init__(self) -> None:
        self._projects: dict[
            str,
            Project,
        ] = {}

    def add(
        self,
        project: Project,
    ) -> Project:
        self._projects[
            project.project_id
        ] = project

        return project

    def get(
        self,
        project_id: str,
    ) -> Project | None:
        return self._projects.get(
            project_id
        )

    def list_all(self) -> list[Project]:
        return list(
            self._projects.values()
        )
