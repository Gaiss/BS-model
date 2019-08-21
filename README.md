# BS-model
#### Research on the Pricing of Convertible Bonds in China Using BS Model & Monte Carlo Simulation

There are downward revision clauses to all convertible bonds in China in order to avoid the bondholders' executing Selling-back rights. This will encourage the issuers and the substantial shareholders to make the downward adjustment. As a result, it may make the convertible bond-pricing model not applicable to China. Based on the assumptions that the convertible rights are European options and the new issues would not affect the stock price and volatilities, and considering all factors that may influence convertible bonds pricing, I price the convertible bonds by using Monte Carlo simulation. The empirical study indicates that the convertible bonds have been underpriced significantly when considering the amending expectation and overpriced slightly without considering the amending expectatio.

* [20180410-东北证券-东北证券可转债专题之二：可转债定价模型研究.pdf](https://github.com/Gaiss/BS-model/blob/master/20180410-%E4%B8%9C%E5%8C%97%E8%AF%81%E5%88%B8-%E4%B8%9C%E5%8C%97%E8%AF%81%E5%88%B8%E5%8F%AF%E8%BD%AC%E5%80%BA%E4%B8%93%E9%A2%98%E4%B9%8B%E4%BA%8C%EF%BC%9A%E5%8F%AF%E8%BD%AC%E5%80%BA%E5%AE%9A%E4%BB%B7%E6%A8%A1%E5%9E%8B%E7%A0%94%E7%A9%B6.pdf) & [中国可转换债券定价研究_郑振龙_林海.pdf](https://github.com/Gaiss/BS-model/blob/master/%E4%B8%AD%E5%9B%BD%E5%8F%AF%E8%BD%AC%E6%8D%A2%E5%80%BA%E5%88%B8%E5%AE%9A%E4%BB%B7%E7%A0%94%E7%A9%B6_%E9%83%91%E6%8C%AF%E9%BE%99_%E6%9E%97%E6%B5%B7.pdf)
> The references about the convertible bond-pricing model.

* [BSmodel.m](https://github.com/Gaiss/BS-model/blob/master/BSmodel.m)
> Take 雨虹转债(128016) as an example to predict this convertible bond's price on 2019-07-16. Simulate 10000 paths based on the BS model to perform Monte Carlo simulation. The detailed thought can refer to the above two PDF.

* [BSmodel_wind.m](https://github.com/Gaiss/BS-model/blob/master/BSmodel_wind.m)
> Connect MATLAB to Wind to get the needed data instead of typing into it manually to realize the same goal.

* [BSmodel_wind_auto.m](https://github.com/Gaiss/BS-model/blob/master/BSmodel_wind_auto.m)
> By specifying the convertible bond code and the time interval, the programme canwill automatically get the needed data from Wind and do the pricing prediction on each trade day during the period of time.

> Data visualization is available to display the paths, the pie chart of the result conditions, the statistic analysis of the result and the comparation between the predicting prices and the true prices.

* [可转债定价模型研究_Gaiss.pdf](https://github.com/Gaiss/BS-model/blob/master/%E5%8F%AF%E8%BD%AC%E5%80%BA%E5%AE%9A%E4%BB%B7%E6%A8%A1%E5%9E%8B%E7%A0%94%E7%A9%B6_Gaiss.pdf)
> A presentation of my whole process and results.

Looking forward to your modification suggestion!
