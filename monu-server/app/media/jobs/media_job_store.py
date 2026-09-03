from app.media.jobs.media_job import MediaJob


class MediaJobStore:
    def __init__(self) -> None:
        self._jobs: dict[
            str,
            MediaJob,
        ] = {}

    def add(
        self,
        job: MediaJob,
    ) -> MediaJob:
        self._jobs[job.job_id] = job
        return job

    def get(
        self,
        job_id: str,
    ) -> MediaJob | None:
        return self._jobs.get(job_id)

    def list_all(
        self,
    ) -> list[MediaJob]:
        return list(self._jobs.values())
