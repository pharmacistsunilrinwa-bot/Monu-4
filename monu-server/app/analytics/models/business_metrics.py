from dataclasses import dataclass


@dataclass
class BusinessMetrics:
    total_revenue: float
    total_clients: int
    total_projects: int
    average_revenue_per_client: float
    average_revenue_per_project: float
