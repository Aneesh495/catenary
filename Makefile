# Makefile for Catenary Simulation Engine

CC ?= clang
CFLAGS ?= -O3 -Wall -Wextra -fPIC
IO ?= io
PYTHON ?= python3

LIB_NAME = libcatenary.dylib

.PHONY: all build test benchmark demo verify clean

all: build test

build: $(LIB_NAME)

$(LIB_NAME): native/catenary.c native/catenary.h
	@echo "Compiling native C ABI acceleration library ($@)..."
	$(CC) $(CFLAGS) -shared -o $@ native/catenary.c

test: build
	@echo "Running Io master verification test suite..."
	$(IO) tests/test_runner.io
	@echo "Running Python test suite..."
	$(PYTHON) python/tests/test_pycatenary.py

benchmark: build
	@echo "Running EN 50318 regulatory benchmark..."
	$(IO) -e 'doFile("src/validation/EN50318Benchmark.io"); doFile("src/validation/ComplianceReport.io"); b := EN50318Benchmark clone setupBenchmark(300.0) executeRun(3.0); ComplianceReport generateReport(b) println'
	@echo "Running high-throughput performance benchmarks..."
	$(IO) benchmarks/bench_runner.io

demo: build
	@echo "Running Catenary interactive SCADA telemetry demonstration..."
	./bin/catenary run 300 1.0

verify: test benchmark

clean:
	@echo "Cleaning compiled artifacts and temporary files..."
	rm -f $(LIB_NAME) *.o
	rm -rf build dist *.egg-info __pycache__ python/__pycache__ python/pycatenary/__pycache__
	rm -f telemetry*.csv *.log
