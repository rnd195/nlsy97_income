library(dplyr)
library(readxl)
library(rstudioapi)
library(AER) # ivreg
library(systemfit) # hausman
library(stargazer)
library(ggplot2)
library(tidyr)
library(lmtest) # bptest


#### Data preparation ####

# set working directory to filepath
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

nlsy97 <- read_excel("data/nlsy97.xlsx")

colnames(nlsy97) <- c(
  "PUBID",
  "KEY_SEX",
  "CV_HGC_RES_DAD",
  "CV_HGC_RES_MOM",
  "KEY_RACE_ETHNICITY",
  "ASVAB_MATH_VERBAL_SCORE_PCT",
  "CV_MARSTAT_COLLAPSED",
  "YINC_1700",
  "CVC_SAT_MATH_SCORE_2007",
  "CVC_SAT_VERBAL_SCORE_2007",
  "CVC_ACT_SCORE_2007",
  "CVC_WKSWK_ADULT2_ALL",
  "CVC_HIGHEST_DEGREE_EVER",
  "CV_BIO_CHILD_HH",
  "CVC_HGC_EVER",
  "KEY_BDATE_Y"
)

glimpse(nlsy97)
summary(nlsy97)

# weird values around 200 000 mark - filter them out
plot(nlsy97$YINC_1700)

# values equal to 95 are "Ungraded" - filter them out
plot(nlsy97$CVC_HGC_EVER)
plot(nlsy97$CV_HGC_RES_DAD)
plot(nlsy97$CV_HGC_RES_MOM)


nlsy97_small <- nlsy97 %>%
  transmute(
    income = YINC_1700,
    degree = ifelse(CVC_HIGHEST_DEGREE_EVER > 3, 1, ifelse(CVC_HIGHEST_DEGREE_EVER %in% c(0, 1, 2, 3), 0, -1)),
    gender = KEY_SEX - 1, # change to 0/1 ... 0 == males
    hispan = ifelse(KEY_RACE_ETHNICITY == 2, 1, 0),
    black = ifelse(KEY_RACE_ETHNICITY == 1, 1, 0),
    exper = CVC_WKSWK_ADULT2_ALL * 7 / 365, # convert to years
    feduc = CV_HGC_RES_DAD, # degree / educ instrument
    meduc = CV_HGC_RES_MOM,
    married = ifelse(CV_MARSTAT_COLLAPSED == 1, 1, ifelse(CV_MARSTAT_COLLAPSED == 0, 0, -1)), # currently married
    child = CV_BIO_CHILD_HH,
    educ = CVC_HGC_EVER,
    abil = ASVAB_MATH_VERBAL_SCORE_PCT,
    # abil_sat_c = CVC_SAT_VERBAL_SCORE_2007 + CVC_SAT_MATH_SCORE_2007,
    # abil_act = CVC_ACT_SCORE_2007
  ) %>%
  filter(
    income > 0 & income < 235884, # > 0 needed for log, < 235884 explained above
    exper >= 0,
    degree >= 0,
    abil > 0, # =0 does not apply
    # abil_sat_c > 0,
    # abil_act > 0,
    feduc >= 0 & feduc < 95, # filter out "Ungraded"
    meduc >= 0 & meduc < 95,
    gender == 0, # only measure males as it is suggested in the setup
    married >= 0,
    child >= 0,
    educ >= 0 & educ < 95
  )

glimpse(nlsy97_small)
nlsy97_small %>%
  select(-gender, -educ) %>%
  summary()

## rendering the table
#library(summarytools)
#nlsy97_small %>%
#  select(-gender, -educ) %>%
#  dfSummary(graph.magnif = 0.5, na.col = F, valid.col = F) %>%
#  print(method = "render")

nlsy97_small %>%
  gather() %>%
  ggplot(aes(value)) +
    facet_wrap(~ key, scales = "free") +
    geom_density()


#### Exploratory analysis ####

# meduc and feduc are correlated but should be exogenous
cor(nlsy97_small$degree, nlsy97_small$feduc)
summary(lm(degree ~ feduc, nlsy97_small))
cor(nlsy97_small$degree, nlsy97_small$meduc)
summary(lm(degree ~ meduc, nlsy97_small))

nlsy97_exper <- nlsy97 %>%
  transmute(
    exper = CVC_WKSWK_ADULT2_ALL * 7 / 365,
    income = YINC_1700
  ) %>%
  filter(exper >= 0, income > 0 & income < 200000)

plot(nlsy97_exper$exper)

# income is not very well determined by experience?
summary(lm(log(income) ~ exper + I(exper^2), nlsy97_exper))
cor(log(nlsy97_exper$income), nlsy97_exper$exper)


#### Basic model ####

fmla_1 <- log(income) ~ degree + exper + I(exper^2)
model_1 <- lm(fmla_1, nlsy97_small)
summary(model_1)
bptest(model_1) # reject null => heteroskedasticity

# abil is a determinant of degree 
cor(nlsy97_small$degree, nlsy97_small$abil)
summary(lm(degree ~ abil, data = nlsy97_small))


#### OLS model ####
# Proxy for ability - Test scores; race as an omitted variable?
fmla_2 <- log(income) ~ degree + exper + I(exper^2) + black + hispan + married + child + abil
model_2 <- lm(fmla_2, nlsy97_small)

summary(model_2)
# Heteroskedasticity?
bptest(model_2)
# Robust standard errors
(model_2r <- coeftest(model_2, vcov = vcovHC(model_2, type = "HC0")))


#### IV model (not reported) ####

## IV feduc (ivreg outputs the same results as tsls() but works better in stargazer)
## 2SLS should be preferred if we have more than 1 IV
model_3 <- ivreg(
  log(income) ~ degree + exper + I(exper^2) + black + hispan + married + child + abil
  | feduc + exper + I(exper^2) + black + hispan + married + child + abil,
  data = nlsy97_small
)
summary(model_3)
bptest(model_3)

(model_3r <- coeftest(model_3, vcov = vcovHC(model_3, type = "HC0")))


#### 2SLS model ####

# 2SLS identical methods
# library(sem)
# model_4 <- tsls(
#   log(income) ~ degree + exper + I(exper^2) + black + hispan + married + child + abil,
#   ~ feduc + meduc + exper + I(exper^2) + black + hispan + married + child + abil, nlsy97_small
# )

# model 4 should be preferred over model 3 due to the presence of 2 IVs
model_4 <- ivreg(
  log(income) ~ degree + exper + I(exper^2) + black + hispan + married + child + abil
  | feduc + meduc + exper + I(exper^2) + black + hispan + married + child + abil,
  data = nlsy97_small
)

summary(model_4)
bptest(model_4)

(model_4r <- coeftest(model_4, vcov = vcovHC(model_4, type = "HC0")))
# (model_4r <- coeftest(model_4, vcov = sandwich)) # identical approach


#### Testing ####

fmla_test <- degree ~ feduc + meduc + exper + I(exper^2) + black + hispan + married + child + abil
model_iv_test <- lm(fmla_test, nlsy97_small)

# reject the null that both are zero => at least one is strong
linearHypothesis(model_iv_test, c("meduc=0", "feduc=0"))

# Wu-Hausman test and other diagnostics 
# (with robust standard errors due to the presence of heterosked.)
summary(model_4, vcov = sandwich, diagnostics = T)$diagnostics
# weak instruments -> reject null (same result) => at least one instrument is strong
# Hausman -> dont reject null => degree might not be endogenous
# Sargan -> dont reject null => additional instruments are valid


#### Output ####

stargazer(model_1, model_2r, model_4r,
# stargazer(model_1, model_2, model_4, # to copy the statistics
  title = "Determining wage: OLS base, OLS and 2SLS",
  header = F,
  type = "text",
  keep.stat = NULL,
  omit.table.layout = "n",
  digits = 4,
  intercept.bottom = F,
  column.labels = c("OLS base", "OLS (robust SE)", "2SLS (robust SE)"),
  dep.var.labels.include = F,
  model.numbers = F,
  dep.var.caption = "Dependent variable: log(income)",
  model.names = F
)
