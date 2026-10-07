from datetime import datetime
from typing import Literal
from pydantic import BaseModel, ConfigDict, Field, model_validator

Status = Literal["OPEN", "IN_PROGRESS", "RESOLVED"]
Priority = Literal["LOW", "MEDIUM", "HIGH"]
Category = Literal["NETWORK", "HARDWARE", "SOFTWARE", "ACCOUNT", "OTHER"]

class TicketCreate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True, extra="forbid")
    title: str = Field(min_length=1, max_length=200)
    description: str = Field(default="", max_length=4000)
    priority: Priority = "MEDIUM"
    status: Status = "OPEN"
    category: Category = "OTHER"
    requester: str = Field(default="Anonymous", min_length=1, max_length=120)
    assignee: str = Field(default="Unassigned", min_length=1, max_length=120)

class TicketUpdate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True, extra="forbid")
    title: str | None = Field(default=None, min_length=1, max_length=200)
    description: str | None = Field(default=None, max_length=4000)
    priority: Priority | None = None
    status: Status | None = None
    category: Category | None = None
    requester: str | None = Field(default=None, min_length=1, max_length=120)
    assignee: str | None = Field(default=None, min_length=1, max_length=120)

    @model_validator(mode="before")
    @classmethod
    def reject_explicit_null(cls, values):
        if isinstance(values, dict) and any(value is None for value in values.values()):
            raise ValueError("Ticket fields cannot be null")
        return values

class TicketOut(TicketCreate):
    id: int
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)

class StatsOut(BaseModel):
    total: int
    open: int
    inProgress: int
    resolved: int
