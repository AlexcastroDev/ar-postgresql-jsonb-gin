FROM ruby:3.3.1

WORKDIR /app

COPY . .

RUN bundle install

RUN chmod +x /app/seed.sh

ENTRYPOINT ["sh", "/app/seed.sh"]
