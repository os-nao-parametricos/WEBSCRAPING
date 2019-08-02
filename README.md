# Coleta dos dados

| Site          | Arg    | Minuto | Hora | Dia | Semana | Mês |
|:-------------:|:------:|:------:|:----:|:---:|:------:|-----|
| superbid      | order  | 0      | 8    | \*  | \*     | \*  |
| superbid      | coleta | 15     | 8    | \*  | \*     | \*  |
| googleflights | coleta | 0      | 9    | \*  | \*     | \*  |
| g1globo       | coleta | 30     | 8    | \*  | \*     | \*  |


# Banco de dados

Todos os programas de coleta de dados armazenam as informações coletadas, por
padrão, em `~/databases/*`, isto porque em alguns casos é mais fácil fazer
apenas o download da página html e depois criar programas de raspagem, e também
para que o proprio usúario possa armazenar os dados da forma que quiser. Contudo
alguns programas também oferece a opção de armazenar a coleta no banco de dados
MySQL. Para isso é necessário instalar e fazer algumas configurações iniciais.

Para usúario Ubuntu, siga as seguintes instruções.

Primeiro instale o MySQL-Server

`$ sudo apt update & sudo apt install mysql-server`

depois configure os seguintes arquivos

**~/.my.cnf**

```
[client]
host=127.0.0.1
user=user
password="password"

[mysql]
user=user
password="password"

[mysqldump]
user=user
password="password"

[mysqldiff]
user=user
password="password"
```

e **/etc/mysql/mysql.cnf**

```
[mysqld]
collation-server = utf8_unicode_ci
init-connect='SET NAMES utf8'
character-set-server = utf8
```

Agora abra o terminal e digite:

`$ mysql`

`mysql> create database webscraping;`

Pronto! Foi instalado o MySQL server e criado um banco de dados chamado
webscraping cujo o qual será utilizado para armazenar os dados dos diferentes
sites.


| Site    | Arg   | Minuto | Hora | Dia | Semana | Mês |
|:-------:|:-----:|:------:|:----:|:---:|:------:|-----|
| g1globo | mysql | 0      | 12   | \*  | \*     | \*  |
