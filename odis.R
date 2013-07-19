url <- 'http://sachin-rameshtendulkar.blogspot.ca/2012/12/sachins-all-odi-centuries-highlights.html'
doc <- htmlParse(url)
videos <- xpathSApply(doc, '//embed', xmlGetAttr, 'src')
thumbnails <- xpathSApply(doc, '//object', xmlGetAttr, 'data-thumbnail-src')
d2$video <- c(videos[1:3], "", videos[4:7], '', videos[8:47])
d2$thumbnail <-  c(thumbnails[1:3], "", thumbnails[4:7], '', thumbnails[8:47])
d2$result <- gsub('^(.*)\\[[0-9]+\\]$', '\\1', d2$result)


# Create Text Template
tpl <- "
<b>Against:</b>  {{x.against}}<br/>
<b>Venue:</b> {{x.venue}}<br/>
<b>Score:</b> {{x.score}}<br/>
<b>Result:</b> <span class={{x.result}}>{{x.result}}</span><br/>
{{#x.sr}}<b>Strike Rate:</b> {{x.sr}} {{/x.sr}}
"

# Create Event Payload for Timeline
d5 <- alply(d2, 1, function(x){
  list(
    startDate = gsub("-", ",", as.character(x$date)),
    headline = sprintf("Century No. %s", x$no),
    text = whisker.render(tpl, list(x = x)),
    asset = list(
      media = x$video,
      thumbnail = x$thumbnail
    )
  )
})

# Create Timeline
m = Timeline$new()
m$main(
  headline =  "ODI Centuries of Sachin",
  type = 'default',
  text = "Sachin Tendulkar is widely acknowledged to be one of the greatest cricketers the world has seen. This is a timeline of his 49 centuries in ODIs, created using rCharts and TimelineJS",
  startDate =  "1994,09,09",
  asset = list(media = 'http://www.youtube.com/watch?v=6PxAandi6r4')
)
m$config(
  font = "Merriweather-Newscycle"
)
names(d5) <- NULL
m$event(d5)
m$save('odis/index.html')
