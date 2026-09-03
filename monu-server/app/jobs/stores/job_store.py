from app.jobs.models.job import Job


class JobStore:
    def __init__(self) -> None:
        self._jobs: dict[str, Job] = {}

    def add(
        self,
        job: Job,
    ) -> Job:
        self._jobs[job.job_id] = job

        return job

    def get(
        self,
        job_id: str,
    ) -> Job | None:
        return self._jobs.get(job_id)

    def list_all(self) -> list[Job]:
        return list(
            self._jobs.values()
        )
