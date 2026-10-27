.PHONY: setup up down seed test test-challenge logs reset

up:
	docker compose up --build -d --wait

setup: up
	docker compose exec backend ruby bin/rails db:seed
	docker compose exec -e RAILS_ENV=test backend ruby bin/rails db:prepare

down:
	docker compose down

seed:
	docker compose exec backend ruby bin/rails db:seed

test:
	docker compose exec -e RAILS_ENV=test backend ruby bin/rails db:prepare
	docker compose exec -e RAILS_ENV=test backend bundle exec rspec spec/models spec/requests spec/services spec/jobs
	docker compose exec frontend npm test

test-challenge:
	docker compose exec -e RAILS_ENV=test backend ruby bin/rails db:prepare
	docker compose exec -e RAILS_ENV=test backend bundle exec rspec spec/challenges
	docker compose exec frontend npm run test:challenge

logs:
	docker compose logs -f --tail=200

reset:
	docker compose down -v
	docker compose up --build -d --wait
	docker compose exec backend ruby bin/rails db:seed
	docker compose exec -e RAILS_ENV=test backend ruby bin/rails db:prepare
