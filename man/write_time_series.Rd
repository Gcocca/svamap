% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/write_time_series.R
\name{write_time_series}
\alias{write_time_series}
\title{write_time_series

This function reads in data from SVA's database and produce 
an xts object}
\usage{
write_time_series(df, date_in, target, name)
}
\arguments{
\item{date_in}{dataset field with dates}

\item{target}{numeric column(s) to be included in the xts object}

\item{name}{name to assign to the target column(s) in the xts object}

\item{path}{Path to file}

\item{encoding}{Ecoding of the text file}
}
\value{
A data.frame object
}
\description{
Generate a time series (xts) object
}
\author{
Giampaolo Cocca
}

