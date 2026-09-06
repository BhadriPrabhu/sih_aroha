from typing import Dict, Any

import numpy as np
from scipy.optimize import milp, LinearConstraint, Bounds


def optimize_cargo(
    items,
    cargo_weight_capacity: float,
    cargo_volume_capacity: float | None = None,
) -> Dict[str, Any]:
    """
    Integer cargo optimization.

    Decision:
        x_i = number of units shipped.

    Objective:
        maximize Σ criticality_i * x_i

    Constraints:
        Σ weight_i*x_i <= weight capacity
        Σ volume_i*x_i <= volume capacity (optional)
        0 <= x_i <= min(available_i, required_i)
        x_i integer

    For the MVP, criticality is the per-unit benefit.
    """

    n = len(items)

    upper = np.array(
        [
            min(item["available_quantity"], item["required_quantity"])
            for item in items
        ],
        dtype=float,
    )

    if np.all(upper <= 0):
        return {
            "status": "NO_DEMAND",
            "selected_items": [],
            "total_weight": 0.0,
            "weight_utilization_percent": 0.0,
            "total_volume": 0.0,
            "volume_utilization_percent": None,
            "total_benefit": 0.0,
        }

    # scipy.milp minimizes, so negate benefit to maximize it.
    objective = np.array(
        [-float(item["criticality"]) for item in items],
        dtype=float,
    )

    constraints = []

    weights = np.array(
        [item["unit_weight"] for item in items],
        dtype=float,
    )

    constraints.append(
        LinearConstraint(
            weights.reshape(1, -1),
            lb=-np.inf,
            ub=cargo_weight_capacity,
        )
    )

    if cargo_volume_capacity is not None:
        volumes = np.array(
            [item["unit_volume"] for item in items],
            dtype=float,
        )

        constraints.append(
            LinearConstraint(
                volumes.reshape(1, -1),
                lb=-np.inf,
                ub=cargo_volume_capacity,
            )
        )

    result = milp(
        c=objective,
        integrality=np.ones(n),
        bounds=Bounds(
            lb=np.zeros(n),
            ub=upper,
        ),
        constraints=constraints,
        options={"time_limit": 5.0},
    )

    if not result.success or result.x is None:
        raise RuntimeError(f"Cargo optimizer failed: {result.message}")

    selected = np.rint(result.x).astype(int)

    total_weight = 0.0
    total_volume = 0.0
    total_benefit = 0.0
    selected_items = []

    for item, quantity in zip(items, selected):
        quantity = int(quantity)

        weight_used = quantity * item["unit_weight"]
        volume_used = quantity * item["unit_volume"]
        benefit = quantity * item["criticality"]

        total_weight += weight_used
        total_volume += volume_used
        total_benefit += benefit

        required = item["required_quantity"]
        unfulfilled = max(0, required - quantity)

        selected_items.append({
            "item_id": item["item_id"],
            "selected_quantity": quantity,
            "required_quantity": required,
            "available_quantity": item["available_quantity"],
            "fulfillment_percent": (
                round(100 * quantity / required, 2)
                if required > 0 else 100.0
            ),
            "unfulfilled_quantity": unfulfilled,
            "criticality": round(item["criticality"], 6),
            "weight_used": round(weight_used, 6),
            "volume_used": round(volume_used, 6),
            "benefit": round(benefit, 6),
        })

    weight_utilization = total_weight / cargo_weight_capacity

    volume_utilization = (
        None
        if cargo_volume_capacity is None
        else total_volume / cargo_volume_capacity
    )

    return {
        "status": "OPTIMAL_OR_BEST_FOUND",
        "selected_items": selected_items,
        "total_weight": round(total_weight, 6),
        "weight_capacity": cargo_weight_capacity,
        "weight_utilization_percent": round(
            100 * weight_utilization, 2
        ),
        "total_volume": round(total_volume, 6),
        "volume_capacity": cargo_volume_capacity,
        "volume_utilization_percent": (
            None
            if volume_utilization is None
            else round(100 * volume_utilization, 2)
        ),
        "total_benefit": round(total_benefit, 6),
        "solver": "scipy.optimize.milp",
    }
