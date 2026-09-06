import math
from typing import List, Dict, Any

import numpy as np


def zero_ratio(history: List[float]) -> float:
    x = np.asarray(history, dtype=float)
    return float(np.mean(x <= 0))


def classify_demand(history: List[float]) -> str:
    """MVP demand classifier. Tune the threshold with real data later."""
    return "intermittent" if zero_ratio(history) >= 0.40 else "regular"


def ses_forecast(history: List[float], alpha: float) -> float:
    """Simple Exponential Smoothing."""
    x = np.asarray(history, dtype=float)

    if np.any(x < 0):
        raise ValueError("Demand cannot be negative.")

    level = float(x[0])

    for actual in x[1:]:
        level = alpha * float(actual) + (1.0 - alpha) * level

    return max(0.0, level)


def ses_mae(history: List[float], alpha: float) -> float:
    """Historical one-step MAE used for alpha tuning."""
    x = np.asarray(history, dtype=float)

    if len(x) < 3:
        return float("inf")

    level = float(x[0])
    errors = []

    for actual in x[1:]:
        errors.append(abs(float(actual) - level))
        level = alpha * float(actual) + (1.0 - alpha) * level

    return float(np.mean(errors))


def tune_ses_alpha(history: List[float]) -> tuple[float, float]:
    """Small offline grid search for alpha."""
    best_alpha = 0.30
    best_mae = float("inf")

    for alpha in np.arange(0.05, 1.00, 0.05):
        mae = ses_mae(history, float(alpha))

        if mae < best_mae:
            best_alpha = float(alpha)
            best_mae = float(mae)

    return best_alpha, best_mae


def sba_forecast(history: List[float], alpha: float = 0.10) -> float:
    """
    Syntetos-Boylan Approximation for intermittent demand.

    Forecast ≈ (1 - alpha/2) * z_hat / p_hat
    """
    x = np.asarray(history, dtype=float)

    if np.any(x < 0):
        raise ValueError("Demand cannot be negative.")

    nonzero_positions = np.where(x > 0)[0]

    if len(nonzero_positions) == 0:
        return 0.0

    z_hat = float(x[nonzero_positions[0]])
    p_hat = float(nonzero_positions[0] + 1)
    last_position = int(nonzero_positions[0])

    for position in nonzero_positions[1:]:
        demand = float(x[position])
        interval = float(position - last_position)

        z_hat += alpha * (demand - z_hat)
        p_hat += alpha * (interval - p_hat)

        last_position = int(position)

    return max(
        0.0,
        (1.0 - alpha / 2.0) * z_hat / max(p_hat, 1e-9)
    )


def historical_mae(history: List[float], method: str, alpha: float) -> float:
    """Rolling historical MAE for the selected forecasting method."""
    x = list(map(float, history))

    if len(x) < 4:
        return 0.0

    errors = []

    for i in range(3, len(x)):
        train = x[:i]
        actual = x[i]

        if method == "SES":
            prediction = ses_forecast(train, alpha)
        else:
            prediction = sba_forecast(train, alpha)

        errors.append(abs(actual - prediction))

    return float(np.mean(errors)) if errors else 0.0


def forecast_item(
    history: List[float],
    horizon_days: int,
    expedition_requirement: float = 0.0,
    expedition_duration_days: int | None = None,
    demand_mode: str = "auto",
    tune_alpha: bool = True,
) -> Dict[str, Any]:

    if any(value < 0 for value in history):
        raise ValueError("Historical demand cannot be negative.")

    detected_mode = classify_demand(history)
    mode = detected_mode if demand_mode == "auto" else demand_mode

    if mode == "regular":
        if tune_alpha:
            alpha, tuning_mae = tune_ses_alpha(history)
        else:
            alpha = 0.30
            tuning_mae = ses_mae(history, alpha)

        baseline_daily = ses_forecast(history, alpha)
        model = "SES"
        mae = historical_mae(history, "SES", alpha)

    else:
        alpha = 0.10
        tuning_mae = None

        baseline_daily = sba_forecast(history, alpha)
        model = "SBA"
        mae = historical_mae(history, "SBA", alpha)

    baseline_horizon = baseline_daily * horizon_days

    if expedition_requirement > 0:
        duration = expedition_duration_days or horizon_days
        duration = min(duration, horizon_days)

        expedition_daily = expedition_requirement / duration
        expedition_horizon = expedition_requirement
    else:
        expedition_daily = 0.0
        expedition_horizon = 0.0

    total_horizon = baseline_horizon + expedition_horizon
    total_daily = total_horizon / horizon_days

    return {
        "model": model,
        "demand_class": mode,
        "detected_demand_class": detected_mode,
        "alpha": round(alpha, 6),
        "forecast_daily_baseline": round(baseline_daily, 6),
        "forecast_daily_expedition_component": round(expedition_daily, 6),
        "forecast_daily_total": round(total_daily, 6),
        "baseline_horizon_demand": round(baseline_horizon, 6),
        "expedition_horizon_demand": round(expedition_horizon, 6),
        "total_horizon_demand": round(total_horizon, 6),
        "forecast_mae": round(mae, 6),
        "alpha_tuning_mae": (
            None if tuning_mae is None else round(tuning_mae, 6)
        ),
        "horizon_days": horizon_days,
    }
