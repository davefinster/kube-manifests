crdbDnsSub:
	HOSTNAME=$$(curl -H Metadata-Flavor:Google http://169.254.169.254/computeMetadata/v1/instance/hostname | cut -d. -f1) && \
	echo $$HOSTNAME && \
	sed "s/\[HOSTNAME\]/$$HOSTNAME/g" ./crdb.yml | sed "s/\[BASEDOMAIN\]/$$BASEDOMAIN/g" > crdb-edited.yml

buildCrdb: crdbDnsSub
	kubectl apply -f crdb-edited.yml

approveCrdb:
	kubectl certificate approve default.node.cockroachdb-0

initCrdb:
	kubectl apply -f crdb-init.yml && \
	sleep 5 && \
	kubectl certificate approve default.client.root

initCrdbClient:
	kubectl apply -f crdb-client.yml

crdbShell:
	kubectl exec -it cockroachdb-client-secure -- ./cockroach sql --certs-dir=/cockroach-certs --host=cockroachdb-public