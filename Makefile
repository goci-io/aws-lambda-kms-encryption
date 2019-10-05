export NAMESPACE ?= goci
export STAGE ?= staging

encrypt:
	$(MAKE) ACTION=encrypt generic

decrypt:
	$(MAKE) ACTION=decrypt generic

generic:
	read -p "Enter secret value: " secret
	aws lambda invoke \
    	--function-name $(NAMESPACE)-$(STAGE)-encryption-$(ACTION) \
    	--payload '{ "value": "'"${secret}"'" }' \
    	--invocation-type RequestResponse \
    	result.txt
	cat result.txt | grep "result" | awk -F'"' '{print $4}'
	rm result.txt
