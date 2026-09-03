from app.actions import ActionService
from app.analytics import AnalyticsService
from app.approvals import ApprovalService
from app.clients import ClientService
from app.decisions import DecisionService
from app.execution import ExecutionService
from app.goals import GoalService
from app.income import IncomeService
from app.integrations import IntegrationService
from app.leads import LeadService
from app.projects import ProjectService
from app.proposals import ProposalService
from app.research import ResearchService
from app.revenue import RevenueService
from app.strategy import StrategyService
from app.system_health import SystemHealthService


class MonuSystem:
    def __init__(self) -> None:
        self.research = ResearchService()
        self.income = IncomeService()
        self.proposals = ProposalService()
        self.leads = LeadService()
        self.projects = ProjectService()
        self.clients = ClientService()
        self.revenue = RevenueService()

        self.analytics = AnalyticsService()
        self.strategy = StrategyService()
        self.goals = GoalService()
        self.decisions = DecisionService()

        self.actions = ActionService()
        self.approvals = ApprovalService()
        self.execution = ExecutionService()

        self.integrations = IntegrationService()
        self.system_health = (
            SystemHealthService()
        )

    def services(self) -> dict[str, object]:
        return {
            "research": self.research,
            "income": self.income,
            "proposals": self.proposals,
            "leads": self.leads,
            "projects": self.projects,
            "clients": self.clients,
            "revenue": self.revenue,
            "analytics": self.analytics,
            "strategy": self.strategy,
            "goals": self.goals,
            "decisions": self.decisions,
            "actions": self.actions,
            "approvals": self.approvals,
            "execution": self.execution,
            "integrations": self.integrations,
            "system_health": (
                self.system_health
            ),
        }

    def service_count(self) -> int:
        return len(self.services())

    def health(self):
        components = {
            name: service is not None
            for name, service
            in self.services().items()
        }

        return self.system_health.check(
            components
        )
