/*
 * catenary.h
 * High-performance C ABI interface for railway catenary-pantograph dynamics.
 */

#ifndef CATENARY_H
#define CATENARY_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

typedef struct {
    double mass1;              /* Head mass [kg] */
    double mass2;              /* Frame mass [kg] */
    double spring_k1;          /* Secondary spring [N/m] */
    double damper_c1;          /* Secondary damper [N*s/m] */
    double damper_c2;          /* Frame damper [N*s/m] */
    double static_preload;     /* Static uplift F0 [N] */
    double velocity;           /* Running velocity [m/s] */
    double x_pos;              /* Longitudinal position [m] */
    double y1;                 /* Head vertical displacement [m] */
    double v1;                 /* Head vertical velocity [m/s] */
    double a1;                 /* Head vertical acceleration [m/s^2] */
    double y2;                 /* Frame vertical displacement [m] */
    double v2;                 /* Frame vertical velocity [m/s] */
    double a2;                 /* Frame vertical acceleration [m/s^2] */
} CatenaryPantographState;

typedef struct {
    size_t num_nodes;
    double element_length;     /* dx [m] */
    double tension;            /* T [N] */
    double linear_mass;        /* mu [kg/m] */
    double *displacements;
    double *velocities;
    double *accelerations;
} CatenaryWireState;

typedef struct {
    CatenaryPantographState panto;
    CatenaryWireState wire;
    double current_time;
    double contact_force;
    double aero_force;
    bool is_arcing;
    double arc_energy;
} CatenarySimulationContext;

/* Core C API functions */
CatenarySimulationContext* catenary_create(size_t num_wire_nodes, double wire_len, double tension, double speed_kmh);
void catenary_free(CatenarySimulationContext *ctx);

int catenary_step(CatenarySimulationContext *ctx, double dt);
double catenary_get_contact_force(const CatenarySimulationContext *ctx);
double catenary_get_head_height(const CatenarySimulationContext *ctx);
double catenary_get_wire_height(const CatenarySimulationContext *ctx, double x);

/* Accelerated numerical kernels */
void catenary_solve_tridiagonal(const double *sub, const double *diag, const double *sup, const double *rhs, double *out, size_t n);
double catenary_compute_aero_uplift(double velocity_ms, double a0, double a1, double a2);

#ifdef __cplusplus
}
#endif

#endif /* CATENARY_H */
