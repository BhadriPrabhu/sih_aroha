# AROHA Analytics Service

## Structure

```text
aroha_analytics/
├── main.py          # FastAPI routes
├── schemas.py       # API input schemas
├── service.py       # Connects the three modules
├── forecasting.py   # SES + SBA forecasting
├── criticality.py   # Multi-factor criticality
├── optimizer.py     # Integer cargo optimization
├── requirements.txt
└── README.md
```

## Install

```bash
pip install -r requirements.txt
```

## Run

From the directory containing `aroha_analytics/`:

```bash
uvicorn aroha_analytics.main:app --reload
```

Swagger UI:

```text
http://127.0.0.1:8000/docs
```

## Endpoints

```text
GET  /health
POST /forecast
POST /criticality
POST /optimize
POST /pipeline
```

## Responsibility

```text
forecasting.py
    historical demand
        ↓
    forecast + MAE

criticality.py
    stock + forecast + domain risk factors
        ↓
    criticality score

optimizer.py
    criticality + requirements + physical constraints
        ↓
    cargo allocation

service.py
    connects the modules

main.py
    exposes them through FastAPI
```

The database and UI should remain outside this service.
