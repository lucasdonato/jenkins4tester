#arquivo de configuração para o ambiente linux

# Docker ToolBox
#DOCKER_IP=192.168.99.100

# Docker normal
DOCKER_IP=127.0.0.1

echo "ZERANDO a Vida do Docker"
docker rm -f $(docker ps -a -q)
docker volume rm $(docker volume ls -q)
docker network rm skynet

echo "Criando Rede no Docker"
docker network create --driver bridge skynet

echo "Subindo Bando de Dados"
docker pull postgres
docker pull dpage/pgadmin4

docker run --name pgdb --network=skynet -e "POSTGRES_PASSWORD=qaninja" -p 5432:5432 -v var/lib/postgresql/data -d postgres
sleep 60
docker run --name pgadmin --network=skynet -p 15432:80 -e "PGADMIN_DEFAULT_EMAIL=root@qaninja.io" -e "PGADMIN_DEFAULT_PASSWORD=qaninja" -d dpage/pgadmin4
sleep 10

echo "Criando Base de Dados NFLIX"
bash gem install pg
bash ruby database.rb $DOCKER_IP

echo "Subindo as APIS"
docker pull papitoio/nflix-api-users
docker pull papitoio/nflix-api-movies
docker pull papitoio/nflix-api-gateway
docker run --name nflix-api-users --network=skynet -e "DATABASE=pgdb" -p 3001:3001 -d papitoio/nflix-api-users
docker run --name nflix-api-movies --network=skynet -e "DATABASE=pgdb" -p 3002:3002 -d papitoio/nflix-api-movies
docker run --name nflix-api-gateway --network=skynet -e "API_USERS=http://nflix-api-users:3001" -e "API_MOVIES=http://nflix-api-movies:3002" -p 3000:3000 -d papitoio/nflix-api-gateway
sleep 10

echo "Subindo WebApp"
docker pull papitoio/nflix-web
docker run --name nflix-web --network=skynet -e "VUE_APP_API=http://$DOCKER_IP:3000" -p 8000:8080 -d papitoio/nflix-web

echo "Criando o usuário de Testes"
bash gem install httparty
bash ruby api-user.rb $DOCKER_IP