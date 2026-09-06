from fastapi import FastAPI

from .schemas import (
    ForecastRequest,
    CriticalityRequest,
    OptimizeRequest,
    PipelineRequest,
)
from .service import (
    run_forecast_service,
    run_criticality_service,
    run_full_pipeline,
)
from .optimizer import optimize_cargo


app = FastAPI(
    title="AROHA Analytics Service",
    version="1.0.0",
    description=(
        "Forecasting, inventory criticality and cargo optimization "
        "for the AROHA polar logistics system."
    ),
)


@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": "AROHA Analytics",
        "modules": [
            "forecasting",
            "criticality",
            "cargo_optimization",
        ],
    }


@app.post("/forecast")
def forecast(request: ForecastRequest):
    return run_forecast_service(request)


@app.post("/criticality")
def criticality(request: CriticalityRequest):
    return run_criticality_service(request)


@app.post("/optimize")
def optimize(request: OptimizeRequest):
    items = [item.model_dump() for item in request.items]

    return optimize_cargo(
        items=items,
        cargo_weight_capacity=request.cargo_weight_capacity,
        cargo_volume_capacity=request.cargo_volume_capacity,
    )


@app.post("/pipeline")
def pipeline(request: PipelineRequest):
    return run_full_pipeline(request)
