import asyncio

from app.media.jobs.media_job import MediaJob
from app.media.jobs.media_job_store import (
    MediaJobStore,
)
from app.media.jobs.media_worker import MediaWorker
from app.media.services.media_service import (
    MediaService,
)


class MediaJobService:
    def __init__(
        self,
        media_service: MediaService,
    ) -> None:
        self.store = MediaJobStore()

        self.worker = MediaWorker(
            media_service
        )

        self._tasks: dict[
            str,
            asyncio.Task,
        ] = {}

    def submit(
        self,
        operation: str,
        source: str,
        prompt: str = "",
    ) -> MediaJob:
        job = MediaJob(
            operation=operation,
            source=source,
            prompt=prompt,
        )

        self.store.add(job)

        task = asyncio.create_task(
            self.worker.execute(job)
        )

        self._tasks[job.job_id] = task

        return job

    def get(
        self,
        job_id: str,
    ) -> MediaJob | None:
        return self.store.get(job_id)

    def list_all(
        self,
    ) -> list[MediaJob]:
        return self.store.list_all()
