\name{plotGroups}
\alias{plotGroups}
\alias{plotAllSpectra}
\title{
	Convenient plot for MS2 data, with superimposed Raw- and processed data.
}
\description{
	Convenient plot for MS2 data, with superimposed Raw- and processed data.
}
\usage{
plotGroups(xraw, precursor = NULL, xa, mzrange = NULL, rtrange = NULL,
ms1peaks = NULL, precursorcol = 1)

plotAllSpectra(xa, specperpage=9, prefix="Spec",
                           pspecs=1:length(xa@pspectra),
                           titles="", ...)

}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{xraw}{
%%     ~~Describe \code{xraw} here~~
}
  \item{precursor}{
%%     ~~Describe \code{precursor} here~~
}
  \item{xa}{
%%     ~~Describe \code{xa} here~~
}
  \item{mzrange}{
%%     ~~Describe \code{mzrange} here~~
}
  \item{rtrange}{
%%     ~~Describe \code{rtrange} here~~
}
  \item{ms1peaks}{
%%     ~~Describe \code{ms1peaks} here~~
}
  \item{precursorcol}{
%%     ~~Describe \code{precursorcol} here~~
}

  \item{specperpage}{Plot multiple spectra per page
}
  \item{prefix}{Use prefix for generated graphics
}
  \item{pspecs}{Indix of spectra to be plotted, default: all
}
  \item{titles}{Graphics title(s)
}
  \item{...}{Arguments passed to - idontknow.
}


}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function(xraw, precursor=NULL, xa, mzrange=NULL, rtrange=NULL,
                       ms1peaks=NULL, precursorcol=1) {

  ## Create usable/nonconflicting set of colors
  groupcolors <- rep(grep("dark.*[^123]$", colors(), value=TRUE),
                     length.out=length(xa@pspectra))
##   groupcolors <- rep(c("red", "blue", "cyan", "magenta", "yellow", "aquamarine4",
##                        "darkred", "darkblue", "darkcyan", "darkmagenta", "darkgray",
##                        "aliceblue","aquamarine","brown" ,"chocolate", "purple", "violetred",
##                        "tomato", "turquoise", "darkgoldenrod4", "brown4"),
##                      length.out=length(xa@pspectra))

  grouppeakcolors <- unlist(sapply(1:length(xa@pspectra),
                                   function(x) {
                                     ## omit black
                                     rep(groupcolors[x], each=length(xa@pspectra[[x]]))
                                   }))

  peakcolors <- rep(1, each=nrow(xa@peaks))
  peakcolors[unlist(xa@pspectra)] <- grouppeakcolors

  bbox <- t(sapply (xa@pspectra, function(x) {
    c(rtmin = min(xa@peaks[x,"rtmin"]),
      rtmed = mean(xa@peaks[x,"rt"]),
      rtmax = max(xa@peaks[x,"rtmax"]),
      mzmin = min(xa@peaks[x,"mzmin"]),
      mzmed = mean(xa@peaks[x,"mz"]),
      mzmax = max(xa@peaks[x,"mzmax"])
      )
  }))

  if (is.null(rtrange)) {
    if (is.null(xraw)) {
      rtrange <- range(getPeaklist(xa)[,"rt"])
    } else {
      rtrange <- range(xraw@scantime)
    }
  }

  if (is.null(mzrange) ) {
    if (!is.null(rtrange)) {
      inrange <- which (bbox[,"rtmed"] > rtrange[1] & bbox[,"rtmed"] < rtrange[2])
      mzrange <- c(max(bbox[inrange,"mzmax"]), min(bbox[inrange,"mzmin"]))
    } else {
      if (!is.null(xraw)) {
        mzrange <- xraw@mzrange
      } else {
        mzrange <- range(getPeaklist(xa)[,"mz"])
      }
    }
  }

##  title <- gsub(".mzData","", basename(xraw@filepath))
  title <- gsub(".mzData","", basename(filepaths(xa@xcmsSet)))
  if (!is.null(xraw)) {
      raw <- rawMat(xraw, mzrange, rtrange, NULL, log=TRUE)
      y <- raw[,"intensity"]
      ylim <- range(y)
      y <- y/ylim[2]
      colorlut <- terrain.colors(20)
      col <- colorlut[y*15+4]
      plot(cbind(raw[,"time"], raw[,"mz"]), pch=".", cex=1.8,
           main = title, xlab="Seconds", ylab="m/z", col=col,
           xlim=range(raw[,"time"]), ylim=range(raw[,"mz"]))

##       par(cex=0.5)
##       plotRaw(xraw, log=TRUE,
##               mzrange=mzrange, rtrange=rtrange,
##               title=gsub(basename(xraw@filepath), ".mzData",""))
##       par(cex=1)
  } else {
    plot.new()
    plot.window(xlim=rtrange, ylim=mzrange,
                xlab="Seconds", ylab="m/z")
    axis(1)
    axis(2)
    box()
    title(main=title,
          xlab="Seconds", ylab="m/z")
  }

  if (!is.null(precursor)) {
      bounds <- which(   precursor[1:nrow(precursor)-1,2]
                      != precursor[2:nrow(precursor),2])

      start <- c(1, bounds[1:length(bounds)]+1)
      end <-  c(bounds[1:length(bounds)], nrow(precursor))

##       col <- ifelse(alphaChannelSupported(),
##                     rgb(t(col2rgb(precursorcol)),
##                         alpha=mean(col2rgb(precursorcol)),
##                         max=255),
##                     precursorcol)

      col <- precursorcol

      rect(precursor[start,"rt"], precursor[start,"mz"]-4,
           precursor[end,"rt"], precursor[end,"mz"]+4,
           border=col)
  }

  if (!is.null(ms1peaks)) {
      ## Most peaks are correct:
      ## TODO: weighted distance (e.g. rt+mz*10)

      ms1    <- peaks(ms1peaks)[,c("rt","mz")]

      ms2pre <- precursor
      ms2a   <- xa

      ## Precursor mz / rt
      psprt <- bbox[,"rtmed"]
      pspmz <- ms2pre[findInterval(psprt, ms2pre[,"rt"]),"mz"]

      psppre <- cbind(rt=bbox[,"rtmed"], mz=pspmz)

      ## Closest MS1 peak

      ms1pre <- peaks(ms1peaks)[knn(ms1, psppre, 1:nrow(ms1)),c("rt","mz", "into")]
      points(ms1pre, col=groupcolors,
             cex=log(ms1pre[,"into"])*0.2,
             lwd=log(ms1pre[,"into"])*0.33,
             )
      segments(bbox[,"rtmed"], bbox[,"mzmin"], ms1pre[,"rt"], ms1pre[,"mz"],
               col=groupcolors, lwd=1.5)

  } else {

      segments(bbox[,"rtmed"], bbox[,"mzmin"], bbox[,"rtmed"], bbox[,"mzmax"],
               col=groupcolors, lwd=1.5)
  }

##   text(x=bbox[,"rtmed"],
##        mzrange[1]+(mzrange[2]-mzrange[1])*(0.8 + 0.05*1:length(xa@pspectra)\%\%4),
##        col=groupcolors, labels=1:length(xa@pspectra))

  ## Random order o to avoid biased overdrawing
  o <- order(xa@peaks[,"into"])
  points(xa@peaks[o,c("rt", "mz")],
         cex=log(xa@peaks[o,"into"])*0.2,
         lwd=log(xa@peaks[o,"into"])*0.33,
         pch=4, col=peakcolors[o])
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
