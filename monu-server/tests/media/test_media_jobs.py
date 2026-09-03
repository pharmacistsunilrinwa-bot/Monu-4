import asyncio

from app.media import (
    MediaJobService,
    MediaProviderRegistry,
    MediaService,
    MockMediaProvider,
)


def test_media_background_job() -> None:
    async def run() -> None:
        registry = MediaProviderRegistry()

        registry.register(
            MockMediaProvider()
        )

        media = MediaService(
            registry
        )

        jobs = MediaJobService(
            media
        )

        job = jobs.submit(
            operation="photo_to_video",
            source="image.jpg",
            prompt=(
                "Create cinematic movement"
            ),
        )

        assert job.status in {
            "pending",
            "running",
            "completed",
        }

        for _ in range(50):
            current = jobs.get(
                job.job_id
            )

            if (
                current is not None
                and current.status
                in {"completed", "failed"}
            ):
                break

            await asyncio.sleep(0.01)

        current = jobs.get(
            job.job_id
        )

        assert current is not None
        assert current.status == "completed"
        assert current.progress == 100
        assert current.result is not None
        assert current.result.success is True

    asyncio.run(run())
