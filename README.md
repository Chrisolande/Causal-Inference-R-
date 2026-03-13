# Causal Inference in R

> My working notes, code, and a Quarto book built while going through *Causal Inference in R*.

This is not a polished course or a tutorial. It is what it is: a record of me working through one of the better causal inference texts available in R, writing things down in my own words, running the code, and occasionally going off-script when something more interesting comes up.

Some sections are thorough. Some are just enough to get the idea down. That is fine.

---

## What is covered

The repo follows the book's structure, which covers the full modern causal inference workflow.

**Identification and DAGs**

Everything starts here. Before touching a model, you need a story about how the data was generated. This section works through directed acyclic graphs, d-separation, backdoor and frontdoor criteria, and what it actually means to identify a causal effect. `dagitty` and `ggdag` do the heavy lifting on the R side.

**Propensity Scores and IPW**

Propensity score matching, weighting, and inverse probability weighting for ATT and ATE estimation. Implemented with `MatchIt` and `WeightIt`, with balance diagnostics via `cobalt`.

**Doubly Robust Estimation**

Augmented IPW and targeted learning. The appeal here is that the estimator stays consistent if either the outcome model or the propensity model is correctly specified, not necessarily both. `marginaleffects` handles most of the marginal effect computation throughout.

**Instrumental Variables**

When selection on observables fails and you have a valid instrument. Two-stage least squares, the exclusion restriction, weak instrument diagnostics.

**Difference-in-Differences**

The parallel trends assumption, two-way fixed effects, and what goes wrong with staggered adoption. This section also touches on the recent DiD literature that has exposed problems with the classic TWFE estimator.

**Regression Discontinuity**

Sharp and fuzzy RD designs, bandwidth selection, and the continuity assumption. Local polynomial regression at the cutoff.

**Sensitivity Analysis**

An effect is only as credible as the assumptions behind it. This section covers Rosenbaum bounds, E-values, and other tools for asking how much unmeasured confounding it would take to explain away a result.

---

## Stack

- **R** with `MatchIt`, `WeightIt`, `marginaleffects`, `dagitty`, `ggdag`, `cobalt`, and friends
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
|   +-- ch07.qmd
|   +-- ch08.qmd
|   +-- ...
+-- R/
+-- data/
+-- _quarto.yml
+-- _brand.yml
```

---

## Status

Still in progress. I am working through the book chapter by chapter and the summaries are not published yet.

To build locally:

```r
# install.packages("quarto")
quarto::quarto_render()
```

---

## Who this is for

Mostly me. But if you are also working through *Causal Inference in R* and want to see how someone else read the same material, it might be useful. The code runs. The reasoning is my own.
