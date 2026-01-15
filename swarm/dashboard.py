#!/usr/bin/env python3
"""
Swarm Dashboard - Real-time agent coordination visualization
Lightweight Flask app for monitoring 2-100+ parallel agents
"""

import json
import os
from pathlib import Path
from datetime import datetime

# Flask imports (install: pip install flask)
try:
    from flask import Flask, render_template_string, jsonify

    FLASK_AVAILABLE = True
except ImportError:
    FLASK_AVAILABLE = False
    print("WARNING: Flask not installed. Install with: pip install flask")
    import sys

    sys.exit(1)

app = Flask(__name__)
SWARM_DIR = Path(os.path.expanduser("~/.claude/swarm"))

# Minimal HTML template with live updates
HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>Swarm Dashboard</title>
    <style>
        body {
            font-family: 'Monaco', 'Courier New', monospace;
            background: #0a0a0a;
            color: #00ff00;
            padding: 20px;
            margin: 0;
        }
        .header {
            text-align: center;
            border-bottom: 2px solid #00ff00;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .header h1 {
            margin: 0;
            font-size: 2em;
            text-transform: uppercase;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: #1a1a1a;
            border: 1px solid #00ff00;
            padding: 15px;
            border-radius: 5px;
        }
        .stat-card h3 {
            margin: 0 0 10px 0;
            font-size: 0.9em;
            color: #00aa00;
        }
        .stat-value {
            font-size: 2em;
            font-weight: bold;
        }
        .agents-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 10px;
            margin-bottom: 30px;
        }
        .agent-card {
            background: #1a1a1a;
            border: 2px solid;
            padding: 10px;
            border-radius: 5px;
            text-align: center;
            transition: all 0.3s ease;
        }
        .agent-card.pending {
            border-color: #666;
            color: #888;
        }
        .agent-card.running {
            border-color: #ff8800;
            color: #ff8800;
            animation: pulse 2s infinite;
        }
        .agent-card.completed {
            border-color: #00ff00;
            color: #00ff00;
        }
        .agent-card.failed {
            border-color: #ff0000;
            color: #ff0000;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        .agent-id {
            font-size: 1.5em;
            font-weight: bold;
            margin-bottom: 5px;
        }
        .agent-status {
            font-size: 0.8em;
            text-transform: uppercase;
        }
        .agent-task {
            font-size: 0.7em;
            color: #00aa00;
            margin-top: 5px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .timeline {
            background: #1a1a1a;
            border: 1px solid #00ff00;
            padding: 20px;
            border-radius: 5px;
            max-height: 400px;
            overflow-y: auto;
        }
        .timeline-item {
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 1px solid #333;
        }
        .timeline-time {
            color: #00aa00;
            font-size: 0.8em;
        }
        .error {
            color: #ff0000;
            text-align: center;
            padding: 40px;
        }
        .refresh-indicator {
            position: fixed;
            top: 20px;
            right: 20px;
            background: #1a1a1a;
            border: 1px solid #00ff00;
            padding: 10px 20px;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🤖 Multi-Agent Swarm Dashboard</h1>
        <p>Real-time coordination for 2-100+ parallel Claude agents</p>
    </div>

    <div class="refresh-indicator">
        Auto-refresh: <span id="countdown">5</span>s
    </div>

    <div id="dashboard"></div>

    <script>
        let refreshInterval;
        let countdownInterval;
        let countdown = 5;

        function loadDashboard() {
            fetch('/api/status')
                .then(response => response.json())
                .then(data => {
                    if (data.error) {
                        document.getElementById('dashboard').innerHTML =
                            '<div class="error">' + data.error + '</div>';
                        return;
                    }
                    renderDashboard(data);
                })
                .catch(error => {
                    document.getElementById('dashboard').innerHTML =
                        '<div class="error">Failed to load swarm data</div>';
                });
        }

        function renderDashboard(data) {
            const pending = data.agents.filter(a => a.status === 'pending').length;
            const running = data.agents.filter(a => a.status === 'running').length;
            const completed = data.agents.filter(a => a.status === 'completed').length;
            const failed = data.agents.filter(a => a.status === 'failed').length;

            const html = `
                <div class="stats">
                    <div class="stat-card">
                        <h3>Total Agents</h3>
                        <div class="stat-value">${data.agent_count}</div>
                    </div>
                    <div class="stat-card">
                        <h3>Pending</h3>
                        <div class="stat-value" style="color: #888">${pending}</div>
                    </div>
                    <div class="stat-card">
                        <h3>Running</h3>
                        <div class="stat-value" style="color: #ff8800">${running}</div>
                    </div>
                    <div class="stat-card">
                        <h3>Completed</h3>
                        <div class="stat-value" style="color: #00ff00">${completed}</div>
                    </div>
                    <div class="stat-card">
                        <h3>Failed</h3>
                        <div class="stat-value" style="color: #ff0000">${failed}</div>
                    </div>
                    <div class="stat-card">
                        <h3>Progress</h3>
                        <div class="stat-value">${Math.round((completed / data.agent_count) * 100)}%</div>
                    </div>
                </div>

                <h2 style="margin-bottom: 20px;">Task: ${data.task}</h2>

                <div class="agents-grid">
                    ${data.agents.map(agent => `
                        <div class="agent-card ${agent.status}">
                            <div class="agent-id">Agent ${agent.agent_id}</div>
                            <div class="agent-status">${agent.status}</div>
                            <div class="agent-task" title="${agent.subtask}">${agent.subtask}</div>
                        </div>
                    `).join('')}
                </div>

                <h2 style="margin-bottom: 20px;">Timeline</h2>
                <div class="timeline" id="timeline">
                    ${renderTimeline(data)}
                </div>
            `;

            document.getElementById('dashboard').innerHTML = html;
        }

        function renderTimeline(data) {
            const events = [];

            // Swarm started
            events.push({
                time: data.started_at,
                message: `Swarm ${data.swarm_id} initialized with ${data.agent_count} agents`
            });

            // Agent events
            data.agents.forEach(agent => {
                if (agent.started_at) {
                    events.push({
                        time: agent.started_at,
                        message: `Agent ${agent.agent_id} started: ${agent.subtask}`
                    });
                }
                if (agent.completed_at) {
                    events.push({
                        time: agent.completed_at,
                        message: `Agent ${agent.agent_id} completed`
                    });
                }
            });

            // Sort by time descending
            events.sort((a, b) => new Date(b.time) - new Date(a.time));

            return events.slice(0, 20).map(event => `
                <div class="timeline-item">
                    <div class="timeline-time">${new Date(event.time).toLocaleString()}</div>
                    <div>${event.message}</div>
                </div>
            `).join('');
        }

        function startRefresh() {
            countdown = 5;
            document.getElementById('countdown').textContent = countdown;

            countdownInterval = setInterval(() => {
                countdown--;
                document.getElementById('countdown').textContent = countdown;
                if (countdown === 0) {
                    countdown = 5;
                    loadDashboard();
                }
            }, 1000);
        }

        // Initial load
        loadDashboard();
        startRefresh();
    </script>
</body>
</html>
"""


@app.route("/")
def index():
    """Main dashboard view"""
    return render_template_string(HTML_TEMPLATE)


@app.route("/api/status")
def api_status():
    """Get current swarm status"""
    try:
        # Find most recent swarm state
        swarm_dirs = sorted(
            SWARM_DIR.glob("swarm_*"), key=os.path.getmtime, reverse=True
        )

        if not swarm_dirs:
            return jsonify({"error": "No active swarms found"})

        swarm_dir = swarm_dirs[0]
        swarm_id = swarm_dir.name

        # Try LangGraph state first
        langgraph_state = swarm_dir / "langgraph_state.json"
        if langgraph_state.exists():
            with open(langgraph_state, "r") as f:
                return jsonify(json.load(f))

        # Fallback to bash state
        bash_state = SWARM_DIR / "swarm-state.json"
        if bash_state.exists():
            with open(bash_state, "r") as f:
                data = json.load(f)
                # Convert bash format to dashboard format
                return jsonify(
                    {
                        "swarm_id": data.get("swarmId", swarm_id),
                        "task": data.get("task", "Unknown task"),
                        "agent_count": data.get("agentCount", 0),
                        "status": data.get("status", "unknown"),
                        "started_at": data.get(
                            "startedAt", datetime.utcnow().isoformat() + "Z"
                        ),
                        "agents": [
                            {
                                "agent_id": a.get("agentId", i + 1),
                                "status": a.get("status", "pending"),
                                "subtask": f"Agent {i + 1} task",
                                "started_at": None,
                                "completed_at": None,
                            }
                            for i, a in enumerate(data.get("agents", []))
                        ],
                    }
                )

        return jsonify({"error": f"No state file found for {swarm_id}"})

    except Exception as e:
        return jsonify({"error": str(e)})


if __name__ == "__main__":
    print("""
╔═══════════════════════════════════════════════════════════════╗
║            Multi-Agent Swarm Dashboard                        ║
║                                                               ║
║  Dashboard: http://localhost:5000                             ║
║  API:       http://localhost:5000/api/status                  ║
║                                                               ║
║  Auto-refresh: 5 seconds                                      ║
║  Real-time agent status updates                               ║
╚═══════════════════════════════════════════════════════════════╝
""")
    app.run(host="0.0.0.0", port=5000, debug=True)
