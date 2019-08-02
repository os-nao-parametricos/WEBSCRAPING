<!-- <img src="img/icon.png" width="150px" align="right" display="block"> -->

[Google Flights](https://www.google.com/flights/)
=====================================

O Google Flights é um serviço de reserva de voos que oferece informações por
quantidade, preço, duração entre outras informações, as passagens áreas de voos
disponiveis por terceiros. Os scripts disponibilizados servem para coletar
preços de passagens diariamente. O objetivo da coleta, inicialmente, é
visualizar a precificação das passagens ao longo do tempo fixando um intervalo
de tempo no futuro para a compra.

# Configurações iniciais

Para começar a coletar os dados primeiro execute o seguinte comando

`$ Rscript google_flights config`

que vai criar uma pasta em `~/databases/google_flights` e um arquivo chamado de
**url.csv**. Este arquivo .csv tem seis colunas que você deverá preencha-las com
as informações que quer coletar.

* **id**: Número inteiro
* **de**: Local de partida
* **para**: Local de chegada
* **di**: Data inicial
* **df**: Data final
* **url**: URL

Essas informações são obtidas no próprio site. Basta você selecionar a opção
somente voo, depois preencher o local de partida, o destino final e o dia da
data de partida, click em pesquisar e isso vai gerar uma url com as informações
que você preencheu. Após isso preencha o arquivo .csv com essas informações da
forma como se segue:


| id | de        | para  | di         | df         | url |
|:--:|:---------:|:-----:|:----------:|:----------:|:---:|
| 1  | São Paulo | Natal | 2019-10-05 | 2019-10-15 |  https://www.google.com/flights/#flt=GRU.NAT.2019-07-24;c:BRL;e:1;sd:1;t:f;tt:o   |


neste exemplo vamos coletar diariamente o preço das passagens de **São Paulo** à
**Natal** com data de partida entre 05/10/2019 e 15/10/2019. Caso queira
verificar a variação de preço para outro destino basta adicionar mais uma linha
da forma como segue:

| id | de        | para     | di         | df         | url                                                                                    |
|:--:|:---------:|:--------:|:----------:|:----------:|:--------------------------------------------------------------------------------------:|
| 1  | São Paulo | Natal    | 2019-10-05 | 2019-10-15 | https://www.google.com/flights/#flt=GRU.NAT.2019-07-24;c:BRL;e:1;sd:1;t:f;tt:o         |
| 2  | Curitiba  | Montreal | 2019-12-15 | 2020-01-15 | https://www.google.com.br/flights/#flt=CWB./m/052p7.2020-01-01;c:BRL;e:1;sd:1;t:f;tt:o |

adicionamos então Curitiba - Brasil à Montreal - Canadá, ou seja, estamos
coletando diariamente o preço das passagens de **Curitiba** à **Montreal** com
data de partida entre 15/12/2019 e 15/01/2020.


# Coletando os dados

Após configurar as compras das passagens baste executar o seguinte comando:

`$ Rscript google_flights.R coleta`

que vai coletar os dados e armazenar em `~/databases/google_flights/yyyy_mm_dd`.

***

Para agendar diariamente você pode utilizar o pacote `cronR` e executar o
seguinte código:

```{r}
library(cronR)
cmd <- cron_rscript("google_flights.R", rscript_args = "coleta")
cron_add(cmd, at = "9:00", id = "googleflights")
```

que vai coletar os dados todos os dias as 9 horas da manhã.

# Raspagem dos dados

##### TODO
