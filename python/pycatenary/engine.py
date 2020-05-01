"""
engine.py: Python wrapper for libcatenary C ABI and Io driver.
"""

import ctypes
import os
import sys
from typing import List, Tuple, Optional

class CatenaryEngine:
    def __init__(self, lib_path: Optional[str] = None):
        if lib_path is None:
            # Check local repository root
            base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
            candidate = os.path.join(base_dir, "libcatenary.dylib")
            if not os.path.exists(candidate):
                candidate = os.path.join(base_dir, "libcatenary.so")
            lib_path = candidate

        self._lib = ctypes.CDLL(lib_path)
        self._setup_signatures()
        self._ctx = None

    def _setup_signatures(self):
        self._lib.catenary_create.argtypes = [ctypes.c_size_t, ctypes.c_double, ctypes.c_double, ctypes.c_double]
        self._lib.catenary_create.restype = ctypes.c_void_p

        self._lib.catenary_free.argtypes = [ctypes.c_void_p]
        self._lib.catenary_free.restype = None

        self._lib.catenary_step.argtypes = [ctypes.c_void_p, ctypes.c_double]
        self._lib.catenary_step.restype = ctypes.c_int

        self._lib.catenary_get_contact_force.argtypes = [ctypes.c_void_p]
        self._lib.catenary_get_contact_force.restype = ctypes.c_double

        self._lib.catenary_get_head_height.argtypes = [ctypes.c_void_p]
        self._lib.catenary_get_head_height.restype = ctypes.c_double

        self._lib.catenary_get_wire_height.argtypes = [ctypes.c_void_p, ctypes.c_double]
        self._lib.catenary_get_wire_height.restype = ctypes.c_double

    def initialize(self, num_nodes: int = 1001, wire_length: float = 550.0, tension: float = 25000.0, speed_kmh: float = 300.0):
        if self._ctx is not None:
            self._lib.catenary_free(self._ctx)
        self._ctx = self._lib.catenary_create(num_nodes, wire_length, tension, speed_kmh)
        if not self._ctx:
            raise RuntimeError("Failed to allocate CatenarySimulationContext in C library")

    def step(self, dt: float = 0.001) -> float:
        if not self._ctx:
            raise RuntimeError("Engine not initialized. Call initialize() first.")
        rc = self._lib.catenary_step(self._ctx, dt)
        if rc != 0:
            raise RuntimeError(f"catenary_step returned error code {rc}")
        return self._lib.catenary_get_contact_force(self._ctx)

    def get_contact_force(self) -> float:
        return self._lib.catenary_get_contact_force(self._ctx) if self._ctx else 0.0

    def get_head_height(self) -> float:
        return self._lib.catenary_get_head_height(self._ctx) if self._ctx else 5.30

    def simulate(self, duration_s: float, dt: float = 0.001) -> List[float]:
        steps = int(duration_s / dt)
        forces = []
        for _ in range(steps):
            f = self.step(dt)
            forces.append(f)
        return forces

    def __del__(self):
        if hasattr(self, "_ctx") and self._ctx:
            self._lib.catenary_free(self._ctx)
            self._ctx = None
