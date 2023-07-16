export GIT_REPO := https://github.com/graytonio/homelab-argocd.git
CURRENT_DATE = $(shell date +%FT%T%Z)

APPS := $(shell find apps -maxdepth 1 -mindepth 1 -type d)
APPS := $(APPS:apps/%=%)

ENVS := $(shell find projects -maxdepth 1 -mindepth 1 -type f -name '*.yaml')
ENVS := $(ENVS:projects/%.yaml=%)

.PHONY: $(ENVS)
$(ENVS): $(APPS)
	@echo "Built $@"

.PHONY: $(APPS)
$(APPS):
	flagops generate -r -s apps/$@/overlays/ -d build/apps/$@/overlays/${MAKECMDGOALS}
	@mkdir -p build/apps/$@
	cp -r apps/$@/base build/apps/$@
	@echo "Built $@"

.PHONY: bootstrap
bootstrap:
	argocd-autopilot repo bootstrap --recover --app "${GIT_REPO}/bootstrap/argo-cd"

.PHONY: set-password
set-password:
	kubectl -n argocd patch secret argocd-secret -p '{"stringData": {"admin.password": "$(shell argocd account bcrypt --password $(PASSWORD))","admin.passwordMtime": "'$(shell date +%FT%T%Z)'"}}'
	kubectl -n argocd rollout restart deployment/argocd-server
	kubectl -n argocd rollout status deployment/argocd-server

.PHONY: dev-cluster-up
dev-cluster-up:
	kind create cluster --name hl-test --config dev-kind-config.yaml

.PHONY: dev-cluster-down
dev-cluster-down:
	kind delete cluster --name hl-test
