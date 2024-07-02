library(ggplot2)
library(tidyverse)
library(lubridate)
install.packages("stargazer") # Instala todas las librerías que no tengas
library(stargazer)
library(stargazer)
library(lmtest)
library(tseries)
library(forecast)
library(car)
library(corrplot)

#Exploración inicial

Consulta <- read.csv("C:/Users/Acer/Desktop/RProjectsHome/RDatasets/Consulta_20240305-124140744.csv")

INTMOVIL <- read.csv("C:/Users/Acer/Desktop/RProjectsHome/RDatasets/TD_LINEAS_INTMOVIL_ITE_VA.csv")

INTMOVIL <- INTMOVIL %>%
  mutate(L_TOTAL_E = as.numeric(gsub(",", "", L_TOTAL_E)))


str(INTMOVIL) #Aquí solo checo la estructura del dataset

#DATA PREPROCESSING

INTMOVIL <- INTMOVIL %>%
  mutate(L_TOTAL_E = as.numeric(gsub(",", "", L_TOTAL_E)))

INTMOVIL <- INTMOVIL %>%
  mutate(FECHA = dmy(FECHA)) 
INTMOVIL <- INTMOVIL %>%
  mutate(MONTH_YEAR = floor_date(FECHA, "month")) 
INTMOVIL <- INTMOVIL %>%
  select(MONTH_YEAR,
         ANIO,
         MES,
         EMPRESA,
         L_TOTAL_E)
INTMOVIL <- INTMOVIL %>%
  group_by(MONTH_YEAR) %>%
  summarise(Lineas.con.internet.por.mes= sum(L_TOTAL_E))


Consulta <- Consulta %>%
  transmute(FECHA = dmy(Fecha),
            Total.de.operaciones.enviadas= Total.de.operaciones.enviadas)
Consulta <- Consulta %>%
  mutate(MONTH_YEAR = floor_date(FECHA, "month"))
Consulta <- Consulta %>%
  select(-FECHA)
Consulta <- Consulta %>%
  group_by(MONTH_YEAR) %>%
  summarise(operaciones.por.mes= sum(Total.de.operaciones.enviadas))



INTMOVIL <- INTMOVIL %>%
  filter(MONTH_YEAR >= as.Date("2019-10-01"))
Consulta <- Consulta %>%
  filter(MONTH_YEAR >= as.Date("2019-10-01"))

DATA <- joined_data <- left_join(Consulta, INTMOVIL, by = "MONTH_YEAR") #Junto bases
DATA <- na.omit(DATA)

DATA <- DATA %>%  #Agrego transformaciones logaritmicas
  mutate(log.operaciones.por.mes = log(operaciones.por.mes),
         log.Lineas.con.internet.por.mes = log(Lineas.con.internet.por.mes))
str(DATA)

#|ARIMAX FINAL

# Función para ajustar modelos ARIMAX con todas las combinaciones de p y q hasta un máximo dado
find_best_arimax <- function(data, max_p, max_q, xreg) {
  best_aic <- Inf
  best_model <- NULL
  
  # Bucle para probar todas las combinaciones de p y q
  for (p in 0:max_p) {
    for (q in 0:max_q) {
      # Intenta ajustar el modelo ARIMAX
      try({
        model <- Arima(data$log.operaciones.por.mes, order = c(p, 0, q), xreg = xreg) #Log(Y) = ARIMAX = ARIMA(p,0,q) + xreg
        current_aic <- AIC(model)
        
        # Verifica si este modelo tiene un mejor AIC
        if (current_aic < best_aic) {
          best_aic <- current_aic
          best_model <- model
          best_order <- c(p, 0, q)
        }
      }, silent = TRUE)
    }
  }
  
  list(model = best_model, order = best_order, AIC = best_aic)
}

# Datos exógenos para el modelo ARIMAX
xreg <- DATA$log.Lineas.con.internet.por.mes

# Llamada a la función
result <- find_best_arimax(DATA, max_p = 3, max_q = 3, xreg = xreg)

# Imprimir los resultados del mejor modelo
print(paste("Mejor modelo ARIMAX(p,0,q): p =", result$order[1], ", q =", result$order[3], ", AIC =", result$AIC))
summary(result$model)   #ARIMAX(1,0,3)
modelo_arimax_simple <- result$model

#Pruebas de supuestos

Acf(residuals(modelo_arimax_simple), main="Autocorrelación de los Residuos") #No autocorrelación significativa
shapiro.test(residuals(modelo_arimax_simple)) #No normalidad
adf.test(residuals(modelo_arimax_simple), alternative = "stationary") #Estacionario
plot(residuals(modelo_arimax_simple), type = 'l', main = "Gráfico de Residuos", ylab = "Residuos") #Ahí se ven los outliers
hist(residuals(modelo_arimax_simple), breaks = 30, main = "Histograma de Residuos", xlab = "Residuos") #Ahí se ven los outliers que impiden que la distribucion sea normal, ve hasta la derecha
qqnorm(residuals(modelo_arimax_simple))
qqline(residuals(modelo_arimax_simple)) # #Ahí se ven los outliers, en las colas desviadas

#Reresion

lm <- lm(log.operaciones.por.mes ~ log.Lineas.con.internet.por.mes, DATA)

stargazer(lm, type = "text")

plot(lm$fitted.values, lm$residuals)
abline(h = 0, col = "red")
dwtest(lm) 
plot(lm$fitted.values, lm$residuals^2)
abline(h = 0, col = "blue")
bptest(lm)
hist(lm$residuals, breaks = "Sturges", main = "Histogram of Residuals", xlab = "Residuals")
qqnorm(lm$residuals)
qqline(lm$residuals, col = "red")
shapiro.test(lm$residuals)


ggplot(DATA, aes(x = log.operaciones.por.mes, y = log.Lineas.con.internet.por.mes)) +
  geom_point() + 
  geom_smooth(method = "lm", se = TRUE, color = "blue") + 
  labs(x = "Logaritmo de lineas con internet", y = "Logaritmo de operaciones", title = "Relación entre operaciones y lineas de servicio móvil con internet") +
  theme_light()

#Visualización

plot(DATA$log.operaciones.por.mes, type = 'o', main = "Logaritmo de Operaciones", xlab = "Tiempo", ylab = "Log(Operaciones)")
plot(DATA$log.Lineas.con.internet.por.mes, type = 'o', main = "Logaritmo de Lineas", xlab = "Tiempo", ylab = "Log(Lineas)")

DATA <- DATA %>% 
  mutate(AnoMes = MONTH_YEAR)


ggplot(DATA, aes(x = AnoMes, y = operaciones.por.mes)) +
  geom_line(color = "blue") +
  geom_point(color = "blue") +
  labs(title = "Transacciones por mes", 
       x = "Año", 
       y = "Transacciones") +
  scale_y_continuous(labels = scales::comma) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(DATA, aes(x = AnoMes, y = log.operaciones.por.mes)) +
  geom_line(color = "blue") +
  geom_point(color = "blue") +
  labs(title = "Transacciones por mes (valores en logaritmos)", 
       x = "Año", 
       y = "Transacciones") +
  scale_y_continuous(labels = scales::comma) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(DATA, aes(x = AnoMes, y = Lineas.con.internet.por.mes)) +
  geom_line(color = "blue") +
  geom_point(color = "blue") +
  labs(title = "Lineas de servicio móvil con internet", 
       x = "Año", 
       y = "Saldo") +
  scale_y_continuous(labels = scales::comma) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(DATA, aes(x = AnoMes, y = log.Lineas.con.internet.por.mes)) +
  geom_line(color = "blue") +
  geom_point(color = "blue") +
  labs(title = "Lineas de servicio móvil con internet (valores en logaritmos)", 
       x = "Año", 
       y = "Saldo") +
  scale_y_continuous(labels = scales::comma) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Visualizar resultados
predicciones <- forecast(modelo_arimax_simple, xreg=DATA$log.Lineas.con.internet.por.mes)


df_predicciones <- data.frame(
  Fecha = DATA$AnoMes,
  Real = DATA$log.operaciones.por.mes,
  Predicho = predicciones$mean
)


ggplot(df_predicciones, aes(x = Fecha)) +
  geom_line(aes(y = Real, color = "Real")) +
  geom_line(aes(y = Predicho, color = "Predicho")) +
  labs(title = "Predicciones del Modelo ARIMAX",
       x = "Fecha",
       y = "Log Operaciones") +
  scale_color_manual(values = c("Real" = "blue", "Predicho" = "red")) +
  theme_light()
