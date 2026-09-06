from typing import Dict, Any

from .forecasting import forecast_item
from .criticality import calculate_criticality
from .optimizer import optimize_cargo


def run_forecast_service(request) -> Dict[str, Any]:
    result = forecast_item(
        history=request.historical_demand,
        horizon_days=request.forecast_horizon_days,
        expedition_requirement=request.expedition_requirement,
        expedition_duration_days=request.expedition_duration_days,
        demand_mode=request.demand_mode,
        tune_alpha=request.tune_alpha,
    )

    return {
        "item_id": request.item_id,
        "station_id": request.station_id,
        **result,
    }


def run_criticality_service(request) -> Dict[str, Any]:
    result = calculate_criticality(
        current_stock=request.current_stock,
        forecast_daily_demand=request.forecast_daily_demand,
        essentiality=request.essentiality,
        lead_time_days=request.lead_time_days,
        expedition_requirement=request.expedition_requirement,
        days_until_expedition=request.days_until_expedition,
        expedition_priority=request.expedition_priority,
        forecast_mae=request.forecast_mae,
        urgency_threshold_days=request.urgency_threshold_days,
        reference_lead_time_days=request.reference_lead_time_days,
        reference_error=request.reference_error,
        w_essentiality=request.w_essentiality,
        w_urgency=request.w_urgency,
        w_lead_time=request.w_lead_time,
        w_expedition=request.w_expedition,
        w_uncertainty=request.w_uncertainty,
    )

    return {
        "item_id": request.item_id,
        "station_id": request.station_id,
        **result,
    }


def run_full_pipeline(request) -> Dict[str, Any]:
    forecasts = []
    criticalities = []
    cargo_items = []

    for item in request.items:

        forecast = forecast_item(
            history=item.historical_demand,
            horizon_days=request.forecast_horizon_days,
            expedition_requirement=item.expedition_requirement,
            expedition_duration_days=request.forecast_horizon_days,
        )

        forecasts.append({
            "item_id": item.item_id,
            **forecast,
        })

        criticality = calculate_criticality(
            current_stock=item.current_stock,
            forecast_daily_demand=forecast["forecast_daily_total"],
            essentiality=item.essentiality,
            lead_time_days=item.lead_time_days,
            expedition_requirement=item.expedition_requirement,
            days_until_expedition=item.days_until_expedition,
            expedition_priority=item.expedition_priority,
            forecast_mae=forecast["forecast_mae"],
        )

        criticalities.append({
            "item_id": item.item_id,
            **criticality,
        })

        required_quantity = max(
            0,
            int(
                forecast["total_horizon_demand"]
                - item.current_stock
            ) + (
                1 if
                forecast["total_horizon_demand"] > item.current_stock
                and (
                    forecast["total_horizon_demand"]
                    - item.current_stock
                ) % 1 != 0
                else 0
            ),
        )

        cargo_items.append({
            "item_id": item.item_id,
            "unit_weight": item.unit_weight,
            "unit_volume": item.unit_volume,
            "available_quantity": item.available_quantity,
            "required_quantity": required_quantity,
            "criticality": criticality["criticality_score"],
        })

    optimization = optimize_cargo(
        items=cargo_items,
        cargo_weight_capacity=request.cargo_weight_capacity,
        cargo_volume_capacity=request.cargo_volume_capacity,
    )

    return {
        "station_id": request.station_id,
        "forecasting": forecasts,
        "criticality": criticalities,
        "optimization": optimization,
    }
