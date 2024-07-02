### Vector Autoregressions for Monetary Policy


---

In this work, we aim to replicate the study by James H. Stock and Mark W. Watson, which evaluates the performance of vector autoregression (VAR) models in macroeconomic tasks such as data description, forecasting, structural inference, and policy analysis. Our goal is to understand how VAR models function in macroeconomics, and to be able to replicate this analysis in further years with new data.

To achieve this, we will provide a comprehensive analysis of VAR models, explaining their framework, types (reduced form, recursive, and structural), and their applications in macroeconomics. We will discuss the limitations of these models, as well as the challenges of adding more variables to each one. Additionally, we will detail the statistical tests and their theoretical foundations.

### Data Source

For the database, we used the FRED as the main source. Our variables are:
- **Inflation rate**: $$p_{i} = 400 \log\left(\frac{P_t}{P_{t-1}}\right), $$ where $P_t$ is the chain-weighted GDP price index.
- **Unemployment rate**: Quarterly data.
- **Federal Reserve's reference interest rate**: Quarterly data calculated as the average of the three months in each quarter.

The period studied spans from the first quarter of 1960 to the last quarter of 2000. All models are theoretically grounded with corresponding algebra. Each model will be run in R and reported in LaTeX.

### VAR Models

The following examples of vector autoregressions take the variables: interest rate, inflation, and unemployment, where $\epsilon_{1t}$, $\epsilon_{2t}$, and $\epsilon_{3t}$ are the error terms.

#### Reduced Form:
$$\begin{align*}
IR_t &= a_1 + b_{11} IR_{t-1} + b_{12} INF_{t-1} + b_{13} UNEMP_{t-1} + \epsilon_{1t} \\
INF_t &= a_2 + b_{21} IR_{t-1} + b_{22} INF_{t-1} + b_{23} UNEMP_{t-1} + \epsilon_{2t} \\
UNEMP_t &= a_3 + b_{31} IR_{t-1} + b_{32} INF_{t-1} + b_{33} UNEMP_{t-1} + \epsilon_{3t}
\end{align*}$$

$$
\begin{bmatrix}
IR_t \\
INF_t \\
UNEMP_t
\end{bmatrix} =
\begin{bmatrix}
a_1 \\
a_2 \\
a_3
\end{bmatrix}
+
\begin{bmatrix}
b_{11} & b_{12} & b_{13} \\
b_{21} & b_{22} & b_{23} \\
b_{31} & b_{32} & b_{33}
\end{bmatrix}
\begin{bmatrix}
IR_{t-1} \\
INF_{t-1} \\
UNEMP_{t-1}
\end{bmatrix}
+
\begin{bmatrix}
\epsilon_{1t} \\
\epsilon_{2t} \\
\epsilon_{3t}
\end{bmatrix}
$$


This type of VAR expresses each variable as a linear function of its own past values, considering the past values of all other variables and a serially uncorrelated error term: $\text{Cor}(\epsilon_{it}$, $\epsilon_{it-k}) = 0 $. Each equation in this model is estimated by ordinary least squares regression. The error terms in these regressions represent the "surprise" movements in the variables after accounting for their past values. If the variables are correlated with each other, the error terms in the reduced-form model will also be correlated across equations.

In the article "Vector Autoregressions," the authors use 4 lags, meaning they utilize the regressors from 4 past periods:

$$ IR_t = a_1 + \sum_{i=1}^{4} (b_{1i1} IR_{t-i} + b_{1i2} INF_{t-i} + b_{1i3} UNEMP_{t-i}) + \epsilon_{1t} $$

$$ INF_t = a_2 + \sum_{i=1}^{4} (b_{2i1} IR_{t-i} + b_{2i2} INF_{t-i} + b_{2i3} UNEMP_{t-i}) + \epsilon_{2t} $$

$$ UNEMP_t = a_3 + \sum_{i=1}^{4} (b_{3i1} IR_{t-i} + b_{3i2} INF_{t-i} + b_{3i3} UNEMP_{t-i}) + \epsilon_{3t} $$

In matrix form:

$$ Y_t = A + B_1 Y_{t-1} + B_2 Y_{t-2} + B_3 Y_{t-3} + B_4 Y_{t-4} + \epsilon_t $$

$$
Y_t = \begin{bmatrix} IR_t \\ 
INF_t \\ 
UNEMP_t \end{bmatrix}
A = 
\begin{bmatrix}
a_1 \\
a_2 \\
a_3
\end{bmatrix}
\epsilon_t = 
\begin{bmatrix}
\epsilon_{1t} \\
\epsilon_{2t} \\
\epsilon_{3t}
\end{bmatrix}
$$

Where $B_i$ are 3x3 matrices for the coefficients of lags 1 to 4, respectively.

#### Recursive Form:

$$\begin{align*}
IR_t &= a_1 + b_{11} IR_{t-1} + b_{12} INF_{t-1} + b_{13} UNEMP_{t-1} + \epsilon_{1t} \\
INF_t &= a_2 + b_{21} IR_{t-1} + b_{22} INF_{t-1} + b_{23} UNEMP_{t-1} + \delta_{21} IR_t + \epsilon_{2t} \\
UNEMP_t &= a_3 + b_{31} IR_{t-1} + b_{32} INF_t + b_{33} UNEMP_{t-1} + \delta_{31} IR_t + \delta_{32} INF_t + \epsilon_{3t}
\end{align*}$$

$$
\begin{bmatrix}
IR_t \\
INF_t \\
UNEMP_t
\end{bmatrix} =
\begin{bmatrix}
a_1 \\
a_2 \\
a_3
\end{bmatrix}
+
\begin{bmatrix}
b_{11} & b_{12} & b_{13} \\
b_{21} & b_{22} & b_{23} \\
b_{31} & b_{32} & b_{33}
\end{bmatrix}
\begin{bmatrix}
IR_{t-1} \\
INF_{t-1} \\
UNEMP_{t-1}
\end{bmatrix}
+
\begin{bmatrix}
0 & 0 & 0 \\
\delta_{21} & 0 & 0 \\
\delta_{31} & \delta_{32} & 0
\end{bmatrix}
\begin{bmatrix}
IR_t \\
INF_t \\
UNEMP_t
\end{bmatrix}
+
\begin{bmatrix}
\epsilon_{1t} \\
\epsilon_{2t} \\
\epsilon_{3t}
\end{bmatrix}
$$

This model constructs the error terms in each regression equation to be uncorrelated with the errors in the preceding equations. It achieves this by including some contemporaneous values as regressors. The results of a recursive VAR depend on the order of the variables. Changing the order changes the equations, coefficients, and residuals of the VAR.

A recursive model with 4 lags can be seen as follows:

$$\begin{align*}
INF_t &= a_1 + \sum_{i=1}^{4} (b_{1i1} IR_{t-i} + b_{1i2} INF_{t-i} + b_{1i3} UNEMP_{t-i}) + \epsilon_{1t} \\
UNEMP_t &= a_2 + c_{21} INF_t + \sum_{i=1}^{4} (b_{2i1} IR_{t-i} + b_{2i2} INF_{t-i} + b_{2i3} UNEMP_{t-i}) + \epsilon_{2t} \\
IR_t &= a_3 + c_{31} INF_t + c_{32} UNEMP_t + \sum_{i=1}^{4} (b_{3i1} IR_{t-i} + b_{3i2} INF_{t-i} + b_{3i3} UNEMP_{t-i}) + \epsilon_{3t}
\end{align*}$$

In matrix form:

$$Y_t = A + C Y_t + B_1 Y_{t-1} + B_2 Y_{t-2} + B_3 Y_{t-3} + B_4 Y_{t-4} + \epsilon_t$$

$$
Y_t = \begin{bmatrix} IR_t \\ 
INF_t \\ 
UNEMP_t \end{bmatrix}
A = 
\begin{bmatrix}
a_1 \\
a_2 \\
a_3
\end{bmatrix}
\epsilon_t = 
\begin{bmatrix}
\epsilon_{1t} \\
\epsilon_{2t} \\
\epsilon_{3t}
\end{bmatrix}
C = 
\begin{bmatrix}
0 & 0 & 0 \\
c_{21} & 0 & 0 \\
c_{31} & c_{32} & 0
\end{bmatrix}
$$

Where $B_i$ are 3x3 matrices for the coefficients of lags 1 to 4, respectively.

#### Structural Form:

This type of VAR uses economic theory to order the contemporaneous links between variables. Structural VARs require "assumptions" that allow correlations to be interpreted causally. These assumptions can apply to the entire VAR or just one equation. The number of structural VARs is limited only by the researcher's inventiveness.

Theoretically, this model could look like the reduced-form model. However, the vector $\epsilon_t$ can be interpreted as a shock explained by the surprise elements of each variable of interest.

$$
\begin{bmatrix}
IR_t \\
INF_t \\
UNEMP_t
\end{bmatrix} =
\begin{bmatrix}
a_1 \\
a_2 \\
a_3
\end{bmatrix}
+
\begin{bmatrix}
b_{11} & b_{12} & b_{13} \\
b_{21} & b_{22} & b_{23} \\
b_{31} & b_{32} & b_{33}
\end{bmatrix}
\begin{bmatrix}
IR_{t-1} \\
INF_{t-1} \\
UNEMP_{t-1}
\end{bmatrix}
+
\begin{bmatrix}
\epsilon_{1t} \\
\epsilon_{2t} \\
\epsilon_{3t}
\end{bmatrix}
$$

where

$$
\begin{bmatrix}
\epsilon_{1t} \\
\epsilon_{2t} \\
\epsilon_{3t}
\end{bmatrix} =
\begin{bmatrix}
\delta_{11} & \delta_{12} & \delta_{13} \\
\delta_{21} & \delta_{22} & \delta_{23} \\
\delta_{31} & \delta_{32} & \delta_{33}
\end{bmatrix}
\begin{bmatrix}
\omega_{1t} \\
\omega_{2t} \\
\omega_{3t}
\end{bmatrix}
$$

The authors base the model on the following Taylor rule: 
$R_t = r^* + 1.5 (\bar{\pi}_t - \pi^* ) - 1.25 (\bar{u}_t - u^*) + \text{lagged values of } R, \pi, u + \epsilon_t$

### Descriptive Analysis

According to the article by Stock and Watson, VAR analysts typically report the results of Granger causality tests, impulse responses, and forecast error variance decompositions. These statistics are more informative than estimated VAR regression coefficients or $R^2$ statistics, which are often not reported.

Granger causality tests are statistical hypothesis tests used to determine whether one time series can predict another. They are based on the idea of predictability and do not prove a cause-effect relationship. Specifically, if variable $X$ $Granger-causes$ variable $Y$, then past values of $X$ must contain information that helps predict $Y$, beyond the information contained in past values of $Y$ alone.

For example: We propose a reduced VAR model for variable $Y$ based on its own past values and the past values of another variable $X$:

$$Y_t = \alpha_0 + \alpha_1 Y_{t-1} + \ldots + \alpha_p Y_{t-p} + \beta_1 X_{t-1} + \ldots + \beta_p X_{t-p} + \epsilon_t$$

Where $t$ is the time window, $p$ is the number of lags, and $\epsilon_t$ is the error term.

- $H_0$: $X$ does not $Granger-cause$ $Y$. That is, all coefficients $(\beta_1, \beta_2, \ldots, \beta_p)$ are zero.
- $H_1$: $X$ $Granger-causes$ $Y$. That is, at least one of the coefficients $(\beta_1, \beta_2, \ldots, \beta_p)$ is not zero.

We compare the $F-statistic$ of two models, one restricted and one unrestricted, with the critical value of an $F$ distribution with $p$ and $T - 2p$ degrees of freedom. 
Where $p$ is the number of lags, $T$ is the sample size, and $SRC$ is the sum of squared residuals for each model.

$$ F = \frac{(SRC_{restricted} - SRC_{unrestricted}) / p}{SRC_{unrestricted} / (T - 2p)} \sim F_{p, T-2p} $$

The unrestricted model can be seen as:

$$Y_t = \alpha_0 + \alpha_1 Y_{t-1} + \ldots + \alpha_p Y_{t-p} + \beta_1 X_{t-1} + \ldots + \beta_p X_{t-p} + \epsilon_t$$

The restricted model looks like this:

$$Y_t = \alpha_0 + \alpha_1 Y_{t-1} + \ldots + \alpha_p Y_{t-p} + \nu_t$$

If $F > F_{p, T-2p}$ $\Rightarrow$ reject $H_0$ and $X$ Granger-causes $Y$.

When performing this test in a programming language, we can directly obtain a $p-value$, and a value less than 0.05 typically means we can reject the null hypothesis, indicating good news for our model.

That said, the Granger test can also be estimated as an individual significance test for each coefficient. This is the case in the work of Stock and Watson, whose results are shown below:

![Image](https://github.com/SebasRhoadsAvila/TimeSeries/blob/main/MonetaryPolicyUS/Images/Imagen1.png)

The table shows the $p-values$ of each time series relative to the dependent variable of each linear equation. Low values indicate it is easy and intuitive to reject the hypothesis that the dependent time series cannot be forecasted. This means there is a significant relationship between variables. However, this hypothesis cannot be rejected in two cases: the FED interest rate relative to inflation and the inflation rate relative to the unemployment rate, with values of 0.27 and 0.31, respectively.

When replicating the hypothesis tests, we obtain different results. In our attempt, in each scenario, we reject the null hypothesis because their $p-values$ are very low.

![Image](https://github.com/SebasRhoadsAvila/TimeSeries/blob/main/MonetaryPolicyUS/Images/Imagen2.png)

In the next section, the authors provide the variance decomposition for different prediction horizons. Their table is divided into 3 sections, each part of the hypothesis of a shock in one variable, analyzing impulse response functions.

![Image](https://github.com/SebasRhoadsAvila/TimeSeries/blob/main/MonetaryPolicyUS/Images/Imagen3.png)

The data in the previous tables show, in each row, how much of the variability of the dependent series is explained through the independent series, starting from the assumption of a shock in one of the variables.

For example, the first table assumes a shock in the inflation rate. In the first row, 100% of the variance of $\pi$ is explained by the same inflation one period after the shock. This variance decreases over time, indicating that the shock's effect is immediate in inflation and diminishes in the long run. The opposite effect is seen in unemployment, whose variance increases gradually, albeit at a very low level. The second and third tables show the effect of a shock in the unemployment rate and the FED rate, respectively.

In this case, we replicate the data with insignificant differences:

![Image](https://github.com/SebasRhoadsAvila/TimeSeries/blob/main/MonetaryPolicyUS/Images/Imagen4.png)

VARs capture comovements in time series that univariate or bivariate models do not detect. Statistics like Granger causality tests and impulse response functions are essential for representing these comovements and serve as references for theoretical macroeconomic models.

![Image](https://github.com/SebasRhoadsAvila/TimeSeries/blob/main/MonetaryPolicyUS/Images/imagen5.png)

Impulse response functions for the recursive VAR are shown in the matrix of 9 graphs. The first row shows the effect of a 1 percentage point unexpected increase in inflation on the three variables, as it processes through the recursive VAR system with coefficients estimated from real data. The second row shows the effect of a 1 percentage point unexpected increase in the unemployment rate, and the third row shows the corresponding effect for the interest rate. These estimated functions show patterns of persistent common variation. For example, an unexpected increase in inflation gradually fades over 24 quarters and is associated with a persistent increase in unemployment and interest rates.

![Image](https://github.com/SebasRhoadsAvila/TimeSeries/blob/main/MonetaryPolicyUS/Images/Imagen6.png)

Notably, the second matrix is a replication of the first.

### Forecasts

For forecasts, predictions are evaluated at various horizons, such as two quarters, four quarters, and eight quarters. These predictions are compared with those made by a univariate autoregression model and a "random walk" (or "no change") model.

The next table, titled "Root Mean Squared Errors of Simulated Out-Of-Sample Forecasts, 1985:1–2000:IV," presents the mean squared forecast errors calculated recursively for univariate and vector autoregressions, as well as for a random walk model. The results for the random walk and univariate autoregressions are shown in the columns labeled RW (random walk) and AR (auto regression), respectively. Each model was estimated using data from 1960:I to the start of the forecast period.

![Image](https://github.com/SebasRhoadsAvila/TimeSeries/blob/main/MonetaryPolicyUS/Images/Imagen7.png)

An ECM is calculated as follows:

$$ECM = \frac{1}{n} \sum_{i=1}^{n} (y_i - \hat{y}_i)^2$$

Where $n$ is the total number of observations, $y_i$ is the observed or actual value for observation $i$, and $\hat{y}_i$ is the predicted value for observation $i$.

![Image](https://github.com/SebasRhoadsAvila/TimeSeries/blob/main/MonetaryPolicyUS/Images/Imagen8.png)


The replicated results contain significantly different values. However, both tables reach the same conclusion. The data indicate that, in many cases, the VAR improves or performs similarly to univariate autoregression, and both outperform the random walk forecast. In simple terms, the VAR provides accurate forecasts compared to other models, especially for forecasting inflation, unemployment, and interest rates.


### Structural Inference

Structural inference in the context of VARs focuses on understanding causal relationships between economic variables. Since VARs only predict future values based on past values, to make causal inferences, such as determining if a change in one variable is responsible for a change in another, additional information is needed.

Structural VARs impose restrictions based on economic theory or institutional knowledge, rather than relying solely on data. These restrictions can include assumptions about the timing of effects or the absence of certain relationships.

VARs often employ "identifying assumptions" to determine contemporary relationships between variables, such as assuming some are exogenous. These assumptions allow the model to be estimated in a way that the relationships between variables can be interpreted causally.

Recall that a structural model can look like this:

$$Y_t = A + B_1 Y_{t-1} + B_2 Y_{t-2} + B_3 Y_{t-3} + B_4 Y_{t-4} + \epsilon_t$$

Where $\epsilon_t$ is the vector of uncorrelated "innovation" errors, constrained as follows:

The first constraints correspond to the retrospective model, where monetary policy does not respond to contemporary shocks in inflation or unemployment. The second constraint corresponds to the prospective model, where coefficients $\delta_{31}$ and $\delta_{32}$ allow a relationship between monetary policy and contemporary shocks of the other variables.

![Image](https://github.com/SebasRhoadsAvila/TimeSeries/blob/main/MonetaryPolicyUS/Images/Imagen10.png)


### Policy Analysis

Stock and Watson argue for two types of policies: the first, which is to maintain the Taylor rule to observe the behavior of variables in response to a monetary shock (or innovations); and the second, where the rule is replaced by another subject to the creativity or knowledge of the researcher.

- **Point Innovations**: These refer to unexpected changes or shocks in policy while the underlying policy rule remains unchanged. The effects of such innovations are captured by impulse response functions within the VAR framework. The structural model graphs are sufficient to explain this case. However, interpreting these effects can be challenging due to potential issues such as the identification problem, where it is difficult to determine the true source and impact of policy shocks.
- **Changes in Policy Rules**: This involves scenarios where the policy rule itself changes. Estimating the effects of such changes is more complex because if the structural equations of the model include expectations (as in the prospective model), these expectations will be influenced by the policy rule. Consequently, the VAR model's coefficients will also depend on the policy rule. This interdependence reflects the essence of Lucas' critique, which holds that policy evaluations based on historical data can be unreliable because the model parameters are likely to change when the policy changes. People's behavior changes as they adjust their future expectations to the new policy.

### References:

1. U.S. Bureau of Economic Analysis. (2023). Real Gross Domestic Product: Chained 2012 Dollars [GDPCTPI]. Retrieved from FRED, Federal Reserve Bank of St. Louis website: https://fred.stlouisfed.org/series/UNRATE
2. U.S. Bureau of Labor Statistics. (2023). Unemployment Rate [UNRATE]. Retrieved from FRED, Federal Reserve Bank of St. Louis website: https://fred.stlouisfed.org/series/GDPCTPI
3. Board of Governors of the Federal Reserve System (US). (2023). Federal Funds Effective Rate [FEDFUNDS]. Retrieved from FRED, Federal Reserve Bank of St. Louis website: https://fred.stlouisfed.org/series/FEDFUNDS
4. Stock, James, H., and Mark W. Watson. 2001. "Vector Autoregressions." Journal of Economic Perspectives, 15 (4): 101-115.

