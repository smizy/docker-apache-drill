
.PHONY: all
all: runtime

.PHONY: clean
clean:
	docker rmi -f smizy/apache-drill:${TAG} || :

.PHONY: runtime
runtime:
	docker build \
		--build-arg BUILD_DATE=${BUILD_DATE} \
		--build-arg VCS_REF=${VCS_REF} \
		--build-arg VERSION=${VERSION} \
		-t smizy/apache-drill:${TAG} .
	docker images | grep apache-drill

.PHONY: test
test:
	(docker network ls | grep vnet ) || docker network create vnet
	zookeeper=1 drillbit=1 ./make_docker_compose_yml.sh drill > docker-compose.ci.yml.tmp
	docker-compose -f docker-compose.ci.yml.tmp up -d 
	docker-compose ps
	docker run --net vnet --volumes-from drillbit-1 smizy/apache-drill:${TAG}  bash -c 'for i in $$(seq 200); do nc -z drillbit-1.vnet 8047 && echo test starting && break; echo -n .; sleep 1; [ $$i -ge 200 ] && echo timeout && exit 124 ; done'
	
	bats test/test_*.bats

	docker-compose -f docker-compose.ci.yml.tmp stop
