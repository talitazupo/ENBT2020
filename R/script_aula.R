#script para ler tabelas
#?read.table -- eh o help da função!
# ou help(read.table)
# ao inves de setwd("./data"), nos podemos
# read.table("./data/ex_04_formatado.csv")
# se usar o excel em portugues (que separa numero com , e nao ., use o csv2 para ler a tabela... que ele entende que o separador é ;)

tabela_full <- read.csv(file = "./data/ex_04_formatado.csv", sep = ",", dec = ".", header = T)
dim(tabela_full)

library(dplyr)

setosa <- filter(tabela_full, especie == "setosa")

