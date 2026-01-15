#!/usr/bin/env python3
"""
LangGraph Swarm Coordinator
Manages state for 2-100+ parallel Claude agents using LangGraph StateGraph
Hybrid architecture: Python coordinates, bash executes
"""

import json
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import TypedDict, Optional
from typing_extensions import TypedDict

# LangGraph imports (install: pip install langgraph)
try:
    from langgraph.graph import StateGraph, START, END
    from langgraph.checkpoint.memory import MemorySaver

    LANGGRAPH_AVAILABLE = True
except ImportError:
    LANGGRAPH_AVAILABLE = False
    print(
        "WARNING: LangGraph not installed. Install with: pip install langgraph",
        file=sys.stderr,
    )


# State schema for swarm coordination
class AgentState(TypedDict):
    agent_id: int
    status: str  # pending, spawning, running, completed, failed
    subtask: str
    phase: str
    dependencies: list[int]
    result: Optional[dict]
    worktree_path: Optional[str]
    started_at: Optional[str]
    completed_at: Optional[str]


class SwarmState(TypedDict):
    swarm_id: str
    task: str
    agent_count: int
    agents: list[AgentState]
    status: str  # initializing, running, completed, failed
    started_at: str
    completed_at: Optional[str]
    results: list[dict]


# Initialize checkpoint saver for persistence
memory_saver = MemorySaver() if LANGGRAPH_AVAILABLE else None


class LangGraphSwarmCoordinator:
    """
    Coordinates multi-agent swarms using LangGraph StateGraph

    Features:
    - State management for 2-100+ agents
    - Parallel execution coordination
    - Dependency tracking
    - Checkpointing and recovery
    - Real-time status updates
    """

    def __init__(self, swarm_dir: str = None):
        self.swarm_dir = Path(swarm_dir or os.path.expanduser("~/.claude/swarm"))
        self.swarm_dir.mkdir(parents=True, exist_ok=True)
        self.graph = None
        self.checkpointer = memory_saver

    def create_graph(self, swarm_id: str, agent_count: int):
        """Create StateGraph for swarm coordination"""
        if not LANGGRAPH_AVAILABLE:
            raise ImportError("LangGraph required. Install: pip install langgraph")

        # Initialize graph with SwarmState
        graph = StateGraph(SwarmState)

        # Add nodes for each agent (parallel execution)
        for i in range(1, agent_count + 1):
            node_name = f"agent_{i}"
            graph.add_node(node_name, self._create_agent_node(i))

        # Add initialization node
        graph.add_node("init", self._init_swarm)

        # Add result aggregation node
        graph.add_node("aggregate", self._aggregate_results)

        # Build edges: init → all agents (parallel) → aggregate
        graph.add_edge(START, "init")
        for i in range(1, agent_count + 1):
            graph.add_edge("init", f"agent_{i}")
            graph.add_edge(f"agent_{i}", "aggregate")
        graph.add_edge("aggregate", END)

        # Compile with checkpointer for state persistence
        self.graph = graph.compile(checkpointer=self.checkpointer)

        return self.graph

    def _create_agent_node(self, agent_id: int):
        """Factory function to create agent execution node"""

        def agent_node(state: SwarmState) -> SwarmState:
            """Execute agent and update state"""
            # Find this agent's state
            agent_state = next(
                (a for a in state["agents"] if a["agent_id"] == agent_id), None
            )
            if not agent_state:
                return state

            # Update agent status to running
            agent_state["status"] = "running"
            agent_state["started_at"] = datetime.utcnow().isoformat() + "Z"

            # Bash will handle actual execution - we just coordinate state
            # The agent writes result to worktree/result.json when done

            return state

        return agent_node

    def _init_swarm(self, state: SwarmState) -> SwarmState:
        """Initialize swarm state"""
        state["status"] = "running"
        state["started_at"] = datetime.utcnow().isoformat() + "Z"
        return state

    def _aggregate_results(self, state: SwarmState) -> SwarmState:
        """Aggregate results from all agents"""
        # Collect results from agents
        results = []
        all_completed = True

        for agent in state["agents"]:
            if agent["status"] == "completed" and agent.get("result"):
                results.append(agent["result"])
            elif agent["status"] != "completed":
                all_completed = False

        state["results"] = results
        state["status"] = "completed" if all_completed else "partial"
        state["completed_at"] = datetime.utcnow().isoformat() + "Z"

        return state

    def initialize_swarm(
        self, swarm_id: str, task: str, agent_count: int, agents: list[AgentState]
    ):
        """Initialize swarm with agents"""
        initial_state: SwarmState = {
            "swarm_id": swarm_id,
            "task": task,
            "agent_count": agent_count,
            "agents": agents,
            "status": "initializing",
            "started_at": datetime.utcnow().isoformat() + "Z",
            "completed_at": None,
            "results": [],
        }

        # Create graph
        self.create_graph(swarm_id, agent_count)

        # Save initial state to file
        state_file = self.swarm_dir / swarm_id / "langgraph_state.json"
        state_file.parent.mkdir(parents=True, exist_ok=True)

        with open(state_file, "w") as f:
            json.dump(initial_state, f, indent=2)

        return initial_state

    def update_agent_status(
        self, swarm_id: str, agent_id: int, status: str, result: dict = None
    ):
        """Update agent status in state"""
        state_file = self.swarm_dir / swarm_id / "langgraph_state.json"

        if not state_file.exists():
            raise FileNotFoundError(f"Swarm state not found: {swarm_id}")

        with open(state_file, "r") as f:
            state: SwarmState = json.load(f)

        # Find and update agent
        for agent in state["agents"]:
            if agent["agent_id"] == agent_id:
                agent["status"] = status
                if status == "completed":
                    agent["completed_at"] = datetime.utcnow().isoformat() + "Z"
                    if result:
                        agent["result"] = result
                break

        # Save updated state
        with open(state_file, "w") as f:
            json.dump(state, f, indent=2)

        return state

    def get_state(self, swarm_id: str) -> SwarmState:
        """Get current swarm state"""
        state_file = self.swarm_dir / swarm_id / "langgraph_state.json"

        if not state_file.exists():
            raise FileNotFoundError(f"Swarm state not found: {swarm_id}")

        with open(state_file, "r") as f:
            return json.load(f)

    def get_agent_status(self, swarm_id: str, agent_id: int) -> AgentState:
        """Get agent status"""
        state = self.get_state(swarm_id)
        agent = next((a for a in state["agents"] if a["agent_id"] == agent_id), None)
        if not agent:
            raise ValueError(f"Agent {agent_id} not found in swarm {swarm_id}")
        return agent

    def visualize_graph(self, swarm_id: str, output_file: str = None):
        """Generate graph visualization (requires graphviz)"""
        if not self.graph:
            state = self.get_state(swarm_id)
            self.create_graph(swarm_id, state["agent_count"])

        try:
            import graphviz

            dot = self.graph.get_graph()
            if output_file:
                dot.render(output_file, format="png", cleanup=True)
            return dot
        except ImportError:
            print(
                "WARNING: graphviz not installed. Install with: pip install graphviz",
                file=sys.stderr,
            )
            return None


# CLI interface
def main():
    """CLI for LangGraph swarm coordinator"""
    if len(sys.argv) < 2:
        print("""
LangGraph Swarm Coordinator - Python state management for multi-agent swarms

Usage:
  langgraph-coordinator.py init <swarm_id> <task> <agent_count> <agents_json>
  langgraph-coordinator.py update <swarm_id> <agent_id> <status> [result_json]
  langgraph-coordinator.py status <swarm_id> [agent_id]
  langgraph-coordinator.py visualize <swarm_id> [output_file]
  langgraph-coordinator.py check-deps

Examples:
  # Initialize swarm
  langgraph-coordinator.py init swarm_123 "Task" 5 '[{...}]'

  # Update agent status
  langgraph-coordinator.py update swarm_123 1 completed '{"result": "done"}'

  # Get status
  langgraph-coordinator.py status swarm_123
  langgraph-coordinator.py status swarm_123 1

  # Visualize graph
  langgraph-coordinator.py visualize swarm_123 graph.png
""")
        sys.exit(1)

    command = sys.argv[1]
    coordinator = LangGraphSwarmCoordinator()

    try:
        if command == "check-deps":
            print(
                json.dumps(
                    {
                        "langgraph_available": LANGGRAPH_AVAILABLE,
                        "python_version": f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}",
                    }
                )
            )

        elif command == "init":
            swarm_id = sys.argv[2]
            task = sys.argv[3]
            agent_count = int(sys.argv[4])
            agents = json.loads(sys.argv[5])

            state = coordinator.initialize_swarm(swarm_id, task, agent_count, agents)
            print(json.dumps(state, indent=2))

        elif command == "update":
            swarm_id = sys.argv[2]
            agent_id = int(sys.argv[3])
            status = sys.argv[4]
            result = json.loads(sys.argv[5]) if len(sys.argv) > 5 else None

            state = coordinator.update_agent_status(swarm_id, agent_id, status, result)
            print(json.dumps(state, indent=2))

        elif command == "status":
            swarm_id = sys.argv[2]
            if len(sys.argv) > 3:
                agent_id = int(sys.argv[3])
                agent = coordinator.get_agent_status(swarm_id, agent_id)
                print(json.dumps(agent, indent=2))
            else:
                state = coordinator.get_state(swarm_id)
                print(json.dumps(state, indent=2))

        elif command == "visualize":
            swarm_id = sys.argv[2]
            output_file = sys.argv[3] if len(sys.argv) > 3 else None
            dot = coordinator.visualize_graph(swarm_id, output_file)
            if dot:
                print(f"Graph visualization saved to {output_file}")
            else:
                print("Graph visualization not available (graphviz required)")

        else:
            print(f"Unknown command: {command}", file=sys.stderr)
            sys.exit(1)

    except Exception as e:
        print(json.dumps({"error": str(e)}), file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
