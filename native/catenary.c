/*
 * catenary.c
 * Accelerated numerical simulation engine for catenary-pantograph interaction.
 */

#include "catenary.h"
#include <stdlib.h>
#include <math.h>
#include <string.h>

CatenarySimulationContext* catenary_create(size_t num_wire_nodes, double wire_len, double tension, double speed_kmh) {
    if (num_wire_nodes < 2 || wire_len <= 0.0 || tension <= 0.0) {
        return NULL;
    }

    CatenarySimulationContext *ctx = (CatenarySimulationContext*)malloc(sizeof(CatenarySimulationContext));
    if (!ctx) return NULL;

    memset(ctx, 0, sizeof(CatenarySimulationContext));

    /* Pantograph standard 2-mass parameters */
    ctx->panto.mass1 = 6.60;
    ctx->panto.mass2 = 18.00;
    ctx->panto.spring_k1 = 7000.0;
    ctx->panto.damper_c1 = 40.0;
    ctx->panto.damper_c2 = 70.0;
    ctx->panto.static_preload = 90.0;
    ctx->panto.velocity = (speed_kmh <= 0.0 ? 300.0 : speed_kmh) / 3.6;
    ctx->panto.x_pos = 20.0;
    ctx->panto.y1 = 0.0;
    ctx->panto.y2 = 0.0;

    /* Wire parameters */
    ctx->wire.num_nodes = num_wire_nodes;
    ctx->wire.element_length = wire_len / (double)(num_wire_nodes - 1);
    ctx->wire.tension = tension;
    ctx->wire.linear_mass = 1.0692; /* CuAg 120 mm^2 */

    ctx->wire.displacements = (double*)calloc(num_wire_nodes, sizeof(double));
    ctx->wire.velocities = (double*)calloc(num_wire_nodes, sizeof(double));
    ctx->wire.accelerations = (double*)calloc(num_wire_nodes, sizeof(double));

    if (!ctx->wire.displacements || !ctx->wire.velocities || !ctx->wire.accelerations) {
        catenary_free(ctx);
        return NULL;
    }

    ctx->current_time = 0.0;
    ctx->contact_force = 90.0;
    ctx->aero_force = 0.0;
    ctx->is_arcing = false;
    ctx->arc_energy = 0.0;

    return ctx;
}

void catenary_free(CatenarySimulationContext *ctx) {
    if (!ctx) return;
    if (ctx->wire.displacements) free(ctx->wire.displacements);
    if (ctx->wire.velocities) free(ctx->wire.velocities);
    if (ctx->wire.accelerations) free(ctx->wire.accelerations);
    free(ctx);
}

double catenary_compute_aero_uplift(double velocity_ms, double a0, double a1, double a2) {
    double v = fabs(velocity_ms);
    return a0 + (a1 * v) + (a2 * v * v);
}

double catenary_get_wire_height(const CatenarySimulationContext *ctx, double x) {
    if (!ctx || !ctx->wire.displacements) return 5.30;
    double len = (double)(ctx->wire.num_nodes - 1) * ctx->wire.element_length;
    if (x <= 0.0) return 5.30 + ctx->wire.displacements[0];
    if (x >= len) return 5.30 + ctx->wire.displacements[ctx->wire.num_nodes - 1];

    double idx_f = x / ctx->wire.element_length;
    size_t i = (size_t)floor(idx_f);
    double frac = idx_f - (double)i;

    if (i >= ctx->wire.num_nodes - 1) {
        return 5.30 + ctx->wire.displacements[ctx->wire.num_nodes - 1];
    }

    double y0 = ctx->wire.displacements[i];
    double y1 = ctx->wire.displacements[i + 1];
    return 5.30 + ((y0 * (1.0 - frac)) + (y1 * frac));
}

int catenary_step(CatenarySimulationContext *ctx, double dt) {
    if (!ctx || dt <= 0.0) return -1;

    /* 1. Aerodynamic uplift */
    ctx->aero_force = catenary_compute_aero_uplift(ctx->panto.velocity, 0.0, 0.12, 0.0058);

    /* 2. Contact mechanics */
    double y_wire = catenary_get_wire_height(ctx, ctx->panto.x_pos);
    double y_head = 5.30 + ctx->panto.y1;
    double penetration = y_head - y_wire;

    double f_contact = 0.0;
    if (penetration > 0.0) {
        /* k_contact = 50,000 N/m, c_contact = 100 N*s/m */
        f_contact = (50000.0 * penetration) + (100.0 * ctx->panto.v1);
        if (f_contact < 0.0) f_contact = 0.0;
    }
    ctx->contact_force = f_contact;

    /* 3. Pantograph dynamic equations */
    double spring_force = (ctx->panto.spring_k1 * (ctx->panto.y1 - ctx->panto.y2)) +
                          (ctx->panto.damper_c1 * (ctx->panto.v1 - ctx->panto.v2));

    double f1_net = -spring_force - f_contact;
    ctx->panto.a1 = f1_net / ctx->panto.mass1;

    double f2_net = spring_force - (ctx->panto.damper_c2 * ctx->panto.v2) +
                    ctx->panto.static_preload + ctx->aero_force;
    ctx->panto.a2 = f2_net / ctx->panto.mass2;

    /* Verlet / Euler update */
    ctx->panto.v1 += ctx->panto.a1 * dt;
    ctx->panto.y1 += ctx->panto.v1 * dt;

    ctx->panto.v2 += ctx->panto.a2 * dt;
    ctx->panto.y2 += ctx->panto.v2 * dt;

    ctx->panto.x_pos += ctx->panto.velocity * dt;
    ctx->current_time += dt;

    /* 4. Arcing detection */
    if (f_contact <= 5.0 && penetration < -0.0005) {
        ctx->is_arcing = true;
        ctx->arc_energy += 25.0 * 350.0 * dt; /* ~8.75 kW arc power */
    } else {
        ctx->is_arcing = false;
    }

    return 0;
}

double catenary_get_contact_force(const CatenarySimulationContext *ctx) {
    return ctx ? ctx->contact_force : 0.0;
}

double catenary_get_head_height(const CatenarySimulationContext *ctx) {
    return ctx ? (5.30 + ctx->panto.y1) : 5.30;
}

void catenary_solve_tridiagonal(const double *sub, const double *diag, const double *sup, const double *rhs, double *out, size_t n) {
    if (n == 0 || !sub || !diag || !sup || !rhs || !out) return;

    double *c_prime = (double*)malloc((n - 1) * sizeof(double));
    double *d_prime = (double*)malloc(n * sizeof(double));
    if (!c_prime || !d_prime) {
        if (c_prime) free(c_prime);
        if (d_prime) free(d_prime);
        return;
    }

    c_prime[0] = sup[0] / diag[0];
    d_prime[0] = rhs[0] / diag[0];

    for (size_t i = 1; i < n - 1; ++i) {
        double m = 1.0 / (diag[i] - sub[i - 1] * c_prime[i - 1]);
        c_prime[i] = sup[i] * m;
        d_prime[i] = (rhs[i] - sub[i - 1] * d_prime[i - 1]) * m;
    }

    d_prime[n - 1] = (rhs[n - 1] - sub[n - 2] * d_prime[n - 2]) / (diag[n - 1] - sub[n - 2] * c_prime[n - 2]);

    out[n - 1] = d_prime[n - 1];
    for (size_t i = n - 1; i > 0; --i) {
        out[i - 1] = d_prime[i - 1] - c_prime[i - 1] * out[i];
    }

    free(c_prime);
    free(d_prime);
}
