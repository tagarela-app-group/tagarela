import json
import sys

command = json.load(sys.stdin).get('tool_input', {}).get('command', '')
if 'gh pr create' in command:
    message = 'PR aberto. Siga a skill entregar até o fim: esteira, merge, mockup se mudou UI, develop, sugerir /compact ou /clear.'
elif 'gh pr merge' in command:
    message = 'PR mergeado. Continue a skill entregar: mockup se mudou UI, git switch develop && git pull && git branch -D <branch>, sugerir /compact ou /clear.'
else:
    sys.exit(0)
print(json.dumps({'hookSpecificOutput': {'hookEventName': 'PostToolUse', 'additionalContext': message}}, ensure_ascii=False))
