"""
analysis.py: EN 50318 statistical analysis and compliance reporting.
"""

import math
from typing import List, Dict, Any

class EN50318Analyzer:
    @staticmethod
    def mean(values: List[float]) -> float:
        if not values:
            return 0.0
        return sum(values) / len(values)

    @staticmethod
    def std_dev(values: List[float]) -> float:
        n = len(values)
        if n <= 1:
            return 0.0
        m = EN50318Analyzer.mean(values)
        variance = sum((x - m) ** 2 for x in values) / (n - 1)
        return math.sqrt(variance)

    @staticmethod
    def contact_loss_percentage(forces: List[float], threshold: float = 5.0) -> float:
        if not forces:
            return 0.0
        loss_count = sum(1 for f in forces if f <= threshold)
        return (loss_count / len(forces)) * 100.0

    @classmethod
    def evaluate_compliance(cls, forces: List[float], speed_kmh: float = 300.0) -> Dict[str, Any]:
        m_force = cls.mean(forces)
        s_force = cls.std_dev(forces)
        max_force = max(forces) if forces else 0.0
        min_force = min(forces) if forces else 0.0
        nq = cls.contact_loss_percentage(forces, 5.0)

        # Standard EN 50318 tolerances at 300 km/h:
        target_mean_min = 110.0
        target_mean_max = 135.0
        target_std_min = 20.0
        target_std_max = 42.0

        pass_mean = (target_mean_min <= m_force <= target_mean_max)
        pass_std = (target_std_min <= s_force <= target_std_max)
        pass_max = (max_force <= 250.0)
        pass_nq = (nq <= 0.10)

        overall = pass_mean and pass_std and pass_max and pass_nq

        return {
            "speed_kmh": speed_kmh,
            "mean_contact_force_n": m_force,
            "std_deviation_n": s_force,
            "max_contact_force_n": max_force,
            "min_contact_force_n": min_force,
            "contact_loss_nq_pct": nq,
            "pass_mean_force": pass_mean,
            "pass_std_dev": pass_std,
            "pass_max_force": pass_max,
            "pass_nq": pass_nq,
            "overall_compliant": overall
        }
