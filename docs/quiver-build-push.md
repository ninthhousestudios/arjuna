cd /home/josh/nhs/soft/astrology/arjuna

docker build -f quiver/Dockerfile -t registry.gitlab.com/ninthhouse/arjuna/quiver:latest -t registry.gitlab.com/ninthhouse/arjuna/quiver:$(git rev-parse --short HEAD) .
docker push registry.gitlab.com/ninthhouse/arjuna/quiver --all-tags
