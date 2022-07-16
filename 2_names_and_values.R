
#2 Names and values

#2.1 Introduction----
##Quiz
##1. Given the following data frame, how do I create a new column called “3” that contains the sum of 1 and 2? You may only use $, not [[. What makes 1, 2, and 3 challenging as variable names?
df <- data.frame(runif(3), runif(3))
names(df) <- c(1, 2)

df$`3` <- mutate(df$1+df$2) #don't know

##2.In the following code, how much memory does y occupy?----
x <- runif(1e6)
y <- list(x, x, x)

#y occupies 24 MB

##3.On which line does (a) get copied in the following example?
a <- c(1, 5, 3, 2)
b <- a
b[[1]] <- 10

# (a) gets copied on line 2

#initial setup-------
library(lobstr)

#2.2 Binding basics----

x <- c(1, 2, 3)
y <- x

obj_addr(x)
#> [1] "0x3e0b588"
obj_addr(y)
#> [1] "0x3e0b588"


# 2.2.1 Non-syntactic names----
_abc <- 1
#> Error: unexpected input in "_"

if <- 10
#> Error: unexpected assignment in "if <-"

`_abc` <- 1
`_abc`
#> [1] 1

`if` <- 10
`if`
#> [1] 10

#2.2.2 Exercises----
##1. Explain the relationship between a, b, c and d in the following code:
a <- 1:10
b <- a
c <- b
d <- 1:10

obj_addr(d)
obj_addr(b)

#a is a name given to a object(vector of values)
#b is a name given to the same object as a(vector of values)
#c is a name given to the same object as b(vector of values), which is a name given to the same object as a(vector of values). #d is a name given to a object(vector of values) with the exact same vector of values but with a different object adress "0x31160a0", as appose to a b c "0x1a9d93f0". 

##2. The following code accesses the mean function in multiple ways. Do they all point to the same underlying function object? Verify this with lobstr::obj_addr().
mean(a)
base::mean(a)
get("mean")(a)
evalq(mean)(a)
match.fun("mean")(a)

lobstr::obj_addr(match.fun("mean"))

#yes they all do the same function "0x2cc31e0".

##3. By default, base R data import functions, like read.csv(), will automatically convert non-syntactic names to syntactic ones. Why might this be problematic? What option allows you to suppress this behaviour?

#`` and "".

##4. What rules does make.names() use to convert non-syntactic names into syntactic ones?

#The character "X" is prepended if necessary. All invalid characters are translated to ".". A missing value is translated to "NA". Names which match R keywords have a dot appended to them. Duplicated values are altered by make.unique.


##5. I slightly simplified the rules that govern syntactic names. Why is .123e1 not a syntactic name? Read ?make.names for the full details.

#A syntactically valid name consists of letters, numbers and the dot or underline characters and starts with a letter or the dot not followed by a number. Names such as ".2way" are not valid, and neither are the reserved words.

# 2.3 Copy-on-modify 
x <- c(1, 2, 3)
y <- x

y[[3]] <- 4
x
#> [1] 1 2 3

# 2.3.1 tracemem() 
x <- c(1, 2, 3)
cat(tracemem(x), "\n")
#> <055FAB40> 

y <- x
y[[3]] <- 4L
#> tracemem[0x055fab40 -> 0x0569a8a8]: 


y[[3]] <- 5L
untracemem(x) #turns tracing off

#2.3.2 Function calls 
f <- function(a) {
  a
}

x <- c(1, 2, 3)
cat(tracemem(x), "\n")
#> <0x7fe1121693a8>

z <- f(x)
# there's no copy here!

untracemem(x)

#2.3.3 Lists

l1 <- list(1, 2, 3)
l2 <- l1
l2[[3]] <- 4

ref(l1, l2)
#> █ [1:0x7fe11166c6d8] <list> 
#> ├─[2:0x7fe11b6d2078] <dbl> 
#> ├─[3:0x7fe11b6d2040] <dbl> 
#> └─[4:0x7fe11b6d2008] <dbl> 
#>  
#> █ [5:0x7fe11411cc18] <list> 
#> ├─[2:0x7fe11b6d2078] 
#> ├─[3:0x7fe11b6d2040] 
#> └─[6:0x7fe114130a70] <dbl>

#2.3.4 Dataframes
d1 <- data.frame(x = c(1, 5, 6), y = c(2, 4, 3))

d2 <- d1
d2[, 2] <- d2[, 2] * 2 #If you modify a column, only that column needs to be modified; the others will still point to their original references:

tracemem(d2) #just checking

d3 <- d1
d3[1, ] <- d3[1, ] * 3

#2.3.5 Character vectors

x <- c("a", "a", "abc", "d")

ref(x, character = TRUE)
#> █ [1:0x7fe114251578] <chr> 
#> ├─[2:0x7fe10ead1648] <string: "a"> 
#> ├─[2:0x7fe10ead1648] 
#> ├─[3:0x7fe11b27d670] <string: "abc"> 
#> └─[4:0x7fe10eda4170] <string: "d">

#2.3.6 Exercises

#1. Why is tracemem(1:10) not useful?
tracemem(1:10)
#because 1:10 is not a vector we are copying and modifying so it does not matter what its unique name.

#2. Explain why tracemem() shows two copies when you run this code. Hint: carefully look at the difference between this code and the code shown earlier in the section.
x <- c(1L, 2L, 3L)
tracemem(x)

x[[3]] <- 4

#because a column was modified and therefor the it is a shallow-copy. 

#3. Sketch out the relationship between the following objects:
a <- 1:10
b <- list(a, a)
c <- list(b, a, 1:10)

#> a
#[1]  1  2  3  4  5  6  7  8  9 10
#> b
#[[1]]
#[1]  1  2  3  4  5  6  7  8  9 10

#[[2]]
#[1]  1  2  3  4  5  6  7  8  9 10

#> c
#[[1]]
#[[1]][[1]]
#[1]  1  2  3  4  5  6  7  8  9 10

#[[1]][[2]]
#[1]  1  2  3  4  5  6  7  8  9 10


#[[2]]
#[1]  1  2  3  4  5  6  7  8  9 10

#[[3]]
#[1]  1  2  3  4  5  6  7  8  9 10

#4. What happens when you run this code?
x <- list(1:10)
x[[2]] <- x

x
