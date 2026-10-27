
FROM nginx:alpine

COPY index.html /usr/share/nginx/html/index.html
COPY image.png /usr/share/nginx/html/image.png

EXPOSE 80
