# load library and OAuth
library(twitteR)
load("my_oauth")
registerTwitterOAuth(my_oauth)

## getting data for seed user
seed <- getUser("drewconway")

# From a Windows machine...
# seed <- getUser("drewconway", cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))

# loading backup (in case internet does not work)
# load("backup/seed")

seed.n <- seed$screenName
seed.n
following <- seed$getFriends()

# From a Windows machine...
# following <- seed$getFriends(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))


# loading backup (in case internet does not work)
# load("backup/following")

following.n <- as.character(lapply(following, function(x) x$getScreenName()))
head(following.n)
# saving follow.list
follow.list <- list()
follow.list[[seed.n]] <- following.n

## extracting description of users
descriptions <- as.character(lapply(following, function(x) x$getDescription()))
descriptions[1]

# functions to subset only users from NYU-Politics
extract.nyu <- function(descriptions){
    nyu <- grep('nyu|new york university', descriptions, ignore.case=TRUE)
    poli <- grep('poli(tics|tical|sci)', descriptions, ignore.case=TRUE)
    others <- grep('policy|wagner|cooperation', descriptions, ignore.case=TRUE)
    nyu.poli <- intersect(nyu, poli)
    nyu.poli <- nyu.poli[nyu.poli %in% others == FALSE]
    return(nyu.poli)
}

nyu <- extract.nyu(descriptions)
nyu.users <- c(seed$screenName, following.n[nyu], "cdsamii", "zeitzoff")


# loop over NYU users following same steps
while (length(nyu.users) > length(follow.list)){

    # pick first user not done
    user <- sample(nyu.users[nyu.users %in% names(follow.list)==FALSE], 1)
    user <- getUser(user)
    user.n <- user$screenName
    cat(user.n, "\n")

    # download list of users he/she follows
    following <- user$getFriends()
    friends <- as.character(lapply(following, function(x) x$getScreenName()))
    follow.list[[user.n]] <- friends
    descriptions <- as.character(lapply(following, function(x) x$getDescription()))

    # subset and add users from NYU Politics
    nyu <- extract.nyu(descriptions)
    new.users <- lapply(following[nyu], function(x) x$getScreenName())
    new.users <- as.character(new.users)
    nyu.users <- unique(c(nyu.users, new.users))

    # if rate limit is hit, wait for a minute
    limit <- getCurRateLimitInfo()[44,3]
    while (limit == "0"){
        cat("sleeping for one minute")
        Sys.sleep(60)
        limit <- getCurRateLimitInfo()[44,3]
    }
    print(nyu.users)
}


# loading backup (in case internet does not work)
# load("backup/follow.list")

# a little bit of network analysis
nyu.users <- names(follow.list)
adjMatrix <- lapply(follow.list, function(x) (nyu.users %in% x)*1)
adjMatrix <- matrix(unlist(adjMatrix), nrow=length(nyu.users), byrow=TRUE, dimnames=list(nyu.users, nyu.users))

library(igraph)
network <- graph.adjacency(adjMatrix)
plot(network)

V(network)$size <- degree(network, mode="in")
V(network)$label.cex <- (degree(network, mode="in")/max(degree(network, mode="in"))*1.25)+0.5
set.seed(777)
l <- layout.fruchterman.reingold.grid(network, niter=500)
pdf("network_nyu.pdf", width=7, height=7)
plot(network, layout=l, edge.width=1, edge.arrow.size=.25, vertex.label.color="black", vertex.shape="none", margin=-.15)
dev.off()


