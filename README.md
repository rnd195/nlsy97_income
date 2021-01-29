### NLSY97 Income

#### a) Data description

Let us present the variables that we have decided to include together with our rationale (see `data/NLSY97_DETAIL.txt` for more info about the variables):

| Variable name   | Description & Justification                                  |
| --------------- | ------------------------------------------------------------ |
| *income*        | Description: Total income of an individual in 2016 <br />Justification: This is simply the dependent variable of interest. |
| *degree*        | Description: Whether an individual has a college degree (from bachelor's to a professional degree) <br />Justification: Positions that require specialized knowledge often require university education. With this variable, we will only be looking at the difference between having no degree and *a* degree (no differentiation between a bachelor's degree or a PhD). |
| *hispan*        | Description: Whether an individual is Hispanic <br />Justification: Systemic racism may still be present in the USA, and thus, we believe that it might play a role in determining wages. |
| *black*         | Description: Whether an individual is from a black racial group <br />Justification: Same rationale as for the `hispan` variable. |
| *exper*         | Description: Number of years worked since age 20 (transformed from weeks) <br />Justification: Wage certainly depends on experience in the field – junior positions get paid less than seniors. |
| *feduc & meduc* | Description: Highest grade completed of the respondent's father and mother <br />Justification: The variable "degree" may be endogenous (more on that later), thus, we will utilize these as instrumental variables. Educated parents might nudge their child into the *right* direction. Moreover, father's/mother's education is not the decision of the child. |
| *married*       | Description: Whether an individual is currently married <br />Justification: Cohen (1991) states that: "Wives are said to improve the household’s decision making process, to motivate men to put more effort into their jobs, to provide emotional support and advice on job-related matters, and to perform tasks directly related to their husbands’ jobs." |
| *child*         | Description: Number of respondent's children living in the same house <br />Justification: Due to tax deductions, people with children have a higher income. |
| *abil*          | Description: ASVAB Math and Verbal test score <br />Justification: We think that this variable may capture the worker's abilities – more *able* workers should be paid more. We will focus on this later. |

There is no way we could fit all the relevant tables and summaries into a 3-page document, and therefore, these will be included in the Appendix, so excuse us for going over the limit.

In Figure 2 (Appendix), we may find the summary statistics for the aforementioned variables. We will be working with 712 observations, which is plenty for an analysis. Note that all of these variables are filtered for males only (as suggested in the setup). Missing values were mapped to negative values in the original dataset, which we have accounted for in the R code. Furthermore, many of our variables are dummies, which are convenient to work with due to their simple interpretation.  

From the summary statistics of the `degree` variable, we see that there are more people without a college degree, however, the number of people with a degree is not negligible. Moreover, there are 89 black people and 125 Hispanics in our dataset – we were concerned that the final subset would not include many people of color, and in turn, biasing the estimation (low precision with a very small number of observations).

The variables `feduc` & `meduc` are relatively normally distributed albeit a bit skewed, however, we think that it does not pose an issue here. On the other hand, `abil` and `exper` might be a bit problematic in terms of distributions (uniform and skewed, respectively). All in all, we have decided not to interfere so that we would not hurt the interpretation.

Furthermore, we are planning on log-transforming the `income` variable to lower the disparities between high- and low-earning individuals, hence the minimum of income is 200 and not zero.

#### b) Base model

First, we will be using the base model suggested in the setup:

![base](https://imgur.com/dOTEqVz.jpg)

Estimating the model with robust standard errors (presence of heteroskedasticity) yields the following results – standard errors are below the estimates:

![base results](https://imgur.com/egzDvOG.jpg)

According to this model, having a degree significantly increases income by almost 50%. Strangely, with increasing experience (also significant), the income falls. This may be attributed to the fact that a lot of the surveyed people are relatively young (born in the 80s) in combination with the fact that the base model may not be very accurate. However, experience squared is positive and significant, suggesting that, for example, the difference in 15 to 20 years of work experience in relation to wage is smaller than the initial few years. Finally, the R-squared is around 0.18 (see Figure 2 in the Appendix for more statistics).

We believe that the model is subject to omitted variable bias (OVB) as, for example, more *able* individuals tend to go to college (*Corr(degree, ability) not equal to 0*). Moreover, other factors such as the wealth of parents or motivation to study may also help in determining income. Consequently, the estimate of the `degree` variable may be overstated. In any case, **if there is an endogenous variable in the model, OLS would be biased and inconsistent,** which means that OLS is not BLUE.

Let us approach the the suspected OVB in two ways: using a proxy variable (discussed in **c)**) and by finding valid instruments for the `degree` variable (part **d)**).

#### c) Proxy variable

We believe that the variable which would represent the ability of an individual should also be present in the model. In fact, Blackburn and Neumark (1993) state that if returns to education are estimated without accounting for ability then an upwards bias should be expected. How do we measure ability, though? Ideally, we would need to find some kind of a cognitive test that most of the respondents have taken and use it as a proxy. SAT or ACT are not the best for this approach because only people who plan on going to college sit these exams – this would greatly reduce the sample size and exclude people who did not plan on going to college.

However, most people (7000+) in the dataset were tested in the [ASVAB test](https://www.military.com/join-armed-forces/asvab). This test apparently scores people in 4 areas – arithmetic, word knowledge, text comprehension and maths. Thus, we will use the results of this test as a proxy for ability. It turns out that the correlation between the variables `abil` and `degree` is over 0.5, which indicates that the first model might have really been subject to OVB.

#### d) Instrumental variables

To tackle the additional issues with the `degree` variable, let us use instrumental variables. The idea is that by using a relevant exogenous variable, we resolve the issue of endogeneity – a valid instrument should fulfill the condition of exogeneity (*Cov(z,u)=0* – not directly testable) and should also be relevant (*Cov(z, degree) not equal to 0* – testable).

There are two candidates for the role of IVs for the `degree` variable, and these are: education of the respondent's father (`feduc`) and education of the respondent's mother (`meduc`). On a theoretical level, educated parents might expect their children to also be educated and will help them achieve this goal (relevance). Furthermore, the education of the father, for example, is a decision of the father, which would suggest that the exogeneity assumption is satisfied.

Testing for relevance, we see that *Corr(feduc, degree)=0.403* and *​Corr(meduc, degree)=0.337​*. Later on, we will conduct additional tests to see whether this approach is correct.

#### e) Full model and discussion

We have settled on the following model (see **a)** for the justification of the chosen variables):



![estimation results1](https://imgur.com/ewdpYkj.jpg)



Now, let us present all the results of the estimation methods that we have considered (see Appendix Figure 1 for a detailed table) – standard errors are listed below the estimates. Note that all models use robust standard errors due to the presence of heteroskedasticity:

![estimation results2](https://imgur.com/Gn2Gf3M.jpg)


To answer the main question of this problem, we see that the effect of having a degree is highly significant in the OLS model but much smaller than in the restricted model, nevertheless, it seems that **having a college degree increases income by 32%**. Thus, the base model may have overstated the magnitude of the effect. Furthermore, the estimate of `exper` is still negative and significant, although less so, but smaller in absolute terms. Again, we are not quite sure why that is the case, but let us stress the fact that we are dealing with a sample of relatively young people. Therefore, the effect of work experience may not be very accurate.

The effect of race in both `black` and `hispan` is not significant, which may suggest that employers no longer discriminate these groups of people in terms of wage. On the other hand, as expected, being married and having children significantly increases income by about 25% and 7% (for each child), respectively. Lastly, the estimate of `abil` is also significant but very small in absolute terms, which may be attributed to its format. It would be worthwhile to see whether a different proxy variable would perform better.

Overall, the 2SLS model is, very similar. The difference is in the larger effect of the `degree` variable (with much bigger standard errors) and no significance for the parameter of `abil`. Both models hover around the 0.24 mark in terms of *R-squared*, which is satisfactory.

**Which model do we prefer?** By performing a variety of tests (see the "Testing" block in the .R file), we see that our instruments (`feduc` and `meduc`) are not weak. However, we fail to reject the null hypothesis in the Wu-Hausman test, which means that **both OLS and 2SLS are consistent but OLS is more efficient.** Moreover, in the Sargan test for overidentification, we fail to reject *H null:Cov(z,u)=0​*, which implies that at least one of the IVs is exogenous. It is worth noting that the latter 2 tests are only valid under homoskedasticity, thus, we used robust standard errors as both models suffered from heteroskedasticity.

In conclusion, we would prefer using the OLS model with robust standard errors because we are lead to believe that it is more efficient than the 2SLS model with respect to the result of the Wu-Hausman test. To reiterate the answer to the main question, it seems that having a college degree increases wage by about 32%.

<div style = "page-break-after: always;"></div>


### Appendix

#### Figure 1 – Estimation results

![table](https://i.imgur.com/xOnDiqR.jpg)

<div style = "page-break-after: always;"></div>

#### Figure 2 – Data summary

<div class="container st-container">
  <table class="table table-striped table-bordered st-table st-table-striped st-table-bordered st-multiline ">
  <thead>
    <tr>
      <th align="center" class="st-protect-top-border"><strong>No</strong></th>
      <th align="center" class="st-protect-top-border"><strong>Variable</strong></th>
      <th align="center" class="st-protect-top-border"><strong>Stats / Values</strong></th>
      <th align="center" class="st-protect-top-border"><strong>Freqs (% of Valid)</strong></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">1</td>
      <td align="left">income
[numeric]</td>
      <td align="left">Mean (sd) : 59337.4 (28950.5)
<br /> min < med < max: <br />
200 < 55000 < 140000
<br /> IQR (CV) : 39000 (0.5)</td>
      <td align="left" style="vertical-align:middle">140 distinct values</td>
	  </td>
    </tr>
    <tr>
      <td align="center">2</td>
      <td align="left">degree
[numeric]</td>
      <td align="left">Min : 0
Mean : 0.4
Max : 1</td>
      <td align="left" style="padding:0;vertical-align:middle"><table style="border-collapse:collapse;border:none;margin:0"><tr style="background-color:transparent"><td style="padding:0 0 0 7px;margin:0;border:0" align="right">0</td><td style="padding:0 2px;border:0;" align="left">:</td><td style="padding:0 4px 0 6px;margin:0;border:0" align="right">446</td><td style="padding:0;border:0" align="left">(</td><td style="padding:0 2px;margin:0;border:0" align="right">62.6%</td><td style="padding:0 4px 0 0;border:0" align="left">)</td></tr><tr style="background-color:transparent"><td style="padding:0 0 0 7px;margin:0;border:0" align="right">1</td><td style="padding:0 2px;border:0;" align="left">:</td><td style="padding:0 4px 0 6px;margin:0;border:0" align="right">266</td><td style="padding:0;border:0" align="left">(</td><td style="padding:0 2px;margin:0;border:0" align="right">37.4%</td><td style="padding:0 4px 0 0;border:0" align="left">)</td></tr></table></td>
      </td>
    </tr>
    <tr>
      <td align="center">3</td>
      <td align="left">hispan
[numeric]</td>
      <td align="left">Min : 0
Mean : 0.2
Max : 1</td>
      <td align="left" style="padding:0;vertical-align:middle"><table style="border-collapse:collapse;border:none;margin:0"><tr style="background-color:transparent"><td style="padding:0 0 0 7px;margin:0;border:0" align="right">0</td><td style="padding:0 2px;border:0;" align="left">:</td><td style="padding:0 4px 0 6px;margin:0;border:0" align="right">587</td><td style="padding:0;border:0" align="left">(</td><td style="padding:0 2px;margin:0;border:0" align="right">82.4%</td><td style="padding:0 4px 0 0;border:0" align="left">)</td></tr><tr style="background-color:transparent"><td style="padding:0 0 0 7px;margin:0;border:0" align="right">1</td><td style="padding:0 2px;border:0;" align="left">:</td><td style="padding:0 4px 0 6px;margin:0;border:0" align="right">125</td><td style="padding:0;border:0" align="left">(</td><td style="padding:0 2px;margin:0;border:0" align="right">17.6%</td><td style="padding:0 4px 0 0;border:0" align="left">)</td></tr></table></td>
      </td>
    </tr>
    <tr>
      <td align="center">4</td>
      <td align="left">black
[numeric]</td>
      <td align="left">Min : 0
Mean : 0.1
Max : 1</td>
      <td align="left" style="padding:0;vertical-align:middle"><table style="border-collapse:collapse;border:none;margin:0"><tr style="background-color:transparent"><td style="padding:0 0 0 7px;margin:0;border:0" align="right">0</td><td style="padding:0 2px;border:0;" align="left">:</td><td style="padding:0 4px 0 6px;margin:0;border:0" align="right">623</td><td style="padding:0;border:0" align="left">(</td><td style="padding:0 2px;margin:0;border:0" align="right">87.5%</td><td style="padding:0 4px 0 0;border:0" align="left">)</td></tr><tr style="background-color:transparent"><td style="padding:0 0 0 7px;margin:0;border:0" align="right">1</td><td style="padding:0 2px;border:0;" align="left">:</td><td style="padding:0 4px 0 6px;margin:0;border:0" align="right">89</td><td style="padding:0;border:0" align="left">(</td><td style="padding:0 2px;margin:0;border:0" align="right">12.5%</td><td style="padding:0 4px 0 0;border:0" align="left">)</td></tr></table></td>
      </td>
    </tr>
    <tr>
      <td align="center">5</td>
      <td align="left">exper
[numeric]</td>
      <td align="left">Mean (sd) : 13.1 (3.5)
<br /> min < med < max: <br />
0 < 13.8 < 18.3
<br /> IQR (CV) : 3.2 (0.3)</td>
      <td align="left" style="vertical-align:middle">386 distinct values</td>
      </td>
    </tr>
    <tr>
      <td align="center">6</td>
      <td align="left">feduc
[numeric]</td>
      <td align="left">Mean (sd) : 13.1 (3.3)
<br /> min < med < max: <br />
2 < 12 < 20
<br /> IQR (CV) : 4 (0.3)</td>
      <td align="left" style="vertical-align:middle">19 distinct values</td>
      </td>
    </tr>
    <tr>
      <td align="center">7</td>
      <td align="left">meduc
[numeric]</td>
      <td align="left">Mean (sd) : 12.9 (2.8)
<br /> min < med < max: <br />
2 < 12 < 20
<br /> IQR (CV) : 2 (0.2)</td>
      <td align="left" style="vertical-align:middle">18 distinct values</td>
      </td>
    </tr>
    <tr>
      <td align="center">8</td>
      <td align="left">married
[numeric]</td>
      <td align="left">Min : 0
Mean : 0.8
Max : 1</td>
      <td align="left" style="padding:0;vertical-align:middle"><table style="border-collapse:collapse;border:none;margin:0"><tr style="background-color:transparent"><td style="padding:0 0 0 7px;margin:0;border:0" align="right">0</td><td style="padding:0 2px;border:0;" align="left">:</td><td style="padding:0 4px 0 6px;margin:0;border:0" align="right">152</td><td style="padding:0;border:0" align="left">(</td><td style="padding:0 2px;margin:0;border:0" align="right">21.3%</td><td style="padding:0 4px 0 0;border:0" align="left">)</td></tr><tr style="background-color:transparent"><td style="padding:0 0 0 7px;margin:0;border:0" align="right">1</td><td style="padding:0 2px;border:0;" align="left">:</td><td style="padding:0 4px 0 6px;margin:0;border:0" align="right">560</td><td style="padding:0;border:0" align="left">(</td><td style="padding:0 2px;margin:0;border:0" align="right">78.6%</td><td style="padding:0 4px 0 0;border:0" align="left">)</td></tr></table></td>
      </td>
    </tr>
    <tr>
      <td align="center">9</td>
      <td align="left">child
[numeric]</td>
      <td align="left">Mean (sd) : 1.8 (1.1)
<br /> min < med < max: <br />
0 < 2 < 6
<br /> IQR (CV) : 1 (0.6)</td>
      <td align="left" style="padding:0;vertical-align:middle"><table style="border-collapse:collapse;border:none;margin:0"><tr style="background-color:transparent"><td style="padding:0 0 0 7px;margin:0;border:0" align="right">0</td><td style="padding:0 2px;border:0;" align="left">:</td><td style="padding:0 4px 0 6px;margin:0;border:0" align="right">81</td><td style="padding:0;border:0" align="left">(</td><td style="padding:0 2px;margin:0;border:0" align="right">11.4%</td><td style="padding:0 4px 0 0;border:0" align="left">)</td></tr><tr style="background-color:transparent"><td style="padding:0 0 0 7px;margin:0;border:0" align="right">1</td><td style="padding:0 2px;border:0;" align="left">:</td><td style="padding:0 4px 0 6px;margin:0;border:0" align="right">216</td><td style="padding:0;border:0" align="left">(</td><td style="padding:0 2px;margin:0;border:0" align="right">30.3%</td><td style="padding:0 4px 0 0;border:0" align="left">)</td></tr><tr style="background-color:transparent"><td style="padding:0 0 0 7px;margin:0;border:0" align="right">2</td><td style="padding:0 2px;border:0;" align="left">:</td><td style="padding:0 4px 0 6px;margin:0;border:0" align="right">259</td><td style="padding:0;border:0" align="left">(</td><td style="padding:0 2px;margin:0;border:0" align="right">36.4%</td><td style="padding:0 4px 0 0;border:0" align="left">)</td></tr><tr style="background-color:transparent"><td style="padding:0 0 0 7px;margin:0;border:0" align="right">3</td><td style="padding:0 2px;border:0;" align="left">:</td><td style="padding:0 4px 0 6px;margin:0;border:0" align="right">114</td><td style="padding:0;border:0" align="left">(</td><td style="padding:0 2px;margin:0;border:0" align="right">16.0%</td><td style="padding:0 4px 0 0;border:0" align="left">)</td></tr><tr style="background-color:transparent"><td style="padding:0 0 0 7px;margin:0;border:0" align="right">4</td><td style="padding:0 2px;border:0;" align="left">:</td><td style="padding:0 4px 0 6px;margin:0;border:0" align="right">35</td><td style="padding:0;border:0" align="left">(</td><td style="padding:0 2px;margin:0;border:0" align="right">4.9%</td><td style="padding:0 4px 0 0;border:0" align="left">)</td></tr><tr style="background-color:transparent"><td style="padding:0 0 0 7px;margin:0;border:0" align="right">5</td><td style="padding:0 2px;border:0;" align="left">:</td><td style="padding:0 4px 0 6px;margin:0;border:0" align="right">2</td><td style="padding:0;border:0" align="left">(</td><td style="padding:0 2px;margin:0;border:0" align="right">0.3%</td><td style="padding:0 4px 0 0;border:0" align="left">)</td></tr><tr style="background-color:transparent"><td style="padding:0 0 0 7px;margin:0;border:0" align="right">6</td><td style="padding:0 2px;border:0;" align="left">:</td><td style="padding:0 4px 0 6px;margin:0;border:0" align="right">5</td><td style="padding:0;border:0" align="left">(</td><td style="padding:0 2px;margin:0;border:0" align="right">0.7%</td><td style="padding:0 4px 0 0;border:0" align="left">)</td></tr></table></td>
      </td>
    </tr>
    <tr>
      <td align="center">10</td>
      <td align="left">abil
[numeric]</td>
      <td align="left">Mean (sd) : 52808.5 (28670)
<br /> min < med < max: <br />
138 < 53257 < 1e+05
<br /> IQR (CV) : 49689.5 (0.5)</td>
      <td align="left" style="vertical-align:middle">706 distinct values</td>
      </td>
    </tr>
  </tbody>
</table>
  <p>Generated by <a href='https://github.com/dcomtois/summarytools'>summarytools</a> 0.9.6 (<a href='https://www.r-project.org/'>R</a> version 4.0.3) 2020-12-01</p>
</div>



### References

Blackburn, M.L. and Neumark, D., 1993. *Are OLS estimates of the return to schooling biased downward? Another look* (No. w4259). National Bureau of Economic Research.

Cohen, Y. and Haberfeld, Y., 1991. Why do married men earn more than unmarried men?. *Social Science Research*, *20*(1), pp.29-44.
