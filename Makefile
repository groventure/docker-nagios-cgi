image := groventure/nagios-cgi:debian-jessie

default: build

build: Dockerfile
	docker build --no-cache --rm -t '$(image)' .
