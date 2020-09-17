# docker build -f Dockerfile.dev .
# v stands for volume
# docker  run -it <image id> -p 3000:3000 -v $(pwd):/app -v /app/node_module