# Tidy Data and Advanced Data Manipulation



## Review

### Prior classes

- [R basics](r-basics.html)
- [Data frames](r-dataframes.html)
- [Manipulating data with dplyr and `%>%`](r-dplyr.html)

### Data needed

Go to [bioconnector.org/data](http://bioconnector.org/data/) and download the following datasets, saving them in a `data` folder relative to your current working RStudio project:

- Heart rate data: [heartrate2dose.csv](http://bioconnector.org/data/heartrate2dose.csv)
- _Tidy_ yeast data: [brauer2007_tidy.csv](http://bioconnector.org/data/brauer2007_tidy.csv)
- _Original_ (untidy) yeast data: [brauer2007_messy.csv](http://bioconnector.org/data/brauer2007_messy.csv)
- Yeast systematic names to GO terms: [brauer2007_sysname2go.csv](http://bioconnector.org/data/brauer2007_sysname2go.csv)

## Tidy data

So far we've dealt exclusively with tidy data -- data that's easy to work with, manipulate, and visualize. That's because our dataset has two key properties:

1. Each _column_ is a _variable_.
2. Each _row_ is an _observation_.

You can read a lot more about tidy data [in this paper](http://www.jstatsoft.org/v59/i10/paper). Let's load some untidy data and see if we can see the difference. This is some made-up data for five different patients (Jon, Ann, Bill, Kate, and Joe) given three different drugs (A, B, and C), at two doses (10 and 20), and measuring their heart rate. Download the [heartrate2dose.csv](http://bioconnector.org/data/heartrate2dose.csv) file directly from [bioconnector.org/data](http://bioconnector.org/data/). Load **readr** and **dplyr**, and import and display the data.


```r
library(readr)
library(dplyr)
hr <- read_csv("data/heartrate2dose.csv")
hr
```

```
## # A tibble: 5 × 7
##    name  a_10  a_20  b_10  b_20  c_10  c_20
##   <chr> <int> <int> <int> <int> <int> <int>
## 1   jon    60    55    65    60    70    70
## 2   ann    65    60    70    65    75    75
## 3  bill    70    65    75    70    80    80
## 4  kate    75    70    80    75    85    85
## 5   joe    80    75    85    80    90    90
```

Notice how with the yeast data each variable (symbol, nutrient, rate, expression, etc.) were each in their own column. In this heart rate data, we have four variables: name, drug, dose, and heart rate. _Name_ is in a column, but _drug_ is in the header row. Furthermore the drug and _dose_ are tied together in the same column, and the _heart rate_ is scattered around the entire table. If we wanted to do things like `filter` the dataset where `drug=="a"` or `dose==20` or `heartrate>=80` we couldn't do it because these variables aren't in columns.

## The **tidyr** package

The **tidyr** package helps with this. There are several functions in the tidyr package but the ones we're going to use are `separate()` and `gather()`. The `gather()` function takes multiple columns, and gathers them into key-value pairs: it makes "wide" data longer. The `separate()` function separates one column into multiple columns. So, what we need to do is _gather_ all the drug/dose data into a column with their corresponding heart rate, and then _separate_ that column into two separate columns for the drug and dose.

Before we get started, load the **tidyr** package, and look at the help pages for `?gather` and `?separate`. Notice how each of these functions takes a data frame as input and returns a data frame as output. Thus, we can pipe from one function to the next.


```r
library(tidyr)
```


### `gather()`

The help for `?gather` tells us that we first pass in a data frame (or omit the first argument, and pipe in the data with `%>%`). The next two arguments are the names of the key and value columns to create, and all the relevant arguments that come after that are the columns we want to _gather_ together. Here's one way to do it.


```r
hr %>% gather(key=drugdose, value=hr, a_10, a_20, b_10, b_20, c_10, c_20)
```

```
## # A tibble: 30 × 3
##     name drugdose    hr
##    <chr>    <chr> <int>
## 1    jon     a_10    60
## 2    ann     a_10    65
## 3   bill     a_10    70
## 4   kate     a_10    75
## 5    joe     a_10    80
## 6    jon     a_20    55
## 7    ann     a_20    60
## 8   bill     a_20    65
## 9   kate     a_20    70
## 10   joe     a_20    75
## # ... with 20 more rows
```

But that gets cumbersome to type all those names. What if we had 100 drugs and 3 doses of each? There are two other ways of specifying which columns to gather. The help for `?gather` tells you how to do this:

> `...` Specification of columns to gather. Use bare variable names. Select all variables between x and z with x:z, exclude y with -y. For more options, see the `select` documentation.

So, we could accomplish the same thing by doing this:


```r
hr %>% gather(key=drugdose, value=hr, a_10:c_20)
```

```
## # A tibble: 30 × 3
##     name drugdose    hr
##    <chr>    <chr> <int>
## 1    jon     a_10    60
## 2    ann     a_10    65
## 3   bill     a_10    70
## 4   kate     a_10    75
## 5    joe     a_10    80
## 6    jon     a_20    55
## 7    ann     a_20    60
## 8   bill     a_20    65
## 9   kate     a_20    70
## 10   joe     a_20    75
## # ... with 20 more rows
```

But what if we didn't know the drug names or doses, but we _did_ know that the only other column in there that we _don't_ want to gather is `name`?


```r
hr %>% gather(key=drugdose, value=hr, -name)
```

```
## # A tibble: 30 × 3
##     name drugdose    hr
##    <chr>    <chr> <int>
## 1    jon     a_10    60
## 2    ann     a_10    65
## 3   bill     a_10    70
## 4   kate     a_10    75
## 5    joe     a_10    80
## 6    jon     a_20    55
## 7    ann     a_20    60
## 8   bill     a_20    65
## 9   kate     a_20    70
## 10   joe     a_20    75
## # ... with 20 more rows
```


### `separate()`

Finally, look at the help for `?separate`. We can pipe in data and omit the first argument. The second argument is the column to separate; the `into` argument is a _character vector_ of the new column names, and the `sep` argument is a character used to separate columns, or a number indicating the position to split at.

> **_Side note, and 60-second lesson on vectors_**: We can create arbitrary-length _vectors_, which are simply variables that contain an arbitrary number of values. To create a numeric vector, try this: `c(5, 42, 22908)`. That creates a three element vector. Try `c("cat", "dog")`.


```r
hr %>% 
  gather(key=drugdose, value=hr, -name) %>% 
  separate(drugdose, into=c("drug", "dose"), sep="_")
```

```
## # A tibble: 30 × 4
##     name  drug  dose    hr
## *  <chr> <chr> <chr> <int>
## 1    jon     a    10    60
## 2    ann     a    10    65
## 3   bill     a    10    70
## 4   kate     a    10    75
## 5    joe     a    10    80
## 6    jon     a    20    55
## 7    ann     a    20    60
## 8   bill     a    20    65
## 9   kate     a    20    70
## 10   joe     a    20    75
## # ... with 20 more rows
```


### Putting it all together: `gather %>% separate %>% filter %>% group_by %>% summarize`

If we create a new data frame that's a tidy version of hr, we can do those kinds of manipulations we talked about before:


```r
# Create a new data.frame
hrtidy <- hr %>% 
  gather(key=drugdose, value=hr, -name) %>% 
  separate(drugdose, into=c("drug", "dose"), sep="_")

# Optionally, view it
# View(hrtidy)

# filter
hrtidy %>% filter(drug=="a")
```

```
## # A tibble: 10 × 4
##     name  drug  dose    hr
##    <chr> <chr> <chr> <int>
## 1    jon     a    10    60
## 2    ann     a    10    65
## 3   bill     a    10    70
## 4   kate     a    10    75
## 5    joe     a    10    80
## 6    jon     a    20    55
## 7    ann     a    20    60
## 8   bill     a    20    65
## 9   kate     a    20    70
## 10   joe     a    20    75
```

```r
hrtidy %>% filter(dose==20)
```

```
## # A tibble: 15 × 4
##     name  drug  dose    hr
##    <chr> <chr> <chr> <int>
## 1    jon     a    20    55
## 2    ann     a    20    60
## 3   bill     a    20    65
## 4   kate     a    20    70
## 5    joe     a    20    75
## 6    jon     b    20    60
## 7    ann     b    20    65
## 8   bill     b    20    70
## 9   kate     b    20    75
## 10   joe     b    20    80
## 11   jon     c    20    70
## 12   ann     c    20    75
## 13  bill     c    20    80
## 14  kate     c    20    85
## 15   joe     c    20    90
```

```r
hrtidy %>% filter(hr>=80)
```

```
## # A tibble: 10 × 4
##     name  drug  dose    hr
##    <chr> <chr> <chr> <int>
## 1    joe     a    10    80
## 2   kate     b    10    80
## 3    joe     b    10    85
## 4    joe     b    20    80
## 5   bill     c    10    80
## 6   kate     c    10    85
## 7    joe     c    10    90
## 8   bill     c    20    80
## 9   kate     c    20    85
## 10   joe     c    20    90
```

```r
# analyze
hrtidy %>%
  filter(name!="joe") %>% 
  group_by(drug, dose) %>%
  summarize(meanhr=mean(hr))
```

```
## Source: local data frame [6 x 3]
## Groups: drug [?]
## 
##    drug  dose meanhr
##   <chr> <chr>  <dbl>
## 1     a    10   67.5
## 2     a    20   62.5
## 3     b    10   72.5
## 4     b    20   67.5
## 5     c    10   77.5
## 6     c    20   77.5
```


## Tidying the yeast data

Now, let's take a look at the yeast data again. The data we've been working with up to this point was already cleaned up to a good degree. All of our variables (symbol, nutrient, rate, expression, GO terms, etc.) were each in their own column. Make sure you have the necessary libraries loaded, and read in the tidy data once more into an object called `ydat`.


```r
# Load libraries
library(readr)
library(dplyr)
library(tidyr)

# Import data
ydat <- read_csv("data/brauer2007_tidy.csv")

# Optionally, View
# View(ydat)

# Or just display to the screen
ydat
```

```
## # A tibble: 198,430 × 7
##    symbol systematic_name nutrient  rate expression
##     <chr>           <chr>    <chr> <dbl>      <dbl>
## 1    SFB2         YNL049C  Glucose  0.05      -0.24
## 2    <NA>         YNL095C  Glucose  0.05       0.28
## 3    QRI7         YDL104C  Glucose  0.05      -0.02
## 4    CFT2         YLR115W  Glucose  0.05      -0.33
## 5    SSO2         YMR183C  Glucose  0.05       0.05
## 6    PSP2         YML017W  Glucose  0.05      -0.69
## 7    RIB2         YOL066C  Glucose  0.05      -0.55
## 8   VMA13         YPR036W  Glucose  0.05      -0.75
## 9    EDC3         YEL015W  Glucose  0.05      -0.24
## 10   VPS5         YOR069W  Glucose  0.05      -0.16
## # ... with 198,420 more rows, and 2 more variables: bp <chr>, mf <chr>
```

But let's take a look to see what this data originally looked like.


```r
yorig <- read_csv("data/brauer2007_messy.csv")
# View(yorig)
yorig
```

```
## # A tibble: 5,536 × 40
##          GID       YORF                    NAME GWEIGHT G0.05  G0.1 G0.15
##        <chr>      <chr>                   <chr>   <int> <dbl> <dbl> <dbl>
## 1  GENE1331X A_06_P5820  SFB2::YNL049C::1082129       1 -0.24 -0.13 -0.21
## 2  GENE4924X A_06_P5866    NA::YNL095C::1086222       1  0.28  0.13 -0.40
## 3  GENE4690X A_06_P1834  QRI7::YDL104C::1085955       1 -0.02 -0.27 -0.27
## 4  GENE1177X A_06_P4928  CFT2::YLR115W::1081958       1 -0.33 -0.41 -0.24
## 5   GENE511X A_06_P5620  SSO2::YMR183C::1081214       1  0.05  0.02  0.40
## 6  GENE2133X A_06_P5307  PSP2::YML017W::1083036       1 -0.69 -0.03  0.23
## 7  GENE1002X A_06_P6258  RIB2::YOL066C::1081766       1 -0.55 -0.30 -0.12
## 8  GENE5478X A_06_P7082 VMA13::YPR036W::1086860       1 -0.75 -0.12 -0.07
## 9  GENE2065X A_06_P2554  EDC3::YEL015W::1082963       1 -0.24 -0.22  0.14
## 10 GENE2440X A_06_P6431  VPS5::YOR069W::1083389       1 -0.16 -0.38  0.05
## # ... with 5,526 more rows, and 33 more variables: G0.2 <dbl>,
## #   G0.25 <dbl>, G0.3 <dbl>, N0.05 <dbl>, N0.1 <dbl>, N0.15 <dbl>,
## #   N0.2 <dbl>, N0.25 <dbl>, N0.3 <dbl>, P0.05 <dbl>, P0.1 <dbl>,
## #   P0.15 <dbl>, P0.2 <dbl>, P0.25 <dbl>, P0.3 <dbl>, S0.05 <dbl>,
## #   S0.1 <dbl>, S0.15 <dbl>, S0.2 <dbl>, S0.25 <dbl>, S0.3 <dbl>,
## #   L0.05 <dbl>, L0.1 <dbl>, L0.15 <dbl>, L0.2 <dbl>, L0.25 <dbl>,
## #   L0.3 <dbl>, U0.05 <dbl>, U0.1 <dbl>, U0.15 <dbl>, U0.2 <dbl>,
## #   U0.25 <dbl>, U0.3 <dbl>
```

There are several issues here.

1. **Multiple variables are stored in one column.** The `NAME` column contains lots of information, split up by `::`’s.
1. **Nutrient and rate variables are stuck in column headers.** That is, the column names contain the values of two variables: nutrient (G, N, P, S, L, U) and growth rate (0.05-0.3). Remember, with tidy data, **each _column_ is a _variable_ and each _row_ is an _observation_.** Here, we have not one observation per row, but 36 (6 nutrients $\times$ 6 rates)! There's no way we could filter this data by a certain nutrient, or try to calculate statistics between rate and expression.
1. **Expression values are scattered throughout the table.** Related to the problem above, and just like our heart rate example, `expression` isn't a single-column variable as in the cleaned tidy data, but it's scattered around these 36 columns.
1. **Other important information is in a separate table.** We're missing all the gene ontology information we had in the tidy data (no information about biological process (`bp`) or molecular function (`mf`)).

Let's tackle these issues one at a time, all on a `%>%` pipeline.

### `separate()` the `NAME` column

Let's `separate()` the `NAME` column `into` multiple different variables. The first row looks like this:

> `SFB2::YNL049C::1082129`

That is, it looks like we've got the gene symbol, the systematic name, and some other number (that isn't discussed in the paper). Let's `separate()`!


```r
yorig %>% 
  separate(NAME, into=c("symbol", "systematic_name", "somenumber"), sep="::")
```

```
## # A tibble: 5,536 × 42
##          GID       YORF symbol systematic_name somenumber GWEIGHT G0.05
## *      <chr>      <chr>  <chr>           <chr>      <chr>   <int> <dbl>
## 1  GENE1331X A_06_P5820   SFB2         YNL049C    1082129       1 -0.24
## 2  GENE4924X A_06_P5866     NA         YNL095C    1086222       1  0.28
## 3  GENE4690X A_06_P1834   QRI7         YDL104C    1085955       1 -0.02
## 4  GENE1177X A_06_P4928   CFT2         YLR115W    1081958       1 -0.33
## 5   GENE511X A_06_P5620   SSO2         YMR183C    1081214       1  0.05
## 6  GENE2133X A_06_P5307   PSP2         YML017W    1083036       1 -0.69
## 7  GENE1002X A_06_P6258   RIB2         YOL066C    1081766       1 -0.55
## 8  GENE5478X A_06_P7082  VMA13         YPR036W    1086860       1 -0.75
## 9  GENE2065X A_06_P2554   EDC3         YEL015W    1082963       1 -0.24
## 10 GENE2440X A_06_P6431   VPS5         YOR069W    1083389       1 -0.16
## # ... with 5,526 more rows, and 35 more variables: G0.1 <dbl>,
## #   G0.15 <dbl>, G0.2 <dbl>, G0.25 <dbl>, G0.3 <dbl>, N0.05 <dbl>,
## #   N0.1 <dbl>, N0.15 <dbl>, N0.2 <dbl>, N0.25 <dbl>, N0.3 <dbl>,
## #   P0.05 <dbl>, P0.1 <dbl>, P0.15 <dbl>, P0.2 <dbl>, P0.25 <dbl>,
## #   P0.3 <dbl>, S0.05 <dbl>, S0.1 <dbl>, S0.15 <dbl>, S0.2 <dbl>,
## #   S0.25 <dbl>, S0.3 <dbl>, L0.05 <dbl>, L0.1 <dbl>, L0.15 <dbl>,
## #   L0.2 <dbl>, L0.25 <dbl>, L0.3 <dbl>, U0.05 <dbl>, U0.1 <dbl>,
## #   U0.15 <dbl>, U0.2 <dbl>, U0.25 <dbl>, U0.3 <dbl>
```

Now, let's `select()` out the stuff we don't want.


```r
yorig %>% 
  separate(NAME, into=c("symbol", "systematic_name", "somenumber"), sep="::") %>% 
  select(-GID, -YORF, -somenumber, -GWEIGHT)
```

```
## # A tibble: 5,536 × 38
##    symbol systematic_name G0.05  G0.1 G0.15  G0.2 G0.25  G0.3 N0.05  N0.1
## *   <chr>           <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
## 1    SFB2         YNL049C -0.24 -0.13 -0.21 -0.15 -0.05 -0.05  0.20  0.24
## 2      NA         YNL095C  0.28  0.13 -0.40 -0.48 -0.11  0.17  0.31  0.00
## 3    QRI7         YDL104C -0.02 -0.27 -0.27 -0.02  0.24  0.25  0.23  0.06
## 4    CFT2         YLR115W -0.33 -0.41 -0.24 -0.03 -0.03  0.00  0.20 -0.25
## 5    SSO2         YMR183C  0.05  0.02  0.40  0.34 -0.13 -0.14 -0.35 -0.09
## 6    PSP2         YML017W -0.69 -0.03  0.23  0.20  0.00 -0.27  0.17 -0.40
## 7    RIB2         YOL066C -0.55 -0.30 -0.12 -0.03 -0.16 -0.11  0.04  0.00
## 8   VMA13         YPR036W -0.75 -0.12 -0.07  0.02 -0.32 -0.41  0.11 -0.16
## 9    EDC3         YEL015W -0.24 -0.22  0.14  0.06  0.00 -0.13  0.30  0.07
## 10   VPS5         YOR069W -0.16 -0.38  0.05  0.14 -0.04 -0.01  0.39  0.20
## # ... with 5,526 more rows, and 28 more variables: N0.15 <dbl>,
## #   N0.2 <dbl>, N0.25 <dbl>, N0.3 <dbl>, P0.05 <dbl>, P0.1 <dbl>,
## #   P0.15 <dbl>, P0.2 <dbl>, P0.25 <dbl>, P0.3 <dbl>, S0.05 <dbl>,
## #   S0.1 <dbl>, S0.15 <dbl>, S0.2 <dbl>, S0.25 <dbl>, S0.3 <dbl>,
## #   L0.05 <dbl>, L0.1 <dbl>, L0.15 <dbl>, L0.2 <dbl>, L0.25 <dbl>,
## #   L0.3 <dbl>, U0.05 <dbl>, U0.1 <dbl>, U0.15 <dbl>, U0.2 <dbl>,
## #   U0.25 <dbl>, U0.3 <dbl>
```

### `gather()` the nutrient+rate and expression data

Let's gather the data from wide to long format so we get nutrient/rate (key) and expression (value) in their own columns.


```r
yorig %>% 
  separate(NAME, into=c("symbol", "systematic_name", "somenumber"), sep="::") %>% 
  select(-GID, -YORF, -somenumber, -GWEIGHT) %>% 
  gather(key=nutrientrate, value=expression, G0.05:U0.3)
```

```
## # A tibble: 199,296 × 4
##    symbol systematic_name nutrientrate expression
##     <chr>           <chr>        <chr>      <dbl>
## 1    SFB2         YNL049C        G0.05      -0.24
## 2      NA         YNL095C        G0.05       0.28
## 3    QRI7         YDL104C        G0.05      -0.02
## 4    CFT2         YLR115W        G0.05      -0.33
## 5    SSO2         YMR183C        G0.05       0.05
## 6    PSP2         YML017W        G0.05      -0.69
## 7    RIB2         YOL066C        G0.05      -0.55
## 8   VMA13         YPR036W        G0.05      -0.75
## 9    EDC3         YEL015W        G0.05      -0.24
## 10   VPS5         YOR069W        G0.05      -0.16
## # ... with 199,286 more rows
```

And while we're at it, let's `separate()` that newly created key column. Take a look at the help for `?separate` again. The `sep` argument could be a delimiter or a number position to split at. Let's split after the first character. While we're at it, let's hold onto this intermediate data frame before we add gene ontology information. Call it `ynogo`.


```r
ynogo <- yorig %>% 
  separate(NAME, into=c("symbol", "systematic_name", "somenumber"), sep="::") %>% 
  select(-GID, -YORF, -somenumber, -GWEIGHT) %>% 
  gather(key=nutrientrate, value=expression, G0.05:U0.3) %>% 
  separate(nutrientrate, into=c("nutrient", "rate"), sep=1)
```

### `inner_join()` it to the gene ontology information

It's rare that a data analysis involves only a single table of data. You normally have many tables that contribute to an analysis, and you need flexible tools to combine them. The **dplyr** package has several tools that let you work with multiple tables at once. Do a [Google image search for "SQL Joins"](https://www.google.com/search?q=SQL+join&tbm=isch), and look at [RStudio's Data Wrangling Cheat Sheet](http://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf) to learn more. 

First, let's import the dataset that links the systematic name to gene ontology information. It's the [brauer2007_sysname2go.csv](http://bioconnector.org/data/brauer2007_sysname2go.csv) file available at [bioconnector.org/data](http://bioconnector.org/data/). Let's call the imported data frame `sn2go`.


```r
# Import the data
sn2go <- read_csv("data/brauer2007_sysname2go.csv")

# Take a look
# View(sn2go)
head(sn2go)
```

```
## # A tibble: 6 × 3
##   systematic_name                           bp
##             <chr>                        <chr>
## 1         YNL049C        ER to Golgi transport
## 2         YNL095C   biological process unknown
## 3         YDL104C proteolysis and peptidolysis
## 4         YLR115W      mRNA polyadenylylation*
## 5         YMR183C              vesicle fusion*
## 6         YML017W   biological process unknown
## # ... with 1 more variables: mf <chr>
```

Now, look up some help for `?inner_join`. Inner join will return a table with all rows from the first table where there are matching rows in the second table, and returns all columns from both tables. Let's give this a try.


```r
yjoined <- inner_join(ynogo, sn2go, by="systematic_name")
# View(yjoined)
yjoined
```

```
## # A tibble: 199,296 × 7
##    symbol systematic_name nutrient  rate expression
##     <chr>           <chr>    <chr> <chr>      <dbl>
## 1    SFB2         YNL049C        G  0.05      -0.24
## 2      NA         YNL095C        G  0.05       0.28
## 3    QRI7         YDL104C        G  0.05      -0.02
## 4    CFT2         YLR115W        G  0.05      -0.33
## 5    SSO2         YMR183C        G  0.05       0.05
## 6    PSP2         YML017W        G  0.05      -0.69
## 7    RIB2         YOL066C        G  0.05      -0.55
## 8   VMA13         YPR036W        G  0.05      -0.75
## 9    EDC3         YEL015W        G  0.05      -0.24
## 10   VPS5         YOR069W        G  0.05      -0.16
## # ... with 199,286 more rows, and 2 more variables: bp <chr>, mf <chr>
```

```r
# The glimpse function makes it possible to see a little bit of everything in your data.
glimpse(yjoined)
```

```
## Observations: 199,296
## Variables: 7
## $ symbol          <chr> "SFB2", "NA", "QRI7", "CFT2", "SSO2", "PSP2", ...
## $ systematic_name <chr> "YNL049C", "YNL095C", "YDL104C", "YLR115W", "Y...
## $ nutrient        <chr> "G", "G", "G", "G", "G", "G", "G", "G", "G", "...
## $ rate            <chr> "0.05", "0.05", "0.05", "0.05", "0.05", "0.05"...
## $ expression      <dbl> -0.24, 0.28, -0.02, -0.33, 0.05, -0.69, -0.55,...
## $ bp              <chr> "ER to Golgi transport", "biological process u...
## $ mf              <chr> "molecular function unknown", "molecular funct...
```

Looks like that did it! There are many different kinds of two-table verbs/joins in dplyr. In this example, every systematic name in `ynogo` had a corresponding entry in `sn2go`, but if this weren't the case, those un-annotated genes would have been removed entirely by the `inner_join`. A `left_join` would have returned all the rows in `ynogo`, but would have filled in `bp` and `mf` with missing values (`NA`) when there was no corresponding entry. See also: `right_join`, `semi_join`, and `anti_join`.


