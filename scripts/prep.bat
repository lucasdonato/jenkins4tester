REM Arquivo de configuração para o Windows

REM Docker convencional
set DOCKER_IP=localhost

REM Docker ToolBox
REM set DOCKER_IP=192.168.99.100

echo "ZERANDO a Vida do Docker"
powershell docker rm -f $(docker ps -a -q)
powershell docker volume rm $(docker volume ls -q)
powershell docker network rm skynet
powershell docker rmi $(docker images -q)

echo "Criando Rede no Docker"
docker network rm skynet
docker network create --driver bridge skynet

echo "Subindo Bando de Dados"
docker pull postgres
docker pull dpage/pgadmin4

docker run --name pgdb --network=skynet -e "POSTGRES_PASSWORD=qaninja" -p 5432:5432 -v var/lib/postgresql/data -d postgres
timeout 10
docker run --name pgadmin --network=skynet -p 15432:80 -e "PGADMIN_DEFAULT_EMAIL=root@qaninja.io" -e "PGADMIN_DEFAULT_PASSWORD=qaninja" -d dpage/pgadmin4
timeout 10

echo "Criando Base de Dados NFLIX"
powershell gem install pg
ruby database.rb %DOCKER_IP%

echo "Subindo as APIS"
docker pull papitoio/nflix-api-users
docker pull papitoio/nflix-api-movies
docker pull papitoio/nflix-api-gateway
docker run --name nflix-api-users --network=skynet -e "DATABASE=pgdb" -p 3001:3001 -d papitoio/nflix-api-users
docker run --name nflix-api-movies --network=skynet -e "DATABASE=pgdb" -p 3002:3002 -d papitoio/nflix-api-movies
docker run --name nflix-api-gateway --network=skynet -e "API_USERS=http://nflix-api-users:3001" -e "API_MOVIES=http://nflix-api-movies:3002" -p 3000:3000 -d papitoio/nflix-api-gateway
timeout 10

echo "Subindo WebApp"

REM "imagem abaixo atualizada docker convencional"
docker pull papitoio/nflix-web2
docker run --name nflix-web --network=skynet -e "VUE_APP_API=http://nflix-web:3000" -p 8000:8000 -d papitoio/nflix-web2

REM docker toobox..
REM docker run --name nflix-web --network=skynet -e "VUE_APP_API=http://%DOCKER_IP%:3000" -p 8000:8000 -d papitoio/nflix-web2

echo "Criando o usuário de Testes"
powershell gem install httparty
ruby api-user.rb %DOCKER_IP%

REM lembrar de configurar os DNS
REM 127.0.0.1   nflix-web
REM 127.0.0.1   nflix-api-users
REM 127.0.0.1   nflix-api-movies
REM 127.0.0.1   nflix-api-gateway
REM 127.0.0.1   pgdb
REM 127.0.0.1   pgadmin