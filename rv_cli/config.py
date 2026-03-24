from platformdirs import user_data_dir
from pathlib import Path

DATA_DIR= Path(user_data_dir("rv"))
DATA_DIR.mkdir(parents=True,exist_ok=True)
commands_file = DATA_DIR/"commands.json"


