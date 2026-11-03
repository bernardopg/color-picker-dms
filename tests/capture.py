#!/usr/bin/env python3
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'capture/pick-color'

class CaptureTests(unittest.TestCase):
    def run_capture(self, scripts, backend='auto'):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            trace = root / 'calls'
            for name, body in scripts.items():
                path = root / name
                path.write_text('#!/bin/sh\necho ' + name + ' >> "$TRACE"\n' + body + '\n')
                path.chmod(0o755)
            env = {**os.environ, 'PATH': tmp + ':/usr/bin:/bin', 'TRACE': str(trace)}
            result = subprocess.run(['/bin/bash', str(SCRIPT), '--backend', backend], env=env, text=True, capture_output=True)
            return result.returncode, json.loads(result.stdout), trace.read_text().splitlines() if trace.exists() else []

    def test_success(self):
        code, result, calls = self.run_capture({'hyprpicker': "printf '#1e90ff\\n'"})
        self.assertEqual((code, result['hex'], result['backend'], calls), (0, '#1E90FF', 'hyprpicker', ['hyprpicker']))
        self.assertEqual((result['r'], result['g'], result['b']), (30, 144, 255))

    def test_cancel_never_launches_another_backend(self):
        code, result, calls = self.run_capture({'hyprpicker': 'exit 1', 'slurp': 'exit 1', 'dms': 'exit 1'}, 'hyprpicker')
        self.assertNotEqual(code, 0)
        self.assertIn('error', result)
        self.assertEqual(calls, ['hyprpicker'])

    def test_auto_cancel_never_launches_another_backend(self):
        code, result, calls = self.run_capture({'hyprpicker': 'exit 1', 'slurp': 'exit 1', 'dms': 'exit 1'})
        self.assertNotEqual(code, 0)
        self.assertEqual(calls, ['hyprpicker'])

    def test_invalid_backend(self):
        code, result, calls = self.run_capture({'hyprpicker': 'exit 0'}, 'invalid')
        self.assertNotEqual(code, 0)
        self.assertIn('unknown', result['error'])
        self.assertEqual(calls, [])

if __name__ == '__main__':
    unittest.main()
