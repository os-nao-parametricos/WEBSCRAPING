# [G1 GLOBO](https://g1.globo.com/)

O G1 é um site de noticias que publica diariamente varias matérias relacionados
a politica, economia, mundo, futebol etc... O objetivo do programa é então
coletar essas notícias e armazena-las. Atráves das notícias coletadas pode-se
fazer diversas análises como por exemplo uma análise de tópicos para ver ao
longo do tempo quais foram os temais mais comentados, se houver notícias
coletadas de outras sites pode-se comparar e ver quais são os assuntos quentes
do mundo e muitos outros tipos de mineração de texto.

# Coleta das notícias

Para coletar todas as notícias disponíveis no G1 primeiro você deve configurar a
pasta onde será armazenado as notícias, no caso, `~/databases/g1globo`

`$ Rscript g1globo.R config`

Depois você pode baixar todas as notícias disponíveis até então que serão salvas
em `~/databases/g1globo/data.RData`.

`$ Rscript g1globo.R tudo`

Para coletar somente as notícias mais recentes execute o seguinte comando no
terminal:

`$ Rscript g1globo.R coleta`

que vai salva-las em `~/databases/g1globo/Sys.Date()-1.RData`. Este último
código pode-se ser agendado para ser executado diáriamente com o programa 
`crontab.R` a partir do seguinte comando:

`$ Rscript crontab.R g1globo`

por *padrão* é agendado todos os dias as 8:15 da manhã.

# Banco de dados

TODO
