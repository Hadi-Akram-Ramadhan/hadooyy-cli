#!/usr/bin/env python3
"""Copy portable assets. Agents handle login, dependencies, MCP and plugins separately."""
import argparse
import json
import os
from pathlib import Path
import shutil
import tempfile
import time

REPO = Path(__file__).resolve().parent
IGNORE = shutil.ignore_patterns('.git', '.in_use', '__pycache__', '*.pyc', 'node_modules')


def skill_dirs(root):
    paths = sorted(p.parent for p in (root / 'skills').rglob('SKILL.md'))
    names = [p.name.casefold() for p in paths]
    if len(names) != len(set(names)):
        raise ValueError('Duplicate skill folder names: resolve before flattening')
    return paths


def backup(path):
    if path.exists():
        target = path.with_name(path.name + '.bak-' + str(time.time_ns()))
        shutil.copy2(path, target)
        return target


def write_text(path, text):
    if path.is_symlink():
        raise ValueError('Refusing symlink: ' + str(path))
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists() and path.read_text(encoding='utf-8-sig') == text:
        return
    backup(path)
    fd, temporary = tempfile.mkstemp(dir=path.parent, prefix='.hadooyy-')
    try:
        with os.fdopen(fd, 'w', encoding='utf-8', newline='\n') as stream:
            stream.write(text)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def read_json(path):
    data = json.loads(path.read_text(encoding='utf-8-sig')) if path.exists() else {}
    if not isinstance(data, dict):
        raise ValueError('Expected JSON object: ' + str(path))
    return data


def merge_json(path, defaults):
    def merge(existing, incoming):
        for key, value in incoming.items():
            if key not in existing:
                existing[key] = value
            elif isinstance(existing[key], dict) and isinstance(value, dict):
                merge(existing[key], value)
        return existing
    data = merge(read_json(path), defaults)
    write_text(path, json.dumps(data, indent=2, ensure_ascii=False) + '\n')


def copy_tree(source, destination):
    source, destination = source.resolve(), destination.absolute()
    if destination.resolve() == source or source in destination.resolve().parents:
        raise ValueError('Source and destination overlap')
    for parent in (destination, *destination.parents):
        if parent.is_symlink():
            raise ValueError('Refusing symlink destination: ' + str(parent))
    for item in source.rglob('*'):
        relative = item.relative_to(source)
        if IGNORE(str(item.parent), [item.name]) or any(part in {'.git', '.in_use', '__pycache__', 'node_modules'} for part in relative.parts):
            continue
        if item.is_symlink():
            raise ValueError('Refusing bundled symlink: ' + str(item))
        if item.is_file():
            target = destination / relative
            if target.is_symlink():
                raise ValueError('Refusing symlink file: ' + str(target))
            if target.exists() and target.read_bytes() == item.read_bytes():
                continue
            target.parent.mkdir(parents=True, exist_ok=True)
            backup(target)
            shutil.copy2(item, target)


def write_identity(path, name, assistant, persona):
    marker, end = '<!-- hadooyy:identity -->', '<!-- /hadooyy:identity -->'
    existing = path.read_text(encoding='utf-8-sig') if path.exists() else ''
    block = f'{marker}\nUser nickname: {name}\nAssistant nickname: {assistant}\nCommunication preferences: {persona}\n{end}'
    if marker in existing:
        start = existing.index(marker)
        stop = existing.index(end, start) + len(end)
        existing = existing[:start] + block + existing[stop:]
    else:
        existing = existing.rstrip() + '\n\n' + block + '\n'
    write_text(path, existing.lstrip())


def append_rules(path):
    rules = (REPO / 'config' / 'engineering-rules.md').read_text(encoding='utf-8')
    marker = '<!-- hadooyy:engineering -->'
    end = '<!-- /hadooyy:engineering -->'
    existing = path.read_text(encoding='utf-8-sig') if path.exists() else ''
    block = marker + '\n' + rules.rstrip() + '\n' + end
    if marker in existing:
        start = existing.index(marker)
        stop = existing.index(end, start) + len(end)
        existing = existing[:start] + block + existing[stop:]
    else:
        existing = existing.rstrip() + '\n\n' + block + '\n'
    write_text(path, existing.lstrip())


def home_paths(home=None):
    if home:
        return home / '.claude', home / '.hermes'
    claude = Path(os.environ.get('CLAUDE_CONFIG_DIR', str(Path.home() / '.claude')))
    local = Path(os.environ.get('LOCALAPPDATA', str(Path.home()))) / 'hermes'
    hermes = Path(os.environ.get('HERMES_HOME', str(local if os.name == 'nt' else Path.home() / '.hermes')))
    return claude, hermes


def install(target, name, assistant, persona, home=None, skin=False):
    skills = skill_dirs(REPO)
    claude, hermes = home_paths(home)
    destinations = []
    if target in {'claude', 'both'}:
        read_json(claude / 'settings.json')  # Fail before copying if config is malformed.
        destinations.append(('claude', claude))
    if target in {'hermes', 'both'}:
        destinations.append(('hermes', hermes))
    for agent, root in destinations:
        if REPO == root.resolve() or REPO in root.resolve().parents:
            raise ValueError('Install outside the cloned repository')
        for source in skills:
            relative = Path(source.name) if agent == 'claude' else source.relative_to(REPO / 'skills')
            copy_tree(source, root / 'skills' / relative)
        if agent == 'claude':
            merge_json(root / 'settings.json', read_json(REPO / 'config' / 'claude_settings.template.json'))
            context = root / 'CLAUDE.md'
        else:
            context = root / 'SOUL.md'
        append_rules(context)
        write_identity(context, name, assistant, persona)
        if skin and agent == 'hermes':
            copy_tree(REPO / 'skins', root / 'skins')
        installed = skill_dirs(root)
        missing = {p.name for p in skills} - {p.name for p in installed}
        if missing:
            raise RuntimeError('Missing skills: ' + ', '.join(sorted(missing)))
        print(f'{agent}: {len(skills)} skills copied and verified; context: {context}')
    print('Assets ready. MCP/plugins/auth still require the steps in SETUP.md. Restart agent after setup.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target', choices=['claude', 'hermes', 'both'], default='claude')
    parser.add_argument('--name', help='Recipient nickname; never copy sender identity')
    parser.add_argument('--assistant-name', help='Recipient choice of assistant nickname')
    parser.add_argument('--persona', help='Recipient communication preferences')
    parser.add_argument('--home', type=Path, help='Isolated test root; defaults to current user/profile')
    parser.add_argument('--skin', action='store_true', help='Copy optional Hadooyy skin, without activating it')
    parser.add_argument('--apply', action='store_true', help='Write files; otherwise show read-only plan')
    args = parser.parse_args()
    claude, hermes = home_paths(args.home)
    print(json.dumps({'skills': len(skill_dirs(REPO)), 'target': args.target, 'claude': str(claude), 'hermes': str(hermes), 'apply': args.apply}, indent=2))
    if not args.apply:
        return
    if not all(v and v.strip() for v in [args.name, args.assistant_name, args.persona]):
        parser.error('--apply requires --name, --assistant-name, --persona from the recipient')
    try:
        install(args.target, args.name.strip(), args.assistant_name.strip(), args.persona.strip(), args.home, args.skin)
    except (OSError, ValueError, RuntimeError) as error:
        parser.exit(1, f'Setup stopped: {error}\nExisting files have adjacent .bak-* backups.\n')


if __name__ == '__main__':
    main()
