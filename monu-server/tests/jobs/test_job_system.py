import asyncio

from app.jobs import JobService


def test_job_system() -> None:
    async def run() -> None:
        service = JobService()

        job = await service.submit(
            name="calculate",
            operation=lambda: 10 + 20,
        )

        for _ in range(10):
            current = service.get(
                job.job_id
            )

            if (
                current is not None
                and current.status
                in {"completed", "failed"}
            ):
                break

            await asyncio.sleep(0.01)

        current = service.get(
            job.job_id
        )

        assert current is not None
        assert current.status == "completed"
        assert current.result == 30

    asyncio.run(run())
