"""
test_pycatenary.py: Verification tests for pycatenary Python package and C ABI.
"""

import unittest
import sys
import os

# Add python directory to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from pycatenary.engine import CatenaryEngine
from pycatenary.analysis import EN50318Analyzer

class TestPycatenary(unittest.TestCase):
    def setUp(self):
        self.engine = CatenaryEngine()
        self.engine.initialize(num_nodes=501, wire_length=250.0, tension=25000.0, speed_kmh=300.0)

    def test_initialization(self):
        f = self.engine.get_contact_force()
        self.assertGreaterEqual(f, 0.0)
        h = self.engine.get_head_height()
        self.assertAlmostEqual(h, 5.30, places=2)

    def test_simulation_step(self):
        # Initial step
        force0 = self.engine.step(0.001)
        self.assertGreaterEqual(force0, 0.0)
        # Advance 10 ms to allow static preload to engage contact wire
        for _ in range(10):
            self.engine.step(0.001)
        engaged_force = self.engine.get_contact_force()
        self.assertGreater(engaged_force, 0.5)

    def test_simulation_run(self):
        forces = self.engine.simulate(duration_s=0.1, dt=0.001)
        self.assertEqual(len(forces), 100)
        mean_f = EN50318Analyzer.mean(forces)
        self.assertGreater(mean_f, 10.0)

    def test_analyzer_compliance(self):
        mock_forces = [125.0 + (5.0 if i % 2 == 0 else -5.0) for i in range(100)]
        results = EN50318Analyzer.evaluate_compliance(mock_forces, speed_kmh=300.0)
        self.assertTrue(results["pass_mean_force"])
        self.assertLessEqual(results["max_contact_force_n"], 250.0)
        self.assertEqual(results["contact_loss_nq_pct"], 0.0)

if __name__ == "__main__":
    unittest.main()
