import asyncio

from app.autonomy import AutonomyService


def test_autonomy_system() -> None:
    async def run() -> None:
        autonomy = AutonomyService()

        async def operation() -> str:
            await asyncio.sleep(0.02)
            return "MONU task completed"

        task = autonomy.submit(
            title="Research opportunity",
            description=(
                "Analyze an AI business opportunity"
            ),
            operation=operation,
        )

        for _ in range(20):
            current = autonomy.get(
                task.task_id
            )

            if (
                current is not None
                and current.status
                in {"completed", "failed"}
            ):
                break

            await asyncio.sleep(0.01)

        current = autonomy.get(task.task_id)

        assert current is not None
        assert current.status == "completed"
        assert current.progress == 100
        assert current.result == (
            "MONU task completed"
        )

        report = autonomy.report(
            task.task_id
        )

        assert report is not None
        assert report.status == "completed"

    asyncio.run(run())
