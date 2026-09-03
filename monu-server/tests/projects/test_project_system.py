from app.projects import ProjectService


def test_project_system() -> None:
    projects = ProjectService()

    project = projects.create(
        title="AI Video Campaign",
        description=(
            "Create AI generated videos "
            "for client"
        ),
        client="AI Media Client",
    )

    assert project.status == "created"

    projects.start(project)

    assert project.status == "active"

    projects.add_task(
        project,
        "Generate video concepts",
    )

    projects.add_task(
        project,
        "Create final videos",
    )

    assert len(project.tasks) == 2

    projects.update_progress(
        project,
        100,
    )

    projects.deliver(
        project,
        "final_video.mp4",
    )

    completed = projects.complete(
        project
    )

    assert completed.status == "completed"

    assert len(
        completed.deliverables
    ) == 1
