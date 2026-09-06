from typing import List, Literal, Optional
from pydantic import BaseModel, Field


class ForecastRequest(BaseModel):
    item_id: str
    station_id: str
    historical_demand: List[float] = Field(min_length=3)
    forecast_horizon_days: int = Field(default=15, ge=1, le=365)
    expedition_requirement: float = Field(default=0.0, ge=0.0)
    expedition_duration_days: Optional[int] = Field(default=None, ge=1)
    demand_mode: Literal["auto", "regular", "intermittent"] = "auto"
    tune_alpha: bool = True


class CriticalityRequest(BaseModel):
    item_id: str
    station_id: str
    current_stock: float = Field(ge=0.0)
    forecast_daily_demand: float = Field(ge=0.0)
    essentiality: float = Field(ge=0.0, le=1.0)
    lead_time_days: float = Field(ge=0.0)
    expedition_requirement: float = Field(default=0.0, ge=0.0)
    days_until_expedition: Optional[float] = Field(default=None, ge=0.0)
    expedition_priority: float = Field(default=0.0, ge=0.0, le=1.0)
    forecast_mae: float = Field(default=0.0, ge=0.0)

    urgency_threshold_days: float = Field(default=10.0, gt=0.0)
    reference_lead_time_days: float = Field(default=30.0, gt=0.0)
    reference_error: float = Field(default=10.0, gt=0.0)

    w_essentiality: float = 0.35
    w_urgency: float = 0.30
    w_lead_time: float = 0.15
    w_expedition: float = 0.10
    w_uncertainty: float = 0.10


class CargoItem(BaseModel):
    item_id: str
    unit_weight: float = Field(gt=0.0)
    unit_volume: float = Field(default=0.0, ge=0.0)
    available_quantity: int = Field(ge=0)
    required_quantity: int = Field(ge=0)
    criticality: float = Field(ge=0.0)


class OptimizeRequest(BaseModel):
    shipment_id: str
    origin_station: str
    destination_station: str
    cargo_weight_capacity: float = Field(gt=0.0)
    cargo_volume_capacity: Optional[float] = Field(default=None, gt=0.0)
    items: List[CargoItem] = Field(min_length=1)


class PipelineItem(BaseModel):
    item_id: str
    historical_demand: List[float] = Field(min_length=3)
    current_stock: float = Field(ge=0.0)
    essentiality: float = Field(ge=0.0, le=1.0)
    lead_time_days: float = Field(ge=0.0)
    expedition_requirement: float = Field(default=0.0, ge=0.0)
    days_until_expedition: Optional[float] = Field(default=None, ge=0.0)
    expedition_priority: float = Field(default=0.0, ge=0.0, le=1.0)
    unit_weight: float = Field(gt=0.0)
    unit_volume: float = Field(default=0.0, ge=0.0)
    available_quantity: int = Field(ge=0)


class PipelineRequest(BaseModel):
    station_id: str
    forecast_horizon_days: int = Field(default=15, ge=1, le=365)
    cargo_weight_capacity: float = Field(gt=0.0)
    cargo_volume_capacity: Optional[float] = Field(default=None, gt=0.0)
    items: List[PipelineItem] = Field(min_length=1)
