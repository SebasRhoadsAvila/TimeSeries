install.packages("readxl")
install.packages("lmtest")
install.packages("knitr")
install.packages("vars")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("tidyr")
install.packages("gridExtra")
install.packages("forecast")
library(forecast)
library(gridExtra)
library(tidyr)
library(ggplot2)
library(dplyr)
library(vars)
library(knitr)
library(readxl)
library(lmtest)
data <- read_excel("C:/Users/srhoadsa/Downloads/SW2001_Data.xlsx")
data <- data %>% 
  transmute(p,u,R) %>%
  filter(complete.cases(.))

#| Granger test

test_p_u <- grangertest(p ~ u, order = 4, data = data)
test_p_R <- grangertest(p ~ R, order = 4, data = data)
test_u_p <- grangertest(u ~ p, order = 4, data = data)
test_u_R <- grangertest(u ~ R, order = 4, data = data)
test_R_p <- grangertest(R ~ p, order = 4, data = data)
test_R_u <- grangertest(R ~ u, order = 4, data = data)

p_value_p_u <- test_p_u$Pr[2]
p_value_p_R <- test_p_R$Pr[2]
p_value_u_p <- test_u_p$Pr[2]
p_value_u_R <- test_u_R$Pr[2]
p_value_R_p <- test_R_p$Pr[2]
p_value_R_u <- test_R_u$Pr[2]


table1 <- matrix(c("NA", p_value_p_u, p_value_p_R,
                   p_value_u_p, "NA", p_value_u_R,
                   p_value_R_p, p_value_R_u, "NA"), 
                 nrow = 3, byrow = TRUE)
colnames(table1) <- c("p", "u", "R")
rownames(table1) <- c("p", "u", "R")


kable(table1, col.names = c("p", "u", "R"), row.names = TRUE, caption = "Table 1: Granger Causality Test P-values")

# Reduced VAR model

var_model <- VAR(data, p = 4, type = "const")
var_model


#| Variance decompositions

# Recursive VAR model

# Fit the VAR model
var_model <- VAR(data, p = 4, type = "const")

# Compute the variance decomposition
vd <- fevd(var_model, n.ahead = 12)
vd
# Extract the variance decomposition for each variable at the specified horizons
vd_p_1 <- vd$p[1, ]
vd_p_4 <- vd$p[4, ]
vd_p_8 <- vd$p[8, ]
vd_p_12 <- vd$p[12, ]

vd_u_1 <- vd$u[1, ]
vd_u_4 <- vd$u[4, ]
vd_u_8 <- vd$u[8, ]
vd_u_12 <- vd$u[12, ]

vd_R_1 <- vd$R[1, ]
vd_R_4 <- vd$R[4, ]
vd_R_8 <- vd$R[8, ]
vd_R_12 <- vd$R[12, ]

# Combine the variance decomposition data for each horizon
table_1B_p <- rbind(vd_p_1, vd_p_4, vd_p_8, vd_p_12)
table_1B_u <- rbind(vd_u_1, vd_u_4, vd_u_8, vd_u_12)
table_1B_R <- rbind(vd_R_1, vd_R_4, vd_R_8, vd_R_12)

# Convert the variance decomposition to percentages
table_1B_p <- table_1B_p * 100
table_1B_u <- table_1B_u * 100
table_1B_R <- table_1B_R * 100


# Change row names for each table
rownames(table_1B_p) <- c("1", "4", "8", "12")
rownames(table_1B_u) <- c("1", "4", "8", "12")
rownames(table_1B_R) <- c("1", "4", "8", "12")


# Add a title to the matrix
title_p <- "Variance Decomposition for p (Inflation)"
title_u <- "Variance Decomposition for u (Unemployment)"
title_R <- "Variance Decomposition for R (Interest Rate)"
# Add the forecast horizons as a column
table_1B_p <- cbind(FH = rownames(table_1B_p), table_1B_p)
table_1B_u <- cbind(FH = rownames(table_1B_u), table_1B_u)
table_1B_R <- cbind(FH = rownames(table_1B_R), table_1B_R)
# Add a column name for the forecast horizons
colnames(table_1B_p) <- c("Forecast Horizon", "p", "u", "R")
colnames(table_1B_u) <- c("Forecast Horizon", "p", "u", "R")
colnames(table_1B_R) <- c("Forecast Horizon", "p", "u", "R")
#DF
table_1B_p <- as.data.frame(table_1B_p)
table_1B_u <- as.data.frame(table_1B_u)
table_1B_R <- as.data.frame(table_1B_R)
# No names
rownames(table_1B_p) <- NULL
rownames(table_1B_u) <- NULL
rownames(table_1B_R) <- NULL


# Print tables with titles
cat(title_p, "\n")
print(table_1B_p, row.names = FALSE)
cat("\n", title_u, "\n")
print(table_1B_u, row.names = FALSE)
cat("\n", title_R, "\n")
print(table_1B_R, row.names = FALSE)




#| Plot IRF 

irfs <- irf(var_model, n.ahead = 12, boot = FALSE)

# p_to_u
# Extract the IRF values 
irf_values_p_to_p <- irfs$irf$p[, "p"]
irf_values_p_to_u <- irfs$irf$p[, "u"]
irf_values_p_to_R <- irfs$irf$p[, "R"]

irf_values_u_to_p <- irfs$irf$u[, "p"]
irf_values_u_to_u <- irfs$irf$u[, "u"]
irf_values_u_to_R <- irfs$irf$u[, "R"]

irf_values_R_to_p <- irfs$irf$R[, "p"]
irf_values_R_to_u <- irfs$irf$R[, "u"]
irf_values_R_to_R <- irfs$irf$R[, "R"]

# Create a data frame for plotting
df_irf_p_p <- data.frame(
  Horizon = 1:13,
  Response = irf_values_p_to_p)
df_irf_p_u <- data.frame(
  Horizon = 1:13,
  Response = irf_values_p_to_u)
df_irf_p_R <- data.frame(
  Horizon = 1:13,
  Response = irf_values_p_to_R)

df_irf_u_p <- data.frame(
  Horizon = 1:13,
  Response = irf_values_u_to_p)
df_irf_u_u <- data.frame(
  Horizon = 1:13,
  Response = irf_values_u_to_u)
df_irf_u_R <- data.frame(
  Horizon = 1:13,
  Response = irf_values_u_to_R)

df_irf_R_p <- data.frame(
  Horizon = 1:13,
  Response = irf_values_R_to_p)
df_irf_R_u <- data.frame(
  Horizon = 1:13,
  Response = irf_values_R_to_u)
df_irf_R_R <- data.frame(
  Horizon = 1:13,
  Response = irf_values_R_to_R)

# Plot 
plot1 <-ggplot(df_irf_p_p, aes(x = Horizon, y = Response)) +
  geom_line() + #p (Inflation) shock to p (Inflation)
  geom_point() +
  labs(title = "Impulse Response of p Shock to p",
       x = "Horizon",
       y = "Response") +
  theme_minimal()

plot2 <-ggplot(df_irf_p_u, aes(x = Horizon, y = Response)) +
  geom_line() + #p (Inflation) shock to u (Unemployment)
  geom_point() +
  labs(title = "Impulse Response of p Shock to u",
       x = "Horizon",
       y = "Response") +
  theme_minimal()

plot3 <-ggplot(df_irf_p_R, aes(x = Horizon, y = Response)) +
  geom_line() + #p (Inflation) shock to R (interest rate)
  geom_point() +
  labs(title = "Impulse Response of p Shock to p",
       x = "Horizon",
       y = "Response") +
  theme_minimal()



plot4 <-ggplot(df_irf_u_p, aes(x = Horizon, y = Response)) +
  geom_line() + #u (Unemployment) shock to p (Inflation)
  geom_point() +
  labs(title = "Impulse Response of u Shock to p",
       x = "Horizon",
       y = "Response") +
  theme_minimal()

plot5 <-ggplot(df_irf_u_u, aes(x = Horizon, y = Response)) +
  geom_line() + #u (Unemployment) shock to u (Unemployment)
  geom_point() +
  labs(title = "Impulse Response of u Shock to u",
       x = "Horizon",
       y = "Response") +
  theme_minimal()

plot6 <-ggplot(df_irf_u_R, aes(x = Horizon, y = Response)) +
  geom_line() + #u (Unemployment) shock to R (interest rate)
  geom_point() +
  labs(title = "Impulse Response of u Shock to p",
       x = "Horizon",
       y = "Response") +
  theme_minimal()


plot7 <-ggplot(df_irf_R_p, aes(x = Horizon, y = Response)) +
  geom_line() + #R (interest rate) shock to p (Inflation)
  geom_point() +
  labs(title = "Impulse Response of R Shock to p",
       x = "Horizon",
       y = "Response") +
  theme_minimal()

plot8 <-ggplot(df_irf_R_u, aes(x = Horizon, y = Response)) +
  geom_line() + #R (interest rate) shock to u (Unemployment)
  geom_point() +
  labs(title = "Impulse Response of R Shock to u",
       x = "Horizon",
       y = "Response") +
  theme_minimal()

plot9 <-ggplot(df_irf_R_R, aes(x = Horizon, y = Response)) +
  geom_line() + #R (interest rate) shock to R (interest rate)
  geom_point() +
  labs(title = "Impulse Response of R Shock to p",
       x = "Horizon",
       y = "Response") +
  theme_minimal()

grid.arrange(plot1, plot2, plot3, plot4, plot5, plot6, plot7, plot8, plot9, ncol=3)


#| Forecastings

# Splitting the data into training and test sets
train_data <- data[1:100, ]
test_data <- data[101:164, ]


# Fit the models on the training data
var_model_train <- VAR(train_data, p = 4, type = "const")


rw_forecast_p_drift <- tail(train_data$p, 1) + mean(diff(train_data$p))
rw_forecast_u_drift <- tail(train_data$u, 1) + mean(diff(train_data$u))
rw_forecast_R_drift <- tail(train_data$R, 1) + mean(diff(train_data$R))


ar_model_p <- arima(data$p, order=c(1,0,0))
ar_model_u <- arima(data$u, order=c(1,0,0))
ar_model_R <- arima(data$R, order=c(1,0,0))

# Generate out-of-sample forecasts 

forecast_results <- predict(var_model_train, h = 8) # h is the forecast horizon, which is 8 quarters in this case


predictions_p_drift <- seq(rw_forecast_p_drift, by = mean(diff(train_data$p)), length.out = nrow(test_data))
predictions_u_drift <- seq(rw_forecast_u_drift, by = mean(diff(train_data$u)), length.out = nrow(test_data))
predictions_R_drift <- seq(rw_forecast_R_drift, by = mean(diff(train_data$R)), length.out = nrow(test_data))

forecasts_p <- as.data.frame(forecast_results$fcst$p[, 1])
forecasts_u <- as.data.frame(forecast_results$fcst$u[, 1])
forecasts_R <- as.data.frame(forecast_results$fcst$R[, 1])

# 2 quarters
forecast_errors_p_2 <- test_data$p[1:2] - forecasts_p[1:2,1]
forecast_errors_u_2 <- test_data$u[1:2] - forecasts_u[1:2,1]
forecast_errors_R_2 <- test_data$R[1:2] - forecasts_R[1:2,1]

rmse_p_2 <- (mean(forecast_errors_p_2^2))
rmse_u_2 <- (mean(forecast_errors_u_2^2))
rmse_R_2 <- (mean(forecast_errors_R_2^2))


forecast_errors_p_2_RW <- test_data$p[1:2] - predictions_p_drift[1:2]
forecast_errors_u_2_RW <- test_data$u[1:2] - predictions_u_drift[1:2]
forecast_errors_R_2_RW <- test_data$R[1:2] - predictions_R_drift[1:2]

rmse_p_2_RW <- (mean(forecast_errors_p_2_RW^2))
rmse_u_2_RW <- (mean(forecast_errors_u_2_RW^2))
rmse_R_2_RW <- (mean(forecast_errors_R_2_RW^2))


forecast_p_AR2 <- forecast(ar_model_p, h=2)
forecast_u_AR2 <- forecast(ar_model_u, h=2)
forecast_R_AR2 <- forecast(ar_model_R, h=2)

mse_p_AR2 <- mean((forecast_p_AR2$mean - test_data$p[1:2])^2)
mse_u_AR2 <- mean((forecast_u_AR2$mean - test_data$u[1:2])^2)
mse_R_AR2 <- mean((forecast_R_AR2$mean - test_data$R[1:2])^2)

# 4 quarters
forecast_errors_p_4 <- test_data$p[1:4] - forecasts_p[1:4,1]
forecast_errors_u_4 <- test_data$u[1:4] - forecasts_u[1:4,1]
forecast_errors_R_4 <- test_data$R[1:4] - forecasts_R[1:4,1]

rmse_p_4 <- (mean(forecast_errors_p_4^2))
rmse_u_4 <- (mean(forecast_errors_u_4^2))
rmse_R_4 <- (mean(forecast_errors_R_4^2))


forecast_errors_p_4_RW <- test_data$p[1:4] - predictions_p_drift[1:4]
forecast_errors_u_4_RW <- test_data$u[1:4] - predictions_u_drift[1:4]
forecast_errors_R_4_RW <- test_data$R[1:4] - predictions_R_drift[1:4]

rmse_p_4_RW <- (mean(forecast_errors_p_4_RW^2))
rmse_u_4_RW <- (mean(forecast_errors_u_4_RW^2))
rmse_R_4_RW <- (mean(forecast_errors_R_4_RW^2))


forecast_p_AR4 <- forecast(ar_model_p, h=4)
forecast_u_AR4 <- forecast(ar_model_u, h=4)
forecast_R_AR4 <- forecast(ar_model_R, h=4)

mse_p_AR4 <- mean((forecast_p_AR4$mean - test_data$p[1:4])^2)
mse_u_AR4 <- mean((forecast_u_AR4$mean - test_data$u[1:4])^2)
mse_R_AR4 <- mean((forecast_R_AR4$mean - test_data$R[1:4])^2)

# 8 quarters
forecast_errors_p <- test_data$p[1:8] - forecasts_p[1:8,1]
forecast_errors_u <- test_data$u[1:8] - forecasts_u[1:8,1]
forecast_errors_R <- test_data$R[1:8] - forecasts_R[1:8,1]

rmse_p <- (mean(forecast_errors_p^2))
rmse_u <- (mean(forecast_errors_u^2))
rmse_R <- (mean(forecast_errors_R^2))


forecast_errors_p_RW <- test_data$p[1:8] - predictions_p_drift[1:8]
forecast_errors_u_RW <- test_data$u[1:8] - predictions_u_drift[1:8]
forecast_errors_R_RW <- test_data$R[1:8] - predictions_R_drift[1:8]

rmse_p_RW <- (mean(forecast_errors_p_RW^2))
rmse_u_RW <- (mean(forecast_errors_u_RW^2))
rmse_R_RW <- (mean(forecast_errors_R_RW^2))


forecast_p_AR <- forecast(ar_model_p, h=8)
forecast_u_AR <- forecast(ar_model_u, h=8)
forecast_R_AR <- forecast(ar_model_R, h=8)

mse_p_AR <- mean((forecast_p_AR$mean - test_data$p[1:8])^2)
mse_u_AR <- mean((forecast_u_AR$mean - test_data$u[1:8])^2)
mse_R_AR <- mean((forecast_R_AR$mean - test_data$R[1:8])^2)


table_2 <- data.frame(
  Quarters = c("2", "4", "8"),
  AR_p=c(mse_p_AR,mse_p_AR4,mse_p_AR),
  RW_p= c(rmse_p_2_RW, rmse_p_4_RW, rmse_p_RW),
  VAR_P = c(rmse_p_2, rmse_p_4, rmse_p),
  AR_u=c(mse_u_AR,mse_u_AR4,mse_u_AR),
  RW_u= c(rmse_u_2_RW, rmse_u_4_RW, rmse_u_RW),
  VAR_u = c(rmse_u_2, rmse_u_4, rmse_u),
  AR_R=c(mse_R_AR,mse_R_AR4,mse_R_AR),
  RW_R= c(rmse_R_2_RW, rmse_R_4_RW, rmse_R_RW),
  VAR_R = c(rmse_R_2, rmse_R_4, rmse_R)
)

print(table_2)

#| Structural inference

data_ts <- data %>% 
  transmute(p, u, R) %>%
  filter(complete.cases(.)) %>%
  ts(start=c(1, 164), 
     frequency=4)  

#Backward-looking
var_model <- VAR(data_ts, p=4) 
svar_model <- SVAR(var_model, method="B", Bmat=matrix(c(1, NA, NA, 
                                                        0, 1, NA, 
                                                        0, 0, 1), 3, 3, byrow=TRUE))
irf_results <- irf(svar_model, impulse="R", response=c("p", "u", "R"), boot=TRUE, n.ahead=20, ci=0.95)
plot(irf_results)

#Forward-looking

Amat_forward_looking <- matrix(c(1, NA, NA, 
                                 0, 1, NA, 
                                 NA, NA, 1), 3, 3, byrow=TRUE)

svar_model_forward <- SVAR(var_model, method="A", Amat=Amat_forward_looking)

irf_results_forward <- irf(svar_model_forward, impulse="R", response=c("p", "u", "R"), boot=TRUE, n.ahead=20, ci=0.95)

plot(irf_results_forward)

