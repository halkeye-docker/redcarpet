build:
	docker build -t halkeye/redcarpet .

run:
	docker run -it --rm -p 3000:3000 -v /storage/homes/halkeye/Photos:/photos:ro --name redcarpet halkeye/redcarpet
