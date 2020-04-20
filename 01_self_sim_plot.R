# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
# ::::: Creating Self-Similarity matrices with song lyrics :::::
# ::::: A replication of the work at SongSim:              :::::
# ::::: https://colinmorris.github.io/SongSim/#/about      :::::
# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

library(here) # for generating relative filepaths

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ::: create functions for making the similarity matrix & plot ::::
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

self.sim.mat <- function(text){
  sapply(text, function(i){
    sapply(text, function(j){
      # browser()
      i == j
    })
  })
}

# Self-Similarity plot function :::
self.sim.plot <- function(mat = sim.mat, phrase.focus = T, 
                          plot.cex = NULL, plot.sub = artist.song){
  # plot a black square for each time the ith word matches the jth word
  
  # mat          ...similarity matrix
  # phrase.focus ...focus on phrases? TRUE or FALSE
  #                 if FALSE, then plot all square where sim.mat[i, j] == TRUE
  #                 if TRUE, then only plot when one of the surrounding squares is also TRUE
  # plot.cex     ...Character EXtension for the plotting character (a square)
  #                 by default, will scale the plotting character with the 
  #                 number of lyrics. Probably don't want > 1 for most songs
  # plot.sub     ...string naming the artist & song; used in plot title
  
  # ::: Example of using phrase.focus: :::
  
  # number:     1, 2, 3, 4, 5, 6, 7
  # word:       a, b, a, b, c, b, d
  
  # phrase.focus == F
  #   1  2  3  4  5  6  7
  # 1 X  -  X  -  -  -  -
  # 2 -  X  -  X  -  -  -
  # 3 X  -  X  -  -  X  -
  # 4 -  X  -  X  -  -  -
  # 5 -  -  -  -  X  -  -
  # 6 -  -  X  -  -  X  -
  # 7 -  -  -  -  -  -  X
  
  # phrase.focus == T
  #   1  2  3  4  5  6  7
  # 1 X  -  X  -  -  -  -
  # 2 -  X  -  X  -  -  -
  # 3 X  -  X  -  -  -  -
  # 4 -  X  -  X  -  -  -
  # 5 -  -  -  -  X  -  -
  # 6 -  -  -  -  -  X  -
  # 7 -  -  -  -  -  -  X
  
  
  # get plot.cex, if not specified
  plot.cex <- if(is.null(plot.cex)) 100/nrow(mat) else plot.cex
  
  # create plot title from artist.song
  plot.title <- paste('Self-Similarity plot for\n',
                      plot.sub)
  
  # make empty plot with X & Y limits equal to the number of words
  plot(1:nrow(mat), 1:nrow(mat), pch = NA_integer_,
       xlim = c(1, nrow(mat)), ylim = c(nrow(mat), 1),
       pin = c(2, 2), xlab = '', ylab = '')
  title(main = plot.title)
  
  sapply(1:nrow(mat), function(i){
    sapply(1:nrow(mat), function(j){
      # browser()

      # check if the word is a one-off repeat (it has no neighbors that are the same)
      # this focuses only on phrases that are repeated
      if(phrase.focus == T){
        # browser()
        neighbors <- c(topleft =    mat[i - 1, j - 1],
                       left =       mat[i - 1, j],
                       bottomleft = if(j != nrow(mat)) mat[i - 1, j + 1],
                       above =      mat[i, j - 1],
                       below =      if(j != nrow(mat)) mat[i, j + 1],
                       topright =   if(i != nrow(mat)) mat[i + 1, j - 1],
                       right =      if(i != nrow(mat)) mat[i + 1, j],
                       bottomright = if(i != nrow(mat) & j != ncol(mat)) mat[i + 1, j + 1])

        phrase.focus <- any(neighbors == TRUE)
        if(mat[i, j] & phrase.focus) points(i, j, pch = 15, cex = plot.cex)

      } else {
        if(mat[i, j]) points(i, j, pch = 15, cex = plot.cex)
      }

    })
  })
}

self.sim.plot.fast <- function(mat = sim.mat, 
                          plot.cex = NULL, plot.sub = artist.song){
  # plot a black square for each time the ith word matches the jth word
  
  # much faster, but doesn't have phrase.focus
  
  # mat          ...similarity matrix
  # plot.cex     ...Character EXtension for the plotting character (a square)
  #                 by default, will scale the plotting character with the 
  #                 number of lyrics. Probably don't want > 1 for most songs
  # plot.sub     ...string naming the artist & song; used in plot title
  
  # get plot.cex, if not specified
  plot.cex <- if(is.null(plot.cex)) 100/nrow(mat) else plot.cex
  
  # create plot title from artist.song
  plot.title <- paste('Self-Similarity plot for\n',
                      plot.sub)
  
  # make empty plot with X & Y limits equal to the number of words
  plot(1:nrow(mat), 1:nrow(mat), pch = NA_integer_,
       xlim = c(1, nrow(mat)), ylim = c(nrow(mat), 1),
       pin = c(2, 2), xlab = '', ylab = '')
  title(main = plot.title)
  
  # browser()
  
  # create plotting index of points to fill-in
  plot.ind <- sapply(1:nrow(sim.mat), function(x){
    ind <- which(sim.mat[x, x] == sim.mat[, x])
    cbind(rep(x, length(ind)), ind)
  })
  
  # combine index into single matrix
  plot.ind <- do.call(rbind, plot.ind)
  
  # for each row of plot.ind, plot a square
  apply(plot.ind, 1, function(x){
    points(x[1], x[2], pch = 15, cex = plot.cex)
  })
  
}

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ::: Read & process the lyrics :::::::::::::::::::::::::::::::::::
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# note: (when saving text file make sure encoding is "UTF-8")

lyrics <- readLines(file.choose(), encoding = 'UTF-8')

  # I think the Mac default is UTF-8, Windows default is ANSI
  # if text is in English characters, the Windows "ANSI" encoding is fine, just 
  # change the encoding argument to: encoding = ''

  # you'll get an "incomplete final line" error if there 
  # isn't a blank line at the end of the text file, but it should be fine


# ::: Enter the artist and name of song :::
# this will be used to title plot & figure
artist.song <- 'Unknown - Happy Birthday'
artist.song <- 'Blink 182 - Down'

# ::: Drop empty lines & check lyrics ::::
(lyrics <- lyrics[which(lyrics != '')]) 

# ::: Drop bracketed lines :::
# e.g., [Verse 1] or [Chorus]
(lyrics <-  lyrics[which(sapply(lyrics, function(x){
  substr(x, 1, 1) == '[' & substr(x, nchar(x), nchar(x)) == ']'
  }) != T)])

# ::: Trim white space before and after each line :::
(lyrics <- trimws(lyrics))

# ::: Split lines into separate words :::
(lyrics <- strsplit(lyrics, split = ' ')) 

# ::: Put all words into single vector :::
lyrics <- do.call(c, lyrics) 

# ::: Remove punctuation :::
lyrics <- sapply(lyrics, function(x){gsub("[[:punct:]]", '', x = x)})
lyrics

# ::: Make all words lower case :::
lyrics <- tolower(lyrics)    

# ::: Name each element after its word :::
names(lyrics) <- lyrics      

# ::: Drop any empty lyrics :::
lyrics <- lyrics[which(sapply(lyrics, function(x){any(strsplit(x, '')[[1]] %in% letters)}))]

# ::: Aside: Making own patterns :::
# artist.song <- 'test'
# seq.end <- sapply(1:10, function(x){sum(1:x)})
# seq.letter <- sapply(seq.end, function(x){1:x})
# seq.letter <- seq.letter[which(sapply(seq.letter, max) < 27)]
# lyrics <- unlist(sapply(seq.letter, function(x){letters[x]}))

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ::: Create similarity matrix and plot :::::::::::::::::::::::::::
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# ::: create the similarity matrix 
# "TRUE" if ith word == jth word, else "FALSE"
sim.mat <- self.sim.mat(lyrics)

# adjust artist.song for naming the figure.png
artist.song.alt <- paste(strsplit(tolower(artist.song), ' ')[[1]], collapse = '_')

# create the figure title
fig.title <- paste0(artist.song.alt, '_self-sim_plot.png')

# ::: Plot with phrase.focus = T :::

# open plotting device and initiate save as .png
png(here(fig.title),
    width = 4000, height = 4000, res = 300)

# generate the plot
self.sim.plot(phrase.focus = T)

# turn off plotting device to complete save
dev.off()

# ::: Plot with self.sim.plot.fast :::
# open plotting device and initiate save as .png
# png(here(fig.title),
#     width = 4000, height = 4000, res = 300)

# generate the plot
# self.sim.plot.fast()

# turn off plotting device to complete save
# dev.off()


  # note: may need to adjust 'cex' argument depending on how many words are in the song

# ::: Extra stuff :::

# note: sometimes words of same length have different number of characters?!
# sapply(lyrics[[1]], nchar) # see the first and third word of "Run Boy Run by Woodkid"
# str(lyrics[[1]][3])
# str(lyrics[[1]][1]) # UTF has an extra character here: a "bite order mark"
# seems it's only at the beginning of the file

# testing punctuation removal
# gsub("[[:punct:]]", '', c(',', '(', ')', '?', '.', '-', '*', ':', '"', '"test"', '!'))

