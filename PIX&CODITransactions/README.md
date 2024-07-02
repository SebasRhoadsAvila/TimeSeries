### Project Overview

This project investigates whether CODI transactions in Mexico can be explained by an equivalent variable that explains PIX transactions in Brazil. The analysis aims to establish a relationship between mobile phone access and banking operations using different econometric models.

### Brazil

#### Data Source

- **Source**: [ANATEL "Accesos de telefonía móvil"](https://informacoes.anatel.gov.br/paineis/acessos/telefonia-movel)
- **Description**: The data refers to the number of active personal mobile phone service contracts.

#### Econometric Model

**Linear Log-Log Model**:
$\log(Y_t) = \beta_0 + \beta_1 \log(X_t) + U_t $

- $\log(Y_t)$: Logarithm of banking operations.
- $\log(X_t)$: Logarithm of mobile phone accesses.
- $U_t$: Error term.

![Image](https://github.com/SebasRhoadsAvila/TimeSeries/blob/main/PIX%26CODITransactions/Images/Imagen1.png)

**Interpretation**:
- Holding everything else constant, a 1% increase in mobile phone accesses is associated with an expected increase of approximately 22% in banking operations.

![Image](https://github.com/SebasRhoadsAvila/TimeSeries/blob/main/PIX%26CODITransactions/Images/Imagen2.png)

### Mexico

#### Data Source

- **Source**: [Instituto Federal de Telecomunicaciones](https://bit.ift.org.mx/BitWebApp/descargaArchivos.xhtml)
- **Description**: Monthly series on mobile service lines with internet access.

#### Econometric Models

1. **ARIMAX(1, 0, 3) Model**:
 $\log(Y_t) = \beta_0 + \beta_1 \log(Y_{t-1}) + \delta_1 U_{t-1} + \delta_2 U_{t-2} + \delta_3 U_{t-3} + \alpha_1 \log(X_t) + U_t $

   - $\log(Y_t)$: Logarithm of banking operations.
   - $\log(X_t)$: Logarithm of mobile phone lines with internet access (exogenous variable).
   - $U_t$: Error term.

![Image](https://github.com/SebasRhoadsAvila/TimeSeries/blob/main/PIX%26CODITransactions/Images/Imagen3.png)

   **Interpretation**:
   - The exogenous variable has a positive effect, with approximately a 7% increase in banking operations.

![Image](https://github.com/SebasRhoadsAvila/TimeSeries/blob/main/PIX%26CODITransactions/Images/Imagen4.png)

   **Note**:
   - The $ARIMAX(1, 0, 3)$ model shows a bias due to the non-normality of residuals, possibly explained by three outliers in the data. However, with 48 observations (months), the expected values of the coefficients are reliable.

2. **Linear Log-Log Model**:
$\log(Y_t) = \beta_0 + \beta_1 \log(X_t) + U_t $

   - $\log(Y_t)$: Logarithm of banking operations.
   - $\log(X_t)$: Logarithm of mobile phone lines with internet access.
   - $U_t$: Error term.

![Image](https://github.com/SebasRhoadsAvila/TimeSeries/blob/main/PIX%26CODITransactions/Images/imagen5.png)

   **Interpretation**:
   - This model did not meet several assumptions (e.g., no autocorrelation, homogeneity, normality). Interestingly, the coefficient for $\( X \)$ is approximately the same as that in the $ARIMAX(1, 0, 3)$ model.

![Image](https://github.com/SebasRhoadsAvila/TimeSeries/blob/main/PIX%26CODITransactions/Images/Imagen6.png)

### Conclusion

The analysis indicates that mobile phone access can significantly explain banking operations in both Brazil and Mexico. Despite some model biases and assumption violations, the results suggest a strong relationship between the number of mobile phone accesses and the number of banking transactions.


---

Replace the `image_url_X` placeholders with the actual URLs or paths to the images you will upload to your GitHub repository. This will ensure that the text is well-integrated with the corresponding images, providing a clear and comprehensive presentation of the analysis.
