"""Run with python test_setup.py. No credentials or live config changes."""
import json
import os
from pathlib import Path
import re
import tempfile

import setup


def check():
    inventory = json.loads((setup.REPO / 'INVENTORY.json').read_text(encoding='utf-8'))
    sources = setup.skill_dirs(setup.REPO)
    assert len(sources) == inventory['total_skills']
    names = [re.search(r'^name:\s*(.+)$', (p / 'SKILL.md').read_text(encoding='utf-8'), re.M).group(1).strip() for p in sources]
    assert len(names) == len(set(names)), 'Duplicate skill frontmatter names'
    scratch = Path(os.environ.get('HERMES_HOME', str(Path.home() / '.hermes'))) / 'cache/scratch'
    scratch.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=scratch, prefix='portability-test-') as tmp:
        root = Path(tmp)
        source = root / 'source'
        source.mkdir()
        (source / 'support.txt').write_text('reference', encoding='utf-8')
        target = root / 'target'
        setup.copy_tree(source, target)
        (target / 'local.txt').write_text('preserve', encoding='utf-8')
        setup.copy_tree(source, target)
        assert (target / 'support.txt').read_text() == 'reference'
        assert (target / 'local.txt').read_text() == 'preserve'
        settings = root / 'settings.json'
        settings.write_text('{"theme":"light","env":{"KEEP":"yes"}}', encoding='utf-8')
        original = settings.read_bytes()
        setup.merge_json(settings, {'theme': 'dark', 'autoUpdatesChannel': 'latest'})
        data = json.loads(settings.read_text())
        assert data['theme'] == 'light' and data['env']['KEEP'] == 'yes'
        assert data['autoUpdatesChannel'] == 'latest'
        assert any(p.read_bytes() == original for p in root.glob('settings.json.bak-*'))
        settings.write_text('{broken', encoding='utf-8')
        try:
            setup.merge_json(settings, {'ok': True})
        except ValueError:
            pass
        else:
            raise AssertionError('Must refuse malformed JSON')
        assert settings.read_text() == '{broken'
        try:
            setup.copy_tree(source, source / 'recursive')
        except ValueError:
            pass
        else:
            raise AssertionError('Must refuse overlapping destinations')
        home = root / 'friend'
        setup.install('both', 'Recipient', 'Helper', 'Recipient tone', home)
        setup.install('both', 'Recipient', 'Helper', 'Recipient tone', home)
        assert len(setup.skill_dirs(home / '.claude')) == len(sources)
        assert len(setup.skill_dirs(home / '.hermes')) == len(sources)
        for path in [home / '.claude/CLAUDE.md', home / '.hermes/SOUL.md']:
            text = path.read_text(encoding='utf-8')
            assert text.count('<!-- hadooyy:identity -->') == 1
            assert 'Recipient' in text and 'Hadi' not in text
        assert not (home / '.claude.json').exists()
        assert not (home / '.hermes/config.yaml').exists()
        assert not (home / '.hermes/auth.json').exists()
    print('PASS: inventory, unique names, safe copy, backup, merge, bad JSON, paths, both agents, repeat setup, recipient identity')


if __name__ == '__main__':
    check()
