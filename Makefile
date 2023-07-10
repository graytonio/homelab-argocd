GIT_REPO := https://github.com/graytonio/homelab-argocd.git

APPS := $(shell find apps -maxdepth 1 -mindepth 1 -type d)
APPS := $(APPS:apps/%=%)

ENVS := $(shell find projects -maxdepth 1 -mindepth 1 -type f -name '*.yaml')
ENVS := $(ENVS:projects/%.yaml=%)

$(ENVS): ENV:=$@
$(ENVS): $(APPS)
	@echo "Built $@"

$(APPS):
	flagops generate -r -s apps/$@/overlays/ -d build/apps/$@/overlays/${MAKECMDGOALS}
	@mkdir -p build/apps/$@/base
	cp -r apps/$@/base build/apps/$@/base
	@echo "Built $@"

$(addprefix bootstrap_,$(ENVS)):
	argocd-autopilot repo bootstrap --recover --app "${GIT_REPO}/bootstrap/argo-cd"