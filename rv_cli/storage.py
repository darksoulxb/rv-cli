import json
from rv.config import commands_file

"""LOAD COMMANDS"""

def load_commands():
    if commands_file.exists():
        with open(commands_file)as f:
            return json.load(f)
    return {}

"""SAVES CHANGES MADE"""

def save_commands(commands):
    temp = commands_file.with_suffix(".tmp")
    with open(temp,"w") as f:
        json.dump(commands,f,indent=2)
    temp.replace(commands_file)
