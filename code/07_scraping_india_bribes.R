
# Starting with the first page
url <- "http://www.ipaidabribe.com/reports/paid"
# read html code from website
url.data <- readLines(url)

# backup
# load("backup/url.data")

# parse HTML tree into an R object
library(XML)
doc <- htmlTreeParse(url.data,  useInternalNodes = TRUE)

# extract what we need: descriptions and basic info for each bribe
titles <- xpathSApply(doc, "//div[@class='teaser-title']", xmlValue)
attributes <- xpathSApply(doc, "//div[@class='teaser-attributes']", xmlValue)

# note that we only need the first 10
titles <- titles[1:10]
attributes <- attributes[1:10]

## all those "\t" and "\n" are just white spaces that we can trim
library(stringr)
titles <- str_trim(titles)

# cleaning the attributes is a bit more complicated, but we can do it
# using regular expressions
cities <- gsub(".*[\t]{4}(.*)[\t]{5}.*", attributes, replacement="\\1")
depts <- gsub(".*\n\t\t    (.*)\t\t.*", attributes, replacement="\\1")
amounts <- gsub(".*Rs. ([0-9]*).*", attributes, replacement="\\1")

# we can put it together in a matrix
page.data <- cbind(titles, cities, depts, amounts)


# let's wrap it in a single function
extract.bribes <- function(url){
    require(stringr)
    cat("url:", url)
    url.data <- readLines(url)
    doc <- htmlTreeParse(url.data,  useInternalNodes = TRUE)
    titles <- xpathSApply(doc, "//div[@class='teaser-title']", xmlValue)[1:10]
    attributes <- xpathSApply(doc, "//div[@class='teaser-attributes']", xmlValue)[1:10]
    titles <- str_trim(titles)
    cities <- gsub(".*[\t]{4}(.*)[\t]{5}.*", attributes, replacement="\\1")
    depts <- gsub(".*\n\t\t    (.*)\t\t.*", attributes, replacement="\\1")
    amounts <- gsub(".*Rs. ([0-9]*).*", attributes, replacement="\\1")
    return(cbind(titles, cities, depts, amounts))
}

## all urls
urls <- paste0("http://www.ipaidabribe.com/reports/paid?page=", 0:50)

## empty array
data <- list()

## looping over urls...
for (i in seq_along(urls)){
    # extracting information
    data[[i]] <- extract.bribes(urls[i])
    # waiting one second between hits
    Sys.sleep(1)
    cat(" done!\n")
}

## transforming it into a data.frame
data <- data.frame(do.call(rbind, data), stringsAsFactors=F)

# backup
# load("backup/data")

# quick summary statistics
head(sort(table(data$depts),dec=T))
head(sort(table(data$cities),dec=T))
summary(as.numeric(data$amounts))


