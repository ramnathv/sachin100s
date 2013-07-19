require(XML)
require(RCurl)
require(lubridate)
require(plyr)
require(whisker)
require(rCharts)

# Get List of Centuries from Wikipedia
url <- 'http://en.wikipedia.org/wiki/List_of_international_cricket_centuries_by_Sachin_Tendulkar'
data_ <- readHTMLTable(url, which = 2:3, stringsAsFactors = F)

# Merge Test and ODI Centuries, Standardizing Column Names
Type <- c('Test', 'ODI')
data__ <- lapply(1:2, function(i){
  d <- transform(data_[[i]], 
    Date = ymd(substr(Date, 2, 11)),
    Type = Type[i]
  )
})
data__[[1]]$pos = ""
data__[[1]]$sr = ""
data__[[2]]$test = ""
names(data__[[1]]) = c("no", "score", "against", "inn", "test",
  "venue", "han", "date", "result", "type", "pos", "sr"
)
names(data__[[2]]) = c("no", "score", "against", "pos", "inn",
  "sr", "venue", "han", "date", "result", "type", "test"
)
d1 = data__[[1]]
d2 = data__[[2]][names(d1)]
d3 = arrange(rbind(d1, d2), date)

# Get Images of Centuries
# url3 <- 'http://omgsachin.blogspot.ca/2011/03/sachin-century-of-centuries.html'
# doc <- htmlParse(url3)
# imgs <- xpathSApply(doc, '//img', xmlGetAttr, 'src')
# d3$imgs <- imgs[grep('[0-9]+\\.jpg$', imgs)]
d3$imgs <- paste0('img/c', 1:100, '.jpg')
d3$result <- gsub('^(.*)\\[[0-9]+\\]$', '\\1', d3$result)
d3$num <- 1:NROW(d3)


# Create Text Template
tpl <- "
<b>Against:</b>  {{x.against}}<br/>
<b>Venue:</b> {{x.venue}}<br/>
<b>Match:</b> {{x.type}}<br/>
<b>Score:</b> {{x.score}}<br/>
<b>Result:</b> <span class={{x.result}}>{{x.result}}</span><br/>
{{#x.sr}}<b>Strike Rate:</b> {{x.sr}} {{/x.sr}}
"

# Create Event Payload for Timeline
d4 <- alply(d3, 1, function(x){
  list(
    startDate = gsub("-", ",", as.character(x$date)),
    headline = sprintf("Century No. %s", x$num),
    text = whisker.render(tpl, list(x = x)),
    asset = list(media = x$img)
  )
})

# Create Timeline
m = Timeline$new()
m$main(
  headline =  "100 Centuries of Sachin",
  type = 'default',
  text = "Sachin Tendulkar is widely acknowledged to be one of the greatest cricketers the world has seen. This is a timeline of his 100 centuries, created using rCharts and TimelineJS",
  startDate =  "1990,08,14",
  asset = list(media = 'http://www.youtube.com/watch?v=6PxAandi6r4')
)
m$config(
  font = "Merriweather-Newscycle"
)
names(d4) <- NULL
m$event(d4)
m$save('index.html')

# Modify JS Path to use Local Assets
x <- paste(readLines('index.html', warn = F), collapse = '\n')
x <- gsub('/Library/Frameworks/R.framework/Versions/3.0/Resources/library/rCharts/libraries/timeline', 'compiled', x)
writeLines(x, con = 'index.html')

# Browse Page
# browseURL('index.html')