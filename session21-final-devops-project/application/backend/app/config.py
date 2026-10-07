from pydantic_settings import BaseSettings, SettingsConfigDict
from sqlalchemy import URL

class Settings(BaseSettings):
    app_name: str = "Campus Helpdesk API"
    database_url: str = ""
    postgres_host: str = "localhost"
    postgres_db: str = "helpdesk"
    postgres_user: str = "helpdesk"
    postgres_password: str = ""
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    def connection_url(self):
        if self.database_url:
            return self.database_url
        return URL.create("postgresql+psycopg", username=self.postgres_user,
                          password=self.postgres_password, host=self.postgres_host,
                          port=5432, database=self.postgres_db).render_as_string(hide_password=False)

settings = Settings()
