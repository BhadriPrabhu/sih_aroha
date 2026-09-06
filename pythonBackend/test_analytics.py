from .forecasting import forecast_item
from .criticality import calculate_criticality
from .optimizer import optimize_cargo


def test_forecast():
    result = forecast_item(
        history=[10, 12, 11, 13, 12, 14],
        horizon_days=10,
    )
    assert result["forecast_daily_total"] >= 0


def test_criticality():
    result = calculate_criticality(
        current_stock=20,
        forecast_daily_demand=10,
        essentiality=1.0,
        lead_time_days=20,
        forecast_mae=2,
    )
    assert 0 <= result["criticality_score"] <= 1


def test_optimizer():
    items = [
        {
            "item_id": "MED",
            "unit_weight": 10,
            "unit_volume": 1,
            "available_quantity": 10,
            "required_quantity": 10,
            "criticality": 1.0,
        },
        {
            "item_id": "FOOD",
            "unit_weight": 20,
            "unit_volume": 2,
            "available_quantity": 10,
            "required_quantity": 10,
            "criticality": 0.5,
        },
    ]

    result = optimize_cargo(
        items=items,
        cargo_weight_capacity=50,
    )

    assert result["total_weight"] <= 50
