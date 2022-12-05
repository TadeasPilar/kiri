build:
	docker rm KiRI || true
	docker build -t kiri .
	docker run --name "KiRI" -it -e DISPLAY=$$DISPLAY kiri || true
	docker cp KiRI:project/kiri/. ./outputs/kiri || true
	docker system prune -f
	

