# Script para manipulação de dados em bases relacionais ---#
# parte do curso Projetos de análise de dados em R
# dados originais extraídos de Jeliazkov et al 2020 Sci Data
# (https://doi.org/10.1038/s41597-019-0344-7)
# primeira versão em 2020-02-12
#-----------------------------------------------------------#

# carregando os pacotes necessários
library("tidyr")

#Lendo os dados#

?list.files  # para abrir o help da funçao list files - que pode ser útil para abrir
# os dados de vários arquivos csv

files.path <- list.files(path = "data/cestes",
                         pattern = ".csv",
                         full.names = TRUE)

files.path
# aí criou uma lista com os path dos files que queremos

comm <- read.csv(files.path[1])
coord <- read.csv(files.path[2])
envir <- read.csv(files.path[3])
splist <- read.csv(files.path[4])
traits <- read.csv(files.path[5])

# inspecionando os arquivos
#entendendo o objeto comm (community)

dim(comm)
head(comm)
tail(comm)
# ou seja, tem 97 sites e 56 espécies
summary(comm) # só pra aprender a usar essa função; mas não é util para todos os tipos de tabela!

#entendendo o objeto coord
dim(coord)
head(coord)
summary(coord)

#entendendo o obj envir
dim(envir)
head(envir)
summary(envir)
#8 variaives ambientais para os 97 sites!

#entendendo o obj splist
dim(splist)
head(splist)
summary(splist)
#tem 56 espécies (correto): o nome, o taxon e o taxcode.

#entendendo o obj traits
dim(traits)
head(traits)
summary(traits)
#temos 14 traits para 56 espécies
