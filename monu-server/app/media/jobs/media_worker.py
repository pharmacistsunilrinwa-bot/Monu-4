import asyncio

from app.media.jobs.media_job import MediaJob
from app.media.services.media_service import (
    MediaService,
)


class MediaWorker:
    def __init__(
        self,
        media_service: MediaService,
    ) -> None:
        self.media_service = media_service

    async def execute(
        self,
        job: MediaJob,
    ) -> MediaJob:
        job.status = "running"
        job.progress = 10

        try:
            await asyncio.sleep(0)

            job.progress = 50

            result = await self.media_service.process(
                operation=job.operation,
                source=job.source,
                prompt=job.prompt,
            )

            if not result.success:
                job.status = "failed"
                job.error = result.error
                job.progress = 100
                return job

            job.result = result
            job.status = "completed"
            job.progress = 100

            return job

        except Exception as error:
            job.status = "failed"
            job.error = str(error)
            job.progress = 100

            return job
