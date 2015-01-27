#' Interactive interface to ggplot2
#'
#' Provides a menu selection system (via \code{manipulate}) so that the variables
#' for different aspects of a plot can be selected interactively.  The \code{ggplot2}
#' command for generating the plot currently being displayed is copied to the console,
#' whence it can be copied to a document for later direct, non-interactive use.
#' 
#' @rdname mPlots
#' @aliases mPlots, mScatter, mBar, mWorldMap
#' @param dat Dataframe containing the variables that might be used in the plot.
#' @return Nothing.  Just for side effects.  
#' @export

mScatter <- function(dat) {
  if(!require(manipulate)) error("Must install 'manipulate' package in RStudio.")
  df = substitute(dat)
  nm = varsByType(head(dat))
  # nm$q is the quantitative variables.
  snames <- NAprepend(nm$all)
  cnames <- NAprepend(nm$c)
  mnames <- list("none", linear="linear","smoother")
  manipulate({p<-doScatter(show,df,x=x,y=y,color=color,size=size,
                           facet=facet,logx=logx,logy=logy,model=model)},
             show = button("Show Expression"),
             x = picker(nm$q,initial=nm$q[[1]],label="x axis"),
             y = picker(nm$q,initial=nm$q[[2]],label="y axis"),
             color = picker(snames, initial="none ",label="Color"),
             size = picker(snames, initial="none ",label="Size"),
             facet = picker(cnames, initial="none ", label="Facet"),
             logx = checkbox(label="Log X-axis"),
             logy = checkbox(label="Log Y-axis"),
             model = picker(mnames, initial="none", label="Model")
  )
}
#' @rdname mPlots
#' @export
mBar <- function(dat) {
  if(!require(manipulate)) error("Must install 'manipulate' package in RStudio.")
  df = substitute(dat)
  nm = varsByType(head(dat))
  numberNames <- NAprepend(nm$q)
  factorNames <- NAprepend(nm$c)
  alignNames <- list(dodge="position_dodge",stack="position_stack",
                     proportion="position_fill")
  fillColorNames <- list( default=NA, seq="seq",div="div",qual="qual")
  paletteNames <- list(default=1,two=2,three=3,four=4,five=5,six=6,seven=7,eight=8)
  manipulate({p<-doBar(show,df,x=x,y=y,position=position,
                       fill=fill,ordery=ordery,orderx=orderx,
                       colors=colors,palette=palette,
                       facetx=facetx,
                       sideways=sideways)},
             show = button("Show Expression"),
             x = picker(factorNames,initial=factorNames[[2]],label="x axis"),
             y = picker(numberNames,initial=numberNames[[2]],label="y axis"),
             fill = picker(factorNames, initial="none ",label="Bar Fill"),
             position = picker(alignNames, initial="stack",label="Alignment"),
             ordery=picker(numberNames, initial="none ",label="Fill Order"),
             orderx=picker(numberNames, initial="none ",label="X Order"),
             colors=picker(fillColorNames, initial="default",label="Color Scheme"),
             palette=picker(paletteNames, initial="default",label="Palette"),
             facetx=picker(factorNames,initial="none ",label="Facet Variable"),
             sideways=checkbox(label="Sideways Labels")
  )
}

#' @param countryVar name of variable with the country names --- default "Country"
#' @rdname mPlots
#' @export
mWorldMap <- function(dat,countryVar="Country"){
  if (!require(manipulate)) error("Must install 'manipulate' package.")
  df = substitute(dat)
  nm = varsByType(head(dat))
  numberNames <- NAprepend(nm$q)
  factorNames <- NAprepend(nm$c)
  regions <- list(World="world", Eurasia="eurasia", Africa="africa",
                  `Latin America`="latin america",`North America`="north america", Oceania="oceania", Asia="asia")
  if( !require(rworldmap)) error("Must install 'rworldmap' package.")
  manipulate(doMap(show=show,dname=df,countryVarName=countryVar,
                   plotVarName=plotVarName,
                   categoryName=categoryName,
                   region=region,
                   bubbles=bubbles),
    show = button("Show Expression"),
    plotVarName=picker(numberNames,initial="none ",label="Quantitative"),
    categoryName=picker(factorNames,initial="none ",label="Category"),
    region=picker(regions, initial="World",label="Region to Show"),
    bubbles =checkbox(label="Bubbles (color=cat, size=quant)")
    )
}

# Utilities
# Pull out the names of the quantitative and categorical variables in a data frame
varsByType = function(dat) {
  # Utility function for converting a vector of names into a list.
  v2list <- function(nms) {
    res = list()
    res[nms] <- nms
    return(res)
  }
  nm = names(dat)
  type = nm
  for (k in 1:length(dat)) type[k] <- class(dat[[k]])
  numberNames <- v2list(nm[type %in% c("integer","numeric")])
  factorNames <- v2list(nm[type %in% c("factor","character","logical","ordered")])
  return( list( c=factorNames, q=numberNames, all=v2list(nm) ) )
}
# Prepend a list with NA for optional items
NAprepend <- function(L) {
  c(list(`none `=NA),L)
}

#
# Converting a vector of names into a list.
v2list <- function(nms) {
  res = list()
  res[nms] <- nms
  return(res)
}


doScatter <- function(show=FALSE,dname,x=NA,y=NA,color=NA,size=NA,facet=NA,logx=FALSE,logy=FALSE,model=""){
  vals <- list(dat=dname,x=x,y=y,color=color,size=size,facet=facet,logx=logx,logy=logy,model=model)
  s <- scatterString(vals)
  if (show) cat(paste(s,"\n"))
  p <- eval(parse(text=s))
  print(p)
  return(p)
}

# Scatter plots
scatterString <- function(s){
#  res <- paste("ggplot(data=",s$dat,")",sep="")
#    res<-paste(res,"+geom_point(aes(x=",s$x,",y=",s$y,"))",sep="")
  res <- paste("ggplot(data=",s$dat,",aes(x=",s$x,",y=",s$y,"))",sep="")
  res <- paste(res,"+geom_point()",sep="")
  if (!is.null(s$color) && !is.na(s$color))
    res<-paste(res, "+aes(colour=",s$color,")",sep="")
  if (!is.null(s$size) && !is.na(s$size))
    res<-paste(res,"+aes(size=",s$size,")",sep="")
  if (s$logx)
    res <- paste(res,"+scale_x_log10()",sep="")
  if (s$logy)
    res <- paste(res,"+scale_y_log10()",sep="")
  if (!is.null(s$facet) && !is.na(s$facet)) # why do I need both?
    res<-paste(res,"+facet_wrap(~",s$facet,",ncol=4)",sep="")
  if (s$model=="linear")
    res <- paste(res, "+ stat_smooth(method=lm)")
  if (s$model=="smoother")
    res <- paste(res, "+ stat_smooth(method=loess)") 
 
  return(res)
}

# Bar Plots
barString <- function(s){
  xStr <- s$x
  if( !is.na(s$orderx))
    xStr <- paste("reorder(",s$x,",",s$orderx,")",sep="")
  fillStr <- if( is.null(s$fill) || is.na(s$fill) ) ")" else paste(",fill=",s$fill,")",sep="")
  orderStr <- if( is.null(s$ordery) || is.na(s$ordery) | is.null(s$fill) || is.na(s$fill) ) " " else 
    paste(",order=reorder(",s$fill,",",s$ordery,")",sep="")
  aesStr <- paste("aes(x=",xStr,",y=",s$y, orderStr,fillStr,sep="")
  res <- paste("ggplot(data=",s$dat,",",aesStr,")",sep="")
  res<-paste(res,"+geom_bar(stat='identity',position=",s$position,"(width=.9))", sep="")
  if( !is.null(s$colors) && !is.na(s$colors)) 
    res <- paste(res,"+scale_fill_brewer(type='",s$colors,"',palette=",s$palette,")",sep="")
  if (s$sideways) 
    res <- paste(res, "+ theme(axis.text.x=element_text(angle=60,hjust=1))")
  if (!is.null(s$facet) && !is.na(s$facetx)) 
    res <- paste(res, "+ facet_wrap(~",s$facetx,",ncol=3)",sep="")
  return(res)
}

doBar <- function(show=FALSE,dname,...){
  vals <- list(dat=dname,...)
  s <- barString(vals)
  if (show) cat(paste(s,"\n"))
  p <- eval(parse(text=s))
  print(p)
  return(p)
}

doMap <- function(show=FALSE,dname,...){
  vals <- list(dat=dname,...)
  s <- mapString(vals)
  if (show) cat(paste(s,"\n"))
  p <- eval(parse(text=s))
}


mapString <- function(s){
  res <- paste("{.s. <- joinCountryData2Map(",s$dat,
       ", joinCode='NAME',nameJoinColumn='",s$countryVarName,"' ); ",sep="")
  res <- paste(res, "par(mai=c(0,0,0.2,0), xaxs='i',yaxs='i') ;",sep="")
  if (!is.na(s$categoryName)) { # plot categories or bubbles
    if (s$bubbles){
      res <-paste(res, ".mp. <- mapBubbles(.s., nameZColour='", 
                  s$categoryName,"'", 
                  ifelse( is.null(s$plotVarName),"",
                          paste(",nameZSize='",s$plotVarName,"'",sep="") ),
                  ",mapRegion='",s$region,"')",sep="")
    }
    else { # categories
      res <- paste(res, ".mp. <- mapCountryData(.s., nameColumnToPlot='",
                     s$categoryName,"',catMethod='categorical',mapRegion='",s$region,"')",sep="")
    }
  }
  else {
    if (!is.na(s$plotVarName)) { # color countries on a continuous scale
      res <- paste(res, ".mp. <- mapCountryData(.s., nameColumnToPlot='",
                   s$plotVarName,"', addLegend=FALSE,mapRegion='",s$region,"'); ", sep="")
      res <- paste(res, 
               "do.call(addMapLegend, c(.mp., legendWidth=.5,legendMar=2))",
               sep="")
    }
    else { # no variables specified
      res <- paste(res, "mapCountryData(mapTitle='Choose Variables');")
    }
  }
  return(paste(res,"}",sep=""))
}