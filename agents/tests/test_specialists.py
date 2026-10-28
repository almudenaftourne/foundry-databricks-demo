import os
from pathlib import Path
import runpy
import types
import unittest
from unittest.mock import Mock, patch


AGENTS = Path(__file__).resolve().parents[1]
CONFIG = {
    "FOUNDRY_PROJECT_ENDPOINT": "https://example.invalid/project/",
    "AZURE_AI_MODEL_DEPLOYMENT_NAME": "test-deployment",
}


def module(name: str, **attributes: object) -> types.ModuleType:
    result = types.ModuleType(name)
    for key, value in attributes.items():
        setattr(result, key, value)
    return result


class SpecialistStartupTests(unittest.TestCase):
    def setUp(self) -> None:
        self.credential = Mock(return_value="credential")
        self.client = Mock(return_value="chat-client")
        self.agent = Mock(return_value="agent")
        self.server = Mock()
        self.project = Mock()
        self.project.return_value.get_openai_client.return_value.base_url = (
            "https://example.invalid/openai/"
        )
        self.model = Mock(return_value="chat-model")
        self.create_graph = Mock(return_value="compiled-graph")
        self.modules = {
            "agent_framework": module("agent_framework", Agent=self.agent),
            "agent_framework.foundry": module(
                "agent_framework.foundry", FoundryChatClient=self.client
            ),
            "agent_framework_foundry_hosting": module(
                "agent_framework_foundry_hosting", ResponsesHostServer=self.server
            ),
            "azure": module("azure"),
            "azure.ai": module("azure.ai"),
            "azure.ai.projects": module("azure.ai.projects", AIProjectClient=self.project),
            "azure.identity": module(
                "azure.identity",
                DefaultAzureCredential=self.credential,
                get_bearer_token_provider=Mock(return_value="token-provider"),
            ),
            "dotenv": module("dotenv", load_dotenv=Mock()),
            "langchain": module("langchain"),
            "langchain.agents": module("langchain.agents", create_agent=self.create_graph),
            "langchain_openai": module("langchain_openai", ChatOpenAI=self.model),
        }

    def load(self, specialist: str) -> dict[str, object]:
        with patch.dict("sys.modules", self.modules):
            return runpy.run_path(str(AGENTS / specialist / "main.py"))

    def test_maf_starts_analyst_without_data_tools(self) -> None:
        with patch.dict(os.environ, CONFIG, clear=True):
            entry = self.load("maf")["main"]
            assert callable(entry)
            entry()
        arguments = self.agent.call_args.kwargs
        self.assertIn("delivery-risk analyst", arguments["instructions"])
        self.assertEqual(arguments["default_options"], {"store": False})
        self.assertNotIn("tools", arguments)
        self.server.return_value.run.assert_called_once_with()
        self.assertEqual(self.client.call_args.kwargs["model"], "test-deployment")

    def test_maf_preserves_fallback_model(self) -> None:
        config = {"FOUNDRY_PROJECT_ENDPOINT": CONFIG["FOUNDRY_PROJECT_ENDPOINT"],
                  "FOUNDRY_MODEL_NAME": "fallback"}
        with patch.dict(os.environ, config, clear=True):
            entry = self.load("maf")["main"]
            assert callable(entry)
            entry()
        self.assertEqual(self.client.call_args.kwargs["model"], "fallback")

    def test_maf_missing_model_fails(self) -> None:
        with patch.dict(os.environ, {}, clear=True):
            entry = self.load("maf")["main"]
            assert callable(entry)
            with self.assertRaises(RuntimeError):
                entry()

    def test_maf_missing_endpoint_fails(self) -> None:
        with patch.dict(os.environ, {"FOUNDRY_MODEL_NAME": "model"}, clear=True):
            entry = self.load("maf")["main"]
            assert callable(entry)
            with self.assertRaises(KeyError):
                entry()

    def test_langgraph_exports_planner_without_data_tools(self) -> None:
        with patch.dict(os.environ, CONFIG, clear=True):
            result = self.load("langgraph")
        self.assertEqual(result["graph"], "compiled-graph")
        self.assertEqual(self.create_graph.call_args.kwargs["tools"], [])
        self.assertIn("Proposed next step", self.create_graph.call_args.kwargs["system_prompt"])
        model_arguments = self.model.call_args.kwargs
        self.assertEqual(model_arguments["model"], "test-deployment")
        self.assertTrue(model_arguments["use_responses_api"])
        self.assertEqual(model_arguments["api_key"], "token-provider")
        self.assertEqual(
            self.project.call_args.kwargs["endpoint"], "https://example.invalid/project"
        )

    def test_langgraph_missing_model_fails(self) -> None:
        with patch.dict(os.environ, {}, clear=True), self.assertRaises(RuntimeError):
            self.load("langgraph")

    def test_langgraph_missing_endpoint_fails(self) -> None:
        with patch.dict(os.environ, {"AZURE_AI_MODEL_DEPLOYMENT_NAME": "model"}, clear=True):
            with self.assertRaises(KeyError):
                self.load("langgraph")


if __name__ == "__main__":
    unittest.main()
