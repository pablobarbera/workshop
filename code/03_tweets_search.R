# load library and OAuth
library(twitteR)
load("my_oauth")
registerTwitterOAuth(my_oauth)

# you can do basic searches using twitteR
searchTwitter("obama")
searchTwitter("#PoliSciNSF")

# from Windows machine...
searchTwitter("#PoliSciNSF", cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))

# search is limited to an undetermined number of recent tweets
tweets <- searchTwitter("nyu", n=2000)

# backup
# load("backup/tweets")

# WARNING!
# the actual number of unique tweets is much lower than n!
tweets.text <- unlist(lapply(tweets, function(x) x$getText()))
length(tweets.text)
length(unique(tweets.text))

# also limited by time
apsa.tweets <- searchTwitter("APSA2012", n=10)

# backup
# load("backup/apsa.tweets")

# oldest tweets is ~5 days old, but we know there were many more
lapply(apsa.tweets, function(x) x$getCreated())



