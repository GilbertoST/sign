from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import Field
from typing import List
import secrets


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    DATABASE_URL: str = "sqlite:///./sign_language.db"
    SECRET_KEY: str = Field(default_factory=lambda: secrets.token_urlsafe(64))
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    ALLOWED_ORIGINS: List[str] = Field(
        default_factory=lambda: [
            "http://localhost:5173",
            "http://localhost:3000",
            "http://127.0.0.1:5173",
        ]
    )


settings = Settings()

