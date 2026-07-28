cd /home/josh/nhs/soft/astrology/arjuna

# The image copies a host-built libswisseph_rs_dart.so from the build context, and
# `dart pub get` does not refresh it. Never skip this — see swisseph-rs-native-lib.md.
./scripts/check-quiver-native-lib.sh

docker build -f quiver/Dockerfile -t registry.gitlab.com/ninthhouse/arjuna/quiver:latest -t registry.gitlab.com/ninthhouse/arjuna/quiver:$(git rev-parse --short HEAD) .
docker push registry.gitlab.com/ninthhouse/arjuna/quiver --all-tags
