# Misc ASV tests ---------------------------------------------------------

# Jacobo de la Cuesta-Zuluaga. September 2026.

# The aim of this script is to perform various common ASV processing
# and plotting steps.

# This script uses a very simple simulated dataset so there is no biological
# meaning behind the results obtained. In other words, use this code for your
# own analysis but don't interpret your results by comparing what you see from
# the results of the examples.

# libraries --------------------------------------------------------------

# %%
library(tidyverse)
library(vegan)
library(ggpubr)
library(conflicted)

# %%
conflicts_prefer(dplyr::filter)
conflicts_prefer(dplyr::select)


# Simulate Species table --------------------------------------------------

# Here we'll simulate a small ASV dataset of Com20, a 20-member community.
# We'll assume species abundances come from a negative-binomial distribution.
# Again, this is a toy dataset, don't try to derive biological meaning from it.

# You don't need to modify anything in this section.

# %%
set.seed(2112)

#%%
# Define number of samples and number of species
n_samples <- c(15, 15)
n_species <- 21


## Community A ------------------------------------------------------------
#%%
# Set simulation parameters
# Negative-binomial dispersion parameter
# Small values give more low or zero counts
size_A <- 0.5

# Species mean abundances
# Assumes mean abundance comes from lognormal distribution
# lower sdlog = more even community, higher = more uneven
mu_A <- rlnorm(n_species, meanlog = 2, sdlog = 1)

# convert to relative abundances
p_A <- mu_A / sum(mu_A)

# varying number of reads per sample
depths_A <- round(runif(n_samples[1], 10000, 50000))

# Simulate reads sample by sample
species_table_A <- depths_A |>
    map(function(d) rnbinom(n_species, mu = p_A * d, size = size_A)) |>
    list_c() |>
    matrix(nrow = n_samples[1], byrow = TRUE) |>
    as_tibble(.name_repair = "universal")


# Community B ------------------------------------------------------------
#%%
# Set simulation parameters
# Negative-binomial dispersion parameter
# Small values give more low or zero counts
size_B <- 0.2

# Species mean abundances
# Assumes mean abundance comes from lognormal distribution
# lower sdlog = more even community, higher = more uneven
mu_B <- rlnorm(n_species, meanlog = 3, sdlog = 3.5)

# convert to relative abundances
p_B <- mu_B / sum(mu_B)

# varying number of reads per sample
depths_B <- round(runif(n_samples[2], 10000, 50000))

# Simulate reads sample by sample
species_table_B <- depths_B |>
    map(function(d) rnbinom(n_species, mu = p_B * d, size = size_B)) |>
    list_c() |>
    matrix(nrow = n_samples[2], byrow = TRUE) |>
    as_tibble(.name_repair = "universal")


## Combine community tables -----------------------------------------------
# %%
# Add species and sample names
# Taxa colors
taxa_colors <- c(
    `Collinsella aerofaciens` = "#9ba4ca",
    `Eggerthella lenta` = "#353e64",
    `Bacteroides fragilis` = "#e4f4cf",
    `Bacteroides thetaiotaomicron` = "#bfe590",
    `Bacteroides uniformis` = "#9bd651",
    `Phocaeicola vulgatus` = "#74ae29",
    `Parabacteroides merdae` = "#4a6f1a",
    `Enterocloster bolteae` = "#FEE5D9",
    `Clostridium_P perfringens` = "#FCBBA1",
    `Thomasclavelia ramosa` = "#FC9272",
    `Lacrimispora saccharolytica` = "#FB6A4A",
    `Bariatricus comes` = "#DE2D26",
    `Dorea formicigenerans` = "#A50F15",
    `Agathobacter rectalis` = "#FEEDDE",
    `Roseburia intestinalis` = "#FDD0A2",
    `Ruminococcus_B gnavus` = "#FDAE6B",
    `Streptococcus parasanguinis` = "#FD8D3C",
    `Streptococcus salivarius` = "#E6550D",
    `Veillonella parvula` = "#A63603",
    `Fusobacterium nucleatum` = "#8001b0",
    `Escherichia coli` = "#000000"
)

# %%
# Combine tables, add species names and sample names
species_table_combined <- bind_rows(species_table_A, species_table_B)
colnames(species_table_combined) <- names(taxa_colors)
species_table <- species_table_combined |>
    mutate(
        Sample = row_number(),
        Sample = str_c(
            "Sample_",
            str_pad(string = as.character(row_number()), width = 2, pad = '0')
        )
    ) |>
    relocate(Sample)

# Note that the code below assumes you have a wide table with species
# or ASV abundances as columns and samples as rows
species_table |>
    head()

# %%
# Create simple metadata table
# Samples from community A belong to condition 1, samples from community B to 2.
# If your samples have an order, you need to specify it is a factor and
# the levels of that factor, similar to what is donde for the variable Condition
samples_table <- species_table |>
    select(Sample) |>
    mutate(
        Condition = if_else(
            row_number() <= n_samples[1],
            "Condition_1",
            "Condition_2"
        ),
        Condition = factor(Condition, levels = c("Condition_1", "Condition_2"))
    )

samples_table |>
    head()


# Stacked bar plot -------------------------------------------------------
# We'll create a stacked barplot of relative abundances using the colors
# %%
# Calculate relative abundance
species_relabund <- species_table |>
    column_to_rownames("Sample") |>
    decostand(method = "total", MARGIN = 1) |>
    rownames_to_column("Sample")

# Test that abundance add up to 1
species_relabund |>
    select(-Sample) |>
    rowSums()


# %%
# Make long format table
# Calculate percentage
species_relabund_long <- species_relabund |>
    pivot_longer(
        cols = -Sample,
        names_to = "Species",
        values_to = "Relabund"
    ) |>
    mutate(Relabund = Relabund * 100)


# %%
# Make df for plot
# Convert species to factor ordered as they are in the color vector above
barplot_table <- species_relabund_long |>
    left_join(samples_table) |>
    mutate(Species = factor(Species, names(taxa_colors)))


# %%
species_barplot <- barplot_table |>
    ggplot(aes(x = Sample, y = Relabund, fill = Species)) +
    geom_col() +
    scale_fill_manual(values = taxa_colors) +
    scale_x_discrete(expand = expansion(c(0, 0))) +
    scale_y_continuous(expand = expansion(c(0, 0))) +
    facet_grid(~Condition, scales = "free") +
    theme_light() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(x = "Sample", y = "Relative abundance (%)")

species_barplot


# Calculate alpha diversity ----------------------------------------------
# Alpha diversity metrics need to be subsampled to account for differences in
# sampling effort, that is, the number of counts on each sample. Otherwise,
# the estimates would be biased and samples with deeper sequencing would appear
# with higher values.

# While people have argued that subsampling, also called rarefaction, should not
# be done, I still think rarefaction is the best method to account for differences
# in sampling effort. I suggest the work of Patrick Schloss on this topic:
# https://doi.org/10.1128/msphere.00354-23
# https://doi.org/10.1128/msphere.00355-23

# To account for the randomness of the process and to use as much data as possible
# one can perform the rarefaction multiple times and calculate a mean or median
# diversity value on each sample. That value can then be used downstream to
# compare between treatments. This is what I implemented here.

#
# %%
# Create function to obtain alpha diversity measures in a single table
single_alphadiv <- function(counts) {
    # Calculate rarefaction depth as the minimum number of counts across samples
    rarefaction_depth <- counts |>
        column_to_rownames("Sample") |>
        rowSums() |>
        min()

    # Rarefy
    rarefied_counts <- counts |>
        column_to_rownames("Sample") |>
        rrarefy(sample = rarefaction_depth)

    # calculate richness and Shannon index
    richness <- rarefied_counts |>
        specnumber(MARGIN = 1)

    shannon <- rarefied_counts |>
        diversity(MARGIN = 1, index = "shannon")

    data.frame(Richness = richness, Shannon = shannon) |>
        rownames_to_column("Sample")
}


# %%
# Calculate median alpha diversity across 100 random subsamplings
# You can decrease this number if your dataset is very big
median_alphadiv <- map(1:100, function(iteration) {
    single_alphadiv(species_table) |>
        mutate(Iteration = iteration)
}) |>
    list_rbind() |>
    group_by(Sample) |>
    summarise(
        Median_richness = median(Richness),
        Median_shannon = median(Shannon)
    )

# You can then include sample metadata for downstream visualization and tests
median_alphadiv |>
    left_join(samples_table) |>
    print(n = 30)


## Alpha diversity plot ---------------------------------------------------
# We'll generate a dot plot of alpha diversity measures by condition
# adding a mean +/- standard error
# %%
alpha_plot_df <- median_alphadiv |>
    left_join(samples_table, by = join_by(Sample))

# %%
richness_plot <- alpha_plot_df |>
    ggplot(aes(x = Condition, y = Median_richness)) +
    geom_point(
        position = position_jitter(width = 0.1, height = 0),
        alpha = 0.75
    ) +
    stat_summary(
        fun.data = "mean_se",
        geom = "pointrange",
        fun.args = list(mult = 1),
        color = "firebrick3"
    ) +
    theme_light() +
    labs(x = "Condition", y = "Species richness")

shannon_plot <- alpha_plot_df |>
    ggplot(aes(x = Condition, y = Median_shannon)) +
    geom_point(
        position = position_jitter(width = 0.1, height = 0),
        alpha = 0.75
    ) +
    stat_summary(
        fun.data = "mean_se",
        geom = "pointrange",
        fun.args = list(mult = 1),
        color = "firebrick3"
    ) +
    theme_light() +
    labs(x = "Condition", y = "Shannon index")


# %%
# Combine plots
alphadiv_plot <- ggarrange(richness_plot, shannon_plot, nrow = 1)

alphadiv_plot


# Beta diversity ---------------------------------------------------------

## Calculate distances ----------------------------------------------------
# %%
# Beta diversity, similar to alpha, requires rarefaction to account for
# differences in sequencing depth, therefore, the minimum number of sequences
# needs to be calculated
rarefaction_depth <- species_table |>
    column_to_rownames("Sample") |>
    rowSums() |>
    min()

# %%
# There are multiple beta-diversity metrics, they will tell you different things
# about your data. You need to pick which to use according to your question.
# We'll calculate three commonly used metrics. You should select one of them
# for downstream analyses.

# Bray-Curtis
# Takes into account species abundance on each sample
# It is widely used in the microbiome field
# `avgdist()` calculates the average dissimilarity between samples after
# a number of iterations. You can decrease this number if your dataset is large.
bray_curtis_dist <- species_table |>
    column_to_rownames("Sample") |>
    avgdist(
        sample = rarefaction_depth,
        dmethod = "bray",
        iterations = 100,
        upper = FALSE
    )

# Jaccard
# Takes into account species presence and absence, not abundance
# It is widely used in the microbiome field
# `avgdist()` calculates the average dissimilarity between samples after
# a number of iterations. You can decrease this number if your dataset is large.
jaccard_dist <- species_table |>
    column_to_rownames("Sample") |>
    avgdist(
        sample = rarefaction_depth,
        dmethod = "jaccard",
        iterations = 100,
        binary = TRUE,
        upper = FALSE
    )

# Aitchison distance
# Takes into account species abundance on each sample
# It transforms the data to take into account the compositionality of
# microbiome data. Only calculated once, no random subsampling.
aitchison_dist <- species_table |>
    column_to_rownames("Sample") |>
    vegdist(method = "aitchison", pseudocount = 1)


## Principal component analysis and plot ----------------------------------
#%%
# Principal coordinate analysis
# We'll run the example using Bray-Curtis dissimilarity, but you can modify the code
# if you want to use another metric.

# PCoA based on Aitchison
pcoa_object <- cmdscale(bray_curtis_dist, k = 3, eig = T, add = TRUE)

# Data frame with PCo and sample data
pcoa_df <- pcoa_object$points |>
    as.data.frame() |>
    rownames_to_column("Sample") |>
    left_join(samples_table)

pcoa_df |>
    head()

# PCo proportion of variance
sum_pco <- sum(pcoa_object$eig)
prop_var <- (pcoa_object$eig / sum_pco) * 100

pco1_var <- round(prop_var[1], 2)
pco2_var <- round(prop_var[2], 2)
pco3_var <- round(prop_var[3], 2)


# %%
# Plot principal component analysis
pcoa_plot <- pcoa_df |>
    ggplot(aes(x = V1, y = V2, color = Condition)) +
    geom_point() +
    coord_fixed() +
    theme_light() +
    labs(
        x = str_glue("PCo1 ({pvar}%)", pvar = pco1_var),
        y = str_glue("PCo2 ({pvar}%)", pvar = pco2_var)
    ) +
    theme(legend.position = "bottom")

pcoa_plot


## Test differences in composition ----------------------------------------

# We can then test whether the composition of the communities are different
# using a PERMANOVA test, and test whether the dispersion of the samples are
# different by group using a beta-dispersion test.

# PERMANOVA can be sensitive to differences in dispersion if the groups are
# unbalanced, however, a treatment can lead to changes in both overall composition
# i.e. where the centroid of the community is located, and the dispersion,
# i.e. how similar are communities within a single condition.

# %%
# Perform beta-dispersion test
# Note that to specify the conditions, the samples should be in the same
# order in both the distance matrix and the metadata table
dist_samples <- bray_curtis_dist |>
    as.matrix() |>
    as.data.frame() |>
    rownames()
dist_samples == samples_table$Sample

# Perform beta disper test
betadisper_object <- betadisper(
    bray_curtis_dist,
    samples_table$Condition,
    add = TRUE
)
betadisper_test <- permutest(betadisper_object, permutations = 999)
betadisper_test


#%%
# Perform PERMANOVA
# Note that `by = "margin"` specifies that the marginal effect of each term
# are computed. Meaning that it evaluates the contribution of each variable
# in the model after accounting for the effect of the others.
# This doesn't matter here because we only have one variable, but becomes
# important when you have multiple variables in your model, for example
# if you want to evaluate the effect of a treatment while adjusting for the
# effect of OD on the community composition.

permanova_test = adonis2(
    bray_curtis_dist ~ Condition,
    permutations = 999,
    data = samples_table,
    by = "margin"
)

permanova_test
