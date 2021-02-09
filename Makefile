all:	golang-1.15.gbp ethtool.gbp flashrom.gbp goes-build.deb goes-boot.deb \
	fe1.deb goes-bmc.zip platina-linux-kernel.deb platina-mk1-ttys.deb \
	platina-mk1-release.deb goes.deb

goes-build.deb: golang-1.15.gbp

goes-boot.deb: goes-build.deb

%.deb:	FORCE
	cd $* && git reset --hard && git clean -d -x -f && make bindeb-pkg

%.gbp:	FORCE
	cd $* && git reset --hard && git clean -d -x -f && gbp buildpackage --git-ignore-branch -us -uc

%.zip:	FORCE
	cd $* && git reset --hard && git clean -d -x -f && goes-build -x -z -v platina-mk1-bmc.zip && cp platina-mk1-bmc.zip ..

clean: FORCE
	rm -f *.deb *.zip *.changes *.buildinfo

FORCE:

.PHONY: FORCE


