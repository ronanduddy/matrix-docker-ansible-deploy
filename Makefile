.PHONY: shell check setup start stop provision install run

shell:
	docker run -it --rm \
		-w /work \
		-v `pwd`:/work \
		-v ~/.ssh/id_rsa_do:/root/.ssh/id_rsa:ro \
		--entrypoint=/bin/sh \
		devture/ansible:2.9.9-r0

check:
	docker run -it --rm \
		-w /work \
		-v `pwd`:/work \
		-v ~/.ssh/id_rsa_do:/root/.ssh/id_rsa:ro \
		devture/ansible:2.9.9-r0 \
		ansible-playbook -i inventory/hosts setup.yml --tags=self-check

setup:
	docker run -it --rm \
		-w /work \
		-v `pwd`:/work \
		-v ~/.ssh/id_rsa_do:/root/.ssh/id_rsa:ro \
		devture/ansible:2.9.9-r0 \
		ansible-playbook -i inventory/hosts setup.yml --tags=setup-all

start:
	docker run -it --rm \
		-w /work \
		-v `pwd`:/work \
		-v ~/.ssh/id_rsa_do:/root/.ssh/id_rsa:ro \
		devture/ansible:2.9.9-r0 \
		ansible-playbook -i inventory/hosts setup.yml --tags=start

stop:
	docker run -it --rm \
		-w /work \
		-v `pwd`:/work \
		-v ~/.ssh/id_rsa_do:/root/.ssh/id_rsa:ro \
		devture/ansible:2.9.9-r0 \
		ansible-playbook -i inventory/hosts setup.yml --tags=stop

provision:
	./inventory/scripts/digitalocean/provision.sh

install: provision setup start check

run: provision check
