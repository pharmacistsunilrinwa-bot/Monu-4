import asyncio
from collections.abc import Callable
from typing import Any

from app.jobs.models.job import Job
from app.jobs.stores.job_store import JobStore


class JobService:
    def __init__(
        self,
        store: JobStore | None = None,
    ) -> None:
        self.store = store or JobStore()

    async def submit(
        self,
        name: str,
        operation: Callable[[], Any],
    ) -> Job:
        job = Job(
            name=name
        )

        self.store.add(job)

        async def run() -> None:
            job.status = "running"

            try:
                result = operation()

                if asyncio.iscoroutine(
                    result
                ):
                    result = await result

                job.result = result
                job.status = "completed"

            except Exception as error:
                job.error = str(error)
                job.status = "failed"

        asyncio.create_task(run())

        return job

    def get(
        self,
        job_id: str,
    ) -> Job | None:
        return self.store.get(job_id)
