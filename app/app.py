from fastapi import FastAPI

app = FastAPI(
    title="Template App",
    description="Template App"
)


@app.get("/")
async def root() -> dict[str, str]:
    """Base endpoint

    Returns:
        dict[str, str]: Hello World message
    """
    return {"message": "Hello World"}
