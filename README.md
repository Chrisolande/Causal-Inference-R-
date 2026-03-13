# Causal Inference in R

> Working notes and chapter summaries built while going through *Causal Inference in R*.

This is not a polished course or tutorial. It is a record of working through one
of the better causal inference texts available in R, writing things down in plain
language, running the code, and occasionally going off-script when something more
interesting comes up. Some sections are thorough. Some are just enough to get the
idea down. That is fine.

**Deployed summaries:** [chrisolande.github.io/Causal-Inference-R-](https://chrisolande.github.io/Causal-Inference-R-/)

---

## Status

Work in progress. Chapters are being added as they are completed. Not everything
is published yet.

| Chapter | Title | Status |
|---------|-------|--------|
| Ch 1 | From casual to causal | Done |
| Ch 2 | The whole game | Done |
| Ch 3 | Potential outcomes and counterfactuals | Done |
| Ch 4 | Expressing causal questions as DAGs | Done |
| Ch 5 | Causal inference is not (just) a statistical problem | Done |
| Ch 6 | From question to answer: stratification and outcome models | Done |
| Ch 7-24 | Remaining chapters | In progress |

---

## What is covered

The repo follows the book's structure, which covers the full modern causal
inference workflow.

**Identification and DAGs**

Everything starts here. Before touching a model, you need a story about how the
data was generated. This section works through directed acyclic graphs,
d-separation, backdoor and frontdoor criteria, and what it actually means to
identify a causal effect. `dagitty` and `ggdag` do the heavy lifting on the R
side.

**Propensity scores and IPW**

Propensity score matching, weighting, and inverse probability weighting for ATT
and ATE estimation. Implemented with `MatchIt` and `WeightIt`, with balance
diagnostics via `cobalt`.

**Doubly robust estimation**

Augmented IPW and targeted learning. The appeal is that the estimator stays
consistent if either the outcome model or the propensity model is correctly
specified, not necessarily both. `marginaleffects` handles most of the marginal
effect computation throughout.

**Instrumental variables**

When selection on observables fails and you have a valid instrument. Two-stage
least squares, the exclusion restriction, weak instrument diagnostics.

**Difference-in-differences**

The parallel trends assumption, two-way fixed effects, and what goes wrong with
staggered adoption. This section also touches on the recent DiD literature that
has exposed problems with the classic TWFE estimator.

**Regression discontinuity**

Sharp and fuzzy RD designs, bandwidth selection, and the continuity assumption.
Local polynomial regression at the cutoff.

**Sensitivity analysis**

An effect is only as credible as the assumptions behind it. This section covers
Rosenbaum bounds, E-values, and other tools for asking how much unmeasured
confounding it would take to explain away a result.

---

## Stack

- **R** with `MatchIt`, `WeightIt`, `marginaleffects`, `dagitty`, `ggdag`,
  `cobalt`, and friends
- **Quarto** for the book format
- **tidyverse** throughout

---

## Structure

```
.
+-- index.qmd
+-- chapters/
|   +-- ch01.qmd
|   +-- ch02.qmd
|   +-- ch03.qmd
|   +-- ch04.qmd
|   +-- ch05.qmd
|   +-- ch06.qmd
|   +-- ...
+-- R/
+-- data/
+-- _quarto.yml
+-- _brand.yml
```

---

## Build locally

```r
quarto::quarto_render()
```

---

## Who this is for

Mostly me. But if you are also working through *Causal Inference in R* and want
to see how someone else read the same material, it might be useful. The code runs.
The reasoning is my own.

---

*These notes are a derivative work of [Causal Inference in R](https://www.r-causal.org/)
by Malcolm Barrett, Lucy D'Agostino McGowan, and Travis Gerke, licensed under
[CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/).*
