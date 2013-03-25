# loading library and OAuth token
library(streamR)
load("my_oauth")

# capturing 2 minutes of tweets sent from Africa
filterStream(file.name="tweets_africa.json", locations=c(-20,-37, 52, 35), timeout=120, oauth=my_oauth)
# parsing tweets into dataframe
tweets.df <- parseTweets("tweets_africa.json", verbose = TRUE)

## backup
# tweets.df <- parseTweets("backup/tweets_africa.json", verbose = TRUE)

# quick map to visualize where tweets are coming from
library(ggplot2)
library(grid)
map.data <- map_data("world")
points <- data.frame(x = as.numeric(tweets.df$lon), y = as.numeric(tweets.df$lat))
# deleting tweets sent from (0,0) coordinates (probably errors)
points <- points[points$y != 0 & points$x != 0, ]
# drawing map using ggplot2
ggplot(map.data) + geom_map(aes(map_id = region), map = map.data, fill = "white", 
    color = "grey20", size = 0.25) + expand_limits(x = map.data$long, y = map.data$lat) +
    scale_x_continuous(limits=c(-20,52)) + scale_y_continuous(limits=c(-37,35)) +
    theme(axis.line = element_blank(), axis.text = element_blank(), axis.ticks = element_blank(), 
        axis.title = element_blank(), panel.background = element_blank(), panel.border = element_blank(), 
        panel.grid.major = element_blank(), plot.background = element_blank(), 
        plot.margin = unit(0 * c(-1.5, -1.5, -1.5, -1.5), "lines")) + geom_point(data = points, 
    aes(x = x, y = y), size = 1, alpha = 1/5, color = "darkblue")


# now the same for tweets coming from Korea
filterStream(file.name="tweets_korea.json", locations=c(124, 34, 131, 42), timeout=120, oauth=my_oauth)
# parsing tweets into dataframe
tweets.df <- parseTweets("tweets_korea.json", verbose = TRUE)

## backup
# tweets.df <- parseTweets("backup/tweets_korea.json", verbose = TRUE)

library(ggplot2)
library(grid)
map.data <- map_data("world")
points <- data.frame(x = as.numeric(tweets.df$lon), y = as.numeric(tweets.df$lat))

ggplot(map.data) + geom_map(aes(map_id = region), map = map.data, fill = "black", 
    color = "grey50", size = 0.25) + expand_limits(x = map.data$long, y = map.data$lat) +
    scale_x_continuous(limits=c(124,130)) + scale_y_continuous(limits=c(34.5,42)) +
    theme(axis.line = element_blank(), axis.text = element_blank(), axis.ticks = element_blank(), 
        axis.title = element_blank(), panel.background = element_rect( fill='black', color='black'), panel.border = element_blank(), 
        panel.grid.major = element_line(color='black'), panel.grid.minor = element_line(color='black'),
        plot.background = element_rect( fill='black', color='black'), 
        plot.margin = unit(0 * c(-1.5, -1.5, -1.5, -1.5), "lines")) + geom_point(data = points, 
    aes(x = x, y = y), size = 1, alpha = 1/5, color = "white")




