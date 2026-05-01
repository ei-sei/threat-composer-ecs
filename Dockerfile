# Stage 1: Build

FROM node:22-alpine AS build

WORKDIR /app

COPY ./app/package.json ./app/yarn.lock ./

RUN yarn install

COPY ./app .

RUN yarn build


# Stage 2: Serve

FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
