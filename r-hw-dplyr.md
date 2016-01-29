# dplyr homework

## Key Concepts

> 
- **dplyr** verbs
- the pipe `%>%`
- the `tbl_df`
- variable creation
- multiple conditions
- properties of grouped data
- aggregation
- summary functions
- window functions



## Getting Started

We're going to work with a different dataset for the homework here. It's a [cleaned-up excerpt](https://github.com/jennybc/gapminder) from the [Gapminder data](http://www.gapminder.org/data/). Download this data at [bioconnector.org/data](http://bioconnector.org/data/) -- it's the [**gapminder.csv** file](http://bioconnector.org/data/gapminder.csv). Download it, and save it in your project directory where you can access it easily from R.

Load the **dplyr** and **readr** packages, and read the gapminder data into R using the `read_csv()` function. 

Make sure you store the results in an object called `gm`.

**n.b. `read_csv()` is *not* the same as `read.csv()`**


```r
library(dplyr)
library(readr)

gm <- read_csv("data/gapminder.csv")
gm
```

```
## Source: local data frame [1,704 x 6]
## 
##        country continent  year lifeExp      pop gdpPercap
##          (chr)     (chr) (int)   (dbl)    (int)     (dbl)
## 1  Afghanistan      Asia  1952  28.801  8425333  779.4453
## 2  Afghanistan      Asia  1957  30.332  9240934  820.8530
## 3  Afghanistan      Asia  1962  31.997 10267083  853.1007
## 4  Afghanistan      Asia  1967  34.020 11537966  836.1971
## 5  Afghanistan      Asia  1972  36.088 13079460  739.9811
## 6  Afghanistan      Asia  1977  38.438 14880372  786.1134
## 7  Afghanistan      Asia  1982  39.854 12881816  978.0114
## 8  Afghanistan      Asia  1987  40.822 13867957  852.3959
## 9  Afghanistan      Asia  1992  41.674 16317921  649.3414
## 10 Afghanistan      Asia  1997  41.763 22227415  635.3414
## ..         ...       ...   ...     ...      ...       ...
```


## Problem Set

Use **dplyr** functions to address the following questions:

1) How many unique countries are represented per continent?


```
## Source: local data frame [5 x 2]
## 
##   continent     n
##       (chr) (int)
## 1    Africa    52
## 2  Americas    25
## 3      Asia    33
## 4    Europe    30
## 5   Oceania     2
```


2) Which European nation had the lowest GDP per capita in 1997? 


```
## Source: local data frame [1 x 6]
## 
##   country continent  year lifeExp     pop gdpPercap
##     (chr)     (chr) (int)   (dbl)   (int)     (dbl)
## 1 Albania    Europe  1997   72.95 3428038  3193.055
```


3) According to the data available, what was the average life expectancy across each continent in the 1980s?


```
## Source: local data frame [5 x 2]
## 
##   continent mean.lifeExp
##       (chr)        (dbl)
## 1    Africa     52.46883
## 2  Americas     67.15978
## 3      Asia     63.73456
## 4    Europe     73.22428
## 5   Oceania     74.80500
```


4) What 5 countries have the highest total GDP over all years combined?


```
## Source: local data frame [5 x 2]
## 
##          country    Total.GDP
##            (chr)        (dbl)
## 1  United States 7.676192e+13
## 2          Japan 2.543482e+13
## 3          China 2.039549e+13
## 4        Germany 1.949689e+13
## 5 United Kingdom 1.328937e+13
```


5) What countries and years had life expectancies of _at least_ 80 years? 

**n.b. only output the columns of interest: country, life expectancy and year (in that order)**


```
## Source: local data frame [22 x 3]
## 
##             country lifeExp  year
##               (chr)   (dbl) (int)
## 1         Australia  80.370  2002
## 2         Australia  81.235  2007
## 3            Canada  80.653  2007
## 4            France  80.657  2007
## 5  Hong Kong, China  80.000  1997
## 6  Hong Kong, China  81.495  2002
## 7  Hong Kong, China  82.208  2007
## 8           Iceland  80.500  2002
## 9           Iceland  81.757  2007
## 10           Israel  80.745  2007
## ..              ...     ...   ...
```


6) What 10 countries have the strongest correlation (in either direction) between life expectancy and per capita GDP?


```
## Source: local data frame [10 x 2]
## 
##           country         r
##             (chr)     (dbl)
## 1          France 0.9962239
## 2         Austria 0.9929642
## 3         Belgium 0.9927496
## 4          Norway 0.9921416
## 5            Oman 0.9907526
## 6  United Kingdom 0.9898930
## 7           Italy 0.9897600
## 8          Israel 0.9884894
## 9         Denmark 0.9870896
## 10      Australia 0.9864457
```


7) Which combinations of continent (besides Asia) and year have the highest average population across all countries?

**n.b. your output should include all results sorted by highest average population**. With what you already know, this one may stump you. See [this Q&A](http://stackoverflow.com/q/27207963/654296) for how to `ungroup` before `arrange`ing.


```
## Source: local data frame [48 x 3]
## 
##    continent  year mean.pop
##        (chr) (int)    (dbl)
## 1   Americas  2007 35954847
## 2   Americas  2002 33990910
## 3   Americas  1997 31876016
## 4   Americas  1992 29570964
## 5   Americas  1987 27310159
## 6   Americas  1982 25211637
## 7   Americas  1977 23122708
## 8   Americas  1972 21175368
## 9     Europe  2007 19536618
## 10    Europe  2002 19274129
## ..       ...   ...      ...
```


8) Which three countries have had the most consistent population estimates (i.e. lowest standard deviation) across the years of available data? 


```
## Source: local data frame [3 x 2]
## 
##                 country   sd.pop
##                   (chr)    (dbl)
## 1 Sao Tome and Principe 45906.14
## 2               Iceland 48541.68
## 3            Montenegro 99737.94
```


9) Subset *gm* to only include observations from 1992 and store the results as  *gm1992*. What kind of object is this?


```
## [1] "tbl_df"     "tbl"        "data.frame"
```


10) **_Bonus!_**Excluding records from 1952, which observations indicate that the population of a country has *decreased* from the previous year **and** the life expectancy has *increased*. See [the vignette on window functions](https://cran.r-project.org/web/packages/dplyr/vignettes/window-functions.html).


```
## Source: local data frame [36 x 6]
## 
##                   country continent  year lifeExp      pop  gdpPercap
##                     (chr)     (chr) (int)   (dbl)    (int)      (dbl)
## 1             Afghanistan      Asia  1982  39.854 12881816   978.0114
## 2  Bosnia and Herzegovina    Europe  1992  72.178  4256013  2546.7814
## 3  Bosnia and Herzegovina    Europe  1997  73.244  3607000  4766.3559
## 4                Bulgaria    Europe  2002  72.140  7661799  7696.7777
## 5                Bulgaria    Europe  2007  73.005  7322858 10680.7928
## 6                 Croatia    Europe  1997  73.680  4444595  9875.6045
## 7          Czech Republic    Europe  1997  74.010 10300707 16048.5142
## 8          Czech Republic    Europe  2002  75.510 10256295 17596.2102
## 9          Czech Republic    Europe  2007  76.486 10228744 22833.3085
## 10      Equatorial Guinea    Africa  1977  42.024   192675   958.5668
## ..                    ...       ...   ...     ...      ...        ...
```
