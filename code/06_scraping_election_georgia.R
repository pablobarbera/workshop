
# Scraping proportion of votes by district
library(XML); library(plyr)
url <- "http://results.cec.gov.ge/index.html"
table <- readHTMLTable(url, stringsAsFactors=F)
table <- table$table36
table[1:6,2:6]

# loading backup (in case internet does not work)
# load("backup/table36")

# deleting percentages
table <- apply(table, 2, function(x) gsub("\\(.*\\)", "", x))
# converting back into data.frame
table <- data.frame(table, stringsAsFactors=F)
# changing variable names
names(table) <- c("district", paste0("party_", table[1,2:18]))
# deleting unnecessary row/column (party names and empty column)
table <- table[-1,-18]
# fixing district names
table$district <- as.numeric(gsub("(.*)\\..*", repl="\\1", table$district))
# fixing variable types
table[,2:17] <- apply(table[,2:17], 2, as.numeric)
table[1:10,]

# Scraping proportion of votes by section within each district
districts <- table$district

extract.results <- function(district){
    url <- paste0("http://results.cec.gov.ge/olq_", district, ".html")
    results <- readHTMLTable(url, stringsAsFactors=F)
    results <- results$table36
    # next two line on Windows only
    # names(results) <- c("section", paste0("party_", names(results[-1])))
    # results <- results[,-length(results)]
    # next two lines on Mac/Linux only
    names(results) <- c("section", paste0("party_", results[1,2:length(results)]))
    results <- results[-1,-length(results)]
    results$district <- district
    return(results)
}

# applying function to all districts
results <- list()
for (district in districts){
    results[[district]] <- extract.results(district)
    cat(district, "\n")
}

results <- do.call(rbind, results)

# loading backup (in case internet does not work)
# load("backup/results")

# test: last digit of party 5 and 41
last.digit <- function(votes){
    last.pos <- nchar(votes)
    as.numeric(substring(votes,last.pos,last.pos)) 
}

plot(table(last.digit(results$party_5)))
plot(table(last.digit(results$party_41)))




