import asyncio

from app.media import (
    MediaProviderRegistry,
    MediaService,
    MockMediaProvider,
)


def test_media_system() -> None:
    async def run() -> None:
        registry = MediaProviderRegistry()

        registry.register(
            MockMediaProvider()
        )

        media = MediaService(
            registry
        )

        photo_video = await media.photo_to_video(
            source="photo.jpg",
            prompt="Animate this image",
        )

        assert photo_video.success is True
        assert (
            photo_video.operation
            == "photo_to_video"
        )

        video_photo = await media.video_to_photo(
            source="video.mp4",
        )

        assert video_photo.success is True
        assert (
            video_photo.operation
            == "video_to_photo"
        )

        cartoon = await media.photo_to_cartoon(
            source="person.jpg",
            prompt="Anime style",
        )

        assert cartoon.success is True

        cartoon_video = (
            await media.video_to_cartoon(
                source="movie.mp4",
                prompt="Animated cinematic style",
            )
        )

        assert cartoon_video.success is True

        generated = await media.generate_video(
            prompt=(
                "A futuristic AI city with "
                "flying vehicles"
            )
        )

        assert generated.success is True
        assert (
            generated.operation
            == "text_to_video"
        )

    asyncio.run(run())
