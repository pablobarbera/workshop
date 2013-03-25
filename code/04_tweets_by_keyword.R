# loading library and OAuth token
library(streamR)
load("my_oauth")

# capturing 3 minutes of tweets mentioning obama or biden
filterStream(file.name="tweets_keyword.json", track=c("obama", "biden"), timeout=180, oauth=my_oauth)
# parsing tweets into dataframe
tweets <- parseTweets("tweets_keyword.json", verbose = TRUE)

## backup
# tweets <- parseTweets("backup/tweets_keyword.json", verbose = TRUE)

# preparing words for analysis
clean.tweets <- function(text){
    # loading required packages
    lapply(c("tm", "Rstem", "stringr"), require, c=T, q=T)
    words <- removePunctuation(text)
    # Note: if you're running this on your computer, you can
    # uncomment next line to 'stem' words in tweets
    # words <- wordStem(words)
    # spliting in words
    words <- str_split(text, " ")
    return(words)
}

# classify an individual tweet
classify <- function(words, pos.words, neg.words){
    # count number of positive and negative word matches
    pos.matches <- sum(words %in% pos.words)
    neg.matches <- sum(words %in% neg.words)
    return(pos.matches - neg.matches)
}

# function that applies sentiment classifier
classifier <- function(tweets, pos.words, neg.words, keyword){
    # subsetting tweets that contain the keyword
    relevant <- grep(keyword, tweets$text, ignore.case=TRUE)
    # preparing tweets for analysis
    words <- clean.tweets(tweets$text[relevant])
    # classifier
    scores <- unlist(lapply(words, classify, pos.words, neg.words))
    n <- length(scores)
    positive <- as.integer(length(which(scores>0))/n*100)
    negative <- as.integer(length(which(scores<0))/n*100)
    neutral <- 100 - positive - negative
    cat(n, "tweets about", keyword, ":", positive, "% positive,",
        negative, "% negative,", neutral, "% neutral")
}


# loading lexicon of positive and negative words (from Neal Caren)
lexicon <- read.csv("lexicon.csv", stringsAsFactors=F)
pos.words <- lexicon$word[lexicon$polarity=="positive"]
neg.words <- lexicon$word[lexicon$polarity=="negative"]

# applying classifier function
classifier(tweets, pos.words, neg.words, keyword="obama")
classifier(tweets, pos.words, neg.words, keyword="biden")



