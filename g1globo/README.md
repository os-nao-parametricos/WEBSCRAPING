# [G1 GLOBO](https://g1.globo.com/)

O G1 é um site de noticias que publica diariamente varias matérias relacionados
a politica, economia, mundo, futebol etc... O objetivo do programa é então
coletar essas notícias e armazena-las. Atráves das notícias coletadas pode-se
fazer diversas análises como por exemplo uma análise de tópicos para ver ao
longo do tempo quais foram os temais mais comentados, se houver notícias
coletadas de outras sites pode-se comparar e ver quais são os assuntos quentes
do mundo e muitos outros tipos de mineração de texto.

# Coleta das notícias

Para coletar todas as notícias disponíveis no G1 basta executar o seguinte
comando no terminal:

`$ Rscript g1globo.R tudo`

TODO - Precisa otimizar

que vai coletar todas as notícias e armazenar no banco de dados MySQL. Para
configurar o banco de dados click [aqui](https://github.com/osnaoparametricos/WEBSCRAPING).

Para coletar somente as notícias mais recentes execute o seguinte comando no
terminal:

`$ Rscript g1globo.R hoje**

que vai coletar as notícias mais recentes e armazenar no banco de dados MySQL.

***

O fluxo ideial é que se execute o primeiro comando para pegar todas as noticias
disponiveis e em seguinte agende uma coleta diarias das noticias.
