import math
from typing import Dict, Any

import numpy as np


def _validate_weights(weights: list[float]) -> None:
    if any(w < 0 for w in weights):
        raise ValueError("Criticality weights cannot be negative.")

    if not math.isclose(sum(weights), 1.0, abs_tol=1e-6):
        raise ValueError("Criticality weights must sum to 1.0.")


def urgency_score(days_of_supply: float, threshold_days: float) -> float:
    """
    U = max(0, (T - DOS) / T)
    Bounded to [0, 1].
    """
    if math.isinf(days_of_supply):
        return 0.0

    return float(
        np.clip(
            (threshold_days - days_of_supply) / threshold_days,
            0.0,
            1.0,
        )
    )


def lead_time_score(lead_time_days: float, reference_days: float) -> float:
    return float(
        np.clip(
            lead_time_days / reference_days,
            0.0,
            1.0,
        )
    )


def expedition_impact_score(
    requirement: float,
    days_until_expedition: float | None,
    priority: float,
) -> float:

    if requirement <= 0:
        return 0.0

    if days_until_expedition is None:
        proximity = 0.5
    elif days_until_expedition <= 0:
        proximity = 1.0
    else:
        proximity = 1.0 / (1.0 + days_until_expedition / 10.0)

    return float(
        np.clip(
            0.5 * proximity + 0.5 * priority,
            0.0,
            1.0,
        )
    )


def uncertainty_score(mae: float, reference_error: float) -> float:
    return float(
        np.clip(
            mae / reference_error,
            0.0,
            1.0,
        )
    )


def calculate_criticality(
    current_stock: float,
    forecast_daily_demand: float,
    essentiality: float,
    lead_time_days: float,
    expedition_requirement: float = 0.0,
    days_until_expedition: float | None = None,
    expedition_priority: float = 0.0,
    forecast_mae: float = 0.0,
    urgency_threshold_days: float = 10.0,
    reference_lead_time_days: float = 30.0,
    reference_error: float = 10.0,
    w_essentiality: float = 0.35,
    w_urgency: float = 0.30,
    w_lead_time: float = 0.15,
    w_expedition: float = 0.10,
    w_uncertainty: float = 0.10,
) -> Dict[str, Any]:

    weights = [
        w_essentiality,
        w_urgency,
        w_lead_time,
        w_expedition,
        w_uncertainty,
    ]
    _validate_weights(weights)

    if forecast_daily_demand > 0:
        dos = current_stock / forecast_daily_demand
    else:
        dos = math.inf

    E = essentiality
    U = urgency_score(dos, urgency_threshold_days)
    L = lead_time_score(lead_time_days, reference_lead_time_days)
    X = expedition_impact_score(
        expedition_requirement,
        days_until_expedition,
        expedition_priority,
    )
    R = uncertainty_score(forecast_mae, reference_error)

    criticality = (
        w_essentiality * E
        + w_urgency * U
        + w_lead_time * L
        + w_expedition * X
        + w_uncertainty * R
    )

    if criticality >= 0.80:
        category = "CRITICAL"
    elif criticality >= 0.60:
        category = "HIGH"
    elif criticality >= 0.35:
        category = "MEDIUM"
    else:
        category = "LOW"

    return {
        "days_of_supply": (
            None if math.isinf(dos) else round(dos, 6)
        ),
        "essentiality_score": round(E, 6),
        "urgency_score": round(U, 6),
        "lead_time_score": round(L, 6),
        "expedition_impact_score": round(X, 6),
        "forecast_uncertainty_score": round(R, 6),
        "criticality_score": round(float(criticality), 6),
        "risk_category": category,
    }
