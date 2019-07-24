# [Superbid](https://www.superbid.net/)


Superbid é um site leilão online que disponibiliza produtos dos mais diversos
tipos, desde carros e motos à joias, relógios e acessórios. O objetivo da coleta
desses dados é tentar precificar, principalmente, automóveis, sendo que no site
tem-se diversas informações quantitativas, informações textuais e imagens o que
torna um grande parque de diversões para análises estatísticas.

# Sobre os dados

Como os produtos são leiloados diariamente e tendo em vista que nem sempre são
vendidos é necessário um tipo de coleta de dados um pouco mais elaborada. No
caso é preciso coletar todos os itens leiloados no dia, armazenar as **urls** e
somente no outro dia buscar o fechamento desses itens.

# Configurando

Para coletar os dados primeiro vamos configurar a pasta onde será salvo os html
e os principais links para acesso as categorias disponiveis no site.

`$ Rscript superbid.R config`

Vai ser criado então uma pasta em `~/databases/superbid` e algumas sub pastas,
também vai ser adicionado um arquivo **.RData** contendo as urls de cada
categoria do site para coletas posteriores.

# Coletando itens leiloados

Após configurar é necessário coletar diariamente os produtos leiloados, para
isso basta executar o seguinte comando:

`$ Rscript superbid.R order`

que vai armazenar na pasta `~/databases/superbid/order` os itens que estão sendo
leiloados no dia de hoje. Essa parte pode ser executada todo dia no período da
manhã, sendo que o encerramento sempre se da no período da tarde.

# Coletando fechamentos

Para coletar os produtos basta executar o seguinte comando: 

`$ Rscript superbid.R coleta`

que vai coletar as "order" do dia anterior, ou seja, os produtos leiolados no
dia de hoje, seu fechamento, será coletado somente amanhã, no dia posterior ao
leilão. Isto é para garantir o fechamento, sendo que cada item após a venda fica
disponíveis no site por alguns dias. Os produtos são então armazenados no
formato .html na pasta `~/databases/superbid/data/yyyy-mm-dd`.


# Raspagem dos fechamentos

TODO



# Fluxo de aquisição

Para agendar os scripts com o crontab pode-se utilizar o seguinte código.

```{r}
library(cronR)

f <- "superbid.R"

cmd <- cron_rscript(f, rscript_args = "order")
cron_add(cmd, at = "8:00", id = "superbid_order")

cmd <- cron_rscript(f, rscript_args = "coleta")
cron_add(cmd, at = "8:15", id = "superbid_coleta")
```
