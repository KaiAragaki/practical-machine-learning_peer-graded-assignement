# Scratchpad
library(targets)
library(tidymodels)


a <- tar_read(train)

a <- a |> 
  select(-problem_id, -dataset)

# which are mostly NA?

b <- a |> apply(2, function(x) is.na(x) |> sum())

which(b >= (nrow(a) * .9))

make_model_spec <- function() {
  boost_tree(tree_depth = tune(),
             learn_rate = tune(),
             min_n = tune(),
             loss_reduction = tune()) |> 
    set_engine('xgboost') |> 
    set_mode('classification')
}


make_workflow <- function(model) {
  workflow() |> 
    add_model(model) |> 
    add_formula(classe ~ .)
}

xgboost_params <- 
  parameters(
    min_n(),
    tree_depth(),
    learn_rate(),
    loss_reduction()
  )

xgboost_grid <- 
  dials::grid_max_entropy(
    xgboost_params, 
    size = 60
  )
train_folds <- vfold_cv(a)


model <- make_model_spec()
wf <- make_workflow(model)

res <- wf |> 
  tune_grid(resamples = train_folds,
            grid = xgboost_grid)

res |> collect_metrics()

res |> show_best(metric = "accuracy")

best <- res |> 
  select_best("accuracy")

model_final <- model |> 
  finalize_model(best)

b <- select(a, user_name:gyros_belt_x, classe) |> 
  select(-kurtosis_roll_belt)

# After yaw_belt
# Before skewness_roll_belt

train_pred <- model_final |> 
  fit(formula = classe ~ .,
      data = b) |> 
  predict(b) |> 
  bind_cols(b)


# Should probably stratify on class when dividing data
# Probably user as well

ggplot(a, aes(x = time, y = a$skewness_roll_belt, color = user_name)) +
  geom_point()

boost_tree_xgboost_spec <-
  boost_tree(tree_depth = tune(), trees = tune(), learn_rate = tune(), min_n = tune(), loss_reduction = tune(), sample_size = tune(), stop_iter = tune()) %>%
  set_engine('xgboost') %>%
  set_mode('classification')

