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

#Exploring
#Temos dados de quantas espécies?
nrow(splist)

#quantas áreas amostradas
nrow(comm)
nrow(envir)

#quantas variáveis ambientais?
# todas as variáveis exceto a primeira coluna com o id
names(envir)[-1]
# contando quantas variáveis
length(names(envir)[-1])

#Qual a riqueza de cada área? Primeiro, precisamos transformar a nossa matriz que possui dados de abundância em uma matriz de presença e ausência.

comm.pa <- comm[, -1] > 0

row.names(comm.pa) <- envir$Sites #ta adicionando nome as linhas que é igual a coluna sites do obj envir
dim(comm.pa)
#No R, os valores de TRUE e FALSE contam como 1 e 0.

#vamos calcular a riqueza da área 1, por exemplo, somando a primeira linha do novo objeto comm.pa.
sum(comm.pa[1, ])

#Como podemos fazer a soma de forma automatizada para as 97 áreas? Podemos usar a função apply.
#Essa função aplica uma função às linhas ou colunas de um objeto (do tipo data.frame ou matrix).
?apply
rich <- apply(X = comm.pa, MARGIN = 1, FUN = sum)
summary(rich) #conseguimos ver qtas sp na area com maior e qts sp na area com menor riqueza
# riqueza media é 6.3

#Vamos usar a função merge() do pacote base para adicionar a coluna de coordenadas ao objeto contendo as variáveis ambientais. Esta função irá combinar duas planilhas por meio de um identificador comum, que é a chave primária. No caso do objeto envir a chave primária é a coluna Sites que contém a numeração das localidades amostradas. Podemos chamar essa coluna usando o operador $.

#sao 97 sites
envir$Sites

#mas se fizermos
summary(envir$Sites)
#No R, a coluna Sites que representa uma variável categórica com o id de cada área está sendo entendida como uma variável numérica. entao, vamos converter essa coluna para um fator

# se checarmos a classe desse vetor, veremos que é numerica
class(envir$Sites)
# queremos que seja uma variável categórica. Para isso, convertemos em fator
as.factor(envir$Sites)
# se usarmos apenas as.factor, não fazemos a conversão, vamos então fazer uma atribuição
envir$Sites <- as.factor(envir$Sites)

#Vamos fazer o mesmo para a variável Sites do objeto coord.
coord$Sites <- as.factor(coord$Sites)

#agora, juntando coord e envir com a funçao merge
envir.coord <- merge(x = envir,
                     y = coord,
                     by = "Sites")

#checking se deu certo
dim(envir)
dim(coord)
dim(envir.coord)
head(envir.coord)

#Agora, queremos transformar a nossa matriz de espécie vs. área em uma planilha que contenha cada observação em uma linha e cada variável em uma coluna. Cada observação é a abundância de uma espécie em uma determinada área. Para fazer essa transformação iremos usar a função gather() do pacote tidyr. Como temos 97 sites e 56 espécies, terminaremos com um objeto com 5432 linhas (97 x 56).

# vetor contendo todos os Sites
Sites <- envir$Sites
length(Sites)

# vetor número de espécies
n.sp <- nrow(splist)
n.sp

# criando tabela com cada especie em cada area especies em linhas
comm.df <- gather(comm[, -1])
dim(comm.df)
head(comm.df)

#Queremos alterar o nome das colunas de comm.df. Para isso, usaremos a função colnames().

# nomes atuais
colnames(comm.df)
# modificando os nomes das colunas
colnames(comm.df) <-  c("TaxCode", "Abundance")
# checando os novos nomes
colnames(comm.df)

#Queremos agora adicionar a coluna Sites ao novo objeto. Vamos usar a função rep(). Esta função cria sequências. Vamos criar uma sequência de localidades, em que cada uma das 97 localidades se repete 56 vezes. A sequência deve ter também 5432 elementos.

# primeiro criamos a sequência
seq.site <- rep(Sites, times = n.sp)
?rep
# checando a dimensão
length(seq.site)
# adicionando ao objeto comm.df
comm.df$Sites <- seq.site
# checando como ficou
head(comm.df)
tail(comm.df)

#Para terminar, vamos juntar splist, traits e envir.coord à planilha comm.df.

#Como vimos na aula, as relações entre duas tabelas são sempre feitas par a par. Então, vamos juntar par a par as tabelas usando a função merge().

#Primeiro, vamos adicionar as informações das espécies contidas em splist à comm.df usando a coluna TaxCode.

comm.sp <- merge(comm.df, splist, by = "TaxCode")
head(comm.sp)

#Segundo, adicionamos os dados de atributos das espécies à tabela de comunidade. Na tabela traits, a coluna que identifica as espécies é chamada Sp. Antes de fazer a junção, precisamos mudar o nome para bater com o nome da coluna em comm.sp que é TaxCode.

names(traits)
# renomeando o primeiro elemento
colnames(traits)[1] <- "TaxCode"
comm.traits <- merge(comm.sp, traits, by = "TaxCode")
head(comm.traits)

#Finalmente, juntamos as variáveis ambientais (que aqui já contém as coordenadas) à tabela geral da comunidade por meio da coluna Sites.

comm.total <- merge(comm.traits, envir.coord, by = "Sites")
head(comm.total)


#Por último, finalizamos nossa rotina de manipulação de dados exportando a planilha final modificada. Para isso, usamos a função write.csv().

write.csv(x = comm.total,
          file = "data/01_data_format_combined.csv",
          row.names = FALSE)
