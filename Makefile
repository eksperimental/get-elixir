.PHONY: test
test: lint unit-test

.PHONY: lint
lint:
	-shellcheck get-elixir.sh
	-checkbashisms get-elixir.sh -f

.PHONY: unit-test
unit-test: test/*

test/%: force
	bash  "$@"
	dash  "$@"
	ash   "$@"
	bash  "$@"
	csh   "$@"
	dash  "$@"
	fish  "$@"
	fizsh "$@"
	ksh   "$@"
	mksh  "$@"
	pdksh "$@"
	sash  "$@"
	tcsh  "$@"
	yash  "$@"
	zsh   "$@"


.PHONY: force
force: ;

