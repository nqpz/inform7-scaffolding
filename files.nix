pkgs:
{
  makefileInclude = pkgs.writeTextFile {
    name = "include.mk";
    text = ''
bin/test.ulx: scaffolding bin story.ni
	inform7-compile bin/test.ulx -debug

bin/release.ulx: scaffolding bin story.ni
	inform7-compile bin/release.ulx -release

.PHONY: test
test: bin/test.ulx
	glulxe bin/test.ulx

scaffolding:
	inform7-create-scaffolding

bin:
	mkdir -p bin

.PHONY: clean
clean:
	rm -rf scaffolding
	rm -rf bin
'';
  };
}
