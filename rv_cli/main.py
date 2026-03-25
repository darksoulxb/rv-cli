from typing import List
import subprocess as sp
import typer
from rv_cli.storage import load_commands, save_commands

app = typer.Typer(context_settings={"allow_extra_args": True, "ignore_unknown_options": True})

'''ADD NEW COMMANDS/SHORTCUTS'''
# @app.command()
# def add(name: str, command: List[str]):
#     data = load_commands()
#
#     if name in data:
#         typer.echo(f"we already got '{name}' . Use 'update' to change it.")
#         raise typer.Exit()
#
#     data[name] = command
#     save_commands(data)
#     typer.echo(f"data saved:\n{name}")

#
# @app.command()
# def add(name: str, command: List[str], mode: str = typer.Option("seq", help="seq or single")):
#     data = load_commands()
#
#
#     if name in RESERVED:
#         typer.echo(f"'{name}' is a reserved command. choose a different name.")
#         raise typer.Exit()
#
#     if name in data:
#         typer.echo(f"we already got '{name}'. use 'update' to change it.")
#         raise typer.Exit()
#
#     data[name] = {"commands": command, "mode": mode}
#     save_commands(data)
#     typer.echo(f"saved [{name}] as '{mode}' mode")

@app.command()
def add(name: str, command: List[str] = typer.Argument(None)):
    if name in RESERVED:
        typer.echo(f"'{name}' is a reserved command. choose a different name.")
        raise typer.Exit()

    data = load_commands()

    if name in data:
        typer.echo(f"we already got '{name}'. use 'update' to change it.")
        raise typer.Exit()

    # mode = typer.prompt("mode", default="seq", prompt_suffix=" [seq/single]: ")
    mode = typer.prompt("mode [seq/single]", default="seq")
    while mode not in ("seq", "single"):
        typer.echo("invalid. enter 'seq' or 'single'")
        mode = typer.prompt("mode", default="seq", prompt_suffix=" [seq/single]: ")

    cmd = command if command else [name]
    data[name] = {"commands": cmd, "mode": mode}
    save_commands(data)
    typer.echo(f"saved [{name}] as '{mode}' mode")


'''SHOW ALL SAVED COMMANDS'''

@app.command()
def list():
    data = load_commands()

    if not data:
        typer.echo("No commands saved yet.")
        return

    for name, entry in data.items():
        full_command = " ".join(entry['commands'])
        typer.echo(f"[{name}] -> {full_command}")

"""REMOVES A COMMAND"""

@app.command()
def remove(name: str):
    # Prevent removal of reserved commands
    if name in RESERVED:
        typer.echo(f"'{name}' is a reserved command and cannot be removed.")
        raise typer.Exit()

    data = load_commands()

    if name not in data:
        typer.echo(f"the '{name}' isn't listed")
        raise typer.Exit()
    del data[name]
    save_commands(data)
    typer.echo(f'removed "{name}"')

"""REMOVES EVERY COMMAND"""
@app.command()
def nuke():
    confirmed = typer.confirm("sure you wanna delete allat?")

    if confirmed:
        save_commands({})
        typer.echo('nuked it clean')
    else:
        typer.echo("nuke aborted")

"""UPDATES EXISTING COMMANDS"""
@app.command()
def update(name: str, command: List[str], mode: str = typer.Option("seq", help="seq or single")):
    data = load_commands()

    if name in RESERVED:
        typer.echo(f"'{name}' is a reserved command. choose a different name.")
        raise typer.Exit()

    if name not in data:
        typer.echo('nothing to update so saving as usual')
        # FIXED: store as dict with mode
        data[name] = {"commands": command, "mode": mode}
        save_commands(data)
        typer.echo(f"data saved:\n{name}")
    elif name in data:
        del data[name]
        data[name] = {"commands": command, "mode": mode}
        save_commands(data)
        typer.echo(f"saved [{command}] as [{name}] in '{mode}' mode")
        # save_commands(data)
        # typer.echo(f"data updated:\n[{name}] --> [{command}]")

"""RENAME A KEY WITHOUT CHANGING COMMAND"""

@app.command()
def rename(old: str, new: str):
    # Prevent renaming to a reserved command name
    if new in RESERVED:
        typer.echo(f"'{new}' is a reserved command. choose a different name.")
        raise typer.Exit()

    data = load_commands()

    if old not in data:
        typer.echo(f"'{old}' not found.")
        raise typer.Exit()

    if new in data:
        typer.echo(f"'{new}' exists, use 'update' to change that.")
        raise typer.Exit()

    data[new] = data.pop(old)
    save_commands(data)
    typer.echo(f"renamed: [{old}] --> [{new}]")

"""RUNS COMMANDS"""
# @app.command()
# def run(name:str):
#     data = load_commands()
#
#     if name not in data:
#         typer.echo(f"data not found on {name}")
#         raise typer.Exit()
#     command = data[name]
#     for cmd in commands:
#         typer.echo(f"running: {cmd}")
#         sp.run(cmd, shell=True)
#     sp.run(command)

"""RUNS COMMANDS CONSIDERING EXTRA OPTIONS"""

@app.command()
def run(name: str):
    data = load_commands()

    if name not in data:
        typer.echo(f"'{name}' not found.")
        raise typer.Exit()

    entry = data[name]
    commands = entry["commands"]
    mode = entry["mode"]

    if mode == "single":
        cmd = " ".join(commands)
        typer.echo(f"running: {cmd}")
        sp.run(cmd, shell=True)
    else:  # seqal execution
        for cmd in commands:
            typer.echo(f"running: {cmd}")
            sp.run(cmd, shell=True)

"""credits"""
@app.command()
def credits():
    typer.echo("make sure to visit — https://github.com/darksoulxb")

# all commands are registered before this runs
RESERVED = {cmd.name or cmd.callback.__name__ for cmd in app.registered_commands}

"""default run"""
@app.callback(invoke_without_command=True)
def main(ctx: typer.Context):
    if ctx.invoked_subcommand is None:
        if ctx.args:
            run(ctx.args[0])
        else:
            typer.echo(ctx.get_help())


if __name__ == "__main__":
    app()
