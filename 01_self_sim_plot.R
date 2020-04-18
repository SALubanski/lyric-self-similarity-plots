# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
# ::::: Creating Self-Similarity matrices with song lyrics :::::
# ::::: A replication of the work at SongSim:              :::::
# ::::: https://colinmorris.github.io/SongSim/#/about      :::::
# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

library(here) # for generating relative filepaths

# list the artist and name of song
# artist.song <- 'Artist - Song'
artist.song <- 'Daft Punk - Harder, Better, Faster, Stronger'
# this will be used to title plot & figure

# read-in lyrics (when saving text file make sure encoding is "UTF-8")
# there should also be an empty line at the beginning & end of the file
(lyrics <- readLines(file.choose(), encoding = 'UTF-8')[-1])
  # I think the Mac default is UTF-8, Windows default is ANSI
  # if text is in English characters, the Windows "ANSI" encoding is fine, just 
  # change the encoding argument to: encoding = ''

(lyrics <- lyrics[which(lyrics != '')]) # drop empty lines

# drop lines that begin and end with brackets, e.g., [Verse 1] or [Chorus]
(lyrics <-  lyrics[which(sapply(lyrics, function(x){
  substr(x, 1, 1) == '[' & substr(x, nchar(x), nchar(x)) == ']'
  }) != T)])

# trim white space before and after each line
(lyrics <- trimws(lyrics))

(lyrics <- strsplit(lyrics, split = ' ')) # split lines into words

lyrics <- do.call(c, lyrics) # put all words into single vector

# testing punctuation removal
# gsub("[[:punct:]]", '', c(',', '(', ')', '?', '.', '-', '*', ':', '"', '"test"', '!'))

# remove punctuation
lyrics <- sapply(lyrics, function(x){gsub("[[:punct:]]", '', x = x)})
lyrics


lyrics <- tolower(lyrics)    # make all words lower case
names(lyrics) <- lyrics      # name each element after its word

# # making own patterns
# seq.end <- sapply(1:10, function(x){sum(1:x)})
# seq.letter <- sapply(seq.end, function(x){1:x})
# seq.letter <- seq.letter[which(sapply(seq.letter, max) < 27)]
# lyrics <- unlist(sapply(seq.letter, function(x){letters[x]}))

# create similarity matrix: "TRUE" if ith word == jth word, else "FALSE"
sim.mat <- sapply(lyrics, function(i){
  sapply(lyrics, function(j){
    # browser()
    i == j
  })
})

# create plot title from artist.song
plot.title <- paste('Self-Similarity plot for\n',
                    artist.song)

# adjust artist.song for naming the figure.png
artist.song.alt <- paste(strsplit(tolower(artist.song), ' ')[[1]], collapse = '_')

# create the figure title
fig.title <- paste0(artist.song.alt, '_self-sim_plot.png')

# save as .png
png(here(fig.title),
    width = 4000, height = 3000, res = 300)

# make empty plot with X & Y limits equal to the number of words
plot(1:length(lyrics), 1:length(lyrics), pch = NA_integer_,
     xlim = c(1, length(lyrics)), ylim = c(length(lyrics), 1),
     pin = c(2, 2), xlab = '', ylab = '')
title(main = plot.title)

# plot a black square for each time the ith word matches the jth word
sapply(1:length(lyrics), function(i){
  sapply(1:length(lyrics), function(j){
    # browser()
    
    # check if the word is a one-off repeat (it has no neighbors that repeat)
    neighbors <- c(sim.mat[i - 1, j - 1],
                sim.mat[i - 1, j],
                if(j != nrow(sim.mat)) sim.mat[i - 1, j + 1],
                sim.mat[i, j - 1],
                if(j != nrow(sim.mat)) sim.mat[i, j + 1],
                if(i != nrow(sim.mat)) sim.mat[i + 1, j - 1],
                if(i != nrow(sim.mat)) sim.mat[i + 1, j],
                if(i != nrow(sim.mat) & j != ncol(sim.mat)) sim.mat[i + 1, j + 1])
     
    single.check <- any(neighbors == TRUE)
    if(sim.mat[i, j] & single.check) points(i, j, pch = 15, cex = 0.4)
  })
})
  # note: may need to adjust 'cex' argument depending on how many words are in the song

dev.off()


# note: sometimes words of same length have different number of characters?!
# sapply(lyrics[[1]], nchar) # see the first and third word of "Run Boy Run by Woodkid"
# str(lyrics[[1]][3])
# str(lyrics[[1]][1]) # UTF has an extra character here: a "bite order mark"
# seems it's only at the beginning of the file
