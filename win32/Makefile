.PHONY: all spec crystal doc clean

CRYSTAL := exec cmd //c "bin\\crystal.bat"
O := .build
FLAGS := $(if $(release),--release )$(if $(stats),--stats )$(if $(threads),--threads $(threads) )

all: crystal

spec: all_spec
	$(O)/all_spec

doc:
	$(CRYSTAL) doc docs/main.cr

crystal: $(O)/crystal

all_spec: $(O)/all_spec

$(O)/all_spec: spec/all_spec.cr
	@mkdir -p $(O)
	$(CRYSTAL) build -o $@ spec/all_spec.cr

$(O)/crystal: src/compiler/crystal.cr
	@mkdir -p $(O)
	$(CRYSTAL) build $(FLAGS) -o $@ src/compiler/crystal.cr

clean:
	rm -rf $(O)
	rm -rf ./doc
