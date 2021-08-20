make_dir <- function(path) {
  if (!dir.exists(path)) {
    dir.create(path)
  }
  path
}

get_file <- function(url, file_name, data_dir) {
  dest_file <- paste0(data_dir, "/", file_name)
  download.file(url, destfile = dest_file)
  dest_file
}

tidy_both <- function(data) {
  data |> 
    select(-c(...1, kurtosis_yaw_belt, skewness_yaw_belt, 
                     kurtosis_yaw_dumbbell, skewness_yaw_dumbbell, 
                     kurtosis_yaw_forearm, skewness_yaw_forearm,
                     cvtd_timestamp)) |> 
    mutate(time = raw_timestamp_part_1 * 1000000 + raw_timestamp_part_2) |> 
    select(-c(raw_timestamp_part_1, raw_timestamp_part_2)) |> 
    group_by(user_name) |> 
    mutate(time = time - min(time),
           classe = as.factor(classe)) 
    #...1 is a row ID col
    # timestamps have been compressed into a single feature
    # rest contain no data
}

make_model_spec <- function() {
  boost_tree(tree_depth = tune(), 
             trees = tune(), 
             learn_rate = tune(), 
             min_n = tune(), 
             loss_reduction = tune(), 
             sample_size = tune(), 
             stop_iter = tune()) |> 
    set_engine('xgboost') |> 
    set_mode('classification')
}

make_recipe <- function() {
  
}

make_workflow <- function(model) {
  workflow() |> 
    add_model(model) |> 
    add_formula(classe ~ yaw_belt)
}
