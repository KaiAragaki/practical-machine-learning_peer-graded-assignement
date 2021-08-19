library(targets)

source("functions.R")

tar_option_set(packages = c("tidyverse", "tidymodels", "clock"))

# End this file with a list of target objects.
list(
  tar_target(data_dir, make_dir("./01_data"), format = "file"),
  tar_target(data_file, get_file("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv", 
                                      "train.csv", 
                                      data_dir),
             format = "file"),
  tar_target(exam_file, get_file("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv",
                                     "test.csv",
                                     data_dir),
             format = "file"),
  tar_target(data, read_csv(data_file, na = c("#DIV/0!", "", "NA"))),
  tar_target(exam, read_csv(exam_file, na = c("#DIV/0!", "", "NA"))),
  tar_target(both, bind_rows(data = data, exam = exam, .id = "dataset")),
  tar_target(both_tidied, tidy_both(both)),
  tar_target(data_tidied, filter(both_tidied, dataset == "data")),
  tar_target(exam_tidied, filter(both_tidied, dataset == "exam")),
  tar_target(partition, initial_split(data_tidied, prop = 0.8, strata = "classe")),
  tar_target(train, training(partition)),
  tar_target(test, testing(partition)),
  tar_target(model_spec, make_model_spec()),
  tar_target(model_fit, model_spec |> fit(classe ~ ., data = train))
)
