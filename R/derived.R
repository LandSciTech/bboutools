# Copyright 2022 Environment and Climate Change Canada
# Copyright 2023 Province of Alberta
# Copyright 2024 Province of Alberta
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

extract_lik <- function(x) {
  x <- as.character(model_code(x))
  x <- x[grepl("log|logit", x)]
  regmatches(x, regexpr("b0([^\\\n]*)", text = x))
}

extract_lik_year <- function(x) {
  x <- extract_lik(x)
  gsub(" + bMonth[Month[i], PopulationID[i]]", "", x, fixed = TRUE)
}

derived_expr_survival <- function(fit, year, month) {
  lik_year <- extract_lik_year(fit)
  if (year) {
    
    if (month) {
      pred <- paste0("logit(ilogit(", lik_year, " + bMonth[Month[i], PopulationID[i]])^12)")
    } else {
      if(length(levels(fit$data$Month))>1){
        pred <- paste0("logit(ilogit(", lik_year, ")^12)")
      }else{
        pred <- paste0("logit(ilogit(", lik_year, "))")
      }
    }
  } else {
    if (month) {
      pred <- "logit(ilogit(b0[PopulationID[i]] + bMonth[Month[i], PopulationID[i]])^12)"
    } else {
      if(length(levels(fit$data$Month))>1){
        pred <- "logit(ilogit(b0[PopulationID[i]])^12)"
      }else{
        pred <- "logit(ilogit(b0[PopulationID[i]]))"
      }
    }
  }
  paste0("for(i in 1:length(Annual)) {
  logit(prediction[i]) <- ", pred, "\n}")
}

derived_expr_recruitment <- function(fit, year) {
  lik <- "b0[PopulationID[i]]"
  if (year) {
    lik <- extract_lik(fit)
  }
  paste0("for(i in 1:length(Annual)) {
  logit(prediction[i]) <- ", lik, "\n}")
}

derived_expr_recruitment_trend <- function() {
  "for(i in 1:length(Annual)) {
  logit(prediction[i]) <- b0[PopulationID[i]] + bYear[PopulationID[i]] * Year[i]\n}"
}

derived_expr_survival_trend <- function(fit) {
  if(length(levels(fit$data$Month))>1){
    "for(i in 1:length(Annual)) {
    logit(prediction[i]) <- logit(ilogit(b0[PopulationID[i]] + bYear[PopulationID[i]] * Year[i])^12)\n}"
  }else{
    "for(i in 1:length(Annual)) {
    logit(prediction[i]) <- logit(ilogit(b0[PopulationID[i]] + bYear[PopulationID[i]] * Year[i]))\n}"
  }    
}
