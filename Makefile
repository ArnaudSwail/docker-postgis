
# TimescaleDB
NAME=timescaledb
ORG=timescale
PG_VER=pg11
PG_VER_NUMBER=$(shell echo $(PG_VER) | cut -c3-)
VERSION=$(shell awk '/^ENV TIMESCALEDB_VERSION/ {print $$3}' Dockerfile)
# mdillon
VERSIONS = $(foreach df,$(wildcard */Dockerfile),$(df:%/Dockerfile=%))

# TimescaleDB
default: image

# mdillon
all: build
build: $(VERSIONS)

# TimescaleDB
.build_$(VERSION)_$(PG_VER)_oss: Dockerfile
	docker build --build-arg PREV_EXTRA="-oss" --build-arg OSS_ONLY=" -DAPACHE_ONLY=1" --build-arg PG_VERSION=$(PG_VER_NUMBER) -t $(ORG)/$(NAME):latest-$(PG_VER)-oss .
	docker tag $(ORG)/$(NAME):latest-$(PG_VER)-oss $(ORG)/$(NAME):$(VERSION)-$(PG_VER)-oss
	touch .build_$(VERSION)_$(PG_VER)_oss

.build_$(VERSION)_$(PG_VER): Dockerfile
	docker build --build-arg PG_VERSION=$(PG_VER_NUMBER) -t $(ORG)/$(NAME):latest-$(PG_VER) .
	docker tag $(ORG)/$(NAME):latest-$(PG_VER) $(ORG)/$(NAME):$(VERSION)-$(PG_VER)
	touch .build_$(VERSION)_$(PG_VER)

define postgis-version
$1:
	docker build -t mdillon/postgis:$(shell echo $1 | sed -e 's/-.*//g') $1
	docker build -t mdillon/postgis:$(shell echo $1 | sed -e 's/-.*//g')-alpine $1/alpine
endef
$(foreach version,$(VERSIONS),$(eval $(call postgis-version,$(version))))

update:
	docker run --rm -v $$(pwd):/work -w /work buildpack-deps ./update.sh

.PHONY: all build update $(VERSIONS)

# TimescaleDB


# image: .build_$(VERSION)_$(PG_VER)
# oss: .build_$(VERSION)_$(PG_VER)_oss
# push: image
# 	docker push $(ORG)/$(NAME):$(VERSION)-$(PG_VER)
# 	docker push $(ORG)/$(NAME):latest-$(PG_VER)
# push-oss: oss
# 	docker push $(ORG)/$(NAME):$(VERSION)-$(PG_VER)-oss
# 	docker push $(ORG)/$(NAME):latest-$(PG_VER)-oss
clean:
	rm -f *~ .build_*

.PHONY: default image push push-oss oss clean