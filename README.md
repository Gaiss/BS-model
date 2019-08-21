# BS-model
Research on the Pricing of Convertible Bonds in China Using BS Model & Monte Carlo Simulation

There are downward revision clauses to all convertible bonds in China in order to avoid the bondholders' executing Selling-back rights. This will encourage the issuers and the substantial shareholders to make the downward adjustment. As a result, it may make the convertible bond-pricing model not applicable to China. Based on the assumptions that the convertible rights are European options and the new issues would not affect the stock price and volatilities, and considering all factors that may influence convertible bonds pricing, I price the convertible bonds by using Monte Carlo simulation. The empirical study indicates that the convertible bonds have been underpriced significantly when considering the amending expectation and overpriced slightly without considering the amending expectatio.

* 20180410-东北证券-东北证券可转债专题之二：可转债定价模型研究.pdf & 中国可转换债券定价研究_郑振龙_林海.pdf
> The references about the convertible bond-pricing model.

* BSmodel.m
> Take 雨虹转债(128016) as an example to predict this convertible bond's price on 2019-07-16. Simulate 10000 paths based on the BS model to perform Monte Carlo simulation. The detailed thought can refer to the above two PDF.

* BSmodel_wind.m
> Connect MATLAB to Wind to get the needed data instead of typing into it manually to realize the same goal.

* BSmodel_wind_auto.m
> By specifying the 
